/*
SETUP:
1. Execute "select newid()" to generate a guid; copy it
2. Press Ctrl-Shift-M to open the "Replace Template Parameter" dialog
3. Update the @ExecutingContextId to match the value for your application or project in the logDatabaseContext table (if it doesn't exist, insert a record)
4. Update the other templates values (File Name, ChangeLogGuid, Description)
5. When naming the File use the standard naming scheme of "[YYYYMMDD]_[Two digit sequence number]_[Camel cased label of key change].sql"
TO DEPLOY: Use @ChangeStatusId value of 100
TO ROLLBACK: Use @ChangeStatusId value of 200
REMEMBER: Update the @Version number every time you alter a change script you have previously committed to the repository
*/
begin try
  declare @CanDeploy tinyint = 0, @ExecutingContextId int = 100, @Version tinyint = 1, @ChangeStatusId tinyint = 100;
  print @@servername + '.' + db_name() + ' - Starting change script - File: <File Name, varchar(500), >.sql - ChangeLogGuid: <Change Script Guid, uniqueidentifier, > - Version: ' + cast(@Version as varchar);
  exec logDatabaseChangeInsert '<Change Script Guid, uniqueidentifier, >', @Version, @ChangeStatusId, @ExecutingContextId, 
    '<File Name, varchar(500), >.sql', 
	  '<Description, varchar(max), >';
  if object_id('tempdb..#Version') is not null begin drop table #Version; end
  create table #Version (currentVersion tinyint not null);
  insert #Version values (@Version);
end try
begin catch
  throw;
end catch
go

declare @ReadOnlyVersion int, @CanDeploy tinyint = 0;
if object_id('tempdb..#Version') is not null begin select top 1 @ReadOnlyVersion = currentVersion from #Version end
exec @CanDeploy = dbo.logCanDatabaseChangeBeDeployed '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion
if (@@error > 0 or @CanDeploy != 0) begin
	set noexec on; --disable script execution
end
go

/* BEGIN DEPLOY SCRIPT */
/********************************************************************
											Your deploy code goes here
*********************************************************************/
/* END DEPLOY SCRIPT */

--update entry in Database Change Log for deployed version
declare @ReadOnlyVersion int;
if object_id('tempdb..#Version') is not null begin select top 1 @ReadOnlyVersion = currentVersion from #Version end
exec logDatabaseChangeUpdate '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion, 110 --Deploy - Completed
print 'Change script successfully Deployed'
set noexec off
go

declare @CanRollback tinyint = 0, @ReadOnlyVersion int
if object_id('tempdb..#Version') is not null begin select top 1 @ReadOnlyVersion = currentVersion from #Version end
exec @CanRollback = dbo.logCanDatabaseChangeBeRolledBack '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion
if (@@error > 0 or @CanRollback != 0) begin
  set noexec on --disable script execution
end
go

/* BEGIN ROLLBACK SCRIPT */
/********************************************************************
											Your rollback code goes here
*********************************************************************/
/* END ROLLBACK SCRIPT */

--update entry in Database Change Log for rolled back version
declare @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion, 210 --Rollback - Completed
print 'Change script successfully Rolledback'
set noexec off
if object_id('tempdb..#Version') is not null begin drop table #Version end