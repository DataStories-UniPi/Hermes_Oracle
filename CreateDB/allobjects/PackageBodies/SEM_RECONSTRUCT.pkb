Prompt Package Body SEM_RECONSTRUCT;
CREATE OR REPLACE PACKAGE body        sem_reconstruct
AS
PROCEDURE stopfinderinputfile(
    o_id pls_integer,
    traj_id pls_integer,
    mpoint moving_point,
    subtraj_id pls_integer:=0)
IS
  /*
  This procedure takes as input one moving_point with its object_id,trajectory_id
  and an optional sub-trjectory_id. It outputs a .dat file in the IO directory
  (where user must have read-write) in the form that is needed from t-optics
  stopfinder. It can be called multiple time in a pl/sql loop block, to output
  many trajectories.
  example:
  for cur in ( select b.o_id,b.traj_id,b.sub_mpoint,b.subtraj_id
  from belg_sub_mpoints b
  where b.o_id=5238 and b.traj_id=3) loop
  sem_reconstruct.stopfinderinputfile(cur.o_id,cur.traj_id,cur.sub_mpoint,cur.subtraj_id);
  end loop;
  */
  l_file utl_file.file_type;
  l_line   VARCHAR2(1000);
  filename VARCHAR2(50);
  utab moving_point_tab;
BEGIN
  filename := 'u'||o_id||'t'||traj_id||'sub'||subtraj_id||'.dat';
  l_file   := utl_file.fopen('IO', filename, 'W');
  --l_line:='X Y V T Cluster';
  l_line:='X Y T';
  utl_file.put_line(l_file, l_line);
  utab:= mpoint.u_tab;
  FOR i IN utab.first..utab.last
  loop
    l_line:=replace(ROUND(utab(i).m.xi,6),',','.')||' ' ||replace(ROUND(utab(i).m.yi,6),',','.')||' '||
    /*round(utab(i).get_speed(tau_tll.d_timepoint_sec(utab(i).p.b.m_y, utab(i).p.b.m_m,
    utab(i).p.b.m_d,utab(i).p.b.m_h,utab(i).p.b.m_min,utab(i).p.b.m_sec)),4)||' '||*/
    tau_tll.d_timepoint_sec(utab(i).p.b.m_y, utab(i).p.b.m_m,utab(i).p.b.m_d,
      utab(i).p.b.m_h,utab(i).p.b.m_min, utab(i).p.b.m_sec).get_abs_date()--||' '||0
    ;
    utl_file.put_line(l_file, l_line);
  end loop;
  --also the last point replace(x,',','.')
  l_line:=replace(ROUND(utab(utab.last).m.xe,6),',','.')||' ' ||replace(ROUND(utab(utab.last).m.ye,6),',','.')||' '||
  /*round(utab(utab.last).get_speed(tau_tll.d_timepoint_sec(utab(utab.last).p.e.m_y, utab(utab.last).p.e.m_m,
  utab(utab.last).p.e.m_d,utab(utab.last).p.e.m_h,utab(utab.last).p.e.m_min,utab(utab.last).p.e.m_sec)),4)||' '||*/
  tau_tll.d_timepoint_sec(utab(utab.last).p.e.m_y, utab(utab.last).p.e.m_m,
    utab(utab.last).p.e.m_d,utab(utab.last).p.e.m_h,utab(utab.last).p.e.m_min, utab(utab.last).p.e.m_sec).get_abs_date()--||' '||0
  ;
  utl_file.put_line(l_file, l_line);
  utl_file.fflush(l_file);
  utl_file.fclose(l_file);
end stopfinderinputfile;

PROCEDURE stops2semtrajs( inputtblstopseqs    VARCHAR2, inputtblsemmpoints  VARCHAR2,
    outputtblsubmpoints VARCHAR2, outputtblsemmpoints VARCHAR2)
IS
  /*
  This procedure takes as input a table name of stops found from T-optics stopfinder,
  a table name of semantic trajectories on which stopfinder run and two output tables
  for sub-trajectories and semantic trajectories. It transforms semantic trajectories to
  semantic trajectories based on the T-Optics findings.(if extra stops found then
  stop episodes are introduced to semantic trajectories).
  */
  query VARCHAR2(5000);
  cursemtraj sem_trajectory     :=NULL;
  outsemtrajs sem_trajectory_tab:=sem_trajectory_tab();
  insemtrajs sem_trajectory_tab;
  newepisode sem_episode;
  curepisode sem_episode;
  cursubmpoint sub_moving_point;
  trajs_cv sys_refcursor;
  utabptr pls_integer;
  episode_mpoint sub_moving_point;
  numOfStops pls_integer :=0;
  numOfPoints pls_integer:=0;
  refcv sys_refcursor;
  refer ref sub_moving_point;
type stoppoints_typ
IS
  TABLE OF NUMBER INDEX BY pls_integer;
  stoppoints stoppoints_typ;
  stopptr pls_integer;
  episodecounter pls_integer  :=0;
  onlyOneStopOnePoint BOOLEAN :=false;
PROCEDURE storeit(
    submpoint sub_moving_point,
    episode sem_episode)
IS
BEGIN
  --insert into sub_moving_point
  EXECUTE immediate 'insert into '||outputtblsubmpoints||' values(:sub_traj)' USING IN submpoint;
  COMMIT;
  --take a ref
  query := 'select ref(t) from '||outputtblsubmpoints||' t
where t.o_id='||submpoint.o_id||'
and t.traj_id='||submpoint.traj_id||'
and t.subtraj_id='||submpoint.subtraj_id ;
  OPEN refcv FOR query;
  FETCH refcv INTO refer;
  CLOSE refcv;
  newepisode:=sem_episode(episode.defining_tag,episode.episode_tag, episode.activity_tag,episode.mbb,refer);
  cursemtraj.episodes.extend(1);
  cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
END storeit;
BEGIN
  EXECUTE immediate 'delete ' || outputtblsubmpoints || ' t';
  COMMIT;
  EXECUTE immediate 'delete ' || outputtblsemmpoints || ' t';
  COMMIT;
  query := 'select value(t)
from ' || inputtblsemmpoints || ' t
where t.o_id=5026 and t.semtraj_id=1
order by t.o_id, t.semtraj_id';
  OPEN trajs_cv FOR query;
  LOOP
    FETCH trajs_cv bulk collect INTO insemtrajs limit 10;
    EXIT
  WHEN insemtrajs.count=0;
    FOR indx IN 1 .. insemtrajs.count
    LOOP
      cursemtraj:=sem_trajectory( insemtrajs(indx).sem_trajectory_tag, insemtrajs(indx).srid, sem_episode_tab(),--empty
      insemtrajs(indx).o_id, insemtrajs(indx).semtraj_id, insemtrajs(indx).profile_id);
      episodecounter:=0;
      FOR e IN insemtrajs(indx).episodes.first..insemtrajs(indx).episodes.last
      LOOP
        SELECT deref(insemtrajs(indx).episodes(e).tlink)
        INTO episode_mpoint
        FROM dual;
        IF insemtrajs(indx).episodes(e).defining_tag='STOP' THEN
          --store episode
          episodecounter           :=episodecounter+1;
          episode_mpoint.subtraj_id:=episodecounter;
          storeit(episode_mpoint,insemtrajs(indx).episodes(e));
        ELSE--move episode
          utabptr:=1;
          query  :='begin
select count(distinct bs.stopid)
into :numOfStops
from '||inputtblstopseqs||' bs
where bs.userid='||episode_mpoint.o_id||'
and bs.trajid='||episode_mpoint.traj_id||'
and bs.subtrajid='||episode_mpoint.subtraj_id||';end;';
          EXECUTE immediate query USING OUT numofstops;
          IF numOfStops > 0 THEN--if stops found
            --break episode
            FOR STOP IN 1..numOfStops
            LOOP--for every stop found
              stopptr:=1;
              query  :='begin
select count(bs.t)--assumes distinct gps times for points
into :numOfPoints--take numOfPoints for stop
from '||inputtblstopseqs||' bs
where bs.userid='||episode_mpoint.o_id||'
and bs.trajid='||episode_mpoint.traj_id||'
and bs.subtrajid='||episode_mpoint.subtraj_id||'
and bs.stopid='||STOP||';end;';--assumes continuation in stop numbering
              EXECUTE immediate query USING OUT numofpoints;
              IF numOfPoints        >1 THEN--if stop has more than 1 points
                onlyonestoponepoint:=false;
                query              :='
select bs.t--take times of stop
from '||inputtblstopseqs||' bs
where bs.userid=:episode_mpointo_id
and bs.trajid=:episode_mpointtraj_id
and bs.subtrajid=:episode_mpointsubtraj_id
and bs.stopid=:stop
order by bs.t';--t-optics ensures time ordering
                OPEN refcv FOR query USING IN episode_mpoint.o_id,
                                           IN episode_mpoint.traj_id,
                                           IN episode_mpoint.subtraj_id,
                                           in stop;
                FETCH refcv bulk collect INTO stoppoints;--bulk collect without limit
                CLOSE refcv;
                --loop through episode sub mpoint utab and stop points
                WHILE (utabptr <= episode_mpoint.sub_mpoint.u_tab.last AND stopptr <= numOfPoints)
                LOOP
                  IF (episode_mpoint.sub_mpoint.u_tab(utabptr).p.b.get_abs_date() < stoppoints(stopptr)) THEN
                    IF utabptr                                                    =1 THEN
                      episodecounter                                             :=episodecounter+1;
                      cursubmpoint :=sub_moving_point(episode_mpoint.o_id, episode_mpoint.traj_id,episodecounter,
                        moving_point(moving_point_tab(),--empty
                      episode_mpoint.traj_id,insemtrajs(indx).srid));
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                      curepisode := sem_episode('MOVE', insemtrajs(indx).episodes(e).episode_tag,
                        insemtrajs(indx).episodes(e).activity_tag, NULL,NULL);
                    ELSE
                      IF stopptr                  =1 THEN
                        IF curepisode.defining_tag='STOP' THEN
                          episodecounter         :=episodecounter+1;
                          cursubmpoint           :=sub_moving_point(episode_mpoint.o_id, episode_mpoint.traj_id,episodecounter,
                            moving_point(moving_point_tab(),--empty
                          episode_mpoint.traj_id,insemtrajs(indx).srid));
                          cursubmpoint.sub_mpoint.u_tab.extend(1);
                          cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                          curepisode                                                        := sem_episode('MOVE',NULL,NULL,NULL,NULL);
                        ELSE
                          cursubmpoint.sub_mpoint.u_tab.extend(1);
                          cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                        END IF;
                      ELSE
                        IF curepisode.defining_tag='STOP' THEN
                          cursubmpoint.sub_mpoint.u_tab.extend(1);
                          cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                        ELSE--move episode
                          cursubmpoint.sub_mpoint.u_tab.extend(1);
                          cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                          dbms_output.put_line('pass'||indx||','||e||','||STOP|| ','||utabptr||','||stopptr);
                        END IF;
                      END IF;
                    END IF;
                    utabptr                                                         :=utabptr+1;
                  elsif (episode_mpoint.sub_mpoint.u_tab(utabptr).p.b.get_abs_date() = stoppoints(stopptr)) THEN
                    IF utabptr                                                       =1 THEN
                      episodecounter :=episodecounter+1;
                      cursubmpoint :=sub_moving_point(episode_mpoint.o_id, episode_mpoint.traj_id,episodecounter,
                        moving_point(moving_point_tab(),--empty
                      episode_mpoint.traj_id,insemtrajs(indx).srid));
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                      curepisode                                                        := sem_episode('STOP',NULL,NULL,NULL,NULL);
                    ELSE
                      IF curepisode.defining_tag='STOP' THEN
                        cursubmpoint.sub_mpoint.u_tab.extend(1);
                        cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                      ELSE--move
                        curepisode.MBB:=cursubmpoint.getsemmbb();
                        storeit(cursubmpoint,curepisode);
                        episodecounter:=episodecounter+1;
                        cursubmpoint  :=sub_moving_point(episode_mpoint.o_id, episode_mpoint.traj_id,episodecounter,
                          moving_point(moving_point_tab(),--empty
                        episode_mpoint.traj_id,insemtrajs(indx).srid));
                        cursubmpoint.sub_mpoint.u_tab.extend(1);
                        cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                        curepisode                                                        := sem_episode('STOP',NULL,NULL,NULL,NULL);
                      END IF;
                    END IF;
                    utabptr                                                         :=utabptr+1;
                    stopptr                                                         :=stopptr+1;
                  elsif (episode_mpoint.sub_mpoint.u_tab(utabptr).p.b.get_abs_date() > stoppoints(stopptr)) then
                    --stopptr has left behind, not a normal state
                    NULL;--error as while should ended
                  END IF;
                END LOOP;
                curepisode.MBB:=cursubmpoint.getsemmbb();
                storeit(cursubmpoint,curepisode);
              ELSE                    --stop has only 1 point (or less?)
                IF numOfStops = 1 THEN--this was the only stop found
                  --store episode as is
                  episodecounter           :=episodecounter+1;
                  episode_mpoint.subtraj_id:=episodecounter;
                  storeit(episode_mpoint,insemtrajs(indx).episodes(e));
                  onlyOneStopOnePoint:=true;
                END IF;
              END IF;
            END LOOP;
            --rest episode sub point points to a move episode
            IF (utabptr     <= episode_mpoint.sub_mpoint.u_tab.last) AND onlyOneStopOnePoint=false THEN
              episodecounter:=episodecounter+1;
              cursubmpoint  :=sub_moving_point(episode_mpoint.o_id, episode_mpoint.traj_id,episodecounter,
                moving_point(moving_point_tab(),--empty
              episode_mpoint.traj_id,insemtrajs(indx).srid));
              cursubmpoint.sub_mpoint.u_tab.extend(1);
              cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
              curepisode                                                        := sem_episode('MOVE',NULL,NULL,NULL,NULL);
              utabptr                                                           :=utabptr+1;
              WHILE (utabptr                                                    <= episode_mpoint.sub_mpoint.u_tab.last)
              LOOP
                cursubmpoint.sub_mpoint.u_tab.extend(1);
                cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= episode_mpoint.sub_mpoint.u_tab(utabptr);
                utabptr                                                           :=utabptr+1;
              END LOOP;
              curepisode.MBB:=cursubmpoint.getsemmbb();
              storeit(cursubmpoint,curepisode);
            END IF;
          ELSE
            --store it as is
            episodecounter           :=episodecounter+1;
            episode_mpoint.subtraj_id:=episodecounter;
            storeit(episode_mpoint,insemtrajs(indx).episodes(e));
          END IF;
        END IF;
        --next episode of input sem trajectory
      END LOOP;
      outsemtrajs.extend(1);
      outsemtrajs(outsemtrajs.last):=cursemtraj;
      --next input sem trajectory
    END LOOP;
    --next bulk fetch
  END LOOP;
  CLOSE trajs_cv;
  --insert trajectories
  EXECUTE immediate 'insert into '||outputtblsemmpoints||'
select sem_trajectory(t.sem_trajectory_tag,t.srid,t.episodes,t.o_id,t.semtraj_id)
from table(:semtrajs) t' USING IN outsemtrajs;
  COMMIT;
end stops2semtrajs;


PROCEDURE rawtrajs2semtrajs(
    inputtblstopseqs    VARCHAR2,
    inputtblmpoints     VARCHAR2,
    outputtblsubmpoints VARCHAR2,
    outputtblsemmpoints VARCHAR2)
IS
/*
  This procedure takes as input a table name of stops found from T-optics stopfinder,
  a table name of raw trajectories on which stopfinder run and two output tables
  for sub-trajectories and semantic trajectories. It transforms raw trajectories to
  semantic trajectories based on the T-Optics findings (raw trajectories are broken
  to episodes based on stop sub trajectories found by T-Optics).
  */
  query VARCHAR2(5000);
  cursemtraj sem_trajectory     :=NULL;
  outsemtrajs sem_trajectory_tab:=sem_trajectory_tab();
type intrajs_typ
IS
  record
  (
    object_id INTEGER,
    mpoint moving_point);
type intrajs_tab
IS
  TABLE OF intrajs_typ;
  intrajs intrajs_tab;
  newepisode sem_episode;
  curepisode sem_episode;
  cursubmpoint sub_moving_point;
  trajs_cv sys_refcursor;
  utabptr pls_integer;
  numOfStops pls_integer :=0;
  numOfPoints pls_integer:=0;
  refcv sys_refcursor;
  refer ref sub_moving_point;
