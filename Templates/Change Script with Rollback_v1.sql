/*
1. Execute "select newid()" to generate a guid; copy it
2. Press Ctrl-Shift-M to open the "Replace Template Parameter" dialog
3. Update the @ExecutingContextId to match the value for your application or project in the logDatabaseContext table (if it doesn't exist, insert a record)
REMEMBER: Update the @Version number every time you alter a change script you have previously committed to the repository
*/
declare @CanDeploy tinyint = 0, @Version tinyint = 1, @ChangeStatusId tinyint = 100, @ExecutingContextId int = 1;
exec logDatabaseChangeInsert '<Change Script Guid, uniqueidentifier, >', @Version, @ChangeStatusId, @ExecutingContextId, 
	'<File Name, varchar(500), >.sql', 
	'<Description, varchar(max), >';
if object_id('tempdb..#Version') is not null begin drop table #Version; end
create table #Version (currentVersion tinyint not null);
insert #Version values (@Version);
print 'Starting change script: <File Name, varchar(500), > version ' + cast(@Version as varchar);
exec @CanDeploy = dbo.logCanDatabaseChangeBeDeployed '<Change Script Guid, uniqueidentifier, >', @Version
if (@CanDeploy != 0) begin
	set noexec on --disable script execution
end
go

print 'Deploying...'
/* BEGIN CHANGE SCRIPT */
/********************************************************************
											Your deploy code goes here
*********************************************************************/
/* END CHANGE SCRIPT */


declare @ReadOnlyVersion int;
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion, 110 --Deploy - Completed
print 'Change script successfully Deployed on ' + @@servername + '.' + db_name();
set noexec off
go

declare @CanRollback tinyint = 0, @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec @CanRollback = dbo.logCanDatabaseChangeBeRolledBack '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion
if (@CanRollback != 0) begin
  set noexec on --disable script execution
end
go


print 'Rolling back...'
/* BEGIN ROLLBACK SCRIPT */
/********************************************************************
											Your rollback code goes here
*********************************************************************/
/* END ROLLBACK SCRIPT */


--update entry in Database Change Log for rolled back version
declare @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion, 210 --Rollback - Completed
print 'Change script successfully Rolledback on ' + @@servername + '.' + db_name();
set noexec off
drop table #Version