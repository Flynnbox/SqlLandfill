--Test 1: Run statement to disable Rollback and execute the script - verify that message is 'Execution has occurred' and version 1 is in table logDatabaseChange
--update logDatabaseChangeConfiguration set IsRollbackEnabled = 0
--select * from logDatabaseChange where ChangeLogGuid = 'E3369115-584F-48FD-B02C-739EC3D2F522'

--Test 2: Execute the script again - verify that the message is 'Change script was not run as an equal or higher version was previously applied...'

--Test 3: Increment @Version to 2 and execute the script - verify that message is 'Execution has occurred' and version 2 is in table logDatabaseChange
--select * from logDatabaseChange where ChangeLogGuid = 'E3369115-584F-48FD-B02C-739EC3D2F522'

--Test 4: Run statement to enable Rollback and execute the script - verify that message is 'Rollback has occurred' and version 2 is in table logDatabaseChange with Rollback = 1
--update logDatabaseChangeConfiguration set IsRollbackEnabled = 1
--select * from logDatabaseChange where ChangeLogGuid = 'E3369115-584F-48FD-B02C-739EC3D2F522'

--Test 5: Run statement to disable Rollback and execute the script - verify that message is 'Execution has occurred' and version 2 is in table logDatabaseChange with Rollback = 0
--update logDatabaseChangeConfiguration set IsRollbackEnabled = 0
--select * from logDatabaseChange where ChangeLogGuid = 'E3369115-584F-48FD-B02C-739EC3D2F522'

declare @Version int = 2
update logDatabaseChangeConfiguration set ExecutingScriptVersion = @Version

print 'Starting change script: 2016_12_16_VerifyRollbackBehavior version ' + cast(@Version as varchar);
if (select top 1 IsRollbackEnabled from logDatabaseChangeConfiguration) = 1 begin
  print 'Starting rollback of script changes...'

  /* BEGIN ROLLBACK SCRIPT */
  print 'Rollback has occurred'
  /* END ROLLBACK SCRIPT */

  exec logDatabaseChangeRollback 'E3369115-584F-48FD-B02C-739EC3D2F522', @Version

  print 'Completed rolledback of script changes'
  set noexec on --disable script execution
end
go

declare @Version int = 1
select top 1 @Version = isNull(ExecutingScriptVersion, 1) from logDatabaseChangeConfiguration
if (dbo.logIsNewVersionOfDatabaseChange('E3369115-584F-48FD-B02C-739EC3D2F522', @Version) = 0) begin
	print 'Change script was not run as an equal or higher version was previously applied to ' + @@servername + '.' + db_name();
	print 'If you have made updates to this script, please increment the version number and re-run the script.';
	set noexec on --disable script execution
end
go

/* BEGIN CHANGE SCRIPT */
print 'Execution has occurred'
/* END CHANGE SCRIPT */

declare @Version int = 1
select top 1 @Version = isNull(ExecutingScriptVersion, 1) from logDatabaseChangeConfiguration
exec logDatabaseChangeInsert 'E3369115-584F-48FD-B02C-739EC3D2F522', @Version, 
	'DatabaseChangeLog', 
	'\Database\IHI\ChangeScripts\DatabaseChangeLog\2016_12_16_VerifyRollbackBehavior.sql', 
	'Test whether rollback behavior is functioning correctly';
print 'Change script successfully applied to ' + @@servername + '.' + db_name();
set noexec off
go