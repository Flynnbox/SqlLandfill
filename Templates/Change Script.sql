--run "select newid()" to generate a guid; copy it and
--press Ctrl-Shift-M to open the "Replace Template Parameter" dialog
--update the @Version number every time you alter the change script
declare @Version int = 1

if object_id('tempdb..#Version') is not null begin
	drop table #Version
end
create table #Version (currentVersion tinyint not null)
insert #Version values (@Version)
print 'Starting change script: <File Name, varchar(500), > version ' + cast(@Version as varchar);
if (dbo.logIsNewVersionOfDatabaseChange('<Change Script Guid, uniqueidentifier, >', @Version) = 0) begin
	print 'Change script was not run as an equal or higher version was previously applied to ' + @@servername + '.' + db_name();
	print 'If you have made updates to this script, please increment the version number and re-run the script.';
	set noexec on --disable script execution
end
go

/* BEGIN CHANGE SCRIPT */
/********************************************************************
											Your code goes here
*********************************************************************/
/* END CHANGE SCRIPT */

declare @Version int
select top 1 @Version = currentVersion from #Version
exec logDatabaseChangeInsert '<Change Script Guid, uniqueidentifier, >', @Version, 
	'<Application Name, varchar(50), >', 
	'\Database\IHI\ChangeScripts\<Application Name, varchar(50), >\<File Name, varchar(500), >.sql', 
	'<Description, varchar(max), >';
print 'Change script successfully applied to ' + @@servername + '.' + db_name();
set noexec off
drop table #Version
go