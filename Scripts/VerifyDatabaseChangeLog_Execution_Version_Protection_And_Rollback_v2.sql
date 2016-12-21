--Test 1: Run statement to disable Rollback and execute the script
--verify that message is 'Deploy has occurred' and version 1 is in logDatabaseChange table with ChangeStatusId of 110
--select * from logDatabaseChange where ChangeLogGuid = 'E4055FD1-3C52-40B3-A56D-CF6086B32B44'

--Test 2: Execute the script again
--verify that the message is 'Change script will not be Deployed as an equal or higher version was successfully Deployed on...'

--Test 3: Increment @Version to 2 and execute the script
--verify that message is 'Deploy has occurred' and version 2 is in logDatabaseChange table with ChangeStatusId of 110
--select * from logDatabaseChange where ChangeLogGuid = 'E4055FD1-3C52-40B3-A56D-CF6086B32B44'

--Test 4: Edit ChangeStatusId to 200 and execute the script
--verify that message is 'Rollback has occurred' and version 2 is in logDatabaseChange table with ChangeStatusId of 210
--select * from logDatabaseChange where ChangeLogGuid = 'E4055FD1-3C52-40B3-A56D-CF6086B32B44'

--Test 5: Execute the script again
--verify that message is 'Changed script will not be Rolledback as this version was already successfully Rolledback on...'
--select * from logDatabaseChange where ChangeLogGuid = 'E4055FD1-3C52-40B3-A56D-CF6086B32B44'

--Test 6: Edit ChangeStatusId to 100 and execute the script
--verify that message is 'Deploy has occurred' and version 2 is in table logDatabaseChange with ChangeStatusId of 110
--select * from logDatabaseChange where ChangeLogGuid = 'E4055FD1-3C52-40B3-A56D-CF6086B32B44'

declare @CanDeploy tinyint = 0, @Version tinyint = 1, @ChangeStatusId tinyint = 100, @ExecutingContextId int = 0;
print 'Starting change script: VerifyDatabaseChangeLogic version ' + cast(@Version as varchar);
exec logDatabaseChangeInsert 'E4055FD1-3C52-40B3-A56D-CF6086B32B44', @Version, @ChangeStatusId, @ExecutingContextId, 
	'VerifyDatabaseChangeLogic.sql', 
	'Test the logic for managing database changes';
if object_id('tempdb..#Version') is not null begin drop table #Version; end
create table #Version (currentVersion tinyint not null);
insert #Version values (@Version);
exec @CanDeploy = dbo.logCanDatabaseChangeBeDeployed 'E4055FD1-3C52-40B3-A56D-CF6086B32B44', @Version
if (@CanDeploy != 0) begin
	set noexec on --disable script execution
end
go

/* BEGIN CHANGE SCRIPT */
print 'Deploy has occurred'
/* END CHANGE SCRIPT */


declare @ReadOnlyVersion int;
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate 'E4055FD1-3C52-40B3-A56D-CF6086B32B44', @ReadOnlyVersion, 110 --Deploy - Completed
print 'Change script successfully Deployed on ' + @@servername + '.' + db_name();
set noexec off
go

declare @CanRollback tinyint = 0, @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec @CanRollback = dbo.logCanDatabaseChangeBeRolledBack 'E4055FD1-3C52-40B3-A56D-CF6086B32B44', @ReadOnlyVersion
if (@CanRollback != 0) begin
  set noexec on --disable script execution
end
go

/* BEGIN ROLLBACK SCRIPT */
print 'Rollback has occurred'
/* END ROLLBACK SCRIPT */


--update entry in Database Change Log for rolled back version
declare @ReadOnlyVersion int
select top 1 @ReadOnlyVersion = currentVersion from #Version
exec logDatabaseChangeUpdate 'E4055FD1-3C52-40B3-A56D-CF6086B32B44', @ReadOnlyVersion, 210 --Rollback - Completed
print 'Change script successfully Rolledback on ' + @@servername + '.' + db_name();
set noexec off
drop table #Version