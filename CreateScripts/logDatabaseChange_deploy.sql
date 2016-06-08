SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select 1 from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'logDatabaseChangeInsert' and ROUTINE_TYPE = 'PROCEDURE')
    drop procedure [dbo].[logDatabaseChangeInsert]
GO

CREATE PROCEDURE [dbo].[logDatabaseChangeInsert]  
(  
 @Guid uniqueidentifier,  
 @Version int = 0,  
 @App varchar(50),  
 @File varchar(500),  
 @Desc varchar(max) = null  
)  
AS  
  
SET NOCOUNT ON  
  
 insert into logDatabaseChange  
 (ChangeLogGuid, ApplicationName, FilePath, FileVersion, Description)  
 values(@Guid, @App, @File, @Version, @Desc)  
  
SET NOCOUNT off
go

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON [dbo].[logDatabaseChangeInsert] TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select 1 from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'logIsNewVersionOfDatabaseChange' and ROUTINE_TYPE = 'FUNCTION')
    drop function [dbo].[logIsNewVersionOfDatabaseChange]
GO

  
CREATE FUNCTION [dbo].[logIsNewVersionOfDatabaseChange]  
(  
 @Guid uniqueidentifier,  
 @Version int = 0  
)  
RETURNS bit  
AS  
BEGIN  
 declare @IsNewDatabaseChange bit  
  
 If Exists(select 1 from logDatabaseChange where ChangeLogGuid = @Guid and FileVersion >= @Version) Begin  
  set @IsNewDatabaseChange = 0  
 End  
 Else Begin  
  set @IsNewDatabaseChange = 1  
 End  
  
 return @IsNewDatabaseChange  
end
go


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'logDatabaseChange')
    DROP TABLE logDatabaseChange

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'logDatabaseChange')
BEGIN
    CREATE TABLE logDatabaseChange
    (
        ChangeLogGuid uniqueidentifier  not null,
        ApplicationName varchar(50) not null,
        FilePath varchar(500) not null,
        FileVersion int not null,
        [Description] varchar(max) null,
        CreatedDate datetime default getdate() not null,
        CreatedBy varchar(50) default SYSTEM_USER not null,
        CONSTRAINT PK_logDatabaseChange PRIMARY KEY NONCLUSTERED
        (
            ChangeLogGuid asc,
            FileVersion asc
        ) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
end
go

exec logDatabaseChangeInsert 'F6F5AA6A-EA7C-414A-A14D-9B3D3FEF8D36', 1, 
    'Utility', 
    '\logDatabaseChange_deploy.sql', 
    'Created logDatabaseChange stored procedure, udf, and table';
