declare @field_from_select_clause uniqueidentifier

declare <cursorName, sysname,>_Cursor  cursor fast_forward for  
   --select clause  

open <cursorName, sysname,>_Cursor  
fetch next from <cursorName, sysname,>_Cursor
into @field_from_select_clause  
while @@fetch_status = 0 begin   

	--Your code here

 fetch next from <cursorName, sysname,>_Cursor
 into @field_from_select_clause
end  

close <cursorName, sysname,>_Cursor
deallocate <cursorName, sysname,>_Cursor