type stoppoints_typ
IS
  TABLE OF NUMBER INDEX BY pls_integer;
  stoppoints stoppoints_typ;
  stopptr pls_integer;
  episodecounter pls_integer  :=0;
  onlyOneStopOnePoint BOOLEAN :=false;
PROCEDURE storeit(
    submpoint sub_moving_point,
    episode sem_episode)
IS
BEGIN
  /*
  this inner procedure takes a sub_moving_point and an episode.Stores the
  sub_moving_point and adds the updated episode to current semantic
  trajectory.
  */
  --insert into sub_moving_point
  EXECUTE immediate 'insert into '||outputtblsubmpoints||' values(:sub_traj)' USING IN submpoint;
  COMMIT;
  --take a ref
  query := 'select ref(t) from '||outputtblsubmpoints||' t
where t.o_id='||submpoint.o_id||'
and t.traj_id='||submpoint.traj_id||'
and t.subtraj_id='||submpoint.subtraj_id ;
  OPEN refcv FOR query;
  FETCH refcv INTO refer;
  CLOSE refcv;
  newepisode:=sem_episode(episode.defining_tag,episode.episode_tag, episode.activity_tag,episode.mbb,refer);
  cursemtraj.episodes.extend(1);
  cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
END storeit;
BEGIN
  --clear output tables
  EXECUTE immediate 'delete ' || outputtblsubmpoints || ' t';
  COMMIT;
  EXECUTE immediate 'delete ' || outputtblsemmpoints || ' t';
  COMMIT;
  --get input moving_points
  query := 'select t.object_id,t.mpoint
from ' || inputtblmpoints || ' t
--where t.object_id=5026 and t.traj_id=1
order by t.object_id, t.traj_id';

  OPEN trajs_cv FOR query;
  LOOP
    FETCH trajs_cv bulk collect INTO intrajs limit 10;--f..ing memory
    EXIT
  WHEN intrajs.count=0;
    --for each moving_point (raw trajectory)
    FOR indx IN 1 .. intrajs.count
    LOOP
      --create a semantic trajectory
      cursemtraj:=sem_trajectory( NULL, intrajs(indx).mpoint.srid, sem_episode_tab(),--empty
      intrajs(indx).object_id, intrajs(indx).mpoint.traj_id, intrajs(indx).object_id);
      --episodes none
      episodecounter:=0;
      --pointer to utab of moving_point
      utabptr:=1;
      --get number of stops for moving_point
      query:='begin
select count(distinct bs.stopid)
into :numOfStops
from '||inputtblstopseqs||' bs
where bs.userid='||intrajs(indx).object_id||'
and bs.trajid='||intrajs(indx).mpoint.traj_id||';end;';

      EXECUTE immediate query USING OUT numofstops;
      IF numOfStops > 0 THEN--if stops found
        --break trajectory
        FOR STOP IN 1..numOfStops
        LOOP--for every stop found
          stopptr:=1;
          --get number of points in that stop
          query:='begin
select count(bs.t)--assumes distinct gps times for points
into :numOfPoints--take numOfPoints for stop
from '||inputtblstopseqs||' bs
where bs.userid='||intrajs(indx).object_id||'
and bs.trajid='||intrajs(indx).mpoint.traj_id||'
and bs.stopid='||STOP||';end;';--assumes continuation in stop numbering

          EXECUTE immediate query USING OUT numofpoints;
          IF numOfPoints        >1 THEN--if stop has more than 1 points
            onlyonestoponepoint:=false;
            query              :='
select bs.t--take times of stop
from '||inputtblstopseqs||' bs
where bs.userid=:episode_mpointo_id
and bs.trajid=:episode_mpointtraj_id
and bs.stopid=:stop
order by bs.t';--t-optics ensures time ordering

            OPEN refcv FOR query USING IN intrajs(indx).object_id,
                                       IN intrajs(indx).mpoint.traj_id,
                                       IN STOP;
            FETCH refcv bulk collect INTO stoppoints;
            CLOSE refcv;
            --loop through mpoint utab and stop points
            WHILE (utabptr <= intrajs(indx).mpoint.u_tab.last AND stopptr <= numofpoints)
            LOOP
              --if time of utab less than time of point in stop
              IF (intrajs(indx).mpoint.u_tab(utabptr).p.b.get_abs_date() < stoppoints(stopptr)) THEN
                --if in first utab
                IF utabptr=1 THEN
                  --create a MOVE episode for current utab
                  episodecounter:=episodecounter+1;
                  cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, moving_point(moving_point_tab(),--empty
                  intrajs(indx).mpoint.traj_id,intrajs(indx).mpoint.srid));
                  cursubmpoint.sub_mpoint.u_tab.extend(1);
                  cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                  curepisode                                                        := sem_episode('MOVE',NULL,NULL, NULL,NULL);
                ELSE
                  --else if not in first utab then
                  --if at first point of stop
                  IF stopptr=1 THEN
                    --if we are in a stop episode
                    IF curepisode.defining_tag='STOP' THEN
                      --create a MOVE episode (remember times above)
                      episodecounter:=episodecounter+1;
                      cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, moving_point(moving_point_tab(),--empty
                      intrajs(indx).mpoint.traj_id,intrajs(indx).mpoint.srid));
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                      curepisode                                                        := sem_episode('MOVE',NULL,NULL,NULL,NULL);
                    ELSE
                      --else in MOVE episode then add utab
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                    END IF;
                  ELSE--else not in first point of stop
                    IF curepisode.defining_tag='STOP' THEN
                      --if in a stop episode then add utab
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                    ELSE--move episode then add utab
                      cursubmpoint.sub_mpoint.u_tab.extend(1);
                      cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                    END IF;
                  END IF;
                END IF;
                utabptr:=utabptr+1;--next utab
                --times of utab begin equals time of stop point
              elsif (intrajs(indx).mpoint.u_tab(utabptr).p.b.get_abs_date() = stoppoints(stopptr)) THEN
                --if in first utab
                IF utabptr=1 THEN
                  --we are in a stop episode so create it
                  episodecounter:=episodecounter+1;
                  cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, moving_point(moving_point_tab(),--empty
                  intrajs(indx).mpoint.traj_id,intrajs(indx).mpoint.srid));
                  cursubmpoint.sub_mpoint.u_tab.extend(1);
                  cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                  curepisode                                                        := sem_episode('STOP',NULL,NULL,NULL,NULL);
                ELSE--not in first utab then
                  IF curepisode.defining_tag='STOP' THEN
                    -- add utab if in stop episode
                    cursubmpoint.sub_mpoint.u_tab.extend(1);
                    cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                  ELSE--move
                    --store episode and create a new stop episode
                    curepisode.MBB:=cursubmpoint.getsemmbb();
                    storeit(cursubmpoint,curepisode);
                    episodecounter:=episodecounter+1;
                    cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, moving_point(moving_point_tab(),--empty
                    intrajs(indx).mpoint.traj_id,intrajs(indx).mpoint.srid));
                    cursubmpoint.sub_mpoint.u_tab.extend(1);
                    cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
                    curepisode                                                        := sem_episode('STOP',NULL,NULL,NULL,NULL);
                  END IF;
                END IF;
                utabptr                                                    :=utabptr+1;--next utab
                stopptr                                                    :=stopptr+1;--next stop point
              elsif (intrajs(indx).mpoint.u_tab(utabptr).p.b.get_abs_date() > stoppoints(stopptr)) THEN
                --else if time of utab is greater than time of point of stop
                NULL;--error as while should ended
              END IF;
            END LOOP;
            --store episode
            curepisode.MBB:=cursubmpoint.getsemmbb();
            storeit(cursubmpoint,curepisode);
          ELSE   --stop has only 1 point (or less?)
            NULL;--do nothing as this can not be modeled as sub_moving_point for now
            /*
            if numOfStops = 1 then--this was the only stop found
            --store episode as is
            episodecounter:=episodecounter+1;
            episode_mpoint.subtraj_id:=episodecounter;
            storeit(outputtblsubmpoints,episode_mpoint,insemtrajs(indx).episodes(e));
            onlyOneStopOnePoint:=true;
            end if;
            */
          END IF;
        END LOOP;--next stop found
        --rest episode sub point points to a move episode
        IF (utabptr     <= intrajs(indx).mpoint.u_tab.last) AND onlyOneStopOnePoint=false THEN
          episodecounter:=episodecounter+1;
          cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, moving_point(moving_point_tab(),--empty
          intrajs(indx).mpoint.traj_id,intrajs(indx).mpoint.srid));
          cursubmpoint.sub_mpoint.u_tab.extend(1);
          cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
          curepisode                                                        := sem_episode('MOVE',NULL,NULL,NULL,NULL);
          utabptr                                                           :=utabptr+1;
          WHILE (utabptr                                                    <= intrajs(indx).mpoint.u_tab.last)
          LOOP
            cursubmpoint.sub_mpoint.u_tab.extend(1);
            cursubmpoint.sub_mpoint.u_tab( cursubmpoint.sub_mpoint.u_tab.last):= intrajs(indx).mpoint.u_tab(utabptr);
            utabptr                                                           :=utabptr+1;
          END LOOP;
          curepisode.MBB:=cursubmpoint.getsemmbb();
          storeit(cursubmpoint,curepisode);
        END IF;
      ELSE
        --store it as one episode sem traj
        episodecounter:=episodecounter+1;
        cursubmpoint  :=sub_moving_point(intrajs(indx).object_id, intrajs(indx).mpoint.traj_id,episodecounter, intrajs(indx).mpoint);
        curepisode    := sem_episode('MOVE',NULL,NULL,NULL,NULL);
        storeit(cursubmpoint,curepisode);
      END IF;
      outsemtrajs.extend(1);
      outsemtrajs(outsemtrajs.last):=cursemtraj;
      --next input sem trajectory
    END LOOP;
    --next bulk fetch
  END LOOP;
  CLOSE trajs_cv;
  --insert trajectories
  EXECUTE immediate 'insert into '||outputtblsemmpoints||'
select sem_trajectory(t.sem_trajectory_tag,t.srid,t.episodes,t.o_id,t.semtraj_id)
from table(:semtrajs) t' USING IN outsemtrajs;
  COMMIT;
end rawtrajs2semtrajs;


procedure feathers2semtrajs(featherstab varchar2, subzonestab varchar2, outputtblsemmpoints VARCHAR2, from_person number, to_person number, srid integer:=8307) is
semtrajs sem_trajectory_tab:=sem_trajectory_tab();
cursemtraj sem_trajectory :=null;
feathers_row sys_refcursor;
type feather_typ is record(
  personid number,
  aday number,
  activitytype number,
  begintime number,
  aduration number,
  alocation number,
  tduration number,
  ttransportmode number
);
type feather_tab is table of feather_typ;
feathers feather_tab;mbb sem_mbb;mbb_geom sdo_geometry;
previous_person number:=-1; current_person number:=-1;current_semtrajid integer:=0;
newepisode sem_episode;stopactivity varchar2(50);moveactivity varchar2(50);
starttime timestamp := to_timestamp('01/01/2013 00:00:00','DD/MM/YYYY HH24:MI:SS');
episodebegintime timestamp;hournum number;minutenum number;episodeendtime timestamp;
moveendtime timestamp; movebegintime timestamp;
current_stopactivity number:=-1;current_alocation number:=-1;
previous_stopactivity number:=-1; previous_alocation number:=-1;
tb tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
te tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
begin

  open feathers_row for 'select t.p_personcounter,t.a_day, t.a_activitytype, t.a_beginningtime, t.a_duration, t.a_location,
    t.t_duration, t.t_transportmode
    from '||featherstab||' t
    where t.p_personcounter between '||from_person||' and '||to_person||'
    order by t.p_personcounter,t.a_day,t.a_beginningtime';
  loop
    fetch feathers_row bulk collect into feathers limit 50000;
    exit when feathers.count=0;
    for i in feathers.first..feathers.last loop
      current_person := feathers(i).personid;
      current_stopactivity := feathers(i).activitytype;
      current_alocation := feathers(i).alocation;
      hournum := trunc(feathers(i).begintime/100);
      minutenum := feathers(i).begintime - (hournum*100);
      if (current_person=previous_person) then
        --this way we build one semantic trajectory per person for all days
        if (feathers(i).tduration <> -1) then
          --make move episode
          moveactivity := case feathers(i).ttransportmode when 1 then 'Car driver'
            when 3 then 'Slow' when 4 then 'Public transport' when 6 then 'Car passenger'
            end;

          episodebegintime:= starttime + numtodsinterval(feathers(i).aday-1, 'day')
            + numtodsinterval(hournum, 'hour')
            + numtodsinterval(minutenum, 'minute');

          moveendtime :=  episodebegintime;
          movebegintime := moveendtime - numtodsinterval(feathers(i).tduration,'minute');

          tb := tau_tll.d_timepoint_sec(extract(year from movebegintime),extract(month from movebegintime),extract(day from movebegintime),
            extract(hour from movebegintime),extract(minute from movebegintime),extract(second from movebegintime));
          te := tau_tll.d_timepoint_sec(extract(year from moveendtime),extract(month from moveendtime),extract(day from moveendtime),
            extract(hour from moveendtime),extract(minute from moveendtime),extract(second from moveendtime));
          --no spatial info for move
          mbb := sem_mbb(sem_st_point(null,null,tb),sem_st_point(null,null,te));

          newepisode:=sem_episode('MOVE', null, moveactivity, mbb, null);
          --add it
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
          --make stop episode
          stopactivity:= case current_stopactivity when 0 then 'Being at home'
            when 1 then 'Work' when 2 then 'Business' when 3 then 'Bring/get'
            when 4 then 'Shopping(daily)' when 5 then 'Shopping(non-daily)' when 6 then 'Services'
            when 7 then 'Social visits' when 8 then 'Leisure' when 9 then 'Touring'
            when 10 then 'Other' end;
          execute immediate 'begin select sdo_geom.sdo_mbr(s.geom)
            into :mbbgeom
            from '||subzonestab||' s
            where s.subzone0=:alocation ; end;'
            using out mbb_geom, in current_alocation;

          episodeendtime := episodebegintime + numtodsinterval(feathers(i).aduration,'minute');
          tb := tau_tll.d_timepoint_sec(extract(year from episodebegintime),extract(month from episodebegintime),extract(day from episodebegintime),
            extract(hour from episodebegintime),extract(minute from episodebegintime),extract(second from episodebegintime));
          te := tau_tll.d_timepoint_sec(extract(year from episodeendtime),extract(month from episodeendtime),extract(day from episodeendtime),
            extract(hour from episodeendtime),extract(minute from episodeendtime),extract(second from episodeendtime));

          mbb := sem_mbb(sem_st_point(mbb_geom.sdo_ordinates(1),mbb_geom.sdo_ordinates(2),tb),sem_st_point(mbb_geom.sdo_ordinates(3),mbb_geom.sdo_ordinates(4),te));

          newepisode:=sem_episode('STOP', null, stopactivity, mbb, null);
          --add it
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
        else--move episode is not preceded
          --merge with previous stop episode if same stop activity and alocation
          if ((previous_stopactivity = current_stopactivity)
            and (previous_alocation = current_alocation)) then
            --extend last stop episode end time

            episodebegintime:= starttime + numtodsinterval(feathers(i).aday-1, 'day')
              + numtodsinterval(hournum, 'hour')
              + numtodsinterval(minutenum, 'minute');
            episodeendtime := episodebegintime + numtodsinterval(feathers(i).aduration,'minute');
            te := tau_tll.d_timepoint_sec(extract(year from episodeendtime),extract(month from episodeendtime),extract(day from episodeendtime),
              extract(hour from episodeendtime),extract(minute from episodeendtime),extract(second from episodeendtime));
            cursemtraj.episodes(cursemtraj.episodes.last).mbb.maxpoint.t:= te;
          else
            --make a new stop episode without a previous move episode. Hope its rare
            stopactivity:= case current_stopactivity when 0 then 'Being at home'
              when 1 then 'Work' when 2 then 'Business' when 3 then 'Bring/get'
              when 4 then 'Shopping(daily)' when 5 then 'Shopping(non-daily)' when 6 then 'Services'
              when 7 then 'Social visits' when 8 then 'Leisure' when 9 then 'Touring'
              when 10 then 'Other' end;
            execute immediate 'begin select sdo_geom.sdo_mbr(s.geom)
              into :mbbgeom
              from '||subzonestab||' s
              where s.subzone0=:alocation ; end;'
              using out mbb_geom, in current_alocation;

            episodebegintime:= starttime + numtodsinterval(feathers(i).aday-1, 'day')
              + numtodsinterval(hournum, 'hour')
              + numtodsinterval(minutenum, 'minute');
            episodeendtime := episodebegintime + numtodsinterval(feathers(i).aduration,'minute');
            tb := tau_tll.d_timepoint_sec(extract(year from episodebegintime),extract(month from episodebegintime),extract(day from episodebegintime),
              extract(hour from episodebegintime),extract(minute from episodebegintime),extract(second from episodebegintime));
            te := tau_tll.d_timepoint_sec(extract(year from episodeendtime),extract(month from episodeendtime),extract(day from episodeendtime),
              extract(hour from episodeendtime),extract(minute from episodeendtime),extract(second from episodeendtime));
            mbb := sem_mbb(sem_st_point(mbb_geom.sdo_ordinates(1),mbb_geom.sdo_ordinates(2),tb),sem_st_point(mbb_geom.sdo_ordinates(3),mbb_geom.sdo_ordinates(4),te));

            newepisode:=sem_episode('STOP', null, stopactivity, mbb, null);
            --add it
            cursemtraj.episodes.extend(1);
            cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
          end if;
        end if;
      else
        --store current_semtraj if not null
        if (cursemtraj is not null) then
          --semtrajs.extend(1);
          --semtrajs(semtrajs.last):=cursemtraj;
          EXECUTE immediate 'insert into '||outputtblsemmpoints||'
            values (:currsemtraj)' USING IN cursemtraj;
          COMMIT;
        end if;
        --new person=>new semtraj
        current_semtrajid:= 1;
        cursemtraj:=sem_trajectory( null, srid, sem_episode_tab(),current_person, current_semtrajid,current_person);--empty
        --we start with a stop as the first episode
        stopactivity:= case current_stopactivity when 0 then 'Being at home'
          when 1 then 'Work' when 2 then 'Business' when 3 then 'Bring/get'
          when 4 then 'Shopping(daily)' when 5 then 'Shopping(non-daily)' when 6 then 'Services'
          when 7 then 'Social visits' when 8 then 'Leisure' when 9 then 'Touring'
          when 10 then 'Other' end;
        execute immediate 'begin select sdo_geom.sdo_mbr(s.geom)
          into :mbbgeom
          from '||subzonestab||' s
          where s.subzone0=:alocation ; end;'
          using out mbb_geom, in current_alocation;

        hournum := trunc(feathers(i).begintime/100);
        minutenum := feathers(i).begintime - (hournum*100);
        episodebegintime:= starttime + numtodsinterval(feathers(i).aday-1, 'day')
          + numtodsinterval(hournum, 'hour')
          + numtodsinterval(minutenum, 'minute');
        episodeendtime := episodebegintime + numtodsinterval(feathers(i).aduration,'minute');
        tb := tau_tll.d_timepoint_sec(extract(year from episodebegintime),extract(month from episodebegintime),extract(day from episodebegintime),
          extract(hour from episodebegintime),extract(minute from episodebegintime),extract(second from episodebegintime));
        te := tau_tll.d_timepoint_sec(extract(year from episodeendtime),extract(month from episodeendtime),extract(day from episodeendtime),
          extract(hour from episodeendtime),extract(minute from episodeendtime),extract(second from episodeendtime));
        mbb := sem_mbb(sem_st_point(mbb_geom.sdo_ordinates(1),mbb_geom.sdo_ordinates(2),tb),sem_st_point(mbb_geom.sdo_ordinates(3),mbb_geom.sdo_ordinates(4),te));

        newepisode:=sem_episode('STOP', null, stopactivity, mbb, null);
        cursemtraj.episodes.extend(1);
        cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
      end if;
      previous_person := current_person;--move previous to current row
      previous_stopactivity := current_stopactivity;
      previous_alocation := current_alocation;
    end loop;--next row
  end loop;--next bulk fetch of rows
  close feathers_row;
  --store current_semtraj if not null
  if (cursemtraj is not null) then
    --semtrajs.extend(1);
    --semtrajs(semtrajs.last):=cursemtraj;
    EXECUTE immediate 'insert into '||outputtblsemmpoints||'
      values (:currsemtraj)' USING IN cursemtraj;
    COMMIT;
  end if;
  --insert trajectories
  /*
  EXECUTE immediate 'insert into '||outputtblsemmpoints||'
    select sem_trajectory(t.sem_trajectory_tag,t.srid,t.episodes,t.o_id,t.semtraj_id)
    from table(:semtrajs) t' USING IN semtrajs;
  COMMIT;
  */
