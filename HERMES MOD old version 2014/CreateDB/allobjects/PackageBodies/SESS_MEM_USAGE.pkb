Prompt Package Body SESS_MEM_USAGE;
CREATE OR REPLACE package body sess_mem_usage as
  function map_type2name(p_type integer)
  return varchar2
  as
    l_v varchar2(20);
  begin
    l_v := case p_type  when 7  then '(procedure)'
                        when 8  then '(function)'
                        when 9  then '(package)'
                        when 11 then '(package body)'
                        when 12 then '(trigger)'
                        when 13 then '(type)'
                        when 14 then '(type body)'
                        else ''
            end;
    return rpad(to_char(p_type), 3) || l_v;
  end map_type2name;

  function get return t_rec_tab pipelined as
    l_owner_array  dbms_session.lname_array;
    l_unit_array   dbms_session.lname_array;
    l_type_array   dbms_session.integer_array;
    l_used_array   dbms_session.integer_array;
    l_free_array   dbms_session.integer_array;
    l_rec          t_rec;
  begin
    dbms_session.get_package_memory_utilization
     (l_owner_array, l_unit_array, l_type_array,
      l_used_array, l_free_array);
    for i in 1..l_owner_array.count loop
      l_rec.owner := l_owner_array(i);
      l_rec.unit  := l_unit_array(i);
      l_rec.type  := map_type2name(l_type_array(i));
      l_rec.used  := l_used_array(i);
      l_rec.free := l_free_array(i);
        pipe row(l_rec);
    end loop;
    return;
  end get;
  
  procedure dump_mem_usage
  as
    c_max_pls_integer constant pls_integer := 2147483647;
    l_usage_list               varchar2(2000);
    l_sum_abs_mb               number;
  begin
    select listagg(owner||';'||unit||';'||type||';'||used||';'||free||';'||alloc_abs_mb, chr(10))
             within group (order by alloc_abs_mb desc) name_usage_list
          ,sum(alloc_abs_mb)                           sum_abs_mb
    into l_usage_list
        ,l_sum_abs_mb
    from (
          select v.*
                ,round((decode(sign(used), -1, c_max_pls_integer, used)
                      + decode(sign(free), -1, c_max_pls_integer, free))/1024/1024, 9) alloc_abs_mb
          from   v$ora_sess_mem_usage v
          order by alloc_abs_mb desc
         )
    --where rownum <= 30
    ;
    dbms_output.put_line('[Owner;Unit;Type;Used;Free;sum_abs_mb(' || l_sum_abs_mb ||')]' ||  chr(10) || l_usage_list);
  end dump_mem_usage;
end sess_mem_usage;
/


