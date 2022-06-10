Prompt Package HDFS_READER;
CREATE OR REPLACE PACKAGE hdfs_reader IS
-- Return type of pl/sql table function
TYPE return_rows_t IS TABLE OF hadoop_row_obj;
-- Checks if current invocation is serial
FUNCTION is_serial RETURN BOOLEAN;
-- Function to actually launch a Hadoop job
FUNCTION launch_hadoop_job(in_directory IN VARCHAR2, id in out number) RETURN BOOLEAN;
-- Tf to read from Hadoop -- This is the main processing code reading from the queue in -- Figure 3 step 6. It also contains the code to insert into -- the table in Figure 3 step 1
FUNCTION read_from_hdfs_file(pcur IN SYS_REFCURSOR, in_directory IN VARCHAR2) RETURN return_rows_t
PIPELINED PARALLEL_ENABLE(PARTITION pcur BY ANY);
END;
/


