Prompt Package Body HDFS_READER;
CREATE OR REPLACE PACKAGE BODY hdfs_reader IS
-- Checks if current process is a px_process
FUNCTION is_serial RETURN BOOLEAN IS
c NUMBER;
BEGIN
SELECT COUNT (*) into c FROM v$px_process WHERE sid = SYS_CONTEXT('USERENV','SESSIONID');
IF c <> 0 THEN
RETURN false;
ELSE
RETURN true;
END IF;
exception when others then
RAISE;
END;
FUNCTION launch_hadoop_job(in_directory IN VARCHAR2, id IN OUT NUMBER) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
instance_id NUMBER;
jname varchar2(4000);
BEGIN
if is_serial then
-- Get id by mixing instance # and session id
id := SYS_CONTEXT('USERENV', 'SESSIONID');
SELECT instance_number INTO instance_id FROM v$instance;
id := instance_id * 100000 + id;
else
-- Get id of the QC
SELECT ownerid into id from v$session where sid = SYS_CONTEXT('USERENV', 'SESSIONID');
end if;
-- Create a row to 'lock' it so only one person does the job -- schedule. Everyone else will get an exception -- This is in Figure 3 step 1
INSERT INTO run_hdfs_read VALUES(id, 'RUNNING');
jname := 'Launch_hadoop_job_async';
-- Launch a job to start the hadoop job
DBMS_SCHEDULER.CREATE_JOB (
job_name => jname,
job_type => 'STORED_PROCEDURE',
job_action => 'sys.launch_hadoop_job_async',
number_of_arguments => 2
);
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (jname, 1, in_directory);
DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (jname, 2, CAST (id AS VARCHAR2));
DBMS_SCHEDULER.ENABLE('Launch_hadoop_job_async');
COMMIT;
RETURN true;
EXCEPTION
-- one of my siblings launched the job. Get out quitely
WHEN dup_val_on_index THEN
dbms_output.put_line('dup value exception');
RETURN false;
WHEN OTHERs THEN
RAISE;
END;
FUNCTION read_from_hdfs_file(pcur IN SYS_REFCURSOR, in_directory IN VARCHAR2) RETURN return_rows_t
PIPELINED PARALLEL_ENABLE(PARTITION pcur BY ANY)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
cleanup BOOLEAN;
payload hadoop_row_obj;
id NUMBER;
dopt dbms_aq.dequeue_options_t;
mprop dbms_aq.message_properties_t;
msgid raw(100);
BEGIN
-- Launch a job to kick off the hadoop job
cleanup := launch_hadoop_job(in_directory, id);
dopt.visibility := DBMS_AQ.IMMEDIATE;
dopt.delivery_mode := DBMS_AQ.BUFFERED;
loop
payload := NULL;
-- Get next row
DBMS_AQ.DEQUEUE('HADOOP_MR_QUEUE', dopt, mprop, payload, msgid);
commit;
pipe row(payload);
end loop;
exception when others then
if cleanup then
delete run_hdfs_read where pk_id = id;
commit;
end if;
END;
END;
/


