Prompt Package Body HADOOP;
CREATE OR REPLACE PACKAGE BODY        hadoop
IS

function test_parallel_any(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by any) is
  l_row dbmsoutput_t;
begin
  loop
    fetch p_cur into l_row.message,l_row.a,l_row.b,l_row.c,l_row.d,l_row.e,l_row.message2,l_row.timer;
    exit when p_cur%notfound;
    select sid into l_row.sid from v$mystat where rownum=1;
    pipe row(l_row);
  end loop;
  return;
end test_parallel_any;

function test_parallel_hash(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by hash(a)) is
  l_row dbmsoutput_t;
begin
  loop
    fetch p_cur into l_row.message,l_row.a,l_row.b,l_row.c,l_row.d,l_row.e,l_row.message2,l_row.timer;
    exit when p_cur%notfound;
    select sid into l_row.sid from v$mystat where rownum=1;
    pipe row(l_row);
  end loop;
  return;
end test_parallel_hash;

function test_parallel_range(p_cur in dbmsoutput_ref_cur) return dbmsoutput_tab pipelined parallel_enable(partition p_cur by range(a)) is
  l_row dbmsoutput_t;
begin
  loop
    fetch p_cur into l_row.message,l_row.a,l_row.b,l_row.c,l_row.d,l_row.e,l_row.message2,l_row.timer;
    exit when p_cur%notfound;
    select sid into l_row.sid from v$mystat where rownum=1;
    pipe row(l_row);
  end loop;
  return;
end test_parallel_range;

PROCEDURE task_in_parallel
AS
  l_chunk_sql         VARCHAR2(1000);
  l_sql_stmt          VARCHAR2(1000);
  l_try               NUMBER;
  l_status            NUMBER;
  stmt                VARCHAR2(4000);
  featherstab         VARCHAR2(50):='FEATHERS_PARTED';
  subzonestab         VARCHAR2(50):='FLANDERS_SUBZONES';
  outputtblsemmpoints VARCHAR2(50):='FEATHERS_SEMTRAJS';
  chunks_table        VARCHAR2(50):='PARALLEL_CHUNKS';
  srcTablePrefix      VARCHAR2(50):='FEATHERS_SEMTRAJS';
  stbtreeprefix       VARCHAR2(50):='FEATHERS_STBTREE';
