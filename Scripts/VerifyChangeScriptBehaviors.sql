/*
VERIFY KEY BEHAVIORS OF CHANGE SCRIPT LOGIC

SETUP:
1. Run the script to deploy the components of the ChangeScript framework and verify it completes with no errors
2. Execute "select newid()" to generate a guid; copy it
3. Press Ctrl-Shift-M to open the "Replace Template Parameter" dialog
4. Paste the guid into the ChangeLogGuid field
5. Update the other templates values if desired (File Name, Description)

TEST 1: Demonstrate Deploy behavior will occur if this change script has not been deployed previously
ACTION: Edit the @ChangeStatusId to 100 (Deploy); Set the @Version to 1;  Execute the script
VERIFY: Message displayed includes 'Deploy has occurred'; version 1 of change is in logDatabaseChange table with ChangeStatusId of 110 (Deploy Successful)
QUERY:  select * from logDatabaseChange where ChangeLogGuid = '<Change Script Guid, uniqueidentifier, >'

TEST 2: Demonstrate Deploy will not occur if an equal or higher version of this change script was deployed successfully
ACTION: Execute the script again
VERIFY: Message displayed includes 'Change script will not be Deployed as an equal or higher version was successfully Deployed'

TEST 3: Demonstrate Deploy will occur if a lower version of this change script was deployed successfully
ACTION: Increment @Version to 2 and execute the script
VERIFY: Message displayed includes 'Deploy has occurred'; version 2 is in logDatabaseChange table with ChangeStatusId of 110 (Deploy Successful)
QUERY:  select * from logDatabaseChange where ChangeLogGuid = '<Change Script Guid, uniqueidentifier, >'

TEST 4: Demonstrate that Rollback will occur if the same version of the change script has been Deployed successfully
ACTION: Edit @ChangeStatusId to 200 (Rollback) and execute the script
VERIFY: Message displayed includes 'Rollback has occurred'; version 2 is in logDatabaseChange table with ChangeStatusId of 210 (Rollback Successful)
QUERY:  select * from logDatabaseChange where ChangeLogGuid = '<Change Script Guid, uniqueidentifier, >'

TEST 5: Demonstrate that Rollback will not occur if the same version of the change script has been Rolledback successfully
ACTION: Execute the script again
VERIFY: Message displayed includes 'Changed script will not be Rolledback as this version was already successfully Rolledback'
QUERY:  select * from logDatabaseChange where ChangeLogGuid = '<Change Script Guid, uniqueidentifier, >'

TEST 6: Demonstrate Deploy behavior will occur if the same version of this change script has been Rollbacked successfully
ACTION: Edit @ChangeStatusId to 100 (Deploy) and execute the script
VERIFY: Message displayed includes 'Deploy has occurred'; version 2 is in table logDatabaseChange with ChangeStatusId of 110 (Deploy Successful)
QUERY:  select * from logDatabaseChange where ChangeLogGuid = '<Change Script Guid, uniqueidentifier, >'
*/

begin try
  declare @CanDeploy tinyint = 0, @ExecutingContextId int = 0, @Version tinyint = 1, @ChangeStatusId tinyint = 100;
  print @@servername + '.' + db_name() + ' - Starting change script - File: <File Name, varchar(500), VerifyChangeScriptBehaviors>.sql - ChangeLogGuid: <Change Script Guid, uniqueidentifier, > - Version: ' + cast(@Version as varchar);
  exec logDatabaseChangeInsert '<Change Script Guid, uniqueidentifier, >', @Version, @ChangeStatusId, @ExecutingContextId, 
    '<File Name, varchar(500), VerifyChangeScriptBehaviors>.sql', 
	  '<Description, varchar(max), Verify the key behaviors of the change script logic>';
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
print 'Deploy has occurred'
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
print 'Rollback has occurred'
/* END ROLLBACK SCRIPT */

--update entry in Database Change Log for rolled back version
declare @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate '<Change Script Guid, uniqueidentifier, >', @ReadOnlyVersion, 210 --Rollback - Completed
print 'Change script successfully Rolledback'
set noexec off
if object_id('tempdb..#Version') is not null begin drop table #Version end