Prompt View V$ORA_SESS_MEM_USAGE;
CREATE OR REPLACE VIEW V$ORA_SESS_MEM_USAGE
AS 
select "OWNER","UNIT","TYPE","USED","FREE" from table(sess_mem_usage.get)
/


