Prompt Type Body SEM_TRAJECTORY;
CREATE OR REPLACE type body               SEM_TRAJECTORY is



  -- Member procedures and functions
  member function sem_stops return sem_episode_tab is
   stop_episodes sem_episode_tab := sem_episode_tab();
  begin
    for i in episodes.first..episodes.last loop
      if upper(episodes(i).defining_tag) = 'STOP' then
        stop_episodes.extend();
        stop_episodes(stop_episodes.last):=episodes(i);
      end if;
    end loop;
    return stop_episodes;
  end sem_stops;

  member function sem_moves return sem_episode_tab is
   move_episodes sem_episode_tab := sem_episode_tab();
  begin
    for i in episodes.first..episodes.last loop
      if upper(episodes(i).defining_tag) = 'MOVE' then
        move_episodes.extend();
        move_episodes(move_episodes.last):=episodes(i);
      end if;
    end loop;
    return move_episodes;
  end sem_moves;

  member function episodes_with(tag varchar2) return sem_episode_tab is
  /*
  This function takes as input a "tag" string less than 1000 chars of the form "tag1+tag2+....+tagn".
  It returns the number of episodes that have tags LIKE those given. LIKE means pattern-matching per input tag.
  Episodes are returned once even though they may match multiple times with some input tags. A null collection
  is returned when none episode is found. Can not be used when tlink is null.
  */
  stmt varchar2(4000);
  inputtag varchar2(1000);
  toolong exception;emptytag  exception;
  plusplace pls_integer;
  newtag varchar2(150);
  tags varchar_ntab:=varchar_ntab();
  cur sys_refcursor;
  return_episodes sem_episode_tab;
  begin
    if length(tag)>1000 then
      raise toolong;
    end if;
    if length(tag)=0 then
      raise emptytag;
    end if;
    inputtag:=tag;
    loop
    plusplace:=instr(inputtag,'+');
    if plusplace <>0 then
      newtag:=substr(inputtag,1,plusplace-1);
      if length(newtag)>0 then
        --dbms_output.put_line(newtag);
        tags.extend();
        tags(tags.last):='%'||newtag||'%';
      end if;
      inputtag:=substr(inputtag,plusplace+1);
    else
      newtag:=substr(inputtag,1);
      if length(newtag)>0 then
        --dbms_output.put_line(newtag);
        tags.extend();
        tags(tags.last):='%'||newtag||'%';
      end if;
      exit;
    end if;
    end loop;
    
    --a better way is to have object sem_episode or sem_mbb a map method 
    stmt:='select sem_episode(eo.defining_tag,eo.episode_tag,eo.activity_tag,eo.mbb,eo.tlink)
      from table(:episodes) eo,(
        select distinct e.tlink
        from table(:episodes) e,
        (select upper(column_value) u from table(:tags)) inp
        where upper(e.defining_tag)||upper(e.episode_tag)||upper(e.activity_tag) like inp.u
        and e.tlink is not null
      )ei 
      where eo.tlink=ei.tlink';
    
    open cur for stmt using in self.episodes, in self.episodes, in tags;
    fetch cur bulk collect into return_episodes;
    close cur;    
    
    if return_episodes.count = 0 then
      return null;
    else
      return return_episodes;
    end if;
    exception
      when toolong then
        dbms_output.put_line('Input tag is too long');
        return null;
      when emptytag then
        dbms_output.put_line('Input tag is empty');
        return null;
      /*when others then
        dbms_output.put_line('ERROR');*/ 
  end episodes_with;

  member function num_of_stops return integer is
  num integer:=0;
  begin
    if (episodes.count = 0) then
      return 0;
    end if;
    for i in episodes.first..episodes.last loop
      if upper(episodes(i).defining_tag) = 'STOP' then
        num := num +1;
      end if;
    end loop;
    return num;
    exception when others then
      dbms_output.put_line('Error on counting stops for obj:'||self.o_id||' traj :'||self.semtraj_id);
  end num_of_stops;

  member function num_of_moves return integer is
  num integer:=0;
  begin
    if (episodes.count = 0) then
      return 0;
    end if;
    for i in episodes.first..episodes.last loop
      if upper(episodes(i).defining_tag) = 'MOVE' then
        num := num +1;
      end if;
    end loop;
    return num;
    exception when others then
      dbms_output.put_line('Error on counting moves for obj:'||self.o_id||' traj :'||self.semtraj_id);
  end num_of_moves;
  
  member function num_of_episodes(tag varchar2, uniques varchar2) return pls_integer is
  /*
  This function takes as input a "tag" string less than 1000 chars of the form "tag1+tag2+....+tagn",
  a "uniques" string of values "yes" or "no"(default). It returns the number of episodes (unique or not) that
  have tags LIKE those given. LIKE means pattern-matching per input tag. Number zero is returned if none
  episode is found. Can not be used when tlink is null.
  */
  inputtag varchar2(1000);
  toolong exception;emptytag  exception;
  plusplace pls_integer;
  newtag varchar2(150);
  tags varchar_ntab:=varchar_ntab();
  howmany integer;
  begin
    if length(tag)>1000 then
      raise toolong;
    end if;
    if length(tag)=0 then
      raise emptytag;
    end if;
    inputtag:=tag;
    loop
    plusplace:=instr(inputtag,'+');
    if plusplace <>0 then
      newtag:=substr(inputtag,1,plusplace-1);
      if length(newtag)>0 then
        --dbms_output.put_line(newtag);
        tags.extend();
        tags(tags.last):='%'||newtag||'%';
      end if;
      inputtag:=substr(inputtag,plusplace+1);
    else
      newtag:=substr(inputtag,1);
      if length(newtag)>0 then
        --dbms_output.put_line(newtag);
        tags.extend();
        tags(tags.last):='%'||newtag||'%';
      end if;
      exit;
    end if;
    end loop;
    if upper(uniques)=upper('yes') then
      --a better way is to have object sem_episode or sem_mbb a map method 
      select count(distinct e.tlink) into howmany
      from table(self.episodes) e,--self.episodes
      (select upper(column_value) u from table(tags)) inp
      where upper(e.defining_tag)||upper(e.episode_tag)||upper(e.activity_tag) like inp.u
      and e.tlink is not null;
    else
      select count(e.tlink) into howmany 
      from table(self.episodes) e,--self.episodes
      (select upper(column_value) u from table(tags)) inp
      where upper(e.defining_tag)||upper(e.episode_tag)||upper(e.activity_tag) like inp.u
      and e.tlink is not null;
    end if;
    --dbms_output.put_line(howmany);
    return howmany;
    exception
      when toolong then
        dbms_output.put_line('Input tag is too long');
        return -1;
      when emptytag then
        dbms_output.put_line('Input tag is empty');
        return -2;
      /*when others then
        dbms_output.put_line('ERROR');*/ 
  end num_of_episodes;
  
  member function timeorderepisodes return sem_episode_tab is
  /*
  This function ordering episodes according to corresponding
  sub trajectories as oracle does not return nested tables in a specific order.
  */
    episodesordered sem_episode_tab;
  begin
    select value(e)
      bulk collect into episodesordered
      from table(self.episodes) e
      order by deref(e.tlink).subtraj_id;
    return episodesordered;
  end;
  
  member function tompoint return moving_point is
  /*
  This function takes episodes of semantic trajectory, checks their ordering according to corresponding
  sub trajectories of each episode and then merges sub trajectories to one moving_point.
  Episodes ordering normally should be in accordance with sub trajectories ids.
  */
    mpoint moving_point;
    submpoint sub_moving_point;
    watcher integer;
    episodesordered sem_episode_tab;
  begin
    episodesordered:=timeorderepisodes;
    for i in episodesordered.first..episodesordered.last loop
      watcher:=i;
      select deref(episodesordered(i).tlink) into submpoint from dual;
      if (i=1) then
        mpoint:=submpoint.sub_mpoint;
      else
        mpoint :=mpoint.merge_moving_points(mpoint,submpoint.sub_mpoint);
      end if;
    end loop;
    mpoint.traj_id:=self.semtraj_id;
    return mpoint;
    exception
      when others then
        dbms_output.put_line('ERROR at oid:'||self.o_id||' semtraj:'||self.semtraj_id||' episode:'||watcher);
  end tompoint;

  member function getMBB return sem_mbb is
    resmbb sem_mbb;
    minx number:=10000000;
    maxx number:=-10000000;
    miny number:=10000000;
    maxy number:=-10000000;
    mint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(3000,1,1,0,0,0);
    maxt tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,0,0,0);
  begin
    for i in episodes.first..episodes.last loop
      if (episodes(i).mbb.minpoint.x < minx) then
        minx :=episodes(i).mbb.minpoint.x;
      end if;
      if (episodes(i).mbb.minpoint.y < miny) then
        miny :=episodes(i).mbb.minpoint.y;
      end if;
      if (episodes(i).mbb.minpoint.t.get_abs_date() < mint.get_abs_date()) then
        mint :=episodes(i).mbb.minpoint.t;
      end if;
      if (episodes(i).mbb.maxpoint.x > maxx) then
        maxx :=episodes(i).mbb.maxpoint.x;
      end if;
      if (episodes(i).mbb.maxpoint.y > maxy) then
        maxy :=episodes(i).mbb.maxpoint.y;
      end if;
      if (episodes(i).mbb.maxpoint.t.get_abs_date() > maxt.get_abs_date()) then
        maxt :=episodes(i).mbb.maxpoint.t;
      end if;
    end loop;
    resmbb:=sem_mbb(sem_st_point(minx,miny,mint),sem_st_point(maxx,maxy,maxt));
    return resmbb;
  end getmbb;
  
  
  member function confined_in(geom sdo_geometry,period tau_tll.d_period_sec,tag varchar2) return sem_trajectory is
  /*
  This function takes as input a sdo_geometry object, a tau_tll.d_period_sec object 
  and a string object less than 1000 chars of the form "tag1+tag2+....+tagn".
  It returns a sem_trajectory object whose episodes are intersecting with parameters, that is, 
  spatially intersecting with sdo_geometry parameter, temporally with d_period_sec parameter
  and textually with tag parameter. If none such episode found the sem_trajectory instance without episodes
  is returned.
  User can set null to geom and period parameters if he/she wants not to have any spatial or temporal constraints.
  The same can happen for text constraints when the user sets % for parameter tag
  */
  outsemtraj sem_trajectory;
  inmbb sem_mbb;
  outepisodes sem_episode_tab;
  ingeom sdo_geometry;
  inperiod tau_tll.d_period_sec;
  intag varchar2(50);
  begin    
    outsemtraj:=sem_trajectory(self.sem_trajectory_tag,self.srid,sem_episode_tab(),self.o_id,self.semtraj_id);
    inmbb:=self.getmbb();--in case a parameter is null
    if (geom is null) then
      ingeom:=sdo_geometry(2003,self.srid,NULL,SDO_ELEM_INFO_ARRAY(1,1003,3),
        SDO_ORDINATE_ARRAY(inmbb.minpoint.x,inmbb.minpoint.y, inmbb.maxpoint.x,inmbb.maxpoint.y));
    else
      ingeom:=geom;
    end if;
    if (period is null) then
      inperiod:=tau_tll.d_period_sec(inmbb.minpoint.t,inmbb.maxpoint.t);
    else
      inperiod:=period;
    end if;
    if (tag is null) then
      intag:='%';
    else
      intag:=tag;
    end if;
    inmbb:=sem_mbb(null,null).to_sem_mbb(ingeom, inperiod);--here a null check is performed also..
    outepisodes:=self.episodes_with(intag);
    if outepisodes is not null then
      for i in outepisodes.first..outepisodes.last loop
        if outepisodes(i).mbb.intersects(inmbb) then
          outsemtraj.episodes.extend();
          outsemtraj.episodes(outsemtraj.episodes.last):=outepisodes(i);
        end if;
      end loop;
    end if;
    return outsemtraj;
  end confined_in;

  member function sim_trajectories(tr sem_trajectory,dbtable varchar2,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number is
  /*
  This function takes as input another sem_trajectory object, a dataset table for calculating global values
  needed , an optional index prefix if such an index (STBTREE) is built, an optional value for lamda parameter,
  an optional 3 number array for weight parameter. It returns a number that defines the distance between
  this semantic trajectory object and the input semantic trajectory.
  */
  type distmatrix_row_typ is table of number index by pls_integer;
  type distmatrix_typ is table of distmatrix_row_typ index by pls_integer;
  distmatrix distmatrix_typ;--assoc array
  minx number;miny number;
  mint tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
  mint2 tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
  mintime number;
  gap_episode sem_episode;
  tr1episodes number;tr2episodes number;
  distepis number;
  dist_diag number;dist_hor number;dist_vert number;
  dbtablenull exception;
  begin
  --dbms_output.enable (buffer_size => null);
  /*
  this is hardcoded for now but you can take those values from dbtable
  parameter executing a select query [select max(e.mbb.maxpoint.x) maxx,min(e.mbb.minpoint.x) minx
  ,max(e.mbb.maxpoint.y) maxy, min(e.mbb.minpoint.y) miny
  ,max(e.mbb.maxpoint.t.get_abs_date()) maxt,
  min(e.mbb.minpoint.t.get_abs_date()) mint
  from belg_sem_trajs t,table(t.episodes) e]
  
  select minlongitude,minlatitude,mintime
  into minx,miny,mint
  from belg_dataset_dimensions;
  */
  
  if (dbtable is null) then
    raise dbtablenull;--or cr a table with the two given sem_trajs in an recall this function passing it, see mydebug
  end if;
  
  execute immediate 'begin select min(e.mbb.minpoint.x), min(e.mbb.minpoint.y), min(e.mbb.minpoint.t.get_abs_date())
    into :minx,:miny,:mint from '||dbtable|| ' t,table(t.episodes) e;end;'
    using out minx, out miny, out mintime;
  
  mint.set_abs_date(mintime);
  mint2.set_abs_date(mintime+1);
  
  gap_episode:=sem_episode('****','****','****',
  sem_mbb(sem_st_point(minx,miny,mint),sem_st_point(minx+1,miny+1, mint2)),null);--minimal extend in meters
  
  --dynamic programming
  tr1episodes:=self.episodes.count;--num_of_episodes('STOP+MOVE','yes');
  tr2episodes:=tr.episodes.count;
  if (dbtable is not null) then
    --step 1
    for i in 1..tr1episodes+1 loop--one more element for gap_episode
      distmatrix(1)(i):=0;  
    end loop;
    for i in 2..tr1episodes+1 loop
      distmatrix(1)(i):=distmatrix(1)(i) + self.episodes(tr1episodes+2-i).sim_episodes(gap_episode,dbtable,indxprefix,lamda, weight);
    end loop;
    --step 2
    for j in 1..tr2episodes+1 loop--one more element for gap_episode
      distmatrix(j)(1):=0;  
    end loop;
    for j in 2..tr2episodes+1 loop
        distmatrix(j)(1):=distmatrix(j)(1) + tr.episodes(tr2episodes+2-j).sim_episodes(gap_episode,dbtable,indxprefix,lamda, weight);
    end loop;
    --step 3
    for i in 2..tr1episodes+1 loop--one more element for gap_episode
      for j in 2..tr2episodes+1 loop
        dist_diag:=self.episodes(tr1episodes+2-i).sim_episodes(tr.episodes(tr2episodes+2-j),dbtable,indxprefix,lamda, weight);
        dist_hor:=self.episodes(tr1episodes+2-i).sim_episodes(gap_episode,dbtable,indxprefix,lamda, weight);
        dist_vert:=tr.episodes(tr2episodes+2-j).sim_episodes(gap_episode,dbtable,indxprefix,lamda, weight);
        
        distmatrix(j)(i):=least(distmatrix(j-1)(i-1) + dist_diag,
          distmatrix(j-1)(i) + dist_vert, distmatrix(j)(i-1) + dist_hor);
      end loop;  
    end loop;
    return distmatrix(tr2episodes+1)(tr1episodes+1);
  else
    raise dbtablenull;--or cr a table with the two given sem_trajs in an recall this function passing it, see mydebug
  end if;
  
  exception
      when dbtablenull then
        dbms_output.put_line('input dbtable is null');
        raise_application_error(-20000,'input dbtable is null');
  end sim_trajectories;


end;
/