BEGIN
  -- Create the TASK
  DBMS_PARALLEL_EXECUTE.CREATE_TASK ('mytask');
  -- Chunk the table by ROWID
  --DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_ROWID('mytask', 'HERMES', sdwTablePrefix||'_STOP_SEMS_DIM', true, 439);
  -- Chunk the table by a column
  l_chunk_sql := 'SELECT distinct t.from_id, t.to_id FROM '||chunks_table||' t ';
  DBMS_PARALLEL_EXECUTE.CREATE_CHUNKS_BY_SQL('mytask', l_chunk_sql, false);
  -- Chunk by column of number type
  /*
  DBMS_PARALLEL_EXECUTE.create_chunks_by_number_col(task_name    => 'mytask', table_owner  => 'HERMES',
  table_name   => featherstab,
  table_column => 'P_PERSONCOUNTER', chunk_size   => 399252);
  */
  -- Execute the DML in parallel
  --   the WHERE clause contain a condition on manager_id, which is the chunk
  --   column. In this case, grouping rows is by manager_id.
  l_sql_stmt := 'begin         
                  --sdw.cellstopsload_parallel('''||srcTablePrefix||''','''||srcTablePrefix||''',:start_id,:end_id);        
                  --sem_reconstruct.feathers2semtrajs('''||featherstab||''','''||subzonestab||''','''||outputtblsemmpoints||''',:start_id, :end_id);        
                  --std.fill_stbtree_structure_par('''||stbtreeprefix||''','''||srcTablePrefix||''',:start_id, :end_id);      
                  hadoop.feathers2stbtreeleaves('''||stbtreeprefix||''','''||srcTablePrefix||''',:start_id, :end_id);
                end;';
  DBMS_PARALLEL_EXECUTE.RUN_TASK('mytask', l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 5);
  -- If there is error, RESUME it for at most 2 times.
  /*
  L_try := 0;
  L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  WHILE(l_try < 2 and L_status != DBMS_PARALLEL_EXECUTE.FINISHED)
  Loop
  L_try := l_try + 1;
  DBMS_PARALLEL_EXECUTE.RESUME_TASK('mytask');
  L_status := DBMS_PARALLEL_EXECUTE.TASK_STATUS('mytask');
  END LOOP;
  */
  -- Done with processing; drop the task
  --DBMS_PARALLEL_EXECUTE.DROP_TASK('mytask');
  --finally run
  /*
  stmt:='insert into '||sdwTablePrefix||'_stops_fact(period_id,stop_sems_id,user_profile_id,num_of_sem_trajectories,
  num_of_users,num_of_activities,avg_duration,radius_of_gyration,crosst)
  select s.period_id, s.stop_sems_id,s.user_profile_id,count(distinct s.semtraj_id),
  count(distinct s.user_id),count(distinct s.activity),
  sum(s.duration)/count(*)
  ,sum(s.radius_of_gyration)/count(*)----radius of many moving_points???
  ,0
  from '||sdwTablePrefix||'_tmp_stops_fact s
  group by s.period_id, s.stop_sems_id,s.user_profile_id';
  execute immediate stmt;
  commit;
  */
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
  dbms_output.put_line('Error_Backtrace...' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
END task_in_parallel;







  -- Checks if current process is a px_process
function is_serial return boolean is
  c number;
begin
  select count (*) into c from v$px_process where sid = sys_context('USERENV','SESSIONID');
  if c <> 0 then
    return false;
  else
    return true;
  end if;
exception
when others then
  raise;
end is_serial;

function read_from_leafers(pcur in sys_refcursor,in_task_name varchar2) return sem_stbnode_entries_nt pipelined PARALLEL_ENABLE(partition pcur by any) is
  --is run by many processes in parallel
  pragma autonomous_transaction;
  cleanup boolean;
  payload sem_stbnode_entry;
  id number;
  dopt dbms_aq.dequeue_options_t;
  mprop dbms_aq.message_properties_t;
  msgid raw(100);
  mysid number;
begin
  select sid into mysid from v$mystat where rownum=1;--just to record processes
  insert into dbmsoutput(message, timer)values(mysid, systimestamp);
  cleanup := launch_leafers(in_task_name, id);
  dopt.visibility := dbms_aq.immediate;
  dopt.delivery_mode := dbms_aq.buffered;
  --dbms_lock.sleep(10);
  loop
    payload := null;
    dbms_aq.dequeue('STBTREE_LEAVES_QUEUE', dopt, mprop, payload, msgid);
    commit;      
    pipe row(payload);
  end loop;
  exception when others then
    if cleanup then
      delete coordinator where pk_id = id;
      commit;
    end if;
end read_from_leafers;

function launch_leafers(task_name varchar2, id in out number) return boolean is
  --is run by many processes in parallel, only one get beyond insert
  pragma autonomous_transaction;
  instance_id number;
  jname varchar2(4000);
begin
  if is_serial then
    id := sys_context('USERENV','SESSIONID');
    select instance_number into instance_id from v$instance;
    id := instance_id*100000 + id;
  else    
    select ownerid into id from v$session where sid=sys_context('USERENV','SESSIONID');
  end if;
  insert into coordinator values(id, 'RUNNING');
  jname:= 'launch_leafers_async';
  
  dbms_scheduler.create_job(jname,'STORED_PROCEDURE','hadoop.launch_leafers_async',2);
  dbms_scheduler.set_job_argument_value(jname,1,cast(id as varchar2));
  dbms_scheduler.set_job_argument_value(jname,2,task_name);
  dbms_scheduler.enable('launch_leafers_async');
  commit;
  return true;
  exception 
    when dup_val_on_index then
      return false;
    when others then
      raise;
end launch_leafers;

procedure launch_leafers_async(id number, in_task_name varchar2) as
  --scheduled by coordinator, one of many processes
  cnt number;
begin
  /*
  begin
    dbms_scheduler.drop_job('Leafers'||id, true);
  exception when others then null; end;
  dbms_scheduler.create_job('Leafers'||id,'STORED_PROCEDURE','hermes.hadoop.leafers_in_parallel',1);
  dbms_scheduler.set_job_argument_value('Leafers'||id,1, in_task_name);
  dbms_scheduler.enable('Leafers'||id);
  */
  --we tried the above but seems to finishing quit fast , before leafers
  --so we start leafers manually and so there is no need to start them from here
  loop
    --select count(*) into cnt from dba_scheduler_jobs where job_name ='Leafers'||id;
    --we are using dbms_parallel_execute oracle package, so monitor it
    select count(*) into cnt from user_parallel_execute_tasks where task_name = in_task_name;
    if (cnt = 0) then
      exit;
    else
      dbms_lock.sleep(5);
    end if;
  end loop;
  loop
    select sum(c) into cnt from (
      select enqueued_msgs - dequeued_msgs c from gv$persistent_queues where queue_name='STBTREE_LEAVES_QUEUE'
    union all
    select num_msgs + spill_msgs c from gv$buffered_queues where queue_name='STBTREE_LEAVES_QUEUE'
    union all
    select 0 c from dual);
    if (cnt = 0) then
      dbms_aqadm.stop_queue('STBTREE_LEAVES_QUEUE');
      dbms_aqadm.drop_queue('STBTREE_LEAVES_QUEUE');
      return;
    else
      dbms_lock.sleep(5);
    end if;  
  end loop;
end launch_leafers_async;

procedure leafers_in_parallel(task_name varchar2) as
  chunks_table        VARCHAR2(50):='PARALLEL_CHUNKS';
  srcTablePrefix      VARCHAR2(50):='FEATHERS_SEMTRAJS';
  stbtreeprefix       VARCHAR2(50):='FEATHERS_STBTREE';
  l_chunk_sql         VARCHAR2(1000);
  l_sql_stmt          VARCHAR2(1000);
begin 
  dbms_parallel_execute.create_task (task_name);
  l_chunk_sql := 'SELECT distinct t.from_id, t.to_id FROM '||chunks_table||' t ';
  dbms_parallel_execute.create_chunks_by_sql(task_name, l_chunk_sql, false);
  l_sql_stmt := 'begin   
                   --hadoop.feathers2stbtreeleaves('''||stbtreeprefix||''','''||srctableprefix||''',:start_id, :end_id);
                   hadoop.feathersepisodes2geometry('''||srctableprefix||''',null,:start_id, :end_id);
                 end;';
  dbms_parallel_execute.run_task(task_name, l_sql_stmt, dbms_sql.native, parallel_level => 10);
  --dbms_parallel_execute.drop_task(task_name);
  exception
    when others then
      dbms_output.put_line(sqlcode||'->'||to_char(sqlerrm));
      dbms_output.put_line('Error_Backtrace...' || dbms_utility.format_error_backtrace());
end leafers_in_parallel;

procedure feathers2stbtreeleaves(idxname varchar2, source_table varchar2, from_id number, to_id number) AS
  type strajcurtyp is ref cursor;
  cur_straj strajcurtyp;
  tmpstraj sem_trajectory;
  roid varchar2(32);
  stmt varchar2(4000);
  lid number;
  mysid number;
  
  newleafentry sem_stbleaf_entry;
  newleaf sem_stbleaf;
  leaftab varchar2(50) :=idxname||'_LEAF';
  nodetab varchar2(50) := idxname||'_NON_LEAF';
  
  dopt dbms_aq.enqueue_options_t;
  mprop dbms_aq.message_properties_t;
  msgid raw(100);
  newnodeentry sem_stbnode_entry := sem_stbnode_entry(null,null);
BEGIN
  select sid into mysid from v$mystat where rownum=1;--just to record processes
  insert into dbmsoutput(message, timer)values(mysid, systimestamp);
  commit;
  stmt := 'select /*+parallel+*/ s.rowid, value(s)            
          from '||source_table||' s            
          where s.o_id between '||from_id||' and '||to_id||'          
          ';
  OPEN cur_straj FOR stmt ;
  loop
    fetch cur_straj into roid, tmpstraj;
    exit when cur_straj%notfound;
    if tmpstraj.episodes.count > 0 then
      --make a leaf
      newleaf := sem_stbleaf(sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),roid,-1,-1,-1,-1,0,sem_stbleaf_entries());
      --episodes are not ordered by oracle as in nested table. Mind that and pass them in order
      for c_epis in (select t.defining_tag,t.episode_tag,t.activity_tag,t.mbb,t.tlink
        from table(tmpstraj.episodes) t order by t.mbb.minpoint.t.m_y,t.mbb.minpoint.t.m_m,t.mbb.minpoint.t.m_d,t.mbb.minpoint.t.m_h,t.mbb.minpoint.t.m_min,t.mbb.minpoint.t.m_sec) loop
          --make a new leafEntry
          newleafentry := sem_stbleaf_entry(c_epis.MBB, c_epis.defining_tag, c_epis.episode_tag, c_epis.activity_tag, c_epis.tlink);
          --add them to leaf
          newleaf.leafEntries.extend();
          newleaf.numOfEntries := newleaf.numOfEntries + 1;
          newleaf.leafEntries(newleaf.numOfEntries) := newleafentry;
        --stbinsert(c_epis.epis,sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
        --stbinsert(tmpstraj.episodes(i),sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
          --        roid, idxname||'_non_leaf', idxname||'_leaf', 155, 155);
      end loop;
      --insert leaf to leaves table
      --lid could be derived by hasing rowid so not to care about uniqueness
      execute immediate 'begin insert into '||leaftab||'(lid, roid, leaf) values (ORA_HASH(:lid), :roid, :leaf);end;'
              using in roid, in roid, in newleaf;
      commit;--per trajectory
      --also push it to aq
      /*
      select ORA_HASH(roid) into lid from dual;
      newnodeentry.ptrto:= lid;
      newnodeentry.mbb:=tmpstraj.getMBB();
      begin
        dopt.visibility := dbms_aq.immediate;
        dopt.delivery_mode := dbms_aq.buffered;
        dbms_aq.enqueue('STBTREE_LEAVES_QUEUE', dopt, mprop, newnodeentry, msgid);--is not visible from dbms_parallel_execute context ????
        commit;
      end;
      */
    end if;
  end loop;  
  close cur_straj;
END feathers2stbtreeleaves;

procedure feathersepisodes2geometry(fromtbl varchar2, totbl varchar2, from_id number, to_id number) is
  type strajcurtyp is ref cursor;
  cur_straj strajcurtyp;
  tmpstraj sem_trajectory;
  stmt varchar2(4000);
  centerx number;centery number;
  epis_sdo_ordinates sdo_ordinate_array:=sdo_ordinate_array();
  i number:=0;
begin
  stmt := 'select /*+parallel+*/ value(s)            
          from '||fromtbl||' s            
          where s.o_id between '||from_id||' and '||to_id||'          
          ';
  OPEN cur_straj FOR stmt ;
  loop
    fetch cur_straj into tmpstraj;
    exit when cur_straj%notfound;
    if tmpstraj.episodes.count > 0 then
      i:=0;
      for epis in (select t.defining_tag,t.episode_tag,t.activity_tag,t.mbb,t.tlink
        from table(tmpstraj.episodes) t where t.defining_tag = 'STOP'
        order by t.mbb.minpoint.t.m_y,t.mbb.minpoint.t.m_m,t.mbb.minpoint.t.m_d,t.mbb.minpoint.t.m_h,t.mbb.minpoint.t.m_min,t.mbb.minpoint.t.m_sec) loop
        i:=i+1;
        epis_sdo_ordinates.extend(1);
        epis_sdo_ordinates(epis_sdo_ordinates.last):=epis.mbb.minpoint.x; 
        epis_sdo_ordinates.extend(1);
        epis_sdo_ordinates(epis_sdo_ordinates.last):=epis.mbb.minpoint.y;
        epis_sdo_ordinates.extend(1);
        epis_sdo_ordinates(epis_sdo_ordinates.last):=epis.mbb.maxpoint.x;        
        epis_sdo_ordinates.extend(1);
        epis_sdo_ordinates(epis_sdo_ordinates.last):=epis.mbb.maxpoint.y;  
              
        INSERT INTO FEATHERS_SEMTRAJS_EPIS_GEOM (O_ID, SEMTRAJ_ID, GEOM, EPISODE_ID) VALUES(tmpstraj.o_id, tmpstraj.semtraj_id,
          sdo_geometry (2003, 8307, null, sdo_elem_info_array (1,1003,3), epis_sdo_ordinates), i);
        epis_sdo_ordinates.delete();
      end loop;      
      commit;
    end if;
  end loop;
end feathersepisodes2geometry;

END hadoop;
/