end feathers2semtrajs;

procedure discoverepisodes(inputtblstopseqs    varchar2,inputtblmpoints     varchar2,
    outputtblsubmpoints varchar2,outputtblsmpoints   varchar2,outputtblfeatures   varchar2) is
    /*
    this procedure takes as input a table of stop points found and a table of moving points.
    It output a table of semantic trajectories and the corresponding sub moving points.
    It is like rawtrajs2semtrajs procedure.
    */
    olduserid  integer := -1;
    oldtrajid  integer := -1;
    oldstopid  integer := -1;
    sub_traj   sub_moving_point;
    sub_utab   moving_point_tab;
    subtraj_id integer;
    sem_traj   sem_trajectory := sem_trajectory(null,-1,sem_episode_tab(),-1,-1, -1);
    type semtrajectories_typ is table of sem_trajectory;
    semtrajectories semtrajectories_typ := semtrajectories_typ();
    trajs_cv        sys_refcursor;
    trajs_cv2       sys_refcursor;
    stops_cv        sys_refcursor;
    query           varchar2(5000);
    type trajs_rec is record(
      o_id    integer,
      traj_id integer,
      mpoint  moving_point);
    type trajs_typ is table of trajs_rec index by pls_integer;
    trajs trajs_typ;
    type stop_rec is record(
      userid    integer,
      trajid    integer,
      stopid    integer,
      numpoints integer);
    type stop_rec_tab is table of stop_rec;
    stops stop_rec_tab;
    refer ref sub_moving_point;
  begin
    execute immediate 'delete ' || outputtblsubmpoints || ' t';
    commit;
    execute immediate 'delete ' || outputtblsmpoints || ' t';
    commit;
    query := 'select t.object_id, t.traj_id, t.mpoint
                from ' || inputtblmpoints || ' t
                order by t.object_id, t.traj_id';
    /*
    query := 'select t.object_id, t.traj_id, t.mpoint
                from ' || view_left_trajs || ' t
                order by t.object_id, t.traj_id';
    */
    open trajs_cv2 for query;
    loop
      fetch trajs_cv2 bulk collect
        into trajs limit 10;
      for indx in 1 .. trajs.count loop
        sem_traj.o_id               := trajs(indx).o_id;
        sem_traj.semtraj_id         := trajs(indx).traj_id; --could be the same
        sem_traj.sem_trajectory_tag := null;
        sem_traj.srid               := trajs(indx).mpoint.srid;
        sem_traj.episodes           := sem_episode_tab();
        sem_traj.profile_id         := trajs(indx).o_id;

        execute immediate 'delete sub_mpoints t
          where t.o_id='||trajs(indx).o_id||'
          and t.traj_id='||trajs(indx).traj_id;
        commit;

        query := 'select t.userid, t.trajid, t.stopid, count(*) numpoints
                from ' || inputtblstopseqs || ' t
                where t.userid=' || trajs(indx).o_id || '
                and t.trajid=' || trajs(indx).traj_id || '
                group by t.userid, t.trajid, t.stopid
                order by t.userid, t.trajid, t.stopid';
        open stops_cv for query;
        loop
          fetch stops_cv bulk collect
            into stops limit 1000;
          for ind in 1 .. stops.count loop
            continue when stops(ind).numpoints < 2; --T-OPTICS might output a STOP of one point. we pass it
            if (stops(ind).userid = olduserid) then
              if (stops(ind).trajid = oldtrajid) then
                if (stops(ind).stopid = oldstopid) then
                  null; --error
                else
                  --new stop
                  subtraj_id := subtraj_id + 1;
                  --add a move
                  sub_utab := getmovepoints(trajs(indx).mpoint,olduserid,oldtrajid,
                     oldstopid,stops(ind).stopid,inputtblstopseqs);
                  continue when sub_utab.count = 0;
                  sub_traj := sub_moving_point(stops(ind).userid,stops(ind).trajid,
                     subtraj_id,moving_point(sub_utab,stops(ind).trajid,
                     trajs(indx).mpoint.srid));
                  --insert subtraj
                  execute immediate 'insert into ' || outputtblsubmpoints ||
                                    ' values(:sub_traj)'
                    using in sub_traj;
                  commit;
                  --addEpisode(get ref to subtraj)
                  query := 'select ref(t) from ' || outputtblsubmpoints || ' t
                                  where t.o_id=' || stops(ind).userid || '
                                  and t.traj_id=' || stops(ind).trajid || '
                                  and t.subtraj_id=' ||subtraj_id;
                  open trajs_cv for query;
                  fetch trajs_cv into refer;
                  close trajs_cv;

                  sem_traj.episodes.extend(1);
                  sem_traj.episodes(sem_traj.episodes.last) := sem_episode('MOVE',
                    null,null,sub_traj.getsemmbb(),refer);
                  subtraj_id := subtraj_id + 1;
                  --calcmovefeatures==>store them
                  --calcfeatures(outputtblfeatures, refer, 'MOVE');
                  --add the stop
                  sub_utab := getstoppoints(stops(ind).userid,stops(ind).trajid,
                    stops(ind).stopid,inputtblstopseqs);
                  sub_traj := sub_moving_point(stops(ind).userid,stops(ind).trajid,
                    subtraj_id,moving_point(sub_utab,stops(ind).trajid,
                    trajs(indx).mpoint.srid));
                  --insert subtraj
                  execute immediate 'insert into ' || outputtblsubmpoints ||
                                    ' values(:sub_traj)'
                    using in sub_traj;
                  commit;
                  --addEpisode(get ref to subtraj)
                  query := 'select ref(t) from ' || outputtblsubmpoints || ' t
                                      where t.o_id=' || stops(ind).userid || '
                                      and t.traj_id=' || stops(ind).trajid || '
                                      and t.subtraj_id=' ||subtraj_id;
                  open trajs_cv for query;
                  fetch trajs_cv
                    into refer;
                  close trajs_cv;

                  sem_traj.episodes.extend(1);
                  sem_traj.episodes(sem_traj.episodes.last) := sem_episode('STOP',
                    null,null,sub_traj.getsemmbb(), refer);
                  --calcstopfeatures==>store them
                  --calcfeatures(outputtblfeatures, refer, 'STOP');
                  --update old...
                  olduserid := stops(ind).userid;
                  oldtrajid := stops(ind).trajid;
                  oldstopid := stops(ind).stopid;
                end if;
              else
                --new traj
                subtraj_id := 1;
                -- add first stop
                sub_utab := getstoppoints(stops(ind).userid,stops(ind).trajid,
                  stops(ind).stopid,inputtblstopseqs);
                sub_traj := sub_moving_point(stops(ind).userid,stops(ind).trajid,
                  subtraj_id,moving_point(sub_utab,stops(ind).trajid,
                  trajs(indx).mpoint.srid));
                --insert subtraj
                execute immediate 'insert into ' || outputtblsubmpoints ||
                                  ' values(:sub_traj)'
                  using in sub_traj;
                commit;
                --addEpisode(get ref to subtraj)
                query := 'select ref(t) from ' || outputtblsubmpoints || ' t
                                      where t.o_id=' || stops(ind).userid || '
                                      and t.traj_id=' || stops(ind).trajid || '
                                      and t.subtraj_id=' ||subtraj_id;
                open trajs_cv for query;
                fetch trajs_cv into refer;
                close trajs_cv;

                sem_traj.episodes.extend(1);
                sem_traj.episodes(sem_traj.episodes.last) := sem_episode('STOP',
                  null, null,sub_traj.getsemmbb(),refer);
                --calcstopfeatures==>store them
                --calcfeatures(outputtblfeatures, refer, 'STOP');
                --update old...
                olduserid := stops(ind).userid;
                oldtrajid := stops(ind).trajid;
                oldstopid := stops(ind).stopid;
              end if;
            else
              --new user
              --add first stop
              subtraj_id := 1;
              sub_utab   := getstoppoints(stops(ind).userid,stops(ind).trajid,
                stops(ind).stopid,inputtblstopseqs);
              sub_traj   := sub_moving_point(stops(ind).userid,stops(ind).trajid,
                subtraj_id,moving_point(sub_utab,stops(ind).trajid,
                trajs(indx).mpoint.srid));
              --insert subtraj
              execute immediate 'insert into ' || outputtblsubmpoints ||
                                ' values(:sub_traj)'
                using in sub_traj;
              commit;
              --addEpisode(get ref to subtraj)
              query := 'select ref(t) from ' || outputtblsubmpoints || ' t
                                      where t.o_id=' || stops(ind).userid || '
                                      and t.traj_id=' || stops(ind).trajid || '
                                      and t.subtraj_id=' ||subtraj_id;
              open trajs_cv for query;
              fetch trajs_cv into refer;
              close trajs_cv;

              sem_traj.episodes.extend(1);
              sem_traj.episodes(sem_traj.episodes.last) := sem_episode('STOP',
                null, null,sub_traj.getsemmbb(), refer);
              --calcfeatures==>store them
              --calcfeatures(outputtblfeatures, refer, 'STOP');
              --update old...
              olduserid := stops(ind).userid;
              oldtrajid := stops(ind).trajid;
              oldstopid := stops(ind).stopid;
            end if;
          end loop;
          --add to semtrajectories or insert if memory problems
          if (sem_traj.episodes.count > 1) then
            /*
            semtrajectories.extend(1);
            semtrajectories(semtrajectories.last) := sem_traj;
            */
            execute immediate 'insert into ' || outputtblsmpoints ||
                              ' values(:o_id, :semtraj_id,:sem_traj)'
              using in sem_traj.o_id, sem_traj.semtraj_id,
              sem_trajectory(sem_traj.sem_trajectory_tag, sem_traj.srid,
              sem_traj.episodes, sem_traj.o_id,sem_traj.semtraj_id, sem_traj.profile_id);
            commit;
          end if;
          exit when stops_cv%notfound;
        end loop;
        close stops_cv;
      end loop;
      exit when trajs_cv2%notfound;
    end loop;
    close trajs_cv2;
    --insert
    /*
    for i in semtrajectories.first .. semtrajectories.last loop
      execute immediate 'insert into ' || outputtblsmpoints ||
                        ' values(:o_id, :semtraj_id,:sem_traj)'
        using in semtrajectories(i).o_id, semtrajectories(i).semtraj_id,
        sem_trajectory(semtrajectories(i).sem_trajectory_tag, semtrajectories(i).srid,
        semtrajectories(i).episodes, semtrajectories(i).o_id, semtrajectories(i).semtraj_id);
      commit;
    end loop;
    */
  end discoverepisodes;

  function getstoppoints(userid integer,trajid integer, stopid integer,stopstbl varchar2)
    return moving_point_tab is
    query varchar2(5000);
    tmpufun unit_function;
    tmptimepoint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    utab moving_point_tab;
    xyt_cv sys_refcursor;
    type xyt_typ is record(
         x number(10,6),
         y number(10,6),
         t number
         );
    type xyt_tab_typ is table of xyt_typ;
    xyt_tab xyt_tab_typ;
    firstpoint boolean:=true;
  begin
    query:='select t.x, t.y, t.t from '||stopstbl||' t
            where t.userid='||userid||'
            and t.trajid='||trajid||'
            and t.stopid='||stopid||'
            order by t.t';
    open xyt_cv for query;
    loop
      fetch xyt_cv bulk collect into xyt_tab limit 2000;
      for indx in 1..xyt_tab.count loop
        if (indx = 1)and (firstpoint) then
          tmpufun:=unit_function(xyt_tab(indx).x, xyt_tab(indx).y,null,null,
                                 null,null,null,null,null,'PLNML_1');
          tmptimepoint.set_Abs_Date(xyt_tab(indx).t);
          utab:=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(tmptimepoint, null),
                                                   tmpufun));
          firstpoint:=false;
        else--append point
          tmptimepoint.set_Abs_Date(xyt_tab(indx).t);
          if (utab(utab.last).p.e is null) then
            utab(utab.last).p.e:=tmptimepoint;
            utab(utab.last).m.xe:=xyt_tab(indx).x;
            utab(utab.last).m.ye:=xyt_tab(indx).y;
          else
            utab.extend(1);
            utab(utab.last):=unit_moving_point(tau_tll.d_period_sec(utab(utab.last-1).p.e, tmptimepoint),
                                 unit_function(utab(utab.last-1).m.xe, utab(utab.last-1).m.ye,
                                 xyt_tab(indx).x, xyt_tab(indx).y,
                                 null,null,null,null,null,'PLNML_1'));
          end if;
        end if;
      end loop;
      exit when xyt_cv%notfound;
    end loop;
    close xyt_cv;
    return utab;
  end getstoppoints;

  function getmovepoints(mpoint moving_point, inuserid integer,intrajid integer, oldstopid integer,
    newstopid integer, stopstbl varchar2)
    return moving_point_tab is
    utab moving_point_tab:=moving_point_tab();
    lastx number(10,6):=-1;lasty number(10,6):=-1;lastt number:=-1;
    curx number(10,6):=-1;cury number(10,6):=-1;curt number:=-1;
    startseg integer:=-1;endseg integer:=-1;
    point_rc sys_refcursor;
    query varchar2(5000);
  begin
    --get last point of stopid=oldstopid
    query := 'select a.x, a.y, a.t
               from (select t.x, t.y, t.t, row_number() over (order by t.t desc) rn
                 from '||stopstbl||' t
                 where t.userid='||inuserid||'
                 and t.trajid='||intrajid||'
                 and t.stopid='||oldstopid||') a
               where a.rn=1'
               ;
    open point_rc for query;
    fetch point_rc into lastx,lasty,lastt;
    close point_rc;

    --get first point of stopid=newstopid
    query := 'select a.x, a.y, a.t
               from (select t.x, t.y, t.t, row_number() over (order by t.t) rn
                 from '||stopstbl||' t
                 where t.userid='||inuserid||'
                 and t.trajid='||intrajid||'
                 and t.stopid='||newstopid||') a
               where a.rn=1'
               ;
    open point_rc for query;
    fetch point_rc into curx,cury,curt;
    close point_rc;

    --get points or segments of mpoint in between
    for i in mpoint.u_tab.first..mpoint.u_tab.last loop
      if ((trunc(mpoint.u_tab(i).p.b.get_abs_date()) = lastt )
        and (mpoint.u_tab(i).m.xi = lastx)
        and (mpoint.u_tab(i).m.yi = lasty)) then
        --this is because of rounding by T-OPTICS (DataPoint.java line 27)
        --we might loose something here
        startseg:=i;
      end if;
      if ((trunc(mpoint.u_tab(i).p.e.get_abs_date()) = curt )
        and (mpoint.u_tab(i).m.xe = curx)
        and (mpoint.u_tab(i).m.ye = cury)) then
         endseg:=i;
      end if;
    end loop;
    if (startseg=-1) then
      return utab;
    else
      if(endseg=-1) then
        endseg:=mpoint.u_tab.last;
      end if;
    end if;

    for i in startseg..endseg loop
      utab.extend(1);
      utab(utab.last):=unit_moving_point(mpoint.u_tab(i).p,
                               mpoint.u_tab(i).m);
    end loop;
    return utab;
  end getmovepoints;


