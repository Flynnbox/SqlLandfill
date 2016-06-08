--***Use Ctrl-Shift-M to replace parameter placeholders***--
if exists (select 1 from information_schema.views where table_name = N'<viewName, sysname, appTable>')
	drop view <viewName, sysname, appTable>
go

create view <viewName, sysname, appTable>
as
select
	--columnlist
from
	--tablelist
go

--run "select newid()" to generate a guid; copy it and
--press Ctrl-Shift-M to open the "Replace Template Parameter" dialog
declare @ChangeScriptGuid uniqueidentifier,  @Version int;

--do not change this value once set
set @ChangeScriptGuid = '<Change Script Guid, uniqueidentifier, >';

--update this version number every time you alter the change script
set @Version = 1;

if (dbo.logIsNewVersionOfDatabaseChange(@ChangeScriptGuid, @Version) = 1) begin
	exec logDatabaseChangeInsert @ChangeScriptGuid, @Version, 
		'<Application Name, varchar(50), >', 
		'\Database\IHI\StoredProcedures\<Application Name, varchar(50), >\<viewName, sysname, appTable>.viw', 
		'<Description, varchar(max), >';
end

print 'View: <viewName, sysname, appTable>.viw version ' + cast(@Version as varchar) + ' successfully applied to ' + @@servername + '.' + db_name();
go
