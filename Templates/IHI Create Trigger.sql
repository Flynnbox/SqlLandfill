--***Use Ctrl-Shift-M to replace parameter placeholders***--

if object_id ('<triggerName, sysname, trg_appTable_action>', 'tr') is not null
	drop trigger [<triggerName, sysname, trg_appTable_action>]

create trigger [dbo].[<triggerName, sysname, trg_appTable_action>] on appTable
after insert
as
set nocount on

	begin try
		begin transaction;

		--Your code here using old and new trigger tables

		commit transaction;
	end try
	begin catch
		rollback transaction;		
		raiserror (error_message(), error_severity(), error_state());
	end catch;

set nocount off
go
