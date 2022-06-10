Prompt Package Body BRINKHOFF;
CREATE OR REPLACE package body brinkhoff is

  procedure brinkhoff_proc(resolution pls_integer, minx double precision,maxy double precision,
    dx double precision, dy double precision, srid pls_integer)
  IS
  /*
  This procedure transform brinkhoff_temp points to moving_points
  on brinkhoff_result table.
  */
    fst INTEGER := 1;

    prev_classid integer;
    prev_id INTEGER;
    prev_tm NUMBER;
    prev_x NUMBER;
    prev_y NUMBER;

    cur_classid integer;
    cur_id INTEGER;
    cur_tm NUMBER;
    cur_x NUMBER;
    cur_y number;

    mpt moving_point_tab := moving_point_tab();

    tb tau_tll.d_timepoint_sec;
    te tau_tll.d_timepoint_sec;
  BEGIN
    tb := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
    te := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);

    FOR rec IN (SELECT classid, id, tm, x, y FROM brinkhoff_temp ORDER BY classid asc, id ASC, tm ASC) LOOP
      cur_classid := rec.classid;
      cur_id := rec.id;
      cur_tm := rec.tm;
      cur_x := round(minx + ((rec.x*dx)/resolution),8);
      cur_y := round(maxy - ((rec.y*dy)/resolution),8);

      IF fst = 1 THEN
        fst := 0;
      ELSE
        if prev_id = cur_id and prev_classid = cur_classid then
          tb.set_abs_date(210866803200 + prev_tm * 30);--must think somethink clever
          te.set_abs_date(210866803200 + cur_tm * 30);

          mpt.EXTEND;
          mpt(mpt.LAST) := unit_moving_point(
                    tau_tll.d_period_sec(tb, te),
                    unit_function(prev_x, prev_y, cur_x, cur_y, null, null, null, null, null, 'PLNML_1')
          );
        else
          INSERT INTO brinkhoff_result(classid, TRAJ_ID, MPOINT)
                 VALUES (prev_classid, prev_id, MOVING_POINT(mpt, prev_id, srid));

          mpt := moving_point_tab();
        END IF;
      END IF;

      prev_classid := cur_classid;
      prev_id := cur_id;
      prev_tm := cur_tm;
      prev_x := cur_x;
      prev_y := cur_y;
    END LOOP;

    INSERT INTO brinkhoff_result(classid, TRAJ_ID, MPOINT)
           VALUES (prev_classid, prev_id, MOVING_POINT(mpt, prev_id, srid));
    commit;
  end brinkhoff_proc;

  procedure brinkhoff_nodes(resolution pls_integer, minx double precision,maxy double precision,
    dx double precision, dy double precision)
  IS
  /*
  This procedure updates table brinkhoff_nodes so each point
  have real coordinates.
  */
  begin
    update BRINKHOFF_NODES b
    set b.longitude= minx + b.x*dx/resolution,
    b.latitude= maxy - b.y*dy/resolution;
  end brinkhoff_nodes;

  procedure nnode_ofpoi(tblnodes varchar2, tblpois varchar2)
  is
  /*
  This procedure updates pois table with the nearest network
  node id for each poi.
  */
   n_node_id number;
  begin
    for c_poi in (select id, name, type, longitude, latitude, x, y, nn_node_id
                 from brinkhoff_pois) loop
      select bn.id
      into n_node_id
      from brinkhoff_nodes bn
      where sdo_nn(get_long_lat_pt (bn.longitude, bn.latitude,4326),
            get_long_lat_pt (c_poi.longitude, c_poi.latitude,4326),
            'sdo_num_res=1') = 'TRUE';

      update brinkhoff_pois bp
      set bp.nn_node_id = n_node_id
      where bp.id = c_poi.id;
      commit;
    end loop;
  end nnode_ofpoi;

  procedure output_propsfile(infilename varchar2,sem_trajs varchar2,poitable varchar2,
    nodestable varchar2)
  is
  /*
  */
    l_file utl_file.file_type;
    l_line   VARCHAR2(1000);
    filename varchar2(100);
    stmt varchar2(4000);
    semtrajstab sem_trajectory_tab;--expect few profiles
    episodes sem_episode_tab;
    first_episode sem_episode;last_episode sem_episode;
    ageom mdsys.sdo_geometry;
    startx number; starty number;
    nnode_id number;
    endx number; endy number;
    legs number;tmp number:=0;
    stopx number;stopy number;
  begin
    stmt :='begin select value(b) bulk collect into :semtrajstab from '||sem_trajs||' b;end;';
    execute immediate stmt using out semtrajstab;
    filename := infilename||'Pros.txt';
    l_file   := utl_file.fopen('IO', filename, 'W');
    l_line:='Time: 1000';--you can change that
    utl_file.put_line(l_file, l_line);
    l_line:='Object_Classes: '||semtrajstab.count||chr(9)||'External_Object_Classes: 0';
    utl_file.put_line(l_file, l_line);
    l_line:='External_Objects_Begin: 0'||chr(9)||'External_Object_per_Timestamp: 0';
    utl_file.put_line(l_file, l_line);
    l_line:='Report_Propability: 100';
    utl_file.put_line(l_file, l_line);

    for i in semtrajstab.first..semtrajstab.last loop--each profile is a class
      episodes := semtrajstab(i).timeorderepisodes();
      l_line:=chr(9)||'Class '||i; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Starting_Objects: 5'; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Objects_per_TimeStamp: 0'; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Maximum_Speed: 500'; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Class_Speed_Agility: 0'; utl_file.put_line(l_file, l_line);
      first_episode := episodes(episodes.first);
      --get the nearest node_id(from nearest poi) to episode centroid with episode_tag
      --MIND THAT IN USER_SDO_GEOM_METADATA SRID IS DECLARED 4326
      --get the centroid of the episode
      ageom := sdo_geom.sdo_centroid(first_episode.mbb.getrectangle(semtrajstab(i).srid),0.005);
      begin
        select p.nn_node_id into nnode_id
        from brinkhoff_pois p
        where sdo_nn(get_long_lat_pt(p.longitude,p.latitude,4326),
              ageom,'sdo_batch_size=10')='TRUE'
        and p.type = first_episode.episode_tag and rownum<2;

        exception when no_data_found then
          nnode_id:=-1;--or get nearest node without poi
      end;
      /*
      --in get_long_lat_pt(p.longitude,p.latitude,4326),
      stmt :='begin select p.nn_node_id into :nnode_id
        from '||poitable||' p
        where sdo_nn(p.poi_geom,:ageom,''sdo_batch_size=10'')=''TRUE''
        and p.type = :episode_tag and rownum<2;end;';
      */
      --get the brinkhoff coords of nnode_id
      stmt :='begin select n.x,n.y into :startx,:starty from '||nodestable||' n where n.id = :nnode_id;end;';
      begin
        execute immediate stmt using out startx, out starty,in nnode_id;
        exception when no_data_found then
          startx:=-1;--or ...
          starty:=-1;--or ...
      end;
      l_line:=chr(9)||'Class_'||i||' Starting_Position: X: '||startx||chr(9)||'Y: '||starty; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Starting_Position_Range: 20'; utl_file.put_line(l_file, l_line);
      last_episode := episodes(episodes.last);
      --get the nearest node_id(from nearest poi) to episode centroid with episode_tag
      --MIND THAT IN USER_SDO_GEOM_METADATA SRID IS DECLARED 4326
      --get the centroid of the episode
      ageom := sdo_geom.sdo_centroid(last_episode.mbb.getrectangle(semtrajstab(i).srid),0.005);
      begin
        select p.nn_node_id into nnode_id
        from brinkhoff_pois p
        where sdo_nn(get_long_lat_pt(p.longitude,p.latitude,4326),
              ageom,'sdo_batch_size=10')='TRUE'
        and p.type = last_episode.episode_tag and rownum<2;

        exception when no_data_found then
          nnode_id:=-1;--or get nearest node without poi
      end;
      --get the brinkhoff coords of nnode_id
      stmt :='begin select n.x,n.y into :endx,:endy from '||nodestable||' n where n.id = :nnode_id;end;';
      begin
        execute immediate stmt using out endx, out endy, in nnode_id;
        exception when no_data_found then
          endx:=-1;--or ...
          endy:=-1;--or ...
      end;
      l_line:=chr(9)||'Class_'||i||' Ending_Position: X: '||endx||chr(9)||'Y: '||endy; utl_file.put_line(l_file, l_line);
      l_line:=chr(9)||'Class_'||i||' Ending_Position_Range: 20'; utl_file.put_line(l_file, l_line);
      --get the number of in between stops
      legs := semtrajstab(i).num_of_stops() - 2;
      l_line:=chr(9)||'Class_'||i||' Legs_Number: '||legs; utl_file.put_line(l_file, l_line);
      tmp:=0;
      for e in episodes.first..episodes.last loop
          if (e = episodes.first or e = episodes.last or upper(episodes(e).defining_tag) = upper('MOVE')) then
              continue;
          end if;
          tmp:=tmp+1;
          l_line:=chr(9)||chr(9)||'Class_'||i||' Stop_'||tmp; utl_file.put_line(l_file, l_line);
          --get the nearest node_id(from nearest poi) to episode centroid with episode_tag
          --MIND THAT IN USER_SDO_GEOM_METADATA SRID IS DECLARED 4326
          ageom := sdo_geom.sdo_centroid(episodes(e).mbb.getrectangle(semtrajstab(i).srid),0.005);
          begin
            select p.nn_node_id into nnode_id
            from brinkhoff_pois p
            where sdo_nn(get_long_lat_pt(p.longitude,p.latitude,4326),
                  ageom,'sdo_batch_size=10')='TRUE'
            and p.type = episodes(e).episode_tag and rownum<2;

            exception when no_data_found then
              nnode_id:=-1;--or get nearest node without poi
          end;
          --get the brinkhoff coords of nnode_id
          stmt :='begin select n.x,n.y into :stopx,:stopy from '||nodestable||' n where n.id = :nnode_id;end;';
          begin
            execute immediate stmt using out stopx, out stopy, in nnode_id;
            exception when no_data_found then
              stopx:=-1;--or ...
              stopy:=-1;--or ...
          end;
          l_line:=chr(9)||chr(9)||'Class_'||i||' Stop'||tmp||' Position: X: '||stopx||chr(9)||'Y: '||stopy; utl_file.put_line(l_file, l_line);
          l_line:=chr(9)||chr(9)||'Class_'||i||' Stop'||tmp||' Position_Range: 20'; utl_file.put_line(l_file, l_line);
          l_line:=chr(9)||chr(9)||'Class_'||i||' Stop'||tmp||' Max_Speed_to_Next_Stop: 200'; utl_file.put_line(l_file, l_line);
          l_line:=chr(9)||chr(9)||'Class_'||i||' Stop'||tmp||' Speed_Agility: 0'; utl_file.put_line(l_file, l_line);
      end loop;
    end loop;
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
  end output_propsfile;

  procedure brinkhoff2semtrajs(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer, from_id number, to_id number)
  is
    brink_cv sys_refcursor;
    query varchar2(4000);
    defining_tag varchar2(30);episode_tag varchar2(50);activity_tag varchar2(50);
    EPISODESEMS varchar2(1500);
    chartime varchar2(200);
    timechar timestamp;
    type gpsin_typ is record(
         id integer,
         profile_id integer,
         EPISODESEMS varchar2(1500),
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
    old_curtimepoint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    old_x number;    old_y number;

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
    --query should be changed based on input
    --query:='select t.id,t.EPISODESEMS, t.realx x, t.realy y from '||brink_output||' t
    query:='select t.moid,t.mpid,t.EPISODESEMS, t.realx x, t.realy y from '||brink_output||' t
        where t.edgeid<>-1
        --and t.scenarioid = 1
        and t.moid between '||from_id||' and '||to_id||'
        order by t.moid, t.realtime';
    open brink_cv for query;
    loop
      fetch brink_cv bulk collect into gpsin limit 100000;

      for indx in gpsin.first..gpsin.last loop
        EPISODESEMS := upper(gpsin(indx).EPISODESEMS);
        defining_tag := substr(EPISODESEMS,instr(EPISODESEMS, ';',1,2)+1,instr(EPISODESEMS, ';',1,3) - (instr(EPISODESEMS, ';',1,2)+1));
        episode_tag := substr(EPISODESEMS,instr(EPISODESEMS, ';',1,3)+1,instr(EPISODESEMS, ';',1,4) - (instr(EPISODESEMS, ';',1,3)+1));
        activity_tag := substr(EPISODESEMS,instr(EPISODESEMS, ';',1,4)+1);
        if (Instr(defining_tag, 'STOP')<>0) then
          defining_tag:='STOP';
        else
          defining_tag:='MOVE';
        end if;
        cur_episode_id:= substr(EPISODESEMS,1,instr(EPISODESEMS, ';',1,1) - 1);--hermoupolis starts episodes from 1 on...
        chartime := substr(EPISODESEMS, instr(EPISODESEMS, ';',1,1)+1, instr(EPISODESEMS, ';',1,2) - (instr(EPISODESEMS, ';',1,1)+1));
        timechar := to_timestamp(chartime,'YYYY-MM-DD HH24:MI:SS.FF');
        cur_timepoint:= to_timepoint(timechar);
        --
        if ( cur_timepoint.f_eq(cur_timepoint,old_curtimepoint)=1 ) then
          dbms_output.put_line('discard point with sems:'||EPISODESEMS);
          continue;
        end if;
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
          cur_semtraj:=sem_trajectory(null,srid,sem_episode_tab(),gpsin(indx).id,gpsin(indx).id,gpsin(indx).profile_id);
          --new episode
          cur_episode:=sem_episode(defining_tag,episode_tag,activity_tag,null,null);
          --new sub_mpoint with start point filled
          unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(cur_timepoint,null),unit_function(gpsin(indx).x,gpsin(indx).y,null,null,null,null,null,null,null,'PLNML_1'));
          cur_submpoint:=sub_moving_point(gpsin(indx).id,gpsin(indx).id,cur_episode_id,moving_point(moving_point_tab(unit_mpoint),gpsin(indx).id,srid));
        else --old_id=cur_id=>same semtraj
          --old_episode<>cur_episode=>new episode
          if (old_episode_id<>cur_episode_id) then
            --store cur_submpoint if not null(store cur_submpoint[remove last uncomplete segment], make it episode,add episode to cur_semtraj.episodes)
            cur_submpoint.sub_mpoint.u_tab.trim;
            if (cur_submpoint.sub_mpoint.u_tab.count=0) then
              dbms_output.put_line('Found an episode with only one gps point when new episode! A sub trajectory can not be created!');
              dbms_output.put_line('Object_id='||old_id||', Trajectory_id='||old_id||', Episode_id='||old_episode_id);
            end if;
            storeit(cur_submpoint,sub_mpoints_out,cur_episode);
            --create new cur_episode()
            cur_episode:=sem_episode(defining_tag,upper(episode_tag),upper(activity_tag),null,null);
            --new sub_mpoint with start point filled
            unit_mpoint:=unit_moving_point(tau_tll.d_period_sec(old_curtimepoint, cur_timepoint),unit_function(old_x, old_y, gpsin(indx).x,gpsin(indx).y,null,null,null,null,null,'PLNML_1'));
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
        old_curtimepoint := cur_timepoint;
        old_x:= gpsin(indx).x;
        old_y:= gpsin(indx).y;
      end loop;
      exit when brink_cv%notfound;
    end loop;
    close brink_cv;
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
    exception when others then
      dbms_output.put_line(chartime);
      dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
  end brinkhoff2semtrajs;

begin
  -- Initialization
  null;
end brinkhoff;
/


