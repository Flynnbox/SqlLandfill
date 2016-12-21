set quoted_identifier off;
go

set ansi_nulls off;
go

if exists
(
	select
		1
	from
		Information_Schema.Routines
	where Routine_Name = 'logDatabaseChangeInsert'
				and Routine_Type = 'PROCEDURE'
)
begin
	drop procedure
		dbo.logDatabaseChangeInsert;
end;
go

create procedure dbo.logDatabaseChangeInsert(
	@guid uniqueidentifier,
	@version int = 0,
	@app varchar(50),
	@file varchar(500),
	@desc varchar(max) = null)
as
	set nocount on;
	insert into logDatabaseChange
	(
		ChangeLogGuid,
		ApplicationName,
		FilePath,
		FileVersion,
		[Description]
	)
	values
	(
		@guid, @app, @file, @version, @desc
	);
	set nocount off;
go

grant execute on dbo.logDatabaseChangeInsert to Public;
go

if exists
(
	select
		1
	from
		Information_Schema.Routines
	where Routine_Name = 'logIsNewVersionOfDatabaseChange'
				and Routine_Type = 'FUNCTION'
)
begin
	drop function
		dbo.logIsNewVersionOfDatabaseChange;
end;
go

create function Dbo.logIsNewVersionOfDatabaseChange
(
	@guid uniqueidentifier,
	@version int = 0
)
returns bit
as
	begin
		declare
			@isNewDatabaseChange bit;
		if exists
		(
			select
				1
			from
				logDatabaseChange
			where ChangeLogGuid = @guid
						and FileVersion >= @version
		)
		begin
			set @isNewDatabaseChange = 0;
		end;
		else
		begin
			set @isNewDatabaseChange = 1;
		end;
		return @isNewDatabaseChange;
	end;
go

if exists
(
	select
		1
	from
		Information_Schema.Tables
	where Table_Name = N'logDatabaseChange'
)
begin
	drop table logDatabaseChange;
end;

if not exists
(
	select
		1
	from
		Information_Schema.Tables
	where Table_Name = N'logDatabaseChange'
)
begin
	create table logDatabaseChange
	(
		ChangeLogGuid uniqueidentifier not null,
		ApplicationName varchar(50) not null,
		FilePath varchar(500) not null,
		FileVersion int not null,
		Description varchar(max) null,
		CreatedDate datetime default getdate() not null,
		CreatedBy varchar(50) default system_user not null,
		constraint PK_logDatabaseChange primary key nonclustered(ChangeLogGuid asc, FileVersion asc)
		with(ignore_dup_key = off) on [Primary]
	)
	on [Primary];
end;
go

exec logDatabaseChangeInsert
	'F6F5AA6A-EA7C-414A-A14D-9B3D3FEF8D36',
	1,
	'Utility',
	'\logDatabaseChange_deploy.sql',
	'Created logDatabaseChange stored procedure, udf, and table';

set quoted_identifier off;
go

set ansi_nulls off;
go