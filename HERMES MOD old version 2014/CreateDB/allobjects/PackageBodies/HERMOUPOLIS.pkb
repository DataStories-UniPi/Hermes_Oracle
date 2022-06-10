Prompt Package Body HERMOUPOLIS;
CREATE OR REPLACE package body Hermoupolis is

  -- Private type declarations
  /*
  type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  <VariableName> <Datatype>;

  -- Function and procedure implementations
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;
  */
  
  procedure raw2semtrajs(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer) 
  is
    brink_cv sys_refcursor;
    query varchar2(4000);
    defining_tag varchar2(30);
    type gpsin_typ is record(
         id integer,
         reporter_tag varchar2(30),
         episode_tag varchar2(30),
         activity_tag varchar2(30),
         stopepisodeid integer,
         timer timestamp,
         x number,
         y number);
    type gpsin_tab is table of gpsin_typ;
    gpsin gpsin_tab;
    old_id integer:=-1;
    cur_semtraj sem_trajectory:=null;
    cur_episode sem_episode;
    cur_submpoint sub_moving_point;
    unit_mpoint unit_moving_point;
    cur_episode_id integer;old_episode_id integer:=-1;
    refcv sys_refcursor;
    refer ref sub_moving_point;
    cur_timepoint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);

    procedure storeit(submpoint sub_moving_point,tablename varchar2,curepisode sem_episode) is
      episode sem_episode;
      begin
        --store sub_mpoint to table
        EXECUTE immediate 'insert into '||tablename||' values(:sub_traj)' USING IN submpoint;
        COMMIT;
        --take a ref
        query := 'select ref(t) from '||tablename||' t                      
          where t.o_id='||submpoint.o_id||'                      
          and t.traj_id='||submpoint.traj_id||'                      
          and t.subtraj_id='||submpoint.subtraj_id ;
        OPEN refcv FOR query;
        FETCH refcv INTO refer;
        CLOSE refcv;
        --update cur_episode to episode
        episode:=sem_episode(curepisode.defining_tag,curepisode.episode_tag, curepisode.activity_tag,submpoint.getsemmbb(),refer);
        --add episode to cur_semtraj
        cur_semtraj.episodes.extend(1);
        cur_semtraj.episodes(cur_semtraj.episodes.last):=episode;  
      end storeit;
      
    function to_timepoint(gpstimer timestamp) return tau_tll.d_timepoint_sec is
      timepointout tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
      begin
        timepointout.m_y:=extract(year from gpstimer);
        timepointout.m_m:=extract(month from gpstimer);
        timepointout.m_d:=extract(day from gpstimer);
        timepointout.m_h:=extract(hour from gpstimer);
        timepointout.m_min:=extract(minute from gpstimer);
        timepointout.m_sec:=extract(second from gpstimer);
        return timepointout;
      end to_timepoint;
  begin
    --cleartables(sub_mpoints_out,sem_trajs_out);
    query:='select t.id,t.defining_tag, t.episode_tag, t.activity_tag,t.episodeid,
        to_timestamp(substr(t.time,9,2)||''-''||substr(t.time,5,3)||''-''||substr(t.time,26,4)||
        '' ''||substr(t.time,12,2)||'':''||substr(t.time,15,2)||'':''||substr(t.time,18,2),''DD-Mon-YYYY HH24:MI.SS'') timer,
        t.x, t.y
        from '||brink_output||' t 
        --where t.id=1
        order by t.id, timer';
    
    open brink_cv for query;
    loop
      fetch brink_cv bulk collect into gpsin limit 100000;
      
      for indx in gpsin.first..gpsin.last loop
        defining_tag:=upper(gpsin(indx).reporter_tag);
        if (Instr(defining_tag, 'STOP')<>0) then
          defining_tag:='STOP';
        else
          defining_tag:='MOVE';
        end if;
        cur_episode_id:=gpsin(indx).stopepisodeid;
        cur_timepoint:=to_timepoint(gpsin(indx).timer);
        --old_id<>cur_id=>new semtraj
        if (old_id <> gpsin(indx).id) then
          --store cur_semtraj if not null(store cur_submpoint[remove last uncomplete segment],
            --make it episode,add episode to cur_semtraj.episodes, store cur_semtraj)
          if (cur_semtraj is not null) then
            cur_submpoint.sub_mpoint.u_tab.trim;
            if (cur_submpoint.sub_mpoint.u_tab.count=0) then
              dbms_output.put_line('Found an episode with only one gps point when new trajectory! A sub trajectory can not be created!');
              dbms_output.put_line('Object_id='||old_id||', Trajectory_id='||old_id||', Episode_id='||old_episode_id);
            end if;
            storeit(cur_submpoint,sub_mpoints_out,cur_episode);
            EXECUTE immediate 'insert into '||sem_trajs_out||' values(:sem_traj)' USING IN cur_semtraj;
            COMMIT;       
          end if;
          --create new cur_semtraj()
          cur_semtraj:=sem_trajectory(null,srid,sem_episode_tab(),gpsin(indx).id,gpsin(indx).id);
          --new episode
          cur_episode:=sem_episode(defining_tag,upper(gpsin(indx).episode_tag),upper(gpsin(indx).activity_tag),null,null);
          --new sub_mpoint with start point filled
          unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,null,null,null,null,null,null,null,'PLNML_1'));
          cur_submpoint:=sub_moving_point(gpsin(indx).id,gpsin(indx).id,cur_episode_id,moving_point(moving_point_tab(unit_mpoint),gpsin(indx).id,srid));
        else --old_id=cur_id=>same semtraj
          --old_episode<>cur_episode=>new episode
          if (old_episode_id<>cur_episode_id) then null;
            --store cur_submpoint if not null(store cur_submpoint[remove last uncomplete segment], make it episode,add episode to cur_semtraj.episodes)
            cur_submpoint.sub_mpoint.u_tab.trim;
            if (cur_submpoint.sub_mpoint.u_tab.count=0) then
              dbms_output.put_line('Found an episode with only one gps point when new episode! A sub trajectory can not be created!');
              dbms_output.put_line('Object_id='||old_id||', Trajectory_id='||old_id||', Episode_id='||old_episode_id);
            end if;
            storeit(cur_submpoint,sub_mpoints_out,cur_episode);
            --create new cur_episode()
            cur_episode:=sem_episode(defining_tag,upper(gpsin(indx).episode_tag),upper(gpsin(indx).activity_tag),null,null);
            --new sub_mpoint with start point filled
            unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,null,null,null,null,null,null,null,'PLNML_1'));
            cur_submpoint:=sub_moving_point(gpsin(indx).id,gpsin(indx).id,cur_episode_id,moving_point(moving_point_tab(unit_mpoint),gpsin(indx).id,srid));
          else--old_episode=cur_episode=>add gps point to cur_submpoint(add as end and as next segment start)
            --add as end
            cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).p.e:=cur_timepoint;
            cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).m.xe:=gpsin(indx).x;
            cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).m.ye:=gpsin(indx).y;
            --add as next's start
            unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,null,null,null,null,null,null,null,'PLNML_1'));
            cur_submpoint.sub_mpoint.u_tab.extend;
            cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last):=unit_mpoint;
          end if;
        end if;
        old_id:=gpsin(indx).id;
        old_episode_id:=cur_episode_id;
      end loop;
      exit when brink_cv%notfound;
    end loop;
    cur_submpoint.sub_mpoint.u_tab.trim;
    if (cur_submpoint.sub_mpoint.u_tab.count>0) then
      storeit(cur_submpoint,sub_mpoints_out,cur_episode);
    end if;
    EXECUTE immediate 'insert into '||sem_trajs_out||' values(:sem_traj)' USING IN cur_semtraj;
    COMMIT;
    close brink_cv;
  end raw2semtrajs;
  
  procedure raw2semtrajs2avoidbug(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer) 
  is
    brink_cv sys_refcursor;
    query varchar2(4000);
    defining_tag varchar2(30);
    type gpsin_typ is record(
         id integer,
         reporter_tag varchar2(30),
         episode_tag varchar2(30),
         activity_tag varchar2(30),
         stopepisodeid integer,
         timer timestamp,
         x number,
         y number);
    type gpsin_tab is table of gpsin_typ;
    gpsin gpsin_tab;
    cur_semtraj sem_trajectory:=null;
    cur_episode sem_episode;
    cur_submpoint sub_moving_point;
    unit_mpoint unit_moving_point;
    cur_episode_id integer;
    refcv sys_refcursor;
    refer ref sub_moving_point;
    cur_timepoint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    old_timestamp timestamp;
    
    numofobjects integer;
    numofepisodes integer;
    maxepisodeid integer;

    procedure storeit(submpoint sub_moving_point,tablename varchar2,curepisode sem_episode) is
      episode sem_episode;
      begin
        --store sub_mpoint to table
        EXECUTE immediate 'insert into '||tablename||' values(:sub_traj)' USING IN submpoint;
        COMMIT;
        --take a ref
        query := 'select ref(t) from '||tablename||' t                      
          where t.o_id='||submpoint.o_id||'                      
          and t.traj_id='||submpoint.traj_id||'                      
          and t.subtraj_id='||submpoint.subtraj_id ;
        OPEN refcv FOR query;
        FETCH refcv INTO refer;
        CLOSE refcv;
        --update cur_episode to episode
        episode:=sem_episode(curepisode.defining_tag,curepisode.episode_tag, curepisode.activity_tag,submpoint.getsemmbb(),refer);
        --add episode to cur_semtraj
        cur_semtraj.episodes.extend(1);
        cur_semtraj.episodes(cur_semtraj.episodes.last):=episode;  
      end storeit;
      
    function to_timepoint(gpstimer timestamp) return tau_tll.d_timepoint_sec is
      timepointout tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
      begin
        timepointout.m_y:=extract(year from gpstimer);
        timepointout.m_m:=extract(month from gpstimer);
        timepointout.m_d:=extract(day from gpstimer);
        timepointout.m_h:=extract(hour from gpstimer);
        timepointout.m_min:=extract(minute from gpstimer);
        timepointout.m_sec:=extract(second from gpstimer);
        return timepointout;
      end to_timepoint;
  begin
    --cleartables(sub_mpoints_out,sem_trajs_out);
    query:='begin select count(distinct t.id) into :numofobjects from '||brink_output||' t;end;';
    execute immediate query using out numofobjects;--starting from zero
   
    for i in 1..numofobjects loop
      --monkey business
      --incremental
      /*      if (i!=4977) then
        continue;
      end if;      */
      --create new cur_semtraj()
      cur_semtraj:=sem_trajectory(null,srid,sem_episode_tab(),i-1,i-1);
      query:='begin select count(distinct t.episodeid),max(t.episodeid)
                    into :numofepisodes, :maxepisodeid from '||brink_output||' t where t.id=:id;end;';
      execute immediate query using out numofepisodes,out maxepisodeid,in i-1;--starting from one
      --monkey business
      --another bug, episodes not in order (from 1 to 4,5,6)
      --i should use
      --select t.id, count(distinct t.stopepisodeid),max(t.stopepisodeid) from attiki_reporter_table t group by t.id;
      --and check whether they are different
      --if (numofepisodes<5) then
      /*      if (numofepisodes!=maxepisodeid) then
        continue;
      end if;      */
      for e in 1..numofepisodes loop
        query:='select t.id,t.defining_tag, t.episode_tag, t.activity_tag,t.episodeid,
          to_timestamp(substr(t.time,9,2)||''-''||substr(t.time,5,3)||''-''||substr(t.time,26,4)||
          '' ''||substr(t.time,12,2)||'':''||substr(t.time,15,2)||'':''||substr(t.time,18,2),''DD-Mon-YYYY HH24:MI.SS'') timer,
          t.x, t.y
          from '||brink_output||' t 
          where t.id=:id and t.episodeid = :episodeid
          order by t.id, timer';
        open brink_cv for query using in i-1,in e;
        fetch brink_cv bulk collect into gpsin;
        close brink_cv;
        for indx in gpsin.first..gpsin.last loop
          -- this is the key point for avoiding bug of first stop
          /*if (e = 1) and (indx = gpsin.last) then
            continue;
          end if;*/
          cur_timepoint:=to_timepoint(gpsin(indx).timer);
          if indx = 1 then
            old_timestamp:=gpsin(indx).timer;
            defining_tag:=upper(gpsin(indx).reporter_tag);
            if (Instr(defining_tag, 'STOP')<>0) then
              defining_tag:='STOP';
            else
              defining_tag:='MOVE';
            end if;
            cur_episode_id:=gpsin(indx).stopepisodeid;
            --new episode
            cur_episode:=sem_episode(defining_tag,upper(gpsin(indx).episode_tag),upper(gpsin(indx).activity_tag),null,null);
            --new sub_mpoint with start point filled
            unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,
                  null,null,null,null,null,null,null,'PLNML_1'));
            cur_submpoint:=sub_moving_point(gpsin(indx).id,gpsin(indx).id,cur_episode_id,moving_point(moving_point_tab(unit_mpoint),gpsin(indx).id,srid));
          else
            if (old_timestamp<gpsin(indx).timer) then
              --add as end
              cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).p.e:=cur_timepoint;
              cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).m.xe:=gpsin(indx).x;
              cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last).m.ye:=gpsin(indx).y;
              --add as next's start
              unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,
                    null,null,null,null,null,null,null,'PLNML_1'));
              cur_submpoint.sub_mpoint.u_tab.extend;
              cur_submpoint.sub_mpoint.u_tab(cur_submpoint.sub_mpoint.u_tab.last):=unit_mpoint;
            else
              --next gpspoint
              continue;
            end if;
          end if;
          old_timestamp:=gpsin(indx).timer;
        end loop;
        cur_submpoint.sub_mpoint.u_tab.trim;
        if (cur_submpoint.sub_mpoint.u_tab.count>0) then
          storeit(cur_submpoint,sub_mpoints_out,cur_episode);
        end if;
      end loop;
      EXECUTE immediate 'insert into '||sem_trajs_out||' values(:sem_traj)' USING IN cur_semtraj;
      COMMIT;
    end loop;
  end raw2semtrajs2avoidbug;

begin
  -- Initialization
  null;
end Hermoupolis;
/


