--***Use Ctrl-Shift-M to replace parameter placeholders***--

if exists (select 1 from information_schema.routines where routine_name = N'<udfName, sysname, app_udfName>' and routine_type = N'function')
	drop function [dbo].[<udfName, sysname, app_udfName>]
go

create function [dbo].[<udfName, sysname, app_udfName>]
(
  @parameter int -- = defaultValue
)
returns bit
as
begin

	return 1
end
go
