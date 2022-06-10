Prompt Package HADOOP;
CREATE OR REPLACE PACKAGE        hadoop IS
-- Return type of pl/sql table function
type payload_t is record(
  roid varchar2(50),
  straj sem_trajectory);
type payload_tab is table of payload_t;
type payload_cur is ref cursor return payload_t;
--examples
type dbmsoutput_t is record(
  message dbmsoutput.message%type,a dbmsoutput.a%type,
  b dbmsoutput.b%type, c dbmsoutput.c%type,
  d dbmsoutput.d%type,e dbmsoutput.e%type,
  message2 dbmsoutput.message2%type, timer dbmsoutput.timer%type,
  sid number);
type dbmsoutput_tab is table of dbmsoutput_t;
type dbmsoutput_ref_cur is ref cursor return dbmsoutput%rowtype;
function test_parallel_any(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by any);
function test_parallel_hash(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by hash(a));
function test_parallel_range(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by range(a));
--end of examples

procedure task_in_parallel;
PROCEDURE del_entries_textindx_par(idxname varchar2, from_id number, to_id number);
--my implentation to solve feathers stbtree scalability
-- Checks if current invocation is serial
function is_serial return boolean;
function read_from_leafers(pcur in sys_refcursor,in_task_name varchar2) return sem_stbnode_entries_nt pipelined parallel_enable(partition pcur by any);
function launch_leafers(task_name varchar2, id in out number) return boolean;
procedure launch_leafers_async(id number, in_task_name varchar2);

procedure leafers_in_parallel(task_name varchar2);
procedure feathers2stbtreeleaves(idxname varchar2, source_table varchar2, from_id number, to_id number);
procedure odmatrix(start_end_geoms varchar2, grid_geoms varchar2, totbl varchar2, from_id number, to_id number);


--to be moved
procedure fill_stbtree_innodes_par(idxname varchar2, from_id number, to_id number, level integer, maxnodeentries integer:=155);
procedure fill_stbtree_leaves_par(idxname varchar2, source_table varchar2, from_oid number, to_oid number, maxleafentries integer:=155);
procedure fill_stbtree_textindx_par(idxname varchar2, from_id number, to_id number);
END;
/


