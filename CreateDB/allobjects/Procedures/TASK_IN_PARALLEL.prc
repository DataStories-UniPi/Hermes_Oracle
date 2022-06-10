Prompt Procedure TASK_IN_PARALLEL;
CREATE OR REPLACE procedure        task_in_parallel as
  l_chunk_sql VARCHAR2(1000);  l_sql_stmt VARCHAR2(1000);
  l_try NUMBER; l_status NUMBER;stmt varchar2(4000);
  featherstab varchar2(50):='FEATHERS_PARTED';
  subzonestab varchar2(50):= 'FLANDERS_SUBZONES';
  outputtblsemmpoints VARCHAR2(50):='FEATHERS_SEMTRAJS';
  chunks_table varchar2(50):='PARALLEL_CHUNKS';
  sdwTablePrefix varchar2(50):='FEATHERS_SEMTRAJS';
  stbtreeprefix varchar2(50):='FEATHERS_STBTREE';
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
        --sdw.cellstopsload_parallel('''||sdwTablePrefix||''','''||sdwTablePrefix||''',:start_id,:end_id);
        --sem_reconstruct.feathers2semtrajs('''||featherstab||''','''||subzonestab||''','''||outputtblsemmpoints||''',:start_id, :end_id);
        std.fill_stbtree_structure_par('''||stbtreeprefix||''','''||sdwTablePrefix||''',:start_id, :end_id);
      end;';
  DBMS_PARALLEL_EXECUTE.RUN_TASK('mytask', l_sql_stmt, DBMS_SQL.NATIVE, parallel_level => 12); 
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
 exception when others then
  dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
        dbms_output.put_line('Error_Backtrace...' ||
          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
end;
/


