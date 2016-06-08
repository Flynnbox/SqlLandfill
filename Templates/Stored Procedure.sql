--***Use Ctrl-Shift-M to replace parameter placeholders***--

if exists (select 1 from information_schema.routines where routine_name = N'<procedureName, sysname, app_procedureName>' and routine_type = N'procedure')
	drop procedure [dbo].<procedureName, sysname, app_procedureName>
go

create procedure [dbo].<procedureName, sysname, app_procedureName>
(
  @parameter datatype = defaultValue
)
as
begin
  set nocount on

	

	set nocount off
end
go

grant execute on [dbo].<procedureName, sysname, app_procedureName> to public
go
