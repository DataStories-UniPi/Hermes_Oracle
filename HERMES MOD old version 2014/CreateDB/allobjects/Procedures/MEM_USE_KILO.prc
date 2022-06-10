Prompt Procedure MEM_USE_KILO;
CREATE OR REPLACE procedure mem_use_kilo(p_kilo number) as
  type t_tab is table of varchar2(1000);
  l_tab t_tab := t_tab();
begin
  select rpad('E', 1000, 'N')
  bulk collect into l_tab
  from dual connect by level <= p_kilo;
  sess_mem_usage.dump_mem_usage;
end;
/


