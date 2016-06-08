declare @defaultConstraintName nvarchar(100)

select
  @defaultConstraintName = object_name([default_object_id])
from
  sys.columns
where
  object_id = object_id('<Table Name, varchar(max), >')
and
	name = '<Column Name, varchar(max), >';

exec('alter table <Table Name, varchar(max), > drop constraint ' + @defaultConstraintName)