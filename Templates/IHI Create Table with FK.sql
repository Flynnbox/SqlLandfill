--***Use Ctrl-Shift-M to replace parameter placeholders***--

if exists (select 1 from information_schema.table_constraints where table_name = N'<tableName, sysname, appTable>' and constraint_name = N'<fkName, sysname, FK_appTable_columnName>')
	alter table [dbo].[<tableName, sysname, appTable>] drop constraint [<fkName, sysname, FK_appTable_columnName>]

if exists (select 1 from information_schema.tables where table_name = N'<tableName, sysname, appTable>')
	drop table <tableName, sysname, appTable>

if not exists (select 1 from information_schema.tables where table_name = N'<tableName, sysname, appTable>')
begin
	create table <tableName, sysname, appTable>
	(
		<pkColumnName, sysname, columnGuid> uniqueidentifier not null,
		constraint PK_<tableName, sysname, appTable> primary key nonclustered
		(
			<pkColumnName, sysname, columnGuid>
		) with (ignore_dup_key = off) on [primary]
	) on [primary]
end

if not exists (select 1 from information_schema.table_constraints where table_name = N'<tableName, sysname, appTable>' and constraint_name = N'<fkName, sysname, FK_appTable_columnName>')
	alter table [dbo].[<tableName, sysname, appTable>] with check 
		add constraint [<fkName, sysname, FK_appTable_columnName>] foreign key(<pkColumnName, sysname, columnGuid>)
		references [dbo].[<tableName, sysname, appTable>] (<fkColumnName, sysname, columnName>)
go
