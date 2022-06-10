Prompt Package SESS_MEM_USAGE;
CREATE OR REPLACE package sess_mem_usage as
  type t_rec is record (
    owner     varchar2(4000)
   ,unit      varchar2(4000)
   ,type      varchar2(40)
   ,used      number
   ,free      number
  );
  type t_rec_tab is table of t_rec;

  function get return t_rec_tab pipelined;
  procedure dump_mem_usage;
end sess_mem_usage;
/


