/*
Make sure SQLCMD mode is enabled under the Query menu before executing
*/

:SETVAR isRollbackEnabled 0

if object_id('tempdb..#ChangeScriptConfiguration') is null begin
	create table #ChangeScriptConfiguration (isRollbackEnabled bit not null default 0, CurrentScriptVersion int not null default 1)
  insert #ChangeScriptConfiguration values (0, 1)
end
update #ChangeScriptConfiguration set isRollbackEnabled = isnull($(isRollbackEnabled), 0)
select isRollbackEnabled from #ChangeScriptConfiguration

--drop table #ChangeScriptConfiguration