PROCEDURE stops2mpoints(
    inputtblstopseqs    VARCHAR2,
    outputtblsubmpoints VARCHAR2)
IS
  /*
  MANY HARD CODED VALUES, PLEASE MIND...
  this procedure takes stop points found by t-optics and transform them
  to moving points.Each stop becomes a moving poing.
  */
  olduserid    INTEGER := -1;
  oldtrajid    INTEGER := -1;
  oldsubtrajid INTEGER := -1;--trajectories are now the sub- trajectories
  oldstopid    INTEGER := -1;
  new_mpoint moving_point;
  utab moving_point_tab    :=moving_point_tab();
  t tau_tll.d_timepoint_sec:= tau_tll.d_timepoint_sec(1,1,1,1,1,1);
BEGIN
null;
/*
  DELETE belgsub_stops_mpoints;
  COMMIT;
  FOR stops IN
  (SELECT t.userid, t.trajid, t.subtrajid, t.stopid, t.x, t.y, t.t
  FROM belgsub_stops_found t
    --where t.userid=3711 and t.trajid=1
  ORDER BY t.userid, t.trajid, t.subtrajid, t.stopid, t.t
  )
  LOOP
    t.set_abs_date(stops.t);
    IF (stops.userid                                         = olduserid) THEN  --same user
      IF (stops.trajid                                       =oldtrajid) THEN   --same trajid
        IF (stops.subtrajid                                  =oldsubtrajid) THEN--same subtrajid
          IF (stops.stopid                                   =oldstopid) THEN   --same stopid
            IF (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e IS NULL) THEN
              new_mpoint.u_tab(new_mpoint.u_tab.last).p.e   :=t;
              new_mpoint.u_tab(new_mpoint.u_tab.last).m.xe  :=stops.x;
              new_mpoint.u_tab(new_mpoint.u_tab.last).m.ye  :=stops.y;
            ELSE
              new_mpoint.u_tab.extend(1);
              new_mpoint.u_tab(new_mpoint.u_tab.last):= unit_moving_point(tau_tll.d_period_sec(
              new_mpoint.u_tab(new_mpoint.u_tab.last-1).p.e, t), unit_function( new_mpoint.u_tab(new_mpoint.u_tab.last-1).m.xe,
              new_mpoint.u_tab(new_mpoint.u_tab.last-1).m.ye, stops.x,stops.y,NULL,NULL,NULL,NULL, NULL,'PLNML_1'));
            END IF;
          ELSE--new stopid
            IF (new_mpoint.u_tab.count>0) AND (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e IS NOT NULL) THEN
              INSERT INTO belgsub_stops_mpoints (object_id, traj_id, subtraj_id, stop_id, mpoint )
                VALUES (olduserid,oldtrajid,oldsubtrajid,oldstopid, new_mpoint);
              COMMIT;
            END IF;
            utab      :=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(t, null),
              unit_function(stops.x,stops.y,NULL,NULL,NULL,NULL,NULL,NULL, NULL,'PLNML_1')));
            new_mpoint:=moving_point(utab,stops.userid,4326);
          END IF;
        ELSE--new subtrajdid
          IF (new_mpoint.u_tab.count>0) AND (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e IS NOT NULL) THEN
            INSERT INTO belgsub_stops_mpoints (object_id, traj_id, subtraj_id, stop_id, mpoint)
              VALUES(olduserid,oldtrajid, oldsubtrajid, oldstopid, new_mpoint);
            COMMIT;
          END IF;
          utab      :=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(t, null),
            unit_function(stops.x,stops.y,NULL,NULL,NULL,NULL,NULL,NULL, NULL,'PLNML_1')));
          new_mpoint:=moving_point(utab,stops.userid,4326);
        END IF;
      ELSE--new trajid
        if (new_mpoint.u_tab.count>0) and (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e is not null) then
          INSERT INTO belgsub_stops_mpoints ( object_id, traj_id,subtraj_id, stop_id, mpoint)
            VALUES ( olduserid,oldtrajid, oldsubtrajid, oldstopid, new_mpoint);
          COMMIT;
        END IF;
        utab      :=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(t, NULL),
          unit_function(stops.x,stops.y,NULL,NULL,NULL,NULL,NULL,NULL, NULL,'PLNML_1')));
        new_mpoint:=moving_point(utab,stops.userid,4326);
      END IF;
    ELSE                        --new user
      IF new_mpoint IS NULL THEN--empty new_mpoint==>create
        utab        :=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(t, NULL),
          unit_function(stops.x,stops.y,NULL,NULL,NULL,NULL,NULL,NULL, NULL,'PLNML_1')));
        new_mpoint  :=moving_point(utab,stops.userid,4326);
      ELSE--not empty new_mpoint==>store it then create new
        IF (new_mpoint.u_tab.count>0) AND (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e IS NOT NULL) THEN
          INSERT INTO belgsub_stops_mpoints ( object_id, traj_id, subtraj_id, stop_id, mpoint )
            VALUES ( olduserid,oldtrajid, oldsubtrajid, oldstopid, new_mpoint);
          COMMIT;
        END IF;
        utab      :=moving_point_tab(unit_moving_point(tau_tll.d_period_sec(t, NULL),
          unit_function(stops.x,stops.y,NULL,NULL,NULL,NULL,NULL,NULL, NULL,'PLNML_1')));
        new_mpoint:=moving_point(utab,stops.userid,4326);
      END IF;
    END IF;
    olduserid   :=stops.userid;
    oldtrajid   :=stops.trajid;
    oldsubtrajid:=stops.subtrajid;
    oldstopid   :=stops.stopid;
  END LOOP;
  IF (new_mpoint.u_tab.count>0) AND (new_mpoint.u_tab(new_mpoint.u_tab.last).p.e IS NOT NULL) THEN
    insert into belgsub_stops_mpoints ( object_id, traj_id, subtraj_id, stop_id, mpoint )
      VALUES ( olduserid, oldtrajid, oldsubtrajid, oldstopid,  new_mpoint);
    COMMIT;
  END IF;
  */
end stops2mpoints;

  procedure reconstructtrajectories(sourcetblgps varchar2, srid integer,
    targettblmpoints varchar2, spacegapmet number, timegapsec number) is
    /*
    This procedure takes as input a table with gps point like the one in the first select query.
    At least there must be a  user id, longtitude, latitude and timestamp.
    Also an srid, a table to store moving point produced, a space gap and a time gap parameter
    to break gpspoints to trajectories of the same object.
    */
    --trajectories sub_moving_point_tab:=sub_moving_point_tab();
    cur_mpoint sub_moving_point;
    new_mpoint sub_moving_point;
    last_segment unit_moving_point;
    --spacegaps;
    times integer:=0;
    d number;
    tsecs number;
    query varchar2(5000);
    gps_cv sys_refcursor;
    type gpspoint_rec is record(
         object_id integer,
         x number(10,6),
         y number(10,6),
         t TAU_TLL.d_timepoint_sec);
    type new_gpspoint_tab is table of gpspoint_rec;
    new_gpspoints new_gpspoint_tab;
    extension boolean:=false;
    cur_gpspoint gpspoint_rec;
  begin
    --mind the column's names for both tables parameters
    --table targettblmpoints (integer, integer, moving_point) should exists, caller to check it
    execute immediate 'delete '||targettblmpoints||' t';
    commit;
    query := 'select t.user_id, t.longtitude, t.latitude, TAU_TLL.d_timepoint_sec(
       20||substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),substr(t.gps_reg_day,1,2),
       substr(t.timestamped,1,2),substr(t.timestamped,3,2),substr(t.timestamped,5,length(t.timestamped))
       ) from '||sourcetblgps||' t
       --where t.user_id=3711
       --where rownum<600000
       where t.gpsfix=''A''
       order by t.user_id, t.gps_reg_day, t.timestamped
       ';
    open gps_cv for query;
    cur_gpspoint.object_id:=-1;
    loop
      fetch gps_cv bulk collect into new_gpspoints limit 50000;
      times:=times+1;
      dbms_output.put_line(50000*times);
      for indx in 1..new_gpspoints.count loop
              if(indx=4598)then
              null;
              end if;
        if (cur_gpspoint.object_id!=new_gpspoints(indx).object_id) then
          --no object==>first trajectory
          new_mpoint := sub_moving_point(new_gpspoints(indx).object_id,1,null,
            moving_point(
              moving_point_tab(
                unit_moving_point(
                  tau_tll.d_period_sec(new_gpspoints(indx).t,null),
                  unit_function(new_gpspoints(indx).x, new_gpspoints(indx).y,null,null,
                                null,null,null,null,null,'PLNML_1'))),
            1,srid));
          extension:=true;
          if (cur_mpoint is not null) then
            --store cur_mpoint
            --insert trajectory (because of no memory errors)
            execute immediate 'insert into '||targettblmpoints||'
                    (object_id,traj_id,mpoint)
                    values(:o_id,:traj_id,:sub_mpoint)'
                    using in cur_mpoint.o_id,
                    in cur_mpoint.traj_id,
                    in cur_mpoint.sub_mpoint;
            commit;
          end if;
          cur_mpoint:=sub_moving_point(new_mpoint.o_id, new_mpoint.traj_id,new_mpoint.subtraj_id,
                                       new_mpoint.sub_mpoint);

          cur_gpspoint.object_id:=new_gpspoints(indx).object_id;
          cur_gpspoint.x:=new_gpspoints(indx).x;
          cur_gpspoint.y:=new_gpspoints(indx).y;
          cur_gpspoint.t:=new_gpspoints(indx).t;
        else
          if ((new_gpspoints(indx).x=cur_gpspoint.x and new_gpspoints(indx).y=cur_gpspoint.y) or
            (new_gpspoints(indx).t.f_eq(new_gpspoints(indx).t, cur_gpspoint.t))=1) then
            null;--discard point
          else
            last_segment:= cur_mpoint.sub_mpoint.u_tab(cur_mpoint.sub_mpoint.u_tab.last);
            d:=last_distance(last_segment.m, new_gpspoints(indx).x, new_gpspoints(indx).y, srid);
            tsecs:=last_duration(last_segment.p, new_gpspoints(indx).t);

            if (d > spacegapmet) then
              new_mpoint := sub_moving_point(new_gpspoints(indx).object_id,cur_mpoint.traj_id+1,null,
                moving_point(
                  moving_point_tab(
                    unit_moving_point(
                      tau_tll.d_period_sec(new_gpspoints(indx).t,null),
                      unit_function(new_gpspoints(indx).x, new_gpspoints(indx).y,null,null,
                                    null,null,null,null,null,'PLNML_1'))),
                cur_mpoint.traj_id+1,srid));
              extension:=true;
              if (cur_mpoint is not null) then
                --store cur_mpoint
                --insert trajectory (because of no memory errors)
                execute immediate 'insert into '||targettblmpoints||'
                        (object_id,traj_id,mpoint)
                        values(:o_id,:traj_id,:sub_mpoint)'
                        using in cur_mpoint.o_id,
                        in cur_mpoint.traj_id,
                        in cur_mpoint.sub_mpoint;
                commit;
              end if;
              cur_mpoint:=sub_moving_point(new_mpoint.o_id, new_mpoint.traj_id,new_mpoint.subtraj_id,
                                       new_mpoint.sub_mpoint);
              --spacegaps
            elsif (tsecs > timegapsec and d <= spacegapmet) then
              --we do not want to execute both ifs on the same point
              new_mpoint := sub_moving_point(new_gpspoints(indx).object_id,cur_mpoint.traj_id+1,null,
                moving_point(
                  moving_point_tab(
                    unit_moving_point(
                      tau_tll.d_period_sec(new_gpspoints(indx).t,null),
                      unit_function(new_gpspoints(indx).x, new_gpspoints(indx).y,null,null,
                                    null,null,null,null,null,'PLNML_1'))),
                cur_mpoint.traj_id+1,srid));
              extension:=true;
              if (cur_mpoint is not null) then
                --store cur_mpoint
                --insert trajectory (because of no memory errors)
                execute immediate 'insert into '||targettblmpoints||'
                        (object_id,traj_id,mpoint)
                        values(:o_id,:traj_id,:sub_mpoint)'
                        using in cur_mpoint.o_id,
                        in cur_mpoint.traj_id,
                        in cur_mpoint.sub_mpoint;
                commit;
              end if;
              cur_mpoint:=sub_moving_point(new_mpoint.o_id, new_mpoint.traj_id,new_mpoint.subtraj_id,
                                       new_mpoint.sub_mpoint);
              --timegaps
            else--enlarge cur_mpoint
              if (last_segment.p.e is null) then
                cur_mpoint.sub_mpoint.u_tab(cur_mpoint.sub_mpoint.u_tab.last).p.e := new_gpspoints(indx).t;
                cur_mpoint.sub_mpoint.u_tab(cur_mpoint.sub_mpoint.u_tab.last).m.xe := new_gpspoints(indx).x;
                cur_mpoint.sub_mpoint.u_tab(cur_mpoint.sub_mpoint.u_tab.last).m.ye := new_gpspoints(indx).y;
              else--last_segment full
                d:=cur_mpoint.sub_mpoint.u_tab.count;
                if (d=20000) then
                  null;
                end if;
                cur_mpoint.sub_mpoint.u_tab.extend(1);
                cur_mpoint.sub_mpoint.u_tab(cur_mpoint.sub_mpoint.u_tab.last) :=
                    unit_moving_point(tau_tll.d_period_sec(last_segment.p.e,new_gpspoints(indx).t),
                      unit_function(last_segment.m.xe, last_segment.m.ye,new_gpspoints(indx).x,new_gpspoints(indx).y,
                                    null,null,null,null,null,'PLNML_1'));
              end if;
              /* memory errors
              if (extension=true) then
                trajectories.extend(1);
                extension:=false;
              end if;
              trajectories(trajectories.last) := cur_mpoint;
              */
            end if;
            cur_gpspoint.object_id:=new_gpspoints(indx).object_id;
            cur_gpspoint.x:=new_gpspoints(indx).x;
            cur_gpspoint.y:=new_gpspoints(indx).y;
            cur_gpspoint.t:=new_gpspoints(indx).t;
          end if;
        end if;
      end loop;
      exit when gps_cv%notfound;
    end loop;
    --last mpoint
    if (cur_mpoint is not null) then
      --store cur_mpoint
      --insert trajectory (because of no memory errors)
      execute immediate 'insert into '||targettblmpoints||'
              (object_id,traj_id,mpoint)
              values(:o_id,:traj_id,:sub_mpoint)'
              using in cur_mpoint.o_id,
              in cur_mpoint.traj_id,
              in cur_mpoint.sub_mpoint;
      commit;
    end if;
    close gps_cv;
    /*
    --insert trajectories
    execute immediate 'insert into '||targettblmpoints||'
            select t.o_id, t.traj_id, t.sub_mpoint from table(:trajectories) t'
            using in trajectories;
    commit;
    */
  end reconstructtrajectories;

  procedure reconstructtrajectoriestoraw(sourcetblgps varchar2, srid integer,
    targettblraw varchar2, spacegapmet number, timegapsec number) is
    /*
    This procedure takes as input a table with gps point like the one in the first select query.
    At least there must be a  user id, longtitude, latitude and timestamp.
    Also an srid, a table to store raw moving point (in raw form) produced, a space gap and a time gap parameter
    to break gpspoints to trajectories of the same object.
    */
    --spacegaps;
    times integer:=0;
    d number;
    tsecs number;
    query varchar2(5000);
    gps_cv sys_refcursor;
    last_cv sys_refcursor;
    type gpspoint_rec is record(
         object_id integer:=-1,
         trajectoryid integer,
         x number(10,6),
         y number(10,6),
         m_y number(10),
         m_m number(10),
         m_d number(10),
         m_h number(10),
         m_min number(10),
         m_sec number);
    type new_gpspoint_tab is table of gpspoint_rec;
    new_gpspoints new_gpspoint_tab;

    cur_gpspoint gpspoint_rec;
    last_point gpspoint_rec;

    last_point_time tau_tll.d_timepoint_sec;
    new_point_time tau_tll.d_timepoint_sec;
  begin
    --mind the column's names for both tables parameters
    --table targettblraw (integer,integer,number(*,6),number(*,6),number(10),number(10),
    --number(10),number(10),number(10),number)
    --userid,trajectoryid, x,y,year,month,day,hour,minute,second
    -- should exists, caller to check it
    execute immediate 'delete '||targettblraw||' t';
    commit;
    query := 'select t.user_id, -1, t.longtitude, t.latitude,
       20||substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),substr(t.gps_reg_day,1,2),
       substr(t.timestamped,1,2),substr(t.timestamped,3,2),
       substr(t.timestamped,5,length(t.timestamped))
       from '||sourcetblgps||' t
       where t.gpsfix=''A''
       order by t.user_id, t.gps_reg_day, t.timestamped
       ';
    open gps_cv for query;
    cur_gpspoint.object_id:=-1;
    loop
      fetch gps_cv
            bulk collect into new_gpspoints limit 50000;
      times:=times+1;
      --dbms_output.put_line(50000*times);
      for indx in 1..new_gpspoints.count loop
        if(indx=3086)then
              null;
              end if;
        if (cur_gpspoint.object_id!=new_gpspoints(indx).object_id) then
          --first trajectory
          execute immediate 'insert into '||targettblraw||'
                  values(:userid,:trajectoryid,:x,:y,:year,:month,:day,:hour,:minute,:second)'
                  using in new_gpspoints(indx).object_id,in 1,in new_gpspoints(indx).x,
                  in new_gpspoints(indx).y, in new_gpspoints(indx).m_y,
                  in new_gpspoints(indx).m_m,in new_gpspoints(indx).m_d,
                  in new_gpspoints(indx).m_h,in new_gpspoints(indx).m_min,
                  in new_gpspoints(indx).m_sec;
          commit;

          cur_gpspoint.object_id:=new_gpspoints(indx).object_id;
          cur_gpspoint.trajectoryid:=1;
          cur_gpspoint.x:=new_gpspoints(indx).x;
          cur_gpspoint.y:=new_gpspoints(indx).y;
          cur_gpspoint.m_y:=new_gpspoints(indx).m_y;
          cur_gpspoint.m_m:=new_gpspoints(indx).m_m;
          cur_gpspoint.m_d:=new_gpspoints(indx).m_d;
          cur_gpspoint.m_h:=new_gpspoints(indx).m_h;
          cur_gpspoint.m_min:=new_gpspoints(indx).m_min;
          cur_gpspoint.m_sec:=new_gpspoints(indx).m_sec;
        else
          if ((new_gpspoints(indx).x=cur_gpspoint.x and new_gpspoints(indx).y=cur_gpspoint.y) or
            (cur_gpspoint.m_y=new_gpspoints(indx).m_y and
              cur_gpspoint.m_m=new_gpspoints(indx).m_m and
              cur_gpspoint.m_d=new_gpspoints(indx).m_d and
              cur_gpspoint.m_h=new_gpspoints(indx).m_h and
              cur_gpspoint.m_min=new_gpspoints(indx).m_min and
              cur_gpspoint.m_sec=new_gpspoints(indx).m_sec)) then
                --discard point
                null;
          else
            --d is in meters
            d:=sdo_geom.sdo_distance(
                  sdo_geometry(2001,srid,sdo_point_type(cur_gpspoint.x, cur_gpspoint.y,null),null,null),
                  sdo_geometry(2001,srid,sdo_point_type(new_gpspoints(indx).x,
                               new_gpspoints(indx).y, null),null,null), 0.0005);
            /*
            tsecs:=abs(last_point.m_y - new_gpspoint.m_y)*12;
            tsecs:=(tsecs+abs(last_point.m_m-new_gpspoints(indx).m_m))*30;
            tsecs:=(tsecs+abs(last_point.m_d-new_gpspoints(indx).m_d))*24;
            tsecs:=(tsecs+abs(last_point.m_h-new_gpspoints(indx).m_h))*60;
            tsecs:=(tsecs+abs(last_point.m_min-new_gpspoints(indx).m_min))*60;
            tsecs:=tsecs+abs(last_point.m_sec-new_gpspoints(indx).m_sec);
            */
            --based on tsecs calculation method may, different number of trajectories, appear

            last_point_time := tau_tll.d_timepoint_sec(cur_gpspoint.m_y,cur_gpspoint.m_m,
                 cur_gpspoint.m_d,cur_gpspoint.m_h,cur_gpspoint.m_min,cur_gpspoint.m_sec);
            new_point_time := tau_tll.d_timepoint_sec(new_gpspoints(indx).m_y,new_gpspoints(indx).m_m,
                 new_gpspoints(indx).m_d,new_gpspoints(indx).m_h,new_gpspoints(indx).m_min,
                 new_gpspoints(indx).m_sec);
            tsecs:=abs(last_point_time.get_Abs_Date()-new_point_time.get_Abs_Date);

            if (d > spacegapmet) then
              cur_gpspoint.trajectoryid := cur_gpspoint.trajectoryid+1;
              execute immediate 'insert into '||targettblraw||'
                  values(:userid,:trajectoryid,:x,:y,:year,:month,:day,:hour,:minute,:second)'
                  using in new_gpspoints(indx).object_id,in cur_gpspoint.trajectoryid,
                  in new_gpspoints(indx).x,in new_gpspoints(indx).y,
                  in new_gpspoints(indx).m_y,in new_gpspoints(indx).m_m,in new_gpspoints(indx).m_d,
                  in new_gpspoints(indx).m_h,in new_gpspoints(indx).m_min,in new_gpspoints(indx).m_sec;
              commit;
              --spacegaps
            elsif (tsecs > timegapsec and d <= spacegapmet) then
              --we do not want to execute both ifs on the same point
              cur_gpspoint.trajectoryid := cur_gpspoint.trajectoryid+1;
              execute immediate 'insert into '||targettblraw||'
                  values(:userid,:trajectoryid,:x,:y,:year,:month,:day,:hour,:minute,:second)'
                  using in new_gpspoints(indx).object_id,in cur_gpspoint.trajectoryid,
                  in new_gpspoints(indx).x,in new_gpspoints(indx).y,
                  in new_gpspoints(indx).m_y,in new_gpspoints(indx).m_m,in new_gpspoints(indx).m_d,
                  in new_gpspoints(indx).m_h,in new_gpspoints(indx).m_min,in new_gpspoints(indx).m_sec;
              commit;
              --timegaps
            else
              execute immediate 'insert into '||targettblraw||'
                  values(:userid,:trajectoryid,:x,:y,:year,:month,:day,:hour,:minute,:second)'
                  using in new_gpspoints(indx).object_id,in cur_gpspoint.trajectoryid,
                  in new_gpspoints(indx).x,in new_gpspoints(indx).y,
                  in new_gpspoints(indx).m_y,in new_gpspoints(indx).m_m,in new_gpspoints(indx).m_d,
                  in new_gpspoints(indx).m_h,in new_gpspoints(indx).m_min,in new_gpspoints(indx).m_sec;
              commit;
            end if;
            cur_gpspoint.object_id:=new_gpspoints(indx).object_id;
            cur_gpspoint.x:=new_gpspoints(indx).x;
            cur_gpspoint.y:=new_gpspoints(indx).y;
            cur_gpspoint.m_y:=new_gpspoints(indx).m_y;
            cur_gpspoint.m_m:=new_gpspoints(indx).m_m;
            cur_gpspoint.m_d:=new_gpspoints(indx).m_d;
            cur_gpspoint.m_h:=new_gpspoints(indx).m_h;
            cur_gpspoint.m_min:=new_gpspoints(indx).m_min;
            cur_gpspoint.m_sec:=new_gpspoints(indx).m_sec;
          end if;
        end if;
      end loop;
      exit when gps_cv%notfound;
    end loop;
    close gps_cv;
  end reconstructtrajectoriestoraw;

  function last_distance(p1 unit_function, p2x number, p2y number, srid integer) return number is
    --d is in meters
    /*
    This function takes as input a unit_function (meaning a starting and ending point of a segment of a moving_point)
    and a second point as a pair of coordinates. It returns the distance between the last point of the segment
    and the input point.
    */
  begin
    if (p1.xe is not null) then
      return sdo_geom.sdo_distance(sdo_geometry(2001,srid,sdo_point_type(p1.xe, p1.ye,null),null,null),
             sdo_geometry(2001,srid,sdo_point_type(p2x, p2y, null),null,null),
             0.0005);
    elsif (p1.xi is not null) then
      return sdo_geom.sdo_distance(sdo_geometry(2001,srid,sdo_point_type(p1.xi, p1.yi,null),null,null),
             sdo_geometry(2001,srid,sdo_point_type(p2x, p2y, null),null,null),
             0.0005);
    else--it can not be
      return -1;
    end if;
  end last_distance;

  function last_duration(t1 tau_tll.d_period_sec, p2t tau_tll.d_timepoint_sec) return number is
    /*
    This function takes as input a d_period_sec (meaning a starting and ending time point of a segment of a moving_point)
    and a d_timepoint_sec. It returns the temporal distance between the last timepoint of the segment
    and the input timepoint.
    */
  begin
    if (t1.e is not null) then
      return abs(p2t.get_Abs_Date()- t1.e.get_abs_date());
    elsif (t1.b is not null) then
      return abs(p2t.get_Abs_Date()- t1.b.get_abs_date());
    else--it can not be
      return -1;
    end if;
  end last_duration;


  procedure getusersgpsdiaries is
    /*
    this procedure is of less importance
    that is why i can not remember why it is made for
    */
    /*
    olduser number:=-1;gpsidstart number;gpsidend number;
    type usertrip_type is record(
         user_id number,
         tripnum number,
         pointtype varchar2(10),
         gpsid number
    );
    type usertrip_tab is table of usertrip_type;
    usertrip usertrip_tab;
    cursor cv is select bt.user_id,bt.tripnum,bt.pointtype,bt.gpsid from belg_users_trips bt
      where (bt.user_id,bt.tripnum) in (select distinct bd.huishoudid,bp.tripindication1
      from belg_processeddata bp, belg_diarytripdatasamples bd
      where bd.persoonid=bp.persoonid)
      order by bt.user_id,bt.tripnum,bt.pointtype desc;
    */
  begin
    null;
    /*
    open cv;
    fetch cv bulk collect into usertrip;
    close cv;

    oldxristis=-1,oldtrip=-1
    gia kathe row
      if xristis<>oldxristis then
        if oldxristis not -1
          gpsidend=usertrip(i-1).gpsid while usertrip(i).pointtype='END'
          insert from gpsidstart to gpsidend
        gpsidstart=usertrip(i).gpsid while usertrip(i).pointtype='START'
      else
        if oldtrip-trip = 1 or 0
          null
        elsif oldtrip-trip > 1
          gpsidend=usertrip(i-1).gpsid while usertrip(i).pointtype='END'
          insert from gpsidstart to gpsidend
          gpsidstart=usertrip(i).gpsid while usertrip(i).pointtype='START'
        end if
      end if
      upd oldxristis,oldtrip

    ex
    5238	1	START	498
    5238	1	END	3135
    5238	2	START	8579
    5238	2	END	9799
    5238	12	START	45976
    5238	12	END	46998
    5238	13	START	47075
    5238	13	END	48091
    5240	1	START	57075
    5240	1	END	58091

    for i in usertrip.first..usertrip.last-1  loop--they come in pairs
      if (usertrip(i).pointtype='START') then
        gpsidstart:=usertrip(i).gpsid;
        gpsidend:=usertrip(i+1).gpsid;
        insert into belg_users_gps_diaries(gpstype,timestamped,gpsfix,latitude,north_south,
                longtitude,east_west,speed,azimuth,gps_reg_day,magnetic_var_g,magnetic_var_m,
                checksum,trip_num,user_id)
        select gpstype,timestamped,gpsfix,latitude,north_south,
                longtitude,east_west,speed,azimuth,gps_reg_day,magnetic_var_g,magnetic_var_m,
                checksum,trip_num,user_id from (
          select t.*,row_number() over (order by substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),
              substr(t.gps_reg_day,1,2),substr(t.timestamped,1,2),substr(t.timestamped,3,2),
              substr(t.timestamped,5,2), timestamped) rn
          from belg_users_gps t where t.user_id=usertrip(i).user_id) p
        where p.rn between gpsidstart and gpsidend ;
        commit;
      else
        null;
      end if;
    end loop;
    */
  end getusersgpsdiaries;

  procedure belgdiariestosemtrajs is
    /*
    This procedure is made for belg dataset. It takes input from their excel files imported
    and produce semantic trajectories and the corresponding sub trajectories.
    */
    cursemtraj sem_trajectory:=null;
    semtrajs sem_trajectory_tab:=sem_trajectory_tab();
    newepisode sem_episode;
    olduser number:=-1;oldday number:=-1;oldtrip number:=-1;semtrajid number:=0;
    oldtripindicator number:=-1;subtraj number:=0;srid number:=4326;
    oldtloc varchar2(50);oldactivitytloc varchar2(50);
  begin
    --
    execute immediate 'delete belg_sub_mpoints';
    commit;
    for cur_in in (
      select 1 huishoudid,2 tripindication1,3 floc,4 category,5 startday
      ,6 tripnumber,7 tloc,8 activitytloc from dual--just to compile as following tables no longer exists
      /*
      select bd.huishoudid, bp.startday,bp.tripnumber,bp.tripindication1,
      bp.vertreklocid,blc.omschrijving floc,
      bd.aankomstlocid,blc2.omschrijving tloc,
      ba.description activitytloc,
      bm.description modes,bm.category
      from belg_processeddata bp, belg_diarytripdatasamples bd,belg_transportationmeans bm,
      belg_activitytype ba,belg_locationdataandtypes bl,belg_localietype blc,
      belg_locationdataandtypes bl2,belg_localietype blc2
      where bp.persoonid=bd.persoonid and bl.locid(+)=bp.vertreklocid
      and bl.locatietypeid=blc.locatietypeid(+)and bl2.locid(+)=bp.aankomstlocid
      and bl2.locatietypeid=blc2.locatietypeid(+)
      and bp.vstartmoment=bd.vstartmoment and bp.veindmoment=bd.veindmoment
      and bm.id=bd.maintransmode and ba.activieittype(+)=bp.activiteittypeid
      --and bd.huishoudid in (211731)
      order by bd.huishoudid, bp.startday,bp.tripindication1
      */
      ) loop
      if (olduser <> cur_in.huishoudid) then
        if(cursemtraj is not null) then
          --store cursemtraj
          newepisode := belgmakestop(olduser,cursemtraj.semtraj_id, cursemtraj.episodes.count+1,
                      oldtripindicator,srid,true,false);
          newepisode.defining_tag:='STOP';
          newepisode.episode_tag:=oldtloc;
          newepisode.activity_tag:=oldactivitytloc;
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
          semtrajs.extend(1);
          semtrajs(semtrajs.last):=cursemtraj;
        end if;
        --first stop
        semtrajid:=1;subtraj:=1;
        newepisode := belgmakestop(cur_in.huishoudid,semtrajid, subtraj,
                    cur_in.tripindication1,srid,false,true);
        newepisode.defining_tag:='STOP';
        newepisode.episode_tag:=cur_in.floc;
        newepisode.activity_tag:='other';
        cursemtraj:=sem_trajectory(null,srid,sem_episode_tab(newepisode),cur_in.huishoudid,
                   semtrajid,cur_in.huishoudid);
        --move
        subtraj:=subtraj+1;
        newepisode := belggetmove(cur_in.huishoudid, semtrajid, subtraj,
                   cur_in.tripindication1,srid);
        newepisode.defining_tag:='MOVE';
        newepisode.activity_tag:=cur_in.category;
        cursemtraj.episodes.extend(1);
        cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
      elsif (oldday <> cur_in.startday) then
        if (cursemtraj is not null) then
          --store cursemtraj
          newepisode := belgmakestop(olduser,cursemtraj.semtraj_id, cursemtraj.episodes.count+1,
                      oldtripindicator,srid,true,false);
          newepisode.defining_tag:='STOP';
          newepisode.episode_tag:=oldtloc;
          newepisode.activity_tag:=oldactivitytloc;
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
          semtrajs.extend(1);
          semtrajs(semtrajs.last):=cursemtraj;
        end if;
        --first stop
        semtrajid:=semtrajid+1;subtraj:=1;
        newepisode := belgmakestop(cur_in.huishoudid,semtrajid, subtraj,
                    cur_in.tripindication1,srid,false,true);
        newepisode.defining_tag:='STOP';
        newepisode.episode_tag:=cur_in.floc;
        newepisode.activity_tag:='other';
        cursemtraj:=sem_trajectory(null,srid,sem_episode_tab(newepisode),cur_in.huishoudid,
                   semtrajid,cur_in.huishoudid);
        --move
        subtraj:=subtraj+1;
        newepisode := belggetmove(cur_in.huishoudid, semtrajid, subtraj,
                   cur_in.tripindication1,srid);
        newepisode.activity_tag:=cur_in.category;
        cursemtraj.episodes.extend(1);
        cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
      elsif (oldtrip <> cur_in.tripnumber) then
        if (abs(cur_in.tripindication1-oldtripindicator)>1) then
          if (cursemtraj is not null) then
            --store cursemtraj
            newepisode := belgmakestop(olduser,cursemtraj.semtraj_id, cursemtraj.episodes.count+1,
                        oldtripindicator,srid,true,false);
            newepisode.defining_tag:='STOP';
            newepisode.episode_tag:=oldtloc;
            newepisode.activity_tag:=oldactivitytloc;
            cursemtraj.episodes.extend(1);
            cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
            semtrajs.extend(1);
            semtrajs(semtrajs.last):=cursemtraj;
          end if;
          --first stop
          semtrajid:=semtrajid+1;subtraj:=1;
          newepisode := belgmakestop(cur_in.huishoudid,semtrajid, subtraj,
                      cur_in.tripindication1,srid,false,true);
          newepisode.defining_tag:='STOP';
          newepisode.episode_tag:=cur_in.floc;
          newepisode.activity_tag:='other';
          cursemtraj:=sem_trajectory(null,srid,sem_episode_tab(newepisode),cur_in.huishoudid,
                     semtrajid,cur_in.huishoudid);
          --move
          subtraj:=subtraj+1;
          newepisode := belggetmove(cur_in.huishoudid, semtrajid, subtraj,
                   cur_in.tripindication1,srid);
          newepisode.activity_tag:=cur_in.category;
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
        elsif (abs(cur_in.tripindication1-oldtripindicator)=1) then
          --stop
          subtraj:=subtraj+1;
          newepisode := belgmakestop(cur_in.huishoudid,semtrajid, subtraj,
                      cur_in.tripindication1,srid,false,false);
          newepisode.defining_tag:='STOP';
          newepisode.episode_tag:=oldtloc;
          newepisode.activity_tag:=oldactivitytloc;
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
          --move
          subtraj:=subtraj+1;
          newepisode := belggetmove(cur_in.huishoudid, semtrajid, subtraj,
                   cur_in.tripindication1,srid);
          newepisode.activity_tag:=cur_in.category;
          cursemtraj.episodes.extend(1);
          cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
        else
          null;--error
        end if;
      else
        null;--error
      end if;
      olduser:=cur_in.huishoudid;
      oldday:=cur_in.startday;
      oldtrip:=cur_in.tripnumber;
      oldtripindicator:=cur_in.tripindication1;
      oldtloc:=cur_in.tloc;
      oldactivitytloc:=cur_in.activitytloc;
    end loop;
    --add last sem trajectory
    if (cursemtraj is not null) then
      --store cursemtraj
      newepisode := belgmakestop(olduser,cursemtraj.semtraj_id, cursemtraj.episodes.count+1,
                  oldtripindicator,srid,true,false);
      newepisode.defining_tag:='STOP';
      newepisode.episode_tag:=oldtloc;
      newepisode.activity_tag:=oldactivitytloc;
      cursemtraj.episodes.extend(1);
      cursemtraj.episodes(cursemtraj.episodes.last):=newepisode;
      semtrajs.extend(1);
      semtrajs(semtrajs.last):=cursemtraj;
    end if;
    --insert trajectories
    execute immediate 'delete belg_sem_trajs';
    commit;
    execute immediate 'insert into belg_sem_trajs
            select sem_trajectory(null,t.srid,t.episodes,t.o_id,t.semtraj_id)
            from table(:semtrajs) t'
            using in semtrajs;
    commit;
  end belgdiariestosemtrajs;

  function belggetmove(userid number, semtraj number, subtraj number,tripid number,
    srid number)
    return sem_episode is
    /*
    this function makes a move episode and it is called by the belgdiariestosemtrajs
    procedure to create semantic trajectories for belg dataset.
    */
    /*
    gpsidstart number;gpsidend number;i number:=0;
    refcv sys_refcursor;refer ref sub_moving_point;
    episode_mpoint sub_moving_point;newx number;newy number;newt tau_tll.d_timepoint_sec;
    query varchar2(5000);j number:=0;
    */
  begin
    null;
    /*
    episode_mpoint:=sub_moving_point(userid,semtraj,subtraj,
               moving_point(moving_point_tab(),semtraj,srid));

    select bt.gpsid
    into gpsidstart
    from belg_users_trips bt
    where bt.user_id=userid
    and bt.tripnum=tripid
    and bt.pointtype='START';

    select bt.gpsid
    into gpsidend
    from belg_users_trips bt
    where bt.user_id=userid
    and bt.tripnum=tripid
    and bt.pointtype='END';

    i:=1;
    for cv in (
      select p.* from (
        select t.*,row_number() over (order by substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),
            substr(t.gps_reg_day,1,2),substr(t.timestamped,1,2),substr(t.timestamped,3,2),
            substr(t.timestamped,5,2), timestamped) rn
        from belg_users_gps t where t.user_id=userid) p
      where p.rn between gpsidstart and gpsidend
       ) loop
      newx:=cv.longtitude;
      newy:=cv.latitude;
      newt:=tau_tll.d_timepoint_sec('20'||substr(cv.gps_reg_day,5,2),substr(cv.gps_reg_day,3,2),
                substr(cv.gps_reg_day,1,2),substr(cv.timestamped,1,2),substr(cv.timestamped,3,2),
                substr(cv.timestamped,5,2));
      if (i=1) then--first point
        episode_mpoint.sub_mpoint.u_tab.extend(1);
        episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
          unit_moving_point(
            tau_tll.d_period_sec(
              newt,
              null),
            unit_function(newx,newy,null,null,
                                null,null,null,null,null,'PLNML_1'));
      else--next point
        if ((newx=episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xi
          and newy=episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.yi) or
            (newt.f_eq(newt,episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).
                p.b))=1) then
            j:=j+1;--discard point when spatially or temporally is the same
                --also you can impose other constraints like outlier (big space or temporal gap)
        else--add point
          episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).p.e:=newt;
          episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe:=newx;
          episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.ye:=newy;
          --prepare for next point
          episode_mpoint.sub_mpoint.u_tab.extend(1);
          episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
            unit_moving_point(
              tau_tll.d_period_sec(
                newt,
                null),
              unit_function(newx,newy,null,null,
                                  null,null,null,null,null,'PLNML_1'));
        end if;
      end if;
      i:=i+1;--count points
    end loop;
    --delete last segment as it was prepared for a next point
    if (episode_mpoint.sub_mpoint.u_tab.count=1) then--also check for 0
      --only one segment
      if (episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe is not null) then
        --full segment
        null;--ok leave it
      else
        --add fake end
        episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe:=
              newx+(newx*0.000001);
        episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.ye:=
              newy+(newy*0.000001);
        episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).p.e:=
              newt.f_add(newt,tau_tll.d_interval(14400));--plus 4 hours
      end if;
    else--more segments
      episode_mpoint.sub_mpoint.u_tab.trim;
    end if;
    --insert into sub_moving_point
    execute immediate 'insert into belg_sub_mpoints values(:sub_traj)'
                        using in episode_mpoint;
    commit;
    --take a ref
    query := 'select ref(t) from belg_sub_mpoints t
                    where t.o_id='||userid||'
                    and t.traj_id='||semtraj||'
                    and t.subtraj_id='||subtraj
    ;
    open refcv for query;
    fetch refcv into refer;
    close refcv;
    --create the episode and return it
    --calcfeatures('belg_sem_episodes_features', refer, 'MOVE');
    return sem_episode('MOVE',null,null,episode_mpoint.getsemmbb(),refer);
    exception when others then
      dbms_output.put_line(userid||','||semtraj||','||subtraj||','||
      episode_mpoint.sub_mpoint.u_tab.count);
    */
  end belggetmove;

  function belgmakestop(userid number, semtraj number, subtraj number,tripid number,
    srid number, atend boolean,firststop boolean)
    return sem_episode is
    /*
    this function makes a stop episode and it is called by the belgdiariestosemtrajs
    procedure to create semantic trajectories for belg dataset.
    */
    /*
    episode_mpoint sub_moving_point;refcv sys_refcursor;
    newx number;newy number;newt tau_tll.d_timepoint_sec;newh number;
    newyear number;newm number;newd number;
    fakex number;fakey number;
    faket tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(2000,1,1,1,1,1);
    gpsidstart number;query varchar2(5000);refer ref sub_moving_point;
    gpsidend number;i number:=0;j number:=0;lasttrip number:=0;
    */
  begin
    null;
    /*
    episode_mpoint:=sub_moving_point(userid,semtraj,subtraj,
               moving_point(moving_point_tab(),semtraj,srid));

    select max(bt.tripnum)--last trip
    into lasttrip
    from belg_users_trips bt
    where bt.user_id=userid;

    if(atend=false) then--create a stop before move
      if (tripid=1) then
        --make fake stop (first)
        select bt.gpsid
        into gpsidstart
        from belg_users_trips bt
        where bt.user_id=userid
        and bt.tripnum=tripid
        and bt.pointtype='START';

        select p.longtitude,p.latitude,
               tau_tll.d_timepoint_sec('20'||substr(p.gps_reg_day,5,2),substr(p.gps_reg_day,3,2),
                  substr(p.gps_reg_day,1,2),substr(p.timestamped,1,2),substr(p.timestamped,3,2),
                  substr(p.timestamped,5,2))
        into newx,newy,newt
        from (
          select t.*,row_number() over (order by substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),
              substr(t.gps_reg_day,1,2),substr(t.timestamped,1,2),substr(t.timestamped,3,2),
              substr(t.timestamped,5,2), timestamped) rn
          from belg_users_gps t
          where t.user_id=userid) p
        where p.rn=gpsidstart;

        fakex:=newx-(newx*0.000001);
        fakey:=newy-(newy*0.000001);
        faket.set_Abs_Date(newt.get_Abs_Date - 14400);--minus 4 hours ERROR OF F_SUB!!!!!

        episode_mpoint.sub_mpoint.u_tab.extend(1);
          episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
            unit_moving_point(
              tau_tll.d_period_sec(
                faket,
                newt),
              unit_function(fakex,fakey,newx,newy,
                                  null,null,null,null,null,'PLNML_1'));
      else--there more trips before or after
        --infer real stop
        select bt.gpsid
        into gpsidend
        from belg_users_trips bt
        where bt.user_id=userid
        and bt.tripnum=tripid
        and bt.pointtype='START';

        select bt.gpsid
        into gpsidstart
        from belg_users_trips bt
        where bt.user_id=userid
        and bt.tripnum=tripid-1
        and bt.pointtype='END';

        if (firststop) then
          gpsidstart:=gpsidstart+1;
        end if;

        i:=1;
        for cv in (
          select p.* from (
            select t.*,row_number() over (order by substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),
                substr(t.gps_reg_day,1,2),substr(t.timestamped,1,2),substr(t.timestamped,3,2),
                substr(t.timestamped,5,2), timestamped) rn
            from belg_users_gps t where t.user_id=userid) p
          where p.rn between gpsidstart and gpsidend
           ) loop
          newx:=cv.longtitude;
          newy:=cv.latitude;
          newt:=tau_tll.d_timepoint_sec('20'||substr(cv.gps_reg_day,5,2),substr(cv.gps_reg_day,3,2),
                    substr(cv.gps_reg_day,1,2),substr(cv.timestamped,1,2),substr(cv.timestamped,3,2),
                    substr(cv.timestamped,5,2));
          if (i=1) then--first point
            episode_mpoint.sub_mpoint.u_tab.extend(1);
            episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
              unit_moving_point(
                tau_tll.d_period_sec(
                  newt,
                  null),
                unit_function(newx,newy,null,null,
                                    null,null,null,null,null,'PLNML_1'));
          else--next point
            if ((newx=episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xi
              and newy=episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.yi) or
                (newt.f_eq(newt,episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).
                    p.b))=1) then
                j:=j+1;--discard point when spatially or temporally is the same
                --also you can impose other constraints like outlier (big space or temporal gap)
            else--add point
              episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).p.e:=newt;
              episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe:=newx;
              episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.ye:=newy;
              --prepare for next point
              episode_mpoint.sub_mpoint.u_tab.extend(1);
              episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
                unit_moving_point(
                  tau_tll.d_period_sec(
                    newt,
                    null),
                  unit_function(newx,newy,null,null,
                                      null,null,null,null,null,'PLNML_1'));
            end if;
          end if;
          i:=i+1;--count points
        end loop;
        --delete last segment as it was prepared for a next point
        if (episode_mpoint.sub_mpoint.u_tab.count=1) then--also check for 0
          --only one segment
          if (episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe is not null) then
            --full segment
            null;--ok leave it
          else
            --add fake end
            episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.xe:=
                  newx+(newx*0.000001);
            episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).m.ye:=
                  newy+(newy*0.000001);
            episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last).p.e:=
                  newt.f_add(newt,tau_tll.d_interval(14400));--plus 4 hours
          end if;
        else--more segments
          episode_mpoint.sub_mpoint.u_tab.trim;
        end if;
      end if;
    else --create last stop after move
      select bt.gpsid
      into gpsidstart
      from belg_users_trips bt
      where bt.user_id=userid
      and bt.tripnum=tripid
      and bt.pointtype='END';


      select p.longtitude,p.latitude,
             tau_tll.d_timepoint_sec('20'||substr(p.gps_reg_day,5,2),substr(p.gps_reg_day,3,2),
                substr(p.gps_reg_day,1,2),substr(p.timestamped,1,2),substr(p.timestamped,3,2),
                substr(p.timestamped,5,2))
      into newx,newy,newt
      from (
        select t.*,row_number() over (order by substr(t.gps_reg_day,5,2),substr(t.gps_reg_day,3,2),
            substr(t.gps_reg_day,1,2),substr(t.timestamped,1,2),substr(t.timestamped,3,2),
            substr(t.timestamped,5,2), timestamped) rn
        from belg_users_gps t where t.user_id=userid) p
      where p.rn=gpsidstart;

      fakex:=newx+(newx*0.000001);
      fakey:=newy+(newy*0.000001);
      faket.set_Abs_Date(newt.get_Abs_Date + 14400);--plus 4 hours

      episode_mpoint.sub_mpoint.u_tab.extend(1);
        episode_mpoint.sub_mpoint.u_tab(episode_mpoint.sub_mpoint.u_tab.last):=
          unit_moving_point(
            tau_tll.d_period_sec(
              newt,
              faket),
            unit_function(newx,newy,fakex,fakey,
                                null,null,null,null,null,'PLNML_1'));
    end if;
    --insert into sub_moving_point
    execute immediate 'insert into belg_sub_mpoints values(:sub_traj)'
                        using in episode_mpoint;
    commit;
    --take a ref
    query := 'select ref(t) from belg_sub_mpoints t
                    where t.o_id='||userid||'
                    and t.traj_id='||semtraj||'
                    and t.subtraj_id='||subtraj
    ;
    open refcv for query;
    fetch refcv into refer;
    close refcv;
    --create the episode and return it
    --calcfeatures('belg_sem_episodes_features', refer, 'STOP');
    return sem_episode('STOP',null,null,episode_mpoint.getsemmbb(),refer);
    exception when others then
      dbms_output.put_line(userid||','||gpsidstart||','||tripid||','||
      semtraj||','||subtraj||','||srid);
      dbms_output.put_line('Error_Backtrace...' ||
          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
    */
  end belgmakestop;

  procedure exportdata(intblsemtrajs varchar2, outblsemtrajs varchar2, semtrajsfile varchar2, insubmpoints varchar2, outblsubmpoints varchar2, submpointsfile varchar2) is
  begin
    exportsemtrajs2import(intblsemtrajs, outblsemtrajs, semtrajsfile);
    exportsubmpoints2import(insubmpoints, outblsubmpoints, submpointsfile);
    commit;
  end exportdata;

  procedure exportindmp(tblname varchar2)
  is
    l_handle number; -- Data Pump job handle
    filename varchar2(50);
    l_status varchar2(200);
  begin
    l_handle := dbms_datapump.open(operation=>'EXPORT', job_mode=>'TABLE');
    filename := 'export_of_'||tblname||'.dmp';
    dbms_datapump.add_file(handle=>l_handle, filename=>filename, directory=>'IO');
    dbms_datapump.add_file(handle=>l_handle, filename=>'log_expdp.txt', directory=>'IO', filetype=>dbms_datapump.ku$_file_type_log_file);
    dbms_datapump.metadata_filter(handle=>l_handle, name=>'SCHEMA_EXPR', value=>' in (''HERMES'')');
    dbms_datapump.metadata_filter(handle=>l_handle, name=>'NAME_EXPR', value=>' in ('''||upper(tblname)||''')');
    dbms_datapump.start_job(handle=>l_handle);
    dbms_datapump.wait_for_job(handle=>l_handle, job_state=>l_status);
    dbms_output.put_line ('status = '||l_status);
  exception
    when others then
      dbms_output.put_line ( dbms_utility.format_error_backtrace );
      dbms_datapump.stop_job(l_handle);
      raise_application_error (-20458,sqlerrm);
  end exportindmp;

  procedure importfromdmp(tblname varchar2)
  is
    l_handle number; -- Data Pump job handle
    filename varchar2(50);
    l_status varchar2(200);
  begin
    l_handle := dbms_datapump.open(operation=>'IMPORT', job_mode=>'TABLE');
    filename := 'export_of_'||tblname||'.dmp';
    dbms_datapump.add_file(handle=>l_handle, filename=>filename, directory=>'IO');
    dbms_datapump.add_file(handle=>l_handle, filename=>'log_impdp.txt', directory=>'IO', filetype=>dbms_datapump.ku$_file_type_log_file);
    dbms_datapump.metadata_filter(handle=>l_handle, name=>'SCHEMA_EXPR', value=>' in (''HERMES'')');
    dbms_datapump.metadata_filter(handle=>l_handle, name=>'NAME_EXPR', value=>' in ('''||upper(tblname)||''')');
    dbms_datapump.set_parameter(l_handle,'TABLE_EXISTS_ACTION','SKIP');
    dbms_datapump.metadata_transform(handle=>l_handle, name=>'OID', value=>0);--nested table episodes are not imported
    dbms_datapump.start_job(handle=>l_handle);
    dbms_datapump.wait_for_job(handle=>l_handle, job_state=>l_status);
    dbms_output.put_line ('status = '||l_status);
  exception
    when others then
      dbms_output.put_line ( dbms_utility.format_error_backtrace );
      dbms_datapump.stop_job(l_handle);
      raise_application_error (-20458,sqlerrm);
  end importfromdmp;

  procedure exportsemtrajs2import(intblsemtrajs varchar2, outblsemtrajs varchar2, filename varchar2) is
    l_file utl_file.file_type;
    l_line varchar2(5000);
    sem_trajs sem_trajectory_tab;
    sem_trajs_cur sys_refcursor;
  begin
    l_file := utl_file.fopen('IO', filename||'.sql', 'W');
    l_line:='CREATE TABLE '||outblsemtrajs||' OF SEM_TRAJECTORY
      nested table episodes store as '||substr(outblsemtrajs,1,8)||'_sem_episodes;';
    utl_file.put_line(l_file, l_line);
    open sem_trajs_cur for 'select value(t)
            from '||intblsemtrajs||' t
            --where t.o_id in (271,27,28)
            ';
    loop
      fetch sem_trajs_cur bulk collect into sem_trajs limit 500;
      exit when sem_trajs.count=0;
      for i in sem_trajs.first..sem_trajs.count loop
        l_line:='insert into hermes.'||outblsemtrajs||' (sem_trajectory_tag,srid,episodes,o_id,semtraj_id) values ('''||
            sem_trajs(i).sem_trajectory_tag||''','''||sem_trajs(i).srid||''',hermes.sem_episode_tab(';
        utl_file.put_line(l_file, l_line);
        for epis in (select e.*, deref(e.tlink).subtraj_id eid from table(sem_trajs(i).episodes) e order by deref(e.tlink).subtraj_id ) loop
          if epis.eid=1 then
            l_line:='hermes.sem_episode('''||
              epis.defining_tag||''','''||epis.episode_tag||''','''||epis.activity_tag||''',hermes.sem_mbb(hermes.sem_st_point('||
              epis.mbb.minpoint.x||','||epis.mbb.minpoint.y||',tau_tll.d_timepoint_sec('||epis.mbb.minpoint.t.m_y||','||
              epis.mbb.minpoint.t.m_m||','||epis.mbb.minpoint.t.m_d||','||epis.mbb.minpoint.t.m_h||','||epis.mbb.minpoint.t.m_min||','||
              epis.mbb.minpoint.t.m_sec||')),hermes.sem_st_point('||
              epis.mbb.maxpoint.x||','||epis.mbb.maxpoint.y||',tau_tll.d_timepoint_sec('||epis.mbb.maxpoint.t.m_y||','||
              epis.mbb.maxpoint.t.m_m||','||epis.mbb.maxpoint.t.m_d||','||epis.mbb.maxpoint.t.m_h||','||epis.mbb.maxpoint.t.m_min||','||
              epis.mbb.maxpoint.t.m_sec||'))),null)';
            utl_file.put_line(l_file, l_line);
          else
            l_line:=',hermes.sem_episode('''||
              epis.defining_tag||''','''||epis.episode_tag||''','''||epis.activity_tag||''',hermes.sem_mbb(hermes.sem_st_point('||
              epis.mbb.minpoint.x||','||epis.mbb.minpoint.y||',tau_tll.d_timepoint_sec('||epis.mbb.minpoint.t.m_y||','||
              epis.mbb.minpoint.t.m_m||','||epis.mbb.minpoint.t.m_d||','||epis.mbb.minpoint.t.m_h||','||epis.mbb.minpoint.t.m_min||','||
              epis.mbb.minpoint.t.m_sec||')),hermes.sem_st_point('||
              epis.mbb.maxpoint.x||','||epis.mbb.maxpoint.y||',tau_tll.d_timepoint_sec('||epis.mbb.maxpoint.t.m_y||','||
              epis.mbb.maxpoint.t.m_m||','||epis.mbb.maxpoint.t.m_d||','||epis.mbb.maxpoint.t.m_h||','||epis.mbb.maxpoint.t.m_min||','||
              epis.mbb.maxpoint.t.m_sec||'))),null)';
            utl_file.put_line(l_file, l_line);
          end if;
        end loop;
        l_line:='),'''||sem_trajs(i).o_id||''','''||sem_trajs(i).semtraj_id||''');';
        utl_file.put_line(l_file, l_line);
      end loop;
    end loop;
    close sem_trajs_cur;
    utl_file.put_line(l_file, 'commit;');
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
  end exportsemtrajs2import;

  procedure exportsubmpoints2import(intblsubmpoints varchar2, outblsubmpoints varchar2, filename varchar2) is
    l_file utl_file.file_type;
    l_line varchar2(5000);
    sub_mpoints sub_moving_point_tab;
    sub_mpoints_cur sys_refcursor;
    utabcounter integer:=0;
  begin
    l_file := utl_file.fopen('IO', filename||'.sql', 'W');
    l_line:='CREATE TABLE '||outblsubmpoints||' OF SUB_MOVING_POINT;';
    utl_file.put_line(l_file, l_line);
    open sub_mpoints_cur for 'select value(t)
            from '||intblsubmpoints||' t
            --where t.o_id in (271,27,28)
            ';
    loop
      fetch sub_mpoints_cur bulk collect into sub_mpoints limit 500;
      exit when sub_mpoints.count=0;
      for i in sub_mpoints.first..sub_mpoints.count loop
        l_line:='insert into hermes.'||outblsubmpoints||' (o_id,traj_id,subtraj_id,sub_mpoint) values ('||
            sub_mpoints(i).o_id||','||sub_mpoints(i).traj_id||','||sub_mpoints(i).subtraj_id||',hermes.moving_point(hermes.moving_point_tab(';
        utl_file.put_line(l_file, l_line);
        utabcounter:=0;
        for utab in (select u.* from table(sub_mpoints(i).sub_mpoint.u_tab) u) loop
          utabcounter:=utabcounter+1;
          if utabcounter=1 then
            l_line:='hermes.unit_moving_point(tau_tll.d_period_sec(tau_tll.d_timepoint_sec('||
              utab.p.b.m_y||','||utab.p.b.m_m||','||utab.p.b.m_d||','||utab.p.b.m_h||','||utab.p.b.m_min||','||utab.p.b.m_sec||')
              ,tau_tll.d_timepoint_sec('||utab.p.e.m_y||','||utab.p.e.m_m||','||utab.p.e.m_d||','||utab.p.e.m_h||','||utab.p.e.m_min||','||utab.p.e.m_sec||'))
              ,hermes.unit_function('||utab.m.xi||','||utab.m.yi||','||utab.m.xe||','||utab.m.ye||',null,null,null,null,null,''plnml_1''))';
            utl_file.put_line(l_file, l_line);
          else
            l_line:=',hermes.unit_moving_point(tau_tll.d_period_sec(tau_tll.d_timepoint_sec('||
              utab.p.b.m_y||','||utab.p.b.m_m||','||utab.p.b.m_d||','||utab.p.b.m_h||','||utab.p.b.m_min||','||utab.p.b.m_sec||')
              ,tau_tll.d_timepoint_sec('||utab.p.e.m_y||','||utab.p.e.m_m||','||utab.p.e.m_d||','||utab.p.e.m_h||','||utab.p.e.m_min||','||utab.p.e.m_sec||'))
              ,hermes.unit_function('||utab.m.xi||','||utab.m.yi||','||utab.m.xe||','||utab.m.ye||',null,null,null,null,null,''plnml_1''))';
            utl_file.put_line(l_file, l_line);
          end if;
        end loop;
        l_line:='),'||sub_mpoints(i).traj_id||','||sub_mpoints(i).sub_mpoint.srid||'));';
        utl_file.put_line(l_file, l_line);
      end loop;
    end loop;
    close sub_mpoints_cur;
    utl_file.put_line(l_file, 'commit;');
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
  end exportsubmpoints2import;

  procedure updatesubmpointrefs(intblsemtrajs varchar2, insubmpoints varchar2) is
    sem_trajs_cur sys_refcursor;
    sem_trajs sem_trajectory_tab;
    type sem_epis_tab_typ is varray(1000) of sem_episode;
    sem_epis_tab sem_episode_tab;
    refer ref sub_moving_point; notfound number:=0;
    outsemtrajs sem_trajectory_tab:=sem_trajectory_tab();
  begin
    open sem_trajs_cur for 'select value(t)
            from '||intblsemtrajs||' t
            --where t.o_id in (271,272)
            ';
    loop
      fetch sem_trajs_cur bulk collect into sem_trajs limit 500;
      exit when sem_trajs.count=0;
      --for every sem traj of intblsemtrajs
      for i in sem_trajs.first..sem_trajs.count loop
        --get episodes in an array
        select value(e) bulk collect into sem_epis_tab from table(sem_trajs(i).episodes) e;-- order by deref(e.tlink).subtraj_id; e.tlink is null!!!
        --for each episode
        for j in sem_epis_tab.first..sem_epis_tab.last loop
          --find sub from insubmpoints based on start time, hopefully it works...
          begin
            execute immediate 'begin select ref(s) into :refer
              from '||insubmpoints||' s, table(s.sub_mpoint.u_tab) u
              where s.o_id=:o_id and s.traj_id=:semtraj_id
              and u.p.b.m_y=:m_y and u.p.b.m_m=:m_m and u.p.b.m_d=:m_d
              and u.p.b.m_h=:m_h and u.p.b.m_min=:m_min and u.p.b.m_sec=:m_sec;end;'
              using out refer, in sem_trajs(i).o_id, in sem_trajs(i).semtraj_id, in sem_epis_tab(j).mbb.minpoint.t.m_y,
                in sem_epis_tab(j).mbb.minpoint.t.m_m, in sem_epis_tab(j).mbb.minpoint.t.m_d, in sem_epis_tab(j).mbb.minpoint.t.m_h,
                in sem_epis_tab(j).mbb.minpoint.t.m_min, in sem_epis_tab(j).mbb.minpoint.t.m_sec;
            exception
              when no_data_found then
                refer:=null;
          end;
          --update episodes ref
          if refer is null then
            notfound:=notfound+1;
          end if;
          sem_epis_tab(j).tlink:=refer;
          refer := null;
        end loop;
        --create a temp array of sem trajs
        outsemtrajs.extend(1);
        outsemtrajs(outsemtrajs.last):=sem_trajectory(sem_trajs(i).sem_trajectory_tag,sem_trajs(i).srid,sem_epis_tab,sem_trajs(i).o_id,sem_trajs(i).semtraj_id,sem_trajs(i).profile_id);
      end loop;
    end loop;
    close sem_trajs_cur;
    --delete intblsemtrajs
    execute immediate 'delete '||intblsemtrajs;
    --insert the modified sem traj
    execute immediate 'insert into '||intblsemtrajs||'
      select sem_trajectory(t.sem_trajectory_tag,t.srid,t.episodes,t.o_id,t.semtraj_id)
      from table(:semtrajs) t' using in outsemtrajs;
    commit;
    dbms_output.put_line('Refs not found=> '||notfound);
  end updatesubmpointrefs;

  procedure fixsubmpoints(oid integer,tid integer,subtid integer,tab integer) is
    i integer;
    o_id integer;
    traj_id integer;
    subtraj_id integer;
    srid integer;
    tpb tau_tll.d_timepoint_sec;
    tpe tau_tll.d_timepoint_sec;
    utab moving_point_tab;
    ntab moving_point_tab;
    tmp_mpoint moving_point;
    nextfix boolean:=false;
  begin
    i:=0;
    delete sub_mpoints_tmp s;
    commit;
    -- Test statements here
    --delete a segment
    for c in (select * from scen_1day_28clas_subs bs --change table
      where bs.o_id=oid and bs.traj_id=tid and bs.subtraj_id=subtid
      order by bs.o_id,bs.traj_id,bs.subtraj_id
      )loop
      utab:=c.sub_mpoint.u_tab;
      srid:=c.sub_mpoint.srid;
      traj_id:=tid;
      ntab:=moving_point_tab();
      for j in utab.first..utab.last loop
        if (j=tab) then
          utab(j).p.e:=utab(j+1).p.e;
          utab(j).m.xe:=utab(j+1).m.xe;
          utab(j).m.ye:=utab(j+1).m.ye;
          ntab.extend;
          ntab(ntab.last):=utab(j);
          null;
        elsif (j=tab+1) then
          null;
        else
          ntab.extend;
          ntab(ntab.last):=utab(j);
        end if;
      end loop;
      tmp_mpoint:=moving_point(ntab,traj_id,srid);
      insert into sub_mpoints_tmp
        (o_id, traj_id, subtraj_id, sub_mpoint)
      values
        (oid, tid, subtid, tmp_mpoint);
      commit;
      update scen_1day_28clas_subs s --change table
        set s.sub_mpoint=(
        select st.sub_mpoint
        from sub_mpoints_tmp st
        where st.o_id=s.o_id
        and st.traj_id=s.traj_id
        and st.subtraj_id=s.subtraj_id
        )
        where (s.o_id,s.traj_id,s.subtraj_id) in (
        select sts.o_id,sts.traj_id,sts.subtraj_id
        from sub_mpoints_tmp sts
        );
        commit;
        --
      /*for j in utab.first..utab.last loop
        o_id:=c.o_id;
        traj_id :=c.traj_id;
        subtraj_id :=c.subtraj_id;
        tpb:=utab(j).p.b;
        tpe:=utab(j).p.e;
        if(nextfix=true) then
          utab(j).p.b.set_abs_date(tpb.get_abs_date + 0.200);
          --store submpoint somewhere to upd sub_mpoints when done
          tmp_mpoint:=moving_point(utab,traj_id,4326);
          dbms_output.put_line(o_id||','||traj_id||','||subtraj_id||','||j);
          insert into sub_mpoints_tmp
            (o_id, traj_id, subtraj_id, sub_mpoint)
          values
            (o_id, traj_id, subtraj_id, tmp_mpoint);
          commit;
          nextfix:=false;
        end if;
        if(tpb.f_eq(tpb,tpe)=1) then
          utab(j).p.e.set_abs_date(tpe.get_abs_date + 0.200);
          nextfix:=true;
        end if;
      end loop;*/
      /*for c2 in (select * from table(c.sub_mpoint.u_tab))loop
        o_id:=c.o_id;
        traj_id :=c.traj_id;
        subtraj_id :=c.subtraj_id;
        if (not c.sub_mpoint.check_sorting) then
          dbms_output.put_line(o_id||','||traj_id||','||subtraj_id);
        end if;
      end loop;*/
    end loop;
    /*exception
      when others then
        dbms_output.put_line(o_id||','||traj_id||','||subtraj_id);*/

  end fixsubmpoints;


-- **
-- * Returns srid for a given parameter table
-- *
-- * @param tablename. The name of the table with the parameter. Max size 30char. Ex: pkg_x.var_y
-- * @param parametername. The name of the parameter we want. Max size 30char
-- * @return varchar2 value
-- **
FUNCTION getparameter
  (
    tablename     IN VARCHAR2,
    parametername IN VARCHAR2
  )
  RETURN VARCHAR2
AS
  v_string VARCHAR2
  (
    4000
  )
  ;
BEGIN
  IF LENGTH (tablename) > 30 OR LENGTH (parametername) > 30 THEN
    RAISE ex_custom;
  END IF;
  --assumes that parametername is a column name of table tablename
  stmt :=' SELECT '|| parametername|| ' FROM '|| tablename|| ' WHERE rownum < 2';
  --DBMS_OUTPUT.put_line (stmt);
  EXECUTE IMMEDIATE stmt INTO v_string;
  RETURN v_string;
EXCEPTION
WHEN ex_custom THEN
  raise_application_error (-20001, 'Max allowed length is 30 char');
end getparameter;

procedure pois_probability (mbb in sem_mbb, insrid pls_integer, is4visualize in varchar2, poitable varchar2,bestpoitag out varchar2)
--HARD CODED VALUES!!!
IS
  mbb_geom MDSYS.SDO_GEOMETRY;
  mbb_centroid MDSYS.SDO_GEOMETRY;
  total_distance NUMBER  := 0;
  sum_step1      NUMBER  := 0;
  i              integer := 0;
  max_prob		number:=-1;
begin
  null;
/*
  select sdo_geom.sdo_mbr(sdo_geom.sdo_buffer(mbb.getrectangle (insrid),5000,0.005)),
    MDSYS.sdo_geom.sdo_centroid (mbb.getrectangle (insrid), 100)
  INTO mbb_geom,
    mbb_centroid
  FROM DUAL;
  if upper (is4visualize) = bltrue then
    visualizer.placemark2kml (mbb_centroid,4326, 'EPISODE_CENTROID.kml', 'CENTROID ', ' ' );
    visualizer.polygon2kml (mbb_geom, 4326, 'EPISODE_RECTANGLE.kml');
  end if;
  SELECT SUM(MDSYS.sdo_geom.sdo_distance (mdsys.sdo_geometry (2001, insrid,
    mdsys.sdo_point_type (x, y, NULL ), NULL, NULL),mbb_centroid,tolerance ))
  into total_distance
  --from (select distinct id, name, type,district,city, state,country,
  from (select name,
  	x,y FROM hermes.IMIS_3DAYS_PORTS) poi--here we should put parameter poitable
  WHERE sdo_geom.relate (mbb_geom, 'CONTAINS+TOUCH',
  	get_long_lat_pt (poi.x, poi.y,2100), 0.001 ) = 'CONTAINS+TOUCH';
  IF UPPER (is4visualize) = bltrue THEN
    DBMS_OUTPUT.put_line ( CHR (13) || CHR (10) || 'ttl_dist: ' || total_distance );
  end if;
  select round (sum ( total_distance / ( mdsys.sdo_geom.sdo_distance (mdsys.sdo_geometry (2001, insrid,
    MDSYS.sdo_point_type (x, y, NULL ), NULL, NULL ), mbb_centroid, tolerance ) ) ), 2 )
  into sum_step1 from(select name,
  			x, y FROM hermes.IMIS_3DAYS_PORTS) poi--here we should put parameter poitable
  WHERE sdo_geom.relate (mbb_geom, 'CONTAINS+TOUCH',
  	get_long_lat_pt (poi.x, poi.y,2100), 0.001 ) = 'CONTAINS+TOUCH';
  IF UPPER (is4visualize) = bltrue THEN
    DBMS_OUTPUT.put_line (CHR (13) || CHR (10) || 'sum_step1: ' || sum_step1 );
  END IF;
  FOR rc_prop IN
  (select name, x, y,
    MDSYS.sdo_geom.sdo_distance (MDSYS.SDO_GEOMETRY (2001, insrid,
    	MDSYS.sdo_point_type (x, y, NULL ), NULL, NULL ),
	mbb_centroid, tolerance ) distance,
    round ( ( total_distance / ( mdsys.sdo_geom.sdo_distance (
    	MDSYS.SDO_GEOMETRY (2001, insrid, MDSYS.sdo_point_type (x, y, NULL ), NULL, NULL ),
	 mbb_centroid, tolerance ) ) ) / sum_step1, 2 ) prop
  from (select name,
  	x, y FROM hermes.IMIS_3DAYS_PORTS) poi--here we should put parameter poitable
  WHERE sdo_geom.relate (mbb_geom, 'CONTAINS+TOUCH',
  	get_long_lat_pt (poi.x, poi.y,2100 ), 0.001 ) = 'CONTAINS+TOUCH'
  GROUP BY name , x, y) LOOP
    IF UPPER (is4visualize) = bltrue THEN
      dbms_output.put_line ( chr (13) || chr (10) || ' NAME, TYPE, DISTRICT, CITY, STATE, COUNTRY, ACTIVITY: '
        || rc_prop.name || ', '
        || chr (13) || chr (10) || ' propability: '
        || rc_prop.prop || CHR (13) || CHR (10) || ' distance from centroid:' || rc_prop.distance || CHR (13) || CHR (10) );
      visualizer.placemark2kml (mdsys.sdo_geometry (2001, 2100, mdsys.sdo_point_type (rc_prop.x, rc_prop.y, null ),
      NULL, NULL ), 4326, i || '_POINT.kml', 'POINT: ' || rc_prop.name || ' Probability:' || rc_prop.prop,' ' );
    end if;
    if (max_prob < rc_prop.prop) then
			max_prob:=rc_prop.prop;
			bestpoitag:=rc_prop.name;
		end if;
    i := i + 1;
  END LOOP;
  */
END pois_probability;

PROCEDURE nn_pois (mbb IN sem_mbb, k INTEGER, is4visualize IN VARCHAR2)
IS
  mbb_geom MDSYS.SDO_GEOMETRY;
  mbb_centroid MDSYS.SDO_GEOMETRY;
  i INTEGER := 0;
begin
  null;
  /*
  srid := 2100;
  SELECT mbb.getrectangle (srid),
    MDSYS.sdo_geom.sdo_centroid (mbb.getrectangle (srid), 100)
  INTO mbb_geom,
    mbb_centroid
  FROM DUAL;
  if upper (is4visualize) = bltrue then
    visualizer.placemark2kml (mbb_centroid, 4326, 'EPISODE_CENTROID.kml', 'CENTROID', ' ' );
    visualizer.polygon2kml (mbb_geom, 4326, 'EPISODE_RECTANGLE.kml');
  END IF;
  FOR rc_sdonn IN
  (SELECT NAME,
    x, y
  from hermes.imis_3days_ports poi
                    where sdo_nn (POI.GEOM,mbb_centroid,  'sdo_num_res=' || k ) = 'TRUE'
  AND sdo_geom.relate (mbb_geom, 'CONTAINS+TOUCH', POI.GEOM, 0.001 ) = 'CONTAINS+TOUCH') LOOP
    IF UPPER (is4visualize) = bltrue THEN
      dbms_output.put_line ( chr (13) || chr (10) || ' NAME'
        || rc_sdonn.name);
      visualizer.placemark2kml (MDSYS.SDO_GEOMETRY (2001, 2100, MDSYS.sdo_point_type (rc_sdonn.x, rc_sdonn.y, NULL ),
        NULL, NULL ), 4326, i || '_POINT.kml', 'POI: ' || rc_sdonn.NAME, ' ' );
    END IF;
    i := i + 1;
  END LOOP;
  */
END nn_pois;

  procedure annotate_episodes(semtrajs varchar2, poitable varchar2) is
    stmt varchar2(4000);
    genericcur sys_refcursor;
    semtraj sem_trajectory;
    stop_episode_tag varchar2(50);
    episode_avgspeed number;
    move_activity_tag varchar2(50);
    sub_mpoint moving_point;
    srid pls_integer;
  begin
    stmt := 'select value(s)
        from '||semtrajs||' s
        --where s.o_id=5238 and s.semtraj_id=1
        order by s.o_id, s.semtraj_id';--just in case
    open genericcur for stmt;
    loop
      fetch genericcur into semtraj;--one by one, if bulk collect consider using limit
      exit when genericcur%notfound;
      srid:=semtraj.srid;
      --update episode tag in memory
      for e in  semtraj.episodes.first..semtraj.episodes.last loop
        stop_episode_tag := null;--start over
        if (upper(semtraj.episodes(e).defining_tag)=upper('STOP')) then
          if (semtraj.episodes(e).episode_tag is null) then--or is null
            sem_reconstruct.pois_probability(semtraj.episodes(e).mbb,srid,'FALSE',poitable,stop_episode_tag);
            semtraj.episodes(e).episode_tag:=stop_episode_tag;
          end if;
        elsif (upper(semtraj.episodes(e).defining_tag)=upper('MOVE')) then
          null;
          /*
          select deref(semtraj.episodes(e).tlink).sub_mpoint into sub_mpoint from dual;
          episode_avgspeed:=sub_mpoint.f_avg_speed;
          dbms_output.put_line(episode_avgspeed);
          if episode_avgspeed < 10 then
              semtraj.episodes(e).activity_tag:='foot';
          elsif episode_avgspeed >= 10 and episode_avgspeed < 20 then
              semtraj.episodes(e).activity_tag:='bike';
          elsif episode_avgspeed >= 20 and episode_avgspeed < 40 then
              semtraj.episodes(e).activity_tag:='moped';
          elsif episode_avgspeed >= 40 and episode_avgspeed < 60 then
              semtraj.episodes(e).activity_tag:='bus' ;
          elsif episode_avgspeed >= 60 then
              semtraj.episodes(e).activity_tag:='car';
          end if;
          */
        else
          null;
        end if;
      end loop;
      --delete old object and insert new
      stmt:='delete from '||semtrajs||' s where s.o_id=:oid and s.semtraj_id=:semtrajid';
      execute immediate stmt using semtraj.o_id,semtraj.semtraj_id;
      commit;
      stmt:='insert into '||semtrajs||' s values(:semtraj)';
      execute immediate stmt using semtraj;
      commit;
    end loop;
  end annotate_episodes;

  procedure submpointsmerging(submpoints varchar2, mpoints varchar2) is
    cur_semtrajs sys_refcursor;
    stmt varchar2(4000);
    type sem_traj_id_typ is record(
         o_id integer,
         semtraj_id integer);
    type sem_traj_ids_typ is table of sem_traj_id_typ;
    sem_traj_ids sem_traj_ids_typ;
    cur_sub_mpoints sys_refcursor;
    mp_array_var mp_array;
    mpoint moving_point;
    procedure store(o_id integer,trajid integer,mpoint moving_point) is

    begin
      execute immediate 'insert into '||mpoints||' values(:o_id,:trajid,:mpoint)'
              using in o_id,in trajid, in mpoint;
      commit;
    end store;
  begin
    stmt:='select distinct m.o_id,m.traj_id from '||submpoints||' m order by m.o_id,m.traj_id';
    --stmt:='select distinct m.traj_id from '||submpoints||' m order by m.traj_id';
    open cur_semtrajs for stmt;
    loop
      fetch cur_semtrajs bulk collect into sem_traj_ids limit 2000;
      exit when sem_traj_ids.count = 0;
      for i in sem_traj_ids.first..sem_traj_ids.last loop
        stmt := 'select m.sub_mpoint from '||submpoints||' m where m.o_id=:o_id and m.traj_id=:traj_id order by m.subtraj_id';
        open cur_sub_mpoints for stmt using in sem_traj_ids(i).o_id,in sem_traj_ids(i).semtraj_id;
        fetch cur_sub_mpoints bulk collect into mp_array_var;
        close cur_sub_mpoints;
        for j in mp_array_var.first..mp_array_var.last loop
          if (j=1) then--first sub mpoint
            mpoint := mp_array_var(j);
          else
            mpoint := mpoint.merge_moving_points(mpoint, mp_array_var(j));
            mpoint.traj_id := sem_traj_ids(i).semtraj_id;
          end if;
        end loop;
        store(sem_traj_ids(i).o_id,sem_traj_ids(i).semtraj_id,mpoint);
      end loop;
    end loop;
    close cur_semtrajs;
  end submpointsmerging;

BEGIN
  -- Package Initialization
  null;
END sem_reconstruct;
/


