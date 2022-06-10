Prompt Package Body SDW;
CREATE OR REPLACE package body        SDW is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  procedure createSDW(sdwtableprefix varchar2, poitable varchar2, dataset_dims varchar2,
    userstable varchar2, intervalsecs number, srcTable varchar2) is
    stmt varchar2(4000);
    toolong exception;
  begin
    if (length(sdwTablePrefix)>10) then
      raise toolong;
    end if;
    --table TIME
    stmt := 'create table '||sdwTablePrefix||'_time_dim(time_id number(9) not null,
         timepoint tau_tll.d_timepoint_sec,hour number(2),day number(2),month number(2),
         year number(4),quarter number(1), dayofweek varchar2(50),
         constraint '||sdwTablePrefix||'_time_dim_pk primary key (time_id))';
    execute immediate stmt;
    --table PERIOD
    stmt := 'create table '||sdwTablePrefix||'_period_dim(period_id number(9) not null,
         timeperiod tau_tll.d_period_sec,rushhour tau_tll.d_period_sec,partofday varchar2(50),
         constraint '||sdwTablePrefix||'_period_dim_pk primary key (period_id))';
    execute immediate stmt;
    --table SPACE
    stmt:='create table '||sdwTablePrefix||'_space_dim(poi_id number(9),poi_geom sdo_geometry,
         district varchar2(50),city varchar2(50),state varchar2(50),country varchar2(50),
         constraint '||sdwTablePrefix||'_space_dim_pk primary key (poi_id))';
    execute immediate stmt;
    --hard coded
    stmt:='insert into user_sdo_geom_metadata(table_name, column_name, diminfo, srid) 
      values('''||sdwTablePrefix||'_space_dim'', ''poi_geom'',
      mdsys.sdo_dim_array(
        mdsys.sdo_dim_element(''Longitude'',4000000,5000000,0.05),
        mdsys.sdo_dim_element(''Latitude'' ,400000,600000,0.05)),2100)';
        dbms_output.put_line(stmt);
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    commit;
    stmt:='create index '||sdwTablePrefix||'_space_dim_idx on '||sdwTablePrefix||'_space_dim(poi_geom) 
      indextype is mdsys.spatial_index';
    execute immediate stmt;
    --table STOP-SEMANTICS
    stmt := 'create table '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id number(9),
         stop_name varchar2(50),stop_type varchar2(50), stop_activity varchar2(50), poi_id number(9),
         constraint '||sdwTablePrefix||'_stops_sems_pk primary key (stop_sems_id),
         constraint '||sdwTablePrefix||'_stop_sems_poi_dim foreign key (poi_id) 
            references '||sdwTablePrefix||'_space_dim(poi_id))';
    execute immediate stmt;
    --table MOVE-SEMANTIC
    stmt:='create table '||sdwTablePrefix||'_move_sems_dim(move_sems_id number(9),
         route_type varchar2(50), move_mode varchar2(50), move_activity varchar2(50),
         constraint '||sdwTablePrefix||'_move_sems_pk primary key (move_sems_id))';
    execute immediate stmt;
    --table USERPROFILE
    stmt:='create table '||sdwTablePrefix||'_users_dim(user_profile_id number(9), 
         device_type varchar2(60), gender varchar2(6),birthday timestamp, profession varchar2(50),marital_status varchar2(20),
         constraint '||sdwTablePrefix||'_users_pk primary key(user_profile_id))';
    execute immediate stmt;
    --table TMPSTOPSFACTS
    stmt:='create table '||sdwTablePrefix||'_tmp_stops_fact(user_id number(9), semtraj_id number(9),
         period_id number(9),stop_sems_id number(9),user_profile_id number(9),activity varchar2(50),
         duration number, radius_of_gyration number)';
    execute immediate stmt;
    --table TMPMOVEFACTS
    stmt:='create table '||sdwTablePrefix||'_tmp_moves_fact(user_id number(9), semtraj_id number(9),
         period_id number(9), from_stop_sems_id number(9),to_stop_sems_id number(9),
         user_profile_id number(9), move_sems_id number(9),activity varchar2(50),
         distance_traveled number,duration number,speed number,acceleration number,radius_of_gyration number)';
    execute immediate stmt; 
    --table STOPSFACTS
    stmt:='create table '||sdwTablePrefix||'_stops_fact(period_id number(9), stop_sems_id number(9),
         user_profile_id number(9), num_of_sem_trajectories integer, num_of_users integer,
         num_of_activities integer, avg_duration number, radius_of_gyration number,crosst number,
         constraint '||sdwTablePrefix||'_stops_fact_pk primary key (period_id,stop_sems_id,user_profile_id),
         constraint '||sdwTablePrefix||'_stops_stop_sems_fk foreign key(stop_sems_id)
            references '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id),
         constraint '||sdwTablePrefix||'_stops_period_fk foreign key(period_id)
            references '||sdwTablePrefix||'_period_dim(period_id),
         constraint '||sdwTablePrefix||'_stops_user_fk foreign key(user_profile_id)
            references '||sdwTablePrefix||'_users_dim(user_profile_id))';
    execute immediate stmt;
    --table MOVEFACTS
    stmt:='create table '||sdwTablePrefix||'_moves_fact(period_id number(9), from_stop_sems_id number(9),
         to_stop_sems_id number(9),user_profile_id number(9), move_sems_id number(9),
         num_of_sem_trajectories integer, num_of_users integer,num_of_activities integer,
         avg_distance_traveled number, avg_travel_duration number, avg_speed number,
         avg_abs_acceleration number,radius_of_gyration number, crosst number,
         constraint '||sdwTablePrefix||'_moves_fact_pk primary key (period_id,from_stop_sems_id,to_stop_sems_id,user_profile_id,move_sems_id),
         constraint '||sdwTablePrefix||'_moves_move_sems_fk foreign key(move_sems_id)
            references '||sdwTablePrefix||'_move_sems_dim(move_sems_id),
         constraint '||sdwTablePrefix||'_moves_period_fk foreign key(period_id)
            references '||sdwTablePrefix||'_period_dim(period_id),
         constraint '||sdwTablePrefix||'_moves_user_fk foreign key(user_profile_id)
            references '||sdwTablePrefix||'_users_dim(user_profile_id),
         constraint '||sdwTablePrefix||'_moves_from_stops_fk foreign key(from_stop_sems_id)
            references '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id),
         constraint '||sdwTablePrefix||'_moves_to_stops_fk foreign key(to_stop_sems_id)
            references '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id))';
    execute immediate stmt; 
    --load dimensions
    sdw.loaddimensions(sdwtableprefix, poitable, dataset_dims,userstable, intervalsecs, srcTable);
    exception
      when toolong then
        dbms_output.put_line('Prefix name is too long');
  end createSDW;
  
  procedure deleteSDW(sdwTablePrefix varchar2) is
    stmt varchar2(5000);
  begin
    stmt := 'delete '||sdwTablePrefix||'_moves_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'delete '||sdwTablePrefix||'_stops_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'delete '||sdwTablePrefix||'_tmp_moves_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'delete '||sdwTablePrefix||'_tmp_stops_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'delete '||sdwTablePrefix||'_users_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'delete '||sdwTablePrefix||'_move_sems_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'delete '||sdwTablePrefix||'_stop_sems_dim';
    execute immediate stmt;
    stmt := 'delete user_sdo_geom_metadata where upper(table_name) = upper('''||sdwTablePrefix||'_space_dim'')';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'delete '||sdwTablePrefix||'_space_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'delete '||sdwTablePrefix||'_period_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'delete '||sdwTablePrefix||'_time_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
  end deleteSDW;
  
  procedure dropSDW(sdwTablePrefix varchar2) is
    stmt varchar2(5000);
  begin
    stmt := 'drop table '||sdwTablePrefix||'_moves_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'drop table '||sdwTablePrefix||'_stops_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'drop table '||sdwTablePrefix||'_tmp_moves_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'drop table '||sdwTablePrefix||'_tmp_stops_fact';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'drop table '||sdwTablePrefix||'_users_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'drop table '||sdwTablePrefix||'_move_sems_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'drop table '||sdwTablePrefix||'_stop_sems_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'delete user_sdo_geom_metadata where upper(table_name) = upper('''||sdwTablePrefix||'_space_dim'')';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'drop table '||sdwTablePrefix||'_space_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end; 
    stmt := 'drop table '||sdwTablePrefix||'_period_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
    stmt := 'drop table '||sdwTablePrefix||'_time_dim';
    begin
      execute immediate stmt;
      exception when others then null;
    end;
  end dropSDW;

  procedure loaddimensions(sdwtableprefix varchar2, poitable varchar2, dataset_dims varchar2,
    userstable varchar2, intervalsecs number, srcTable varchar2) is
  begin
    loadstopsemsdim(sdwTablePrefix, poitable);
    loadperiodsdim(sdwtableprefix,dataset_dims,intervalsecs);
    loadmovesemsdim(sdwTablePrefix, srcTable);
    loaduserprofilesdim(sdwTablePrefix,userstable);
  end loaddimensions;
  
  procedure loadmovesemsdim(sdwtableprefix varchar2, srctable varchar2) is
  /*
  srctable is the sem_trajs soource table where move episodes reside
  */
  query varchar2(4000);  
  tmp_rc sys_refcursor;
  type move_sems_typ is record(
    move_mode varchar2(50),
    move_activity varchar2(50)
  );
  type move_sems_tab is table of move_sems_typ;
  move_sems move_sems_tab;
  begin
    execute immediate 'delete '||sdwTablePrefix||'_move_sems_dim';
    commit;
    query:='select distinct upper(mmode),upper(mactiv) from(
      select  e.episode_tag mmode, e.activity_tag mactiv
      from '||srctable||' b,table(b.episodes) e where upper(e.defining_tag)=upper(''MOVE''))';
    open tmp_rc for query;
    fetch tmp_rc bulk collect into move_sems;
    close tmp_rc;
    for i in move_sems.first..move_sems.last loop
      execute immediate 'insert into '||sdwtableprefix||'_move_sems_dim(
         move_sems_id,route_type, move_mode,move_activity) 
         values(:i,null,:move_mode,:move_activ)'--route_type is null for now
         using in i,in move_sems(i).move_mode,in move_sems(i).move_activity;
    end loop;
    commit;
  end loadmovesemsdim;
  
  procedure loaduserprofilesdim(sdwTablePrefix varchar2, userstable varchar2) is
    /*
  userstable is the users table 
  */
  begin
    execute immediate 'delete '||sdwTablePrefix||'_users_dim';
    commit;
    --quite hard coded, but is up to application
    execute immediate 'insert into '||sdwTablePrefix||'_users_dim(user_profile_id,
         device_type,gender,birthday,profession,marital_status)
         select id,null,gender,
         to_timestamp(''01-01-''||birthyear||'' 00:00:00'',''dd-mm-rr hh24:mi:ss''),
         profession,marital_status from '||userstable||' pt
         ';
    commit;
  end loaduserprofilesdim;
  
  procedure updatedistrict(stepx number, stepy number, poitable varchar2) is
    x number:=0;y number:=0;
    minx number; maxx number; miny number;maxy number;
    currx number;curry number;
  begin
    execute immediate 'begin select min(p.longitude), max(p.longitude), min(p.latitude), max(p.latitude) 
      into :minx, :maxx, :miny, :maxy from '||poitable||' p;end;'
      using out minx, out maxx, out miny, out maxy;

    currx:=minx;
    curry:=miny;

    while currx <= maxx loop
      x:=x+1;
      while curry <= maxy loop
        y:=y+1;
        
        execute immediate 'update '||poitable||' a
          set a.district = ''district_'||x||'_'||y||'''
          where a.longitude between :currx and :currx_stepx
          and a.latitude between :curry and :curry_stepy'
          using in currx, in currx+stepx, in curry, in curry+stepy;
        
        curry:=curry+stepy;
      end loop;
      currx:=currx+stepx;
      curry:=miny;
      y:=0;
    end loop;
  end updatedistrict;
  
  procedure loadstopsemsdim(sdwtableprefix varchar2, poitable varchar2) is
    tmp_rc sys_refcursor;
    srid number:=2100;--hard coded!!!
  begin
    /*
    this procedure needs a table with POI information
    (id,name,type,district,city,state,country,activity,latitude,longitude)
    where id could appears multiple times (if other activity...)
    type used for episode_tag and activity for activity_tag
    or change it.
    */
    
    
    execute immediate 'delete '||sdwTablePrefix||'_space_dim';
    commit;
    execute immediate 'delete '||sdwTablePrefix||'_stop_sems_dim';
    commit;
    execute immediate 'insert into '||sdwTablePrefix||'_space_dim(poi_id,poi_geom,district,city,state,country) 
         select id,
         mdsys.sdo_geometry(2001,'||srid||',sdo_point_type(longitude,latitude,0),null,null),
         district,city,state,country
         from ( select 
            distinct pt.id,pt.latitude,pt.longitude,
            --distinct pt.id, pt.poi_geom.sdo_point.x longitude, pt.poi_geom.sdo_point.y latitude,
            pt.district,pt.city,pt.state,pt.country
            from  '||poitable||' pt)';
    --district granularity
    
    /*
    execute immediate 'insert into '||sdwTablePrefix||'_space_dim(poi_id,poi_geom,district,city,state,country)
      select rownum id,a.geom, a.district,a.city, a.state, a.country
      from(  select district,city, state, country, sdo_aggr_mbr(p.poi_geom) geom
        from '||poitable||' p group by district,city, state, country) a;
    */
          
    commit;
    
    execute immediate 'insert into '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id,
         stop_name,stop_type,stop_activity,poi_id)
         select rownum,pt.name,pt.type,pt.activity,pt.id
         from '||poitable||' pt
            ';
    --district granularity
    /*
    execute immediate 'insert into '||sdwTablePrefix||'_stop_sems_dim(stop_sems_id,
         stop_name,stop_type,stop_activity,poi_id)
      select rownum, c.district,b.type, b.activity, c.id
      from(
        select rownum id,a.geom, a.district,a.city, a.state, a.country
            from(  select district,city, state, country, sdo_aggr_mbr(p.poi_geom) geom
              from '||poitable||' p group by district,city, state, country) a)c,
        (select distinct p.district,p.type, p.activity
        from '||poitable||' p) b
      where c.district=b.district;
    */
    commit;
  end loadstopsemsdim;
  
  procedure loadtimedim(sdwTablePrefix varchar2, dataset_dims varchar2,
    intervalperiod number) is
    /*
    dataset_dims is the table holding the dataset dimensions (global)
    */
    query varchar2(4000);
    b tau_tll.d_timepoint_sec;
    e tau_tll.d_timepoint_sec;
    cur_tp tau_tll.d_timepoint_sec;
    tmp_rc sys_refcursor;
    tmptimestamp timestamp;
    --d double precision;
    timeid integer;
  begin
    query:='select mint  from '||dataset_dims;
    open tmp_rc for query;
    --fetch tmp_rc into b;--depending on input
    fetch tmp_rc into tmptimestamp;
    close tmp_rc;
    
    b:=tau_tll.d_timepoint_sec(extract(year from tmptimestamp), extract(month from tmptimestamp), extract(day from tmptimestamp),
      extract(hour from tmptimestamp), extract(minute from tmptimestamp), extract(second from tmptimestamp));
    
    query:='select maxt from '||dataset_dims; 
    open tmp_rc for query;
    --fetch tmp_rc into e;--depending on input
    fetch tmp_rc into tmptimestamp;
    close tmp_rc;
    
    e:=tau_tll.d_timepoint_sec(extract(year from tmptimestamp), extract(month from tmptimestamp), extract(day from tmptimestamp),
      extract(hour from tmptimestamp), extract(minute from tmptimestamp), extract(second from tmptimestamp));
    
    cur_tp:=b;
    execute immediate 'delete '||sdwTablePrefix||'_time_dim';
    commit;
    timeid:=1;
    while (cur_tp.get_Abs_Date < e.get_Abs_Date) loop
      /*if(timeid=15702)then
        null;
      end if;
      d:=cur_tp.get_Abs_Date;
      d:=e.get_Abs_Date;*/
      execute immediate 'insert into '||sdwTablePrefix||'_time_dim(
              time_id, timepoint,hour,day,month,year) values(
              :timeid, :cur_tp,:cur_tp_m_h,:cur_tp_m_d,:cur_tp_m_m,:cur_tp_m_y)'
              using in timeid, cur_tp,cur_tp.m_h,cur_tp.m_d,cur_tp.m_m,cur_tp.m_y;
      cur_tp.set_Abs_Date(cur_tp.get_Abs_Date + intervalperiod);
      if (cur_tp.get_Abs_Date >= e.get_Abs_Date) then
        execute immediate 'insert into '||sdwTablePrefix||'_time_dim(
              time_id, timepoint,hour,day,month,year) values(
              :timeid, :cur_tp,:cur_tp_m_h,:cur_tp_m_d,:cur_tp_m_m,:cur_tp_m_y)'
              using in timeid+1, e,e.m_h,e.m_d,e.m_m,e.m_y;
      end if;
      timeid:=timeid+1;
    end loop; 
    commit;
    execute immediate 'update '||sdwTablePrefix||'_time_dim t
            set t.quarter=
                case when t.month in (1,2,3) then 1
                  when t.month in (4,5,6) then 2
                  when t.month in (7,8,9) then 3
                  when t.month in (10,11,12) then 4
                end
                ,t.dayofweek=to_char(to_date(t.year||''-''||t.month||''-''||t.day,''rrrr-mm-dd''), ''DAY'')';
    commit;
  end loadtimedim;
  
  procedure loadperiodsdim(sdwTablePrefix varchar2, dataset_dims varchar2,
    intervalperiod number) is
    /*
    dataset_dims is the table holding the dataset dimensions (global)
    */
    times_cur sys_refcursor;
    type time_typ is record(
         id number(9),
         timepoint tau_tll.d_timepoint_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    tp tau_tll.d_period_sec;
    stmt varchar2(4000);
  begin
    sdw.loadtimedim(sdwTablePrefix,dataset_dims,intervalperiod);
    open times_cur for 'select t.time_id, t.timepoint
      from '||sdwTablePrefix||'_time_dim t
      --where rownum <10--for test
      order by t.time_id';
    loop
      fetch times_cur bulk collect into times;   
      exit when times.count=0;  
      for t in times.first..times.count-1 loop--to form periods of time
        tp:=tau_tll.d_period_sec(times(t).timepoint,times(t+1).timepoint);
        
        stmt:='insert into '||sdwTablePrefix||'_period_dim
          (period_id, timeperiod)
        values
          (:timesid, :tp)';
        execute immediate stmt using in times(t).id, tp;
        commit;        
      end loop;
    end loop;
    
  end loadperiodsdim;
  
  procedure cellstopsload(sdwTablePrefix varchar2,stbtreeprefix varchar2) is
    stop_sems_cur sys_refcursor;
    times_cur sys_refcursor;
    type stop_sems_typ is record(
         stop_sems_id pls_integer,
         poi_id pls_integer,
         poi_geom mdsys.sdo_geometry,
         stop_type varchar2(50),
         stop_activity varchar2(50)
    );
    type stop_sems_tab is table of stop_sems_typ;
    stop_sems stop_sems_tab;
    type time_typ is record(
         id pls_integer,
         timeperiod tau_tll.d_period_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    episodes sem_episode_tab;
    episodes_tmp sem_episode_tab;
    empoint sub_moving_point;
    portionmpoint moving_point;
    tolerance number:=0.01;
    intersection mdsys.sdo_geometry;
    debugint pls_integer;
    refer ref sub_moving_point;
    stmt varchar2(4000);
    nodes stbtree_nodes_tab_typ;
    leaves stbtree_leaves_tab_typ;
  begin
    --
    open stop_sems_cur for 'select t.stop_sems_id, t.poi_id, p.poi_geom, t.stop_type, t.stop_activity--stop_name is not used
            from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
            where t.poi_id = p.poi_id
            --and stop_sems_id = 1466-->= 128--for test
            --order by t.stop_sems_id,t.poi_id
            ';
    loop
      fetch stop_sems_cur bulk collect into stop_sems ;--limit 500;
      exit when stop_sems.count=0;
      --dbms_output.put_line('start stop_sems recs no order->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
      open times_cur for 'select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <10--for test
            --order by t.period_id
            ';
        loop
          fetch times_cur bulk collect into times;-- limit 1000;  
          exit when times.count=0;   
      for i in stop_sems.first..stop_sems.count loop
        --dbms_output.put_line('stop_sems '||i||' start at '||systimestamp);
        /*--moved upwards
        open times_cur for 'select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <10--for test
            --order by t.period_id
            ';
        loop
          fetch times_cur bulk collect into times;-- limit 1000;  
          exit when times.count=0; 
          */
          --dbms_output.put_line('start times recs no order for stop_sem:'||i||'->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
          for j in times.first..times.count loop
            /* 
            stb_range_episodes returns whole episodes that their mbb
            intersect with the poi mbr and time period
            so we refine resulted episodes by taking the portion of episode's
            sub moving_point (the sub sub mpoint...) in time period and then check if intersection exists 
            between that polyline and poi geometry (also stop type and stop activity)
            For such a mpoint calculate measures ....
            */
            starting_time:=systimestamp;
            
            select std.stb_range_episodes(sem_episode('STOP',upper(stop_sems(i).stop_type),upper(stop_sems(i).stop_activity),
                sem_mbb(null,null).to_sem_mbb(stop_sems(i).poi_geom,times(j).timeperiod),null),stbtreeprefix)
            into episodes from dual;
            
            stmt:='range episodes for stop_sem, times: '||to_char(systimestamp - starting_time)||'--'||episodes.count;
            insert into dbmsoutput(message,a,b)values(stmt,i,j);commit;         
            --dbms_output.put_line('range episodes for stop_sem, times:'||i||','||j||'->'||to_char(systimestamp - starting_time)||' found->'||episodes.count);
            
            if (episodes.count>0) then
              for k in episodes.first..episodes.last loop
                --time
                --either check with at_period if portionmpoint is needed for measures
                --or avoid if range do that work or calc it mor efficiently
                --commonperiod:=tau_tll.d_period_sec(episodes(k).mbb.minpoint.t,episodes(k).mbb.maxpoint.t).intersects(times(j).timeperiod).duratin().m_value;
                --test it as should be faster than at_period
                select deref(episodes(k).tlink)
                into empoint from dual;
                portionmpoint:=empoint.sub_mpoint.at_period_no_lib(times(j).timeperiod);
                if (portionmpoint is not null) then--this should not be needed
                  --measures
                  stmt:='insert into '||sdwTablePrefix||'_tmp_stops_fact(user_id,semtraj_id,period_id,stop_sems_id,user_profile_id,
                     activity,duration,radius_of_gyration) 
                     values (:empointo_id,:empointtraj_id,
                     :timesid,:stopsemsid,:empointo_id,:episodesactivity_tag,
                     :f_duration,
                     :radius_of_gyration)';
                  execute immediate stmt using in empoint.o_id,empoint.traj_id,
                     times(j).id,stop_sems(i).stop_sems_id,empoint.o_id,episodes(k).activity_tag,
                     portionmpoint.f_duration(),
                     portionmpoint.radius_of_gyration;
                  commit;
                end if;
              end loop;          
            end if;
          end loop;
          --exit when times.count=0;
        end loop;
        --close times_cur;
        --dbms_output.put_line('stop_sems '||i||'ends at'||systimestamp);
      end loop;
      --exit when pois.count=0;
      close times_cur;--from moving times cur upwards
    end loop;
    close stop_sems_cur;
    --insert into sem_dw_stops_fact
    
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
  end cellstopsload;
  
  procedure cellstopsload_parallel(sdwTablePrefix varchar2,stbtreeprefix varchar2, fstop_sem_id number, tstop_sem_id number) is
    stop_sems_cur sys_refcursor;
    times_cur sys_refcursor;
    type stop_sems_typ is record(
         stop_sems_id pls_integer,
         poi_id pls_integer,
         poi_geom mdsys.sdo_geometry,
         stop_type varchar2(50),
         stop_activity varchar2(50)
    );
    type stop_sems_tab is table of stop_sems_typ;
    stop_sems stop_sems_tab;
    type time_typ is record(
         id pls_integer,
         timeperiod tau_tll.d_period_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    episodes sem_episode_tab;
    episodes_tmp sem_episode_tab;
    empoint sub_moving_point;
    portionmpoint moving_point;
    tolerance number:=0.01;
    intersection mdsys.sdo_geometry;
    debugint pls_integer;
    refer ref sub_moving_point;
    stmt varchar2(4000);
    nodes stbtree_nodes_tab_typ;
    leaves stbtree_leaves_tab_typ;
  begin
    --
    open stop_sems_cur for 'select t.stop_sems_id, t.poi_id, p.poi_geom, t.stop_type, t.stop_activity--stop_name is not used
            from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
            where t.poi_id = p.poi_id
            and t.stop_sems_id between '||fstop_sem_id||' and '||tstop_sem_id||'--parallel
            --and stop_sems_id = 1466-->= 128--for test
            --order by t.stop_sems_id,t.poi_id
            ';
    loop
      fetch stop_sems_cur bulk collect into stop_sems ;--limit 500;
      exit when stop_sems.count=0;
      --dbms_output.put_line('start stop_sems recs no order->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
      open times_cur for 'select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <10--for test
            --order by t.period_id
            ';
        loop
          fetch times_cur bulk collect into times;-- limit 1000;  
          exit when times.count=0; 
      for i in stop_sems.first..stop_sems.count loop
        --dbms_output.put_line('stop_sems '||i||' start at '||systimestamp);
        /*moved upwards
        open times_cur for 'select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <10--for test
            --order by t.period_id
            ';
        loop
          fetch times_cur bulk collect into times;-- limit 1000;  
          exit when times.count=0; 
          */
          --dbms_output.put_line('start times recs no order for stop_sem:'||i||'->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
          for j in times.first..times.count loop
            /* 
            stb_range_episodes returns whole episodes that their mbb
            intersect with the poi mbr and time period
            so we refine resulted episodes by taking the portion of episode's
            sub moving_point (the sub sub mpoint...) in time period and then check if intersection exists 
            between that polyline and poi geometry (also stop type and stop activity)
            For such a mpoint calculate measures ....
            */
            starting_time:=systimestamp;
            
            select std.stb_range_episodes(sem_episode('STOP',upper(stop_sems(i).stop_type),upper(stop_sems(i).stop_activity),
                sem_mbb(null,null).to_sem_mbb(stop_sems(i).poi_geom,times(j).timeperiod),null),stbtreeprefix)
            into episodes from dual;
            
            stmt:='range episodes for stop_sem, times: '||to_char(systimestamp - starting_time)||'--'||episodes.count;
            insert into dbmsoutput(message,a,b)values(stmt,i,j);commit;         
            --dbms_output.put_line('range episodes for stop_sem, times:'||i||','||j||'->'||to_char(systimestamp - starting_time)||' found->'||episodes.count);
            
            if (episodes.count>0) then
              for k in episodes.first..episodes.last loop
                --time
                --either check with at_period if portionmpoint is needed for measures
                --or avoid if range do that work or calc it mor efficiently
                --commonperiod:=tau_tll.d_period_sec(episodes(k).mbb.minpoint.t,episodes(k).mbb.maxpoint.t).intersects(times(j).timeperiod).duratin().m_value;
                --test it as should be faster than at_period
                select deref(episodes(k).tlink)
                into empoint from dual;
                portionmpoint:=empoint.sub_mpoint.at_period_no_lib(times(j).timeperiod);
                if (portionmpoint is not null) then--this should not be needed
                  --measures
                  stmt:='insert into '||sdwTablePrefix||'_tmp_stops_fact(user_id,semtraj_id,period_id,stop_sems_id,user_profile_id,
                     activity,duration,radius_of_gyration) 
                     values (:empointo_id,:empointtraj_id,
                     :timesid,:stopsemsid,:empointo_id,:episodesactivity_tag,
                     :f_duration,
                     :radius_of_gyration)';
                  execute immediate stmt using in empoint.o_id,empoint.traj_id,
                     times(j).id,stop_sems(i).stop_sems_id,empoint.o_id,episodes(k).activity_tag,
                     portionmpoint.f_duration(),
                     portionmpoint.radius_of_gyration;
                  commit;
                end if;
              end loop;          
            end if;
          end loop;
          --exit when times.count=0;
        end loop;
        --close times_cur;
        --dbms_output.put_line('stop_sems '||i||'ends at'||systimestamp);
      end loop;
      --exit when pois.count=0;
      close times_cur;--from moving times cur upwards
    end loop;
    close stop_sems_cur;
    --insert into sem_dw_stops_fact
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
  end cellstopsload_parallel;
  
  procedure cellmovesload(sdwtableprefix varchar2,stbtreeprefix varchar2) is
  /*
  This is quite resource demanding procedure!!!
  */
    query varchar2(5000);
    rc sys_refcursor;
    type stop_sems_typ is record(
         stop_sems_id pls_integer,
         poi_id pls_integer,
         poi_geom mdsys.sdo_geometry,
         stop_type varchar2(50),
         stop_activity varchar2(50)
    );
    type stop_sems_tab is table of stop_sems_typ;
    stop_sems stop_sems_tab;
    type time_typ is record(
         id pls_integer,
         timeperiod tau_tll.d_period_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    type move_sems_typ is record(
         move_sems_id pls_integer,
         route_type varchar2(50 byte),
         move_mode	varchar2(50 byte),
         move_activity	varchar2(50 byte)
    );
    type move_sems_tab is table of move_sems_typ;
    move_sems move_sems_tab;
    episodes sem_episode_tab;
    empoint sub_moving_point;
    portionmpoint moving_point;
    from_stop sem_episode;
    to_stop sem_episode;
    viamove sem_episode;
    early tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    intervalsecs tau_tll.d_interval;
    later tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    stmt varchar2(4000);
  begin
    open rc for 'select t.stop_sems_id, t.poi_id, p.poi_geom, t.stop_type, t.stop_activity
            from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
            where t.poi_id = p.poi_id
            --and rownum <10--for test
            --order by t.stop_sems_id,t.poi_id
            ';
            
    fetch rc bulk collect into stop_sems;
    close rc;
    query:='select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <10--for test
            --order by t.period_id
            ';
    open rc for query;
    fetch rc bulk collect into times;
    close rc;
    query:='select t.move_sems_id, t.route_type, t.move_mode, t.move_activity
            from '||sdwTablePrefix||'_move_sems_dim t
            --where rownum <10--for test
            --order by t.move_sems_id
            ';
    open rc for query;
    fetch rc bulk collect into move_sems;
    close rc;
    
    for i in stop_sems.first..stop_sems.last loop--to form the from-poi
      for m in move_sems.first..move_sems.last loop--move_sems
        for k in stop_sems.first..stop_sems.last loop--to form the to-poi
          for j in times.first..times.last loop--to form periods of time
            intervalsecs:=times(j).timeperiod.b.f_diff(times(j).timeperiod.e,times(j).timeperiod.b);
            /* 
            stb_range_episodes returns whole move episode that their mbb
            intersect with the time period and begin on from-stop-sems and wind up to to-stop-sems
            where those stop-sems have times that the from-stop ends to move.begin
            and the to-stop start at move.ends
            so we refine resulted episodes by taking the portion of episode's
            sub moving_point (the sub sub mpoint...) in time period 
            For such a mpoint calculate measures ....
            
            select std.stb_range_episodes(stop_sems(i).poi_geom,stop_sems(k).poi_geom,times(j).timeperiod,stbtreeprefix)
            into episodes from dual;
            */
            early.set_abs_date(times(j).timeperiod.b.get_abs_date()-intervalsecs.m_value);
            later.set_abs_date(times(j).timeperiod.e.get_abs_date()+intervalsecs.m_value);
            from_stop:=sem_episode('STOP',stop_sems(i).stop_type,stop_sems(i).stop_activity,
              sem_mbb(null,null).to_sem_mbb(stop_sems(i).poi_geom,tau_tll.d_period_sec(early,times(j).timeperiod.b)),null);
            to_stop:=sem_episode('STOP',stop_sems(k).stop_type,stop_sems(k).stop_activity,
              sem_mbb(null,null).to_sem_mbb(stop_sems(k).poi_geom,tau_tll.d_period_sec(times(j).timeperiod.e, later)),null);
            viamove:=sem_episode('MOVE',move_sems(m).move_mode,move_sems(m).move_activity,
              null,null);
              
            select std.stb_from_to_via(from_stop,to_stop,viaMove,stbtreeprefix)
            into episodes from dual;
            
            --dbms_output.put_line('episodes='||episodes.count||' for '||'STOP,'||stop_sems(i).stop_type||','||stop_sems(i).stop_activity||
            --', '||i||'->'||'MOVE,'||move_sems(m).move_mode||','||move_sems(m).move_activity||', '||m||'->'||
            --'STOP,'||stop_sems(k).stop_type||','||stop_sems(k).stop_activity||', '||k||' at timep '||j);
            /*
            and then check if portionmpoint is null instead of the two additional text constraints
            no spatial constraint for MOVE episodes
            */
            if (episodes.count>0) then
              for e in episodes.first..episodes.last loop
                --additional constraints, loose them if you want
                --if (episodes(e).episode_tag=move_sems(m).move_mode) then
                  --if (episodes(e).activity_tag=move_sems(m).move_activity) then
                    select deref(episodes(e).tlink)
                    into empoint from dual;
                    
                    portionmpoint:=empoint.sub_mpoint.at_period(times(j).timeperiod);
                    --measures
                    if (portionmpoint is not null) then
                      stmt:='insert into '||sdwtableprefix||'_tmp_moves_fact(user_id,semtraj_id,period_id,from_stop_sems_id,
                        to_stop_sems_id,user_profile_id,move_sems_id,activity,distance_traveled,duration,speed,
                        acceleration,radius_of_gyration)
                      values
                        (:empointo_id,:empointtraj_id,:timesid,:fstopsemssid,:tstopsemsid,:empointo_id,
                         /*(select move_semantic_id from sem_dw_move_semantics_dim
                         where road_type=episodes(m).episode_tag and transport_mode=episodes(m).activity_tag),*/
                         :move_sems_id,
                         :episodesactivity_tag,:lengthportionmpointroute
                         ,:portionmpointf_duration,:portionmpointf_avg_speed,:portionmpointf_avg_acceleration,
                         :mbrportionmpointroute,:portionmpointradius_of_gyration)';
                      execute immediate stmt using in empoint.o_id,empoint.traj_id,times(j).id,stop_sems(i).stop_sems_id,
                      stop_sems(k).stop_sems_id,empoint.o_id,
                         /*(select move_semantic_id from sem_dw_move_semantics_dim
                         where road_type=episodes(m).episode_tag and transport_mode=episodes(m).activity_tag),*/
                         move_sems(m).move_sems_id,
                         episodes(e).activity_tag,mdsys.sdo_geom.sdo_length(portionmpoint.route(),0.00005)
                         ,portionmpoint.f_duration(),portionmpoint.f_avg_speed,portionmpoint.f_avg_acceleration
                         ,portionmpoint.radius_of_gyration;
                      commit;
                    end if;
                  --end if;
                --end if;
              end loop;
            end if;
          end loop;
        end loop;
      end loop;
    end loop;
    --insert into _moves_fact
    
    stmt:='insert into '||sdwTablePrefix||'_moves_fact(period_id,from_stop_sems_id,to_stop_sems_id,user_profile_id,move_sems_id,
       num_of_sem_trajectories,num_of_users,num_of_activities,avg_distance_traveled,
       avg_travel_duration,avg_speed,avg_abs_acceleration,radius_of_gyration,crosst)
       select s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id,count(distinct s.semtraj_id),
              count(distinct s.user_id),count(distinct s.activity),
              sum(s.distance_traveled)/count(*),sum(s.duration)/count(*),sum(s.speed)/count(*)
              ,sum(s.acceleration)/count(*)
              ,sum(s.radius_of_gyration)/count(*)
               ,0
       from '||sdwTablePrefix||'_tmp_moves_fact s
       group by s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id';   
    execute immediate stmt;
    commit;
  end cellmovesload;
  
  procedure semtrajstopsload(sdwTablePrefix varchar2,semtrajs varchar2) is
    query varchar2(5000);
    traj_rc sys_refcursor;
    sem_trajs sem_trajectory_tab;
	currentepis sem_episode;
	USER_ID number(9);
	SEMTRAJ_ID number(9);
	period_id number(9);
  period_ids integer_nt;
	timeperiod tau_tll.D_PERIOD_SEC;
	stop_sems_id number(9);
  stop_sems_ids integer_nt;
	USER_PROFILE_ID number(9);
	ACTIVITY varchar2(50);
	DURATION number;
	RADIUS_OF_GYRATION number;
	
    empoint sub_moving_point;
    portionmpoint moving_point;
	
  begin
    query:='select value(t)
            from '||semtrajs||' t
            --where (t.o_id,t.semtraj_id) not in (select a,b from dbmsoutput)
            --order by t.o_id,t.semtraj_id
            ';--order not important
    open traj_rc for query;
    fetch traj_rc bulk collect into sem_trajs;
    close traj_rc;
    
  for i in sem_trajs.first..sem_trajs.last loop
        --dbms_output.put_line('semtraj->'||i||'-'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
		currentepis:=null;
		USER_ID:=sem_trajs(i).o_id;
		USER_PROFILE_ID:=sem_trajs(i).o_id;
		SEMTRAJ_ID:=sem_trajs(i).semtraj_id;
		for e in sem_trajs(i).episodes.first..sem_trajs(i).episodes.last loop
			currentepis:=sem_trajs(i).episodes(e);
			if (currentepis.defining_tag!='STOP') then
				continue;--move pointers down
			else
				--find the period_id or ids in which move episode overlap
				begin
					query:='select t.period_id
						from '||sdwTablePrefix||'_period_dim t
						where t.timeperiod.f_overlaps(t.timeperiod,
						  tau_tll.d_period_sec(:t1,:t2))=1';
          open traj_rc for query using in currentepis.mbb.minpoint.t,in currentepis.mbb.maxpoint.t;
					fetch traj_rc bulk collect into period_ids;
          close traj_rc;
				end;
				if (period_ids.count=0) then
					continue;
				else
          for p in period_ids.first..period_ids.last loop
            --dbms_output.put_line('semtraj->'||i||', period->'||p||'-'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
            --get the timeperiod
            begin
            query:='begin select t.timeperiod into :timeperiod
              from '||sdwTablePrefix||'_period_dim t
              where t.period_id=:period_id;
              end;';
            execute immediate query using out timeperiod, in period_ids(p);
            exception when no_data_found then
              timeperiod:=null;
            end;
            --find the stop_sem_id or ids for the current stop
            begin
            query:='select t.stop_sems_id
              from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
              where t.poi_id = p.poi_id
              and upper(t.stop_type) like upper('''||currentepis.episode_tag||''')
              and upper(t.stop_activity) like upper('''||currentepis.activity_tag||''')
              and sem_mbb(p.poi_geom,:timeperiod).intersects01(:mbb)=1';--time intersection is asured here
            open traj_rc for query using in timeperiod, in currentepis.mbb;
            fetch traj_rc bulk collect into stop_sems_ids;
            close traj_rc;
            end;
            
            if(stop_sems_ids.count=0) then
              continue;
            else
              for s in stop_sems_ids.first..stop_sems_ids.last loop
                --dbms_output.put_line('semtraj->'||i||', period->'||p||',stop_sem->'||s||'-'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
                select deref(currentepis.tlink) into empoint from dual;
                
                portionmpoint:=empoint.sub_mpoint.at_period(timeperiod);
                query:='insert into '||sdwTablePrefix||'_tmp_stops_fact(user_id,semtraj_id,period_id,stop_sems_id,user_profile_id,
                               activity,duration,radius_of_gyration) 
                               values (:empointo_id,:empointtraj_id,
                               :timesid,:stopsemsid,:empointo_id,:episodesactivity_tag,
                               :f_duration,
                               :radius_of_gyration)';
                execute immediate query using in USER_ID,SEMTRAJ_ID,period_ids(p),stop_sems_ids(s),
                  USER_PROFILE_ID,currentepis.activity_tag,
                  portionmpoint.f_duration(),
                  portionmpoint.radius_of_gyration;
                commit;
              end loop;
            end if;
          end loop;
				end if;
			end if;
		end loop;
  end loop;
    --insert into _stops_fact
    
    query:='insert into '||sdwTablePrefix||'_stops_fact(period_id,stop_sems_id,user_profile_id,num_of_sem_trajectories,
       num_of_users,num_of_activities,avg_duration,radius_of_gyration,crosst)
       select s.period_id, s.stop_sems_id,s.user_profile_id,count(distinct s.semtraj_id),
              count(distinct s.user_id),count(distinct s.activity),
              sum(s.duration)/count(*)
              ,sum(s.radius_of_gyration)/count(*)----radius of many moving_points???
              ,0
       from '||sdwTablePrefix||'_tmp_stops_fact s
       group by s.period_id, s.stop_sems_id,s.user_profile_id';   
    execute immediate query;
    commit;
    exception
      when others then
        dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
        dbms_output.put_line('Error_Backtrace...' ||
          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
  end semtrajstopsload;
  
  procedure semtrajmovesload(sdwTablePrefix varchar2, semtrajs varchar2) is
    query varchar2(5000);
    traj_rc sys_refcursor;
    sem_trajs sem_trajectory_tab;
	preprevious sem_episode;
	previous sem_episode;
	currentepis sem_episode;
	USER_ID number(9);
	SEMTRAJ_ID number(9);
	period_id number(9);
  period_ids integer_nt;
	timeperiod tau_tll.D_PERIOD_SEC;
	from_stop_sems_id number(9);
  from_stop_sems_ids integer_nt;
	to_stop_sems_id number(9);
  to_stop_sems_ids integer_nt;
	USER_PROFILE_ID number(9);
	MOVE_SEMS_ID number(9);
	ACTIVITY varchar2(50);
	DISTANCE_TRAVELED number;
	DURATION number;
	SPEED number;
	ACCELERATION number;
	RADIUS_OF_GYRATION number;
	
    empoint sub_moving_point;
    portionmpoint moving_point;
	
  begin
    query:='select value(t)
            from '||semtrajs||' t
            --where (t.o_id,t.semtraj_id) not in (select a,b from dbmsoutput)
            order by t.o_id,t.semtraj_id';--order not important
    open traj_rc for query;
    fetch traj_rc bulk collect into sem_trajs;
    close traj_rc;
    
    for i in sem_trajs.first..sem_trajs.last loop
		preprevious:=null;
		previous:=null;
		currentepis:=null;
		USER_ID:=sem_trajs(i).o_id;
		USER_PROFILE_ID:=sem_trajs(i).o_id;
		SEMTRAJ_ID:=sem_trajs(i).semtraj_id;
		for e in sem_trajs(i).episodes.first..sem_trajs(i).episodes.last loop
			preprevious:=previous;
			previous:=currentepis;
			currentepis:=sem_trajs(i).episodes(e);
			if (preprevious is null) or (previous.defining_tag!='MOVE') then
				continue;--move pointers down
			else
				--find the period_id or ids  in which move episode overlap
				begin
					query:='select t.period_id
						from '||sdwTablePrefix||'_period_dim t
						where t.timeperiod.f_overlaps(t.timeperiod,
						  tau_tll.d_period_sec(:t1,:t2))=1';
					open traj_rc for query using in currentepis.mbb.minpoint.t,in currentepis.mbb.maxpoint.t;
					fetch traj_rc bulk collect into period_ids;
          close traj_rc;
				end;
				if (period_ids.count=0) then
					continue;
				else
          for p in period_ids.first..period_ids.last loop
            --get the timeperiod
            begin
            query:='begin select t.timeperiod into :timeperiod
              from '||sdwTablePrefix||'_period_dim t
              where t.period_id=:period_id;
              end;';
            execute immediate query using out timeperiod, in period_ids(p);
            exception when no_data_found then
              timeperiod:=null;
            end;
            --find the stop_sem_id or ids for the previous stop
            begin
            query:='select t.stop_sems_id
              from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
              where t.poi_id = p.poi_id
              and upper(t.stop_type) like upper('''||preprevious.episode_tag||''')
              and upper(t.stop_activity) like upper('''||preprevious.activity_tag||''')
              and sem_mbb(p.poi_geom,:timeperiod).intersects01(:mbb)=1';
            open traj_rc for query using in tau_tll.d_period_sec(preprevious.mbb.minpoint.t
              ,preprevious.mbb.maxpoint.t), in preprevious.mbb;
            fetch traj_rc bulk collect into from_stop_sems_ids;
            close traj_rc;
            end;
            
            if(from_stop_sems_ids.count=0) then
              continue;
            else
              for fs in from_stop_sems_ids.first..from_stop_sems_ids.last loop
                --find the stop_sem_id or ids for the next stop
                begin
                query:='select t.stop_sems_id
                  from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
                  where t.poi_id = p.poi_id
                  and upper(t.stop_type) like upper('''||currentepis.episode_tag||''')
                  and upper(t.stop_activity) like upper('''||currentepis.activity_tag||''')
                  and sem_mbb(p.poi_geom,:timeperiod).intersects01(:mbb)=1';
                open traj_rc for query using in tau_tll.d_period_sec(currentepis.mbb.minpoint.t
                  ,currentepis.mbb.maxpoint.t), in currentepis.mbb;
                fetch traj_rc bulk collect into to_stop_sems_ids;
                close traj_rc;
                end;
                
                if(to_stop_sems_ids.count=0) then
                  continue;
                else
                  for ts in to_stop_sems_ids.first..to_stop_sems_ids.last loop
                    --find the move_sem_id for the current move
                    begin
                    query:='begin select t.move_sems_id into :MOVE_SEMS_ID
                      from '||sdwTablePrefix||'_move_sems_dim t
                      where (upper(t.move_mode) like upper('''||previous.activity_tag||''') or (t.move_mode is null))
                      and (upper(t.move_activity) like upper('''||previous.episode_tag||''') or (t.move_activity is null)); 
                      end;';
                    execute immediate query using out MOVE_SEMS_ID;
                    exception when no_data_found then
                      move_sems_id:=-1;
                      dbms_output.put_line('no_data_found');
                      when TOO_MANY_ROWS then--this should not happen
                      move_sems_id:=-1;
                      dbms_output.put_line('TOO_MANY_ROWS');
                    end;
                    if (MOVE_SEMS_ID!=-1) then
                    
                      select deref(previous.tlink) into empoint from dual;
                      
                      portionmpoint:=empoint.sub_mpoint.at_period(timeperiod);
                      query:='insert into '||sdwtableprefix||'_tmp_moves_fact(user_id,semtraj_id,period_id,from_stop_sems_id,
                        to_stop_sems_id,user_profile_id,move_sems_id,activity,distance_traveled,duration,speed,
                        acceleration,radius_of_gyration)
                        values
                        (:empointo_id,:empointtraj_id,:timesid,:fstopsemssid,:tstopsemsid,:empointo_id,
                         :move_sems_id,
                         :activity_tag,:lengthtrajectory
                         ,:duration,:avg_speed,:avg_acceleration,
                         :radius_of_gyration)';
                      execute immediate query using in user_id,semtraj_id,period_ids(p),from_stop_sems_ids(fs),
                        to_stop_sems_ids(ts),USER_PROFILE_ID,MOVE_SEMS_ID,previous.activity_tag,
                        mdsys.sdo_geom.sdo_length(portionmpoint.route(),0.00005),
                        portionmpoint.f_duration(),portionmpoint.f_avg_speed,portionmpoint.f_avg_acceleration,
                        portionmpoint.radius_of_gyration;
                      commit;
                    end if;
                  end loop;
                end if;
              end loop;
            end if;
          end loop;
				end if;
			end if;
		end loop;
	end loop;
    --insert into _moves_fact
    
    query:='insert into '||sdwTablePrefix||'_moves_fact(period_id,from_stop_sems_id,to_stop_sems_id,user_profile_id,move_sems_id,
       num_of_sem_trajectories,num_of_users,num_of_activities,avg_distance_traveled,
       avg_travel_duration,avg_speed,avg_abs_acceleration,radius_of_gyration,crosst)
       select s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id,count(distinct s.semtraj_id),
              count(distinct s.user_id),count(distinct s.activity),
              sum(s.distance_traveled)/count(*),sum(s.duration)/count(*),sum(s.speed)/count(*)
              ,sum(s.acceleration)/count(*)
              ,sum(s.radius_of_gyration)/count(*)
               ,0
       from '||sdwTablePrefix||'_tmp_moves_fact s
       group by s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id';   
    execute immediate query;
    commit;
    exception
      when others then
        dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
        dbms_output.put_line('Error_Backtrace...' ||
          DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
  end semtrajmovesload;
  
  procedure textstopsload(sdwTablePrefix varchar2,stbtreeprefix varchar2) is
    stop_sems_cur sys_refcursor;
    times_cur sys_refcursor;
    type stop_sems_typ is record(
         stop_sems_id pls_integer,
         poi_id pls_integer,
         poi_geom mdsys.sdo_geometry,
         stop_type varchar2(50),
         stop_activity varchar2(50)
    );
    type stop_sems_tab is table of stop_sems_typ;
    stop_sems stop_sems_tab;
    type time_typ is record(
         id pls_integer,
         timeperiod tau_tll.d_period_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    tmp_episode sem_episode;
    episodes sem_episode_tab;
    leafentries sem_stbleafentrymid_tab;
    empoint sub_moving_point;
    portionmpoint moving_point;
    stmt varchar2(4000);
    previous_epis_tag varchar2(50);
    previous_activ_tag varchar2(50);
  begin
    --for each stop_sems i and period j
    open stop_sems_cur for 'select t.stop_sems_id, t.poi_id, p.poi_geom, t.stop_type, t.stop_activity--stop_name is not used
            from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
            where t.poi_id = p.poi_id
            --and stop_sems_id = 1466-->= 128--for test
            --order by t.stop_sems_id,t.poi_id
            ';
    loop
      fetch stop_sems_cur bulk collect into stop_sems ;--limit 500;
      exit when stop_sems.count=0;
      --dbms_output.put_line('start stop_sems recs no order->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
      open times_cur for 'select t.period_id, t.timeperiod
          from '||sdwTablePrefix||'_period_dim t
          --where rownum <10--for test
          --order by t.period_id
          ';
      loop
        fetch times_cur bulk collect into times;-- limit 1000;  
        exit when times.count=0;
      for i in stop_sems.first..stop_sems.count loop
        --dbms_output.put_line('stop_sems '||i||' start at '||systimestamp);
        --firstly load valid leaves from tag index, avoid needless executions
        --dbms_output.put_line('pattern_tags start '||systimestamp);
        if previous_epis_tag is null then--first time
          tmp_episode:= sem_episode(upper('STOP'), upper(stop_sems(i).stop_type),upper(stop_sems(i).stop_activity), null,null);
          leafentries:=std.pattern_tags(tmp_episode, null, null, stbtreeprefix);
          delete temptemp;
          insert into temptemp select /*value(l)*/distinct l.stbnodeid from table(leafentries) l;
          commit;
        else
          if upper(previous_epis_tag)!=upper(stop_sems(i).stop_type) or upper(previous_activ_tag)!=upper(stop_sems(i).stop_activity) then--a tag is different now
            tmp_episode:= sem_episode(upper('STOP'), upper(stop_sems(i).stop_type),upper(stop_sems(i).stop_activity), null,null);
            leafentries:=std.pattern_tags(tmp_episode, null, null, stbtreeprefix);
            delete temptemp;
            insert into temptemp select /*value(l)*/distinct l.stbnodeid from table(leafentries) l;
            commit;
          end if;
        end if;
        previous_epis_tag := upper(stop_sems(i).stop_type);
        previous_activ_tag := upper(stop_sems(i).stop_activity);
        --dbms_output.put_line('pattern_tags end '||systimestamp);
        --check further only if found from tag some leaves
        if (leafentries.count>0) then        
          /*moved upwards
          open times_cur for 'select t.period_id, t.timeperiod
              from '||sdwTablePrefix||'_period_dim t
              --where rownum <10--for test
              --order by t.period_id
              ';
          loop
            fetch times_cur bulk collect into times;-- limit 1000;  
            exit when times.count=0; 
            */
            --dbms_output.put_line('start times recs no order for stop_sem:'||i||'->'||to_char(systimestamp, 'MM-DD-YYYY HH24:MI:SS.FF'));
            for j in times.first..times.count loop
              --make episode(i,j) 
              tmp_episode:= sem_episode(upper('STOP'), upper(stop_sems(i).stop_type),upper(stop_sems(i).stop_activity),
                sem_mbb(null,null).to_sem_mbb(stop_sems(i).poi_geom,times(j).timeperiod),null);
                      
              starting_time:=systimestamp;
              /* 
              stb_range_episodes returns whole episodes that their mbb
              intersect with the poi mbr and time period also all tags are taken into acount and prune the range results
              so we refine resulted episodes by taking the portion of episode's
              sub moving_point (the sub sub mpoint...) in time period and then check if intersection exists 
              between that polyline and poi geometry (also stop type and stop activity)
              For such a mpoint calculate measures ....
              */
              --select std.stb_range_episodes(tmp_episode,leafentries,stbtreeprefix) into episodes from dual;
              select std.stb_range_episodes(tmp_episode,'temptemp',stbtreeprefix) into episodes from dual;
              
              stmt:='range episodes for stop_sem, times: '||to_char(systimestamp - starting_time)||'--'||episodes.count;
              insert into dbmsoutput(message,a,b, c, message2)values(stmt,i,j, 200,'text_low_gran');commit;
              --dbms_output.put_line('range episodes for stop_sem, times:'||i||','||j||'->'||to_char(systimestamp - starting_time)||' found->'||episodes.count);
              
              if (episodes.count > 0) then
                --for each leaf entry=>episode
                for k in episodes.first..episodes.last loop
                  --calculate measures
                  select deref(episodes(k).tlink) into empoint from dual;
                  portionmpoint:=empoint.sub_mpoint.at_period_no_lib(times(j).timeperiod);
                  stmt:='insert into '||sdwTablePrefix||'_tmp_stops_fact(user_id,semtraj_id,period_id,stop_sems_id,user_profile_id,
                     activity,duration,radius_of_gyration) 
                     values (:empointo_id,:empointtraj_id,
                     :timesid,:stopsemsid,:empointo_id,:episodesactivity_tag,
                     :f_duration,
                     :radius_of_gyration)';
                  execute immediate stmt using in empoint.o_id,empoint.traj_id,
                     times(j).id,stop_sems(i).stop_sems_id,empoint.o_id,episodes(k).activity_tag,
                     portionmpoint.f_duration(),
                     portionmpoint.radius_of_gyration;
                  commit;
                end loop;
              end if;
            end loop;
          --end loop;
          close times_cur;        
        end if;
      end loop;--from moving bulk collect of times
        --dbms_output.put_line('stop_sems '||i||'ends at '||systimestamp);
      end loop;
    end loop;
    close stop_sems_cur;
    --delete ttttt;
    --insert into sem_dw_stops_fact
    
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
  end textstopsload;
  
  procedure textmovesload(sdwTablePrefix varchar2,stbtreeprefix varchar2) is
    query varchar2(5000);
    rc sys_refcursor;
    type stop_sems_typ is record(
         stop_sems_id pls_integer,
         poi_id pls_integer,
         poi_geom mdsys.sdo_geometry,
         stop_type varchar2(50),
         stop_activity varchar2(50)
    );
    type stop_sems_tab is table of stop_sems_typ;
    stop_sems stop_sems_tab;
    type time_typ is record(
         id pls_integer,
         timeperiod tau_tll.d_period_sec
    );
    type time_tab is table of time_typ;
    times time_tab;
    type move_sems_typ is record(
         move_sems_id pls_integer,
         route_type varchar2(50 byte),
         move_mode    varchar2(50 byte),
         move_activity    varchar2(50 byte)
    );
    type move_sems_tab is table of move_sems_typ;
    move_sems move_sems_tab;
    result_episode sem_episode;
    empoint sub_moving_point;
    portionmpoint moving_point;
    
    from_stop sem_episode;
    to_stop sem_episode;
    via_move sem_episode;
    previous_from_stop sem_episode:=sem_episode('STOP',null,null,null,null);
    previous_to_stop sem_episode:=sem_episode('STOP',null,null,null,null);
    previous_via_move sem_episode:=sem_episode('MOVE',null,null,null,null);
    
    candidate_moves sem_stbleafentrymid_tab:= sem_stbleafentrymid_tab();
    solutions_tags_from_stop sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    solutions_tags_via_move sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    solutions_tags_to_stop sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    
    solutions_mbbs_from_stop sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    solutions_mbbs_via_move sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    solutions_mbbs_to_stop sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
    results_moves sem_stbleafentrymid_tab:= sem_stbleafentrymid_tab();
    
    early tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    intervalsecs tau_tll.d_interval;
    later tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
    stmt varchar2(4000);
  begin
    open rc for 'select t.stop_sems_id, t.poi_id, p.poi_geom, t.stop_type, t.stop_activity
            from '||sdwTablePrefix||'_stop_sems_dim t, '||sdwTablePrefix||'_space_dim p
            where t.poi_id = p.poi_id
            --and rownum <30--for test
            --order by t.stop_sems_id,t.poi_id
            ';
            
    fetch rc bulk collect into stop_sems;
    close rc;
    query:='select t.period_id, t.timeperiod
            from '||sdwTablePrefix||'_period_dim t
            --where rownum <3--for test
            --order by t.period_id
            ';
    open rc for query;
    fetch rc bulk collect into times;
    close rc;
    query:='select t.move_sems_id, t.route_type, t.move_mode, t.move_activity
            from '||sdwTablePrefix||'_move_sems_dim t
            --where rownum <30--for test
            --order by t.move_sems_id
            ';
    open rc for query;
    fetch rc bulk collect into move_sems;
    close rc;
    
    for i in stop_sems.first..stop_sems.last loop--to form the from-poi
      --check if tags are the same as previously to avoid calling pattern_tags for same tags
      if (previous_from_stop.episode_tag is null or
        (previous_from_stop.episode_tag != stop_sems(i).stop_type) or (previous_from_stop.activity_tag != stop_sems(i).stop_activity)) then
        --make an from_stop episode with only tags
        from_stop:=sem_episode('STOP',stop_sems(i).stop_type,stop_sems(i).stop_activity,null,null);
        --get solutions from tag patterns for from_stop 
        solutions_tags_from_stop:=std.pattern_tags(from_stop, null, sem_stbleafentrymid_tab(), stbtreeprefix);
      end if;
      --prepare next check
      previous_from_stop.episode_tag := stop_sems(i).stop_type;
      previous_from_stop.activity_tag := stop_sems(i).stop_activity;
      if (solutions_tags_from_stop.count > 0) then
        --solutions found
        for m in move_sems.first..move_sems.last loop--move_sems
          --check if tags are the same as previously to avoid calling pattern_tags for same tags
          if (previous_via_move.episode_tag is null or
            (previous_via_move.episode_tag != move_sems(m).move_mode) or (previous_via_move.activity_tag != move_sems(m).move_activity)) then
            --make a via_move episode with only tags
            via_move:=sem_episode('MOVE',move_sems(m).move_mode, move_sems(m).move_activity,null,null);
            --get solutions from tag patterns for via_move 
            solutions_tags_via_move:=std.pattern_tags(via_move, '>', solutions_tags_from_stop, stbtreeprefix);
          end if;
          --prepare next check
          previous_via_move.episode_tag := move_sems(m).move_mode;
          previous_via_move.activity_tag := move_sems(m).move_activity;
          if (solutions_tags_via_move.count > 0) then
            --solutions found
            for k in stop_sems.first..stop_sems.last loop--to form the to-poi
              --check if tags are the same as previously to avoid calling pattern_tags for same tags
              if (previous_to_stop.episode_tag is null or
                (previous_to_stop.episode_tag != stop_sems(k).stop_type) or (previous_to_stop.activity_tag != stop_sems(k).stop_activity)) then
                --make a to_stop episode with only tags
                to_stop:=sem_episode('STOP',stop_sems(k).stop_type,stop_sems(k).stop_activity,null,null);
                --get solutions from tag patterns for to_stop 
                solutions_tags_to_stop:=std.pattern_tags(to_stop, '>', solutions_tags_via_move, stbtreeprefix);
              end if;
              --prepare next check
              previous_to_stop.episode_tag := stop_sems(k).stop_type;
              previous_to_stop.activity_tag := stop_sems(k).stop_activity;
              if (solutions_tags_to_stop.count > 0) then
                --solutions found
                --inverse combine solutions_tags_to_stop with solutions_tags_via_move
                select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
                  bulk collect into candidate_moves
                  from (select distinct t1.o_id, t1.traj_id, t1.stbnodeid, t1.entryid, t1.numOfEntries--<here is the difference with std.combine
                          from table(solutions_tags_to_stop) t2, table(solutions_tags_via_move) t1
                         where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id
                           and ((t2.stbnodeid = t1.stbnodeid and t2.entryid = t1.entryid+1)
                            or (t2.stbnodeid > t1.stbnodeid and t2.entryid=1 and t1.entryid=t1.numOfEntries))) k;
                  
                --dbms_output.put_line('candidate_moves='||candidate_moves.count||' for '||'STOP,'||stop_sems(i).stop_type||','||stop_sems(i).stop_activity||
                --  ', '||i||'->'||'MOVE,'||move_sems(m).move_mode||','||move_sems(m).move_activity||', '||m||
                --  '->'||'STOP,'||stop_sems(k).stop_type||','||stop_sems(k).stop_activity||', '||k);
                  
                if (candidate_moves.count > 0) then
                  --solutions found         
                  for j in times.first..times.last loop--to form periods of time
                    --helping variables
                    intervalsecs:=times(j).timeperiod.b.f_diff(times(j).timeperiod.e,times(j).timeperiod.b);                    
                    early.set_abs_date(times(j).timeperiod.b.get_abs_date()-intervalsecs.m_value);
                    later.set_abs_date(times(j).timeperiod.e.get_abs_date()+intervalsecs.m_value);
                    --check mbb intesecting for from_stop episode
                    from_stop.mbb:=sem_mbb(null,null).to_sem_mbb(stop_sems(i).poi_geom,tau_tll.d_period_sec(early,times(j).timeperiod.b));
                    solutions_mbbs_from_stop := std.pattern_mbbs(from_stop, null, 1, sem_stbleafentrymid_tab(), solutions_tags_from_stop, stbtreeprefix);
                    --solutions_mbbs_from_stop := std.pattern_mbbs(from_stop, null, 2, sem_stbleafentrymid_tab(), solutions_tags_from_stop, stbtreeprefix);
                    
                    if (solutions_mbbs_from_stop.count > 0) then
                      --check mbb intesecting for via_move episode though mbb is null
                      solutions_mbbs_via_move:=std.pattern_mbbs(via_move, '>', 1, solutions_mbbs_from_stop, solutions_tags_via_move, stbtreeprefix);
                      --solutions_mbbs_via_move:=std.pattern_mbbs(via_move, '>', 2, solutions_mbbs_from_stop, solutions_tags_via_move, stbtreeprefix);
                      
                      if (solutions_mbbs_via_move.count > 0) then
                        --check mbb intesecting for to_stop episode
                        to_stop.mbb:=sem_mbb(null,null).to_sem_mbb(stop_sems(k).poi_geom,tau_tll.d_period_sec(times(j).timeperiod.e, later));
                        solutions_mbbs_to_stop := std.pattern_mbbs(to_stop, '>', 1, solutions_tags_via_move, solutions_tags_to_stop, stbtreeprefix);
                        --solutions_mbbs_to_stop := std.pattern_mbbs(to_stop, '>', 2, solutions_tags_via_move, solutions_tags_to_stop, stbtreeprefix);
                        
                        if (solutions_mbbs_to_stop.count > 0) then
                          --solutions found
                          --inverse combine solutions_mbbs_to_stop with solutions_mbbs_via_move
                          select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
                            bulk collect into results_moves
                            from (select distinct t1.o_id, t1.traj_id, t1.stbnodeid, t1.entryid, t1.numOfEntries--<here is the difference with std.combine
                                    from table(solutions_mbbs_to_stop) t2, table(solutions_tags_via_move) t1
                                   where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id
                                     and ((t2.stbnodeid = t1.stbnodeid and t2.entryid = t1.entryid+1)
                                      or (t2.stbnodeid > t1.stbnodeid and t2.entryid=1 and t1.entryid=t1.numOfEntries))) k;
                          --results_moves are a subset of candidate_moves as their derivation comes from tags also
                          --dbms_output.put_line('results_moves='||results_moves.count||' for '||'STOP,'||stop_sems(i).stop_type||','||stop_sems(i).stop_activity||
                          --  ', '||i||'->'||'MOVE,'||move_sems(m).move_mode||','||move_sems(m).move_activity||', '||m||
                           -- '->'||'STOP,'||stop_sems(k).stop_type||','||stop_sems(k).stop_activity||', '||k||' at timep '|| j);
                            
                          if (results_moves.count > 0) then
                            --finally work through results as episodes
                            for e in results_moves.first..results_moves.last loop  
                              execute immediate 'begin select sem_episode(def_tag,epis_tag,activ_tag,mbb,tlink) into :tmp_episode
                                              from (select rownum aa, t.* from table(      
                                              select l.leaf.leafentries from '||stbtreeprefix||'_leaf l where lid=:lid) t)
                                              where aa =:entryid;end;'
                                using out result_episode, in results_moves(e).stbnodeid, in results_moves(e).entryid;
                                
                              select deref(result_episode.tlink) into empoint from dual;
                              
                              portionmpoint:=empoint.sub_mpoint.at_period(times(j).timeperiod);
                              --measures
                              
                              if (portionmpoint is not null) then
                                stmt:='insert into '||sdwtableprefix||'_tmp_moves_fact(user_id,semtraj_id,period_id,from_stop_sems_id,
                                  to_stop_sems_id,user_profile_id,move_sems_id,activity,distance_traveled,duration,speed,
                                  acceleration,radius_of_gyration)
                                values
                                  (:empointo_id,:empointtraj_id,:timesid,:fstopsemssid,:tstopsemsid,:empointo_id,
                                   /*(select move_semantic_id from sem_dw_move_semantics_dim
                                   where road_type=episodes(m).episode_tag and transport_mode=episodes(m).activity_tag),*/
                                   :move_sems_id,
                                   :episodesactivity_tag,:lengthportionmpointroute
                                   ,:portionmpointf_duration,:portionmpointf_avg_speed,:portionmpointf_avg_acceleration,
                                   :mbrportionmpointroute,:portionmpointradius_of_gyration)';
                                execute immediate stmt using in empoint.o_id,empoint.traj_id,times(j).id,stop_sems(i).stop_sems_id,
                                stop_sems(k).stop_sems_id,empoint.o_id,
                                   /*(select move_semantic_id from sem_dw_move_semantics_dim
                                   where road_type=episodes(m).episode_tag and transport_mode=episodes(m).activity_tag),*/
                                   move_sems(m).move_sems_id,
                                   result_episode.activity_tag,mdsys.sdo_geom.sdo_length(portionmpoint.route(),0.00005)
                                   ,portionmpoint.f_duration(),portionmpoint.f_avg_speed,portionmpoint.f_avg_acceleration
                                   ,portionmpoint.radius_of_gyration;
                                commit;
                              end if;
                            end loop;--results_moves
                          end if;
                        end if;
                      end if;
                    end if;  
                  end loop;--times
                end if;
              end if;
            end loop;--stop_sems
          end if;
        end loop;--move_sems
      end if;
    end loop;--stop_sems
    --insert into _moves_fact    
    stmt:='insert into '||sdwTablePrefix||'_moves_fact(period_id,from_stop_sems_id,to_stop_sems_id,user_profile_id,move_sems_id,
       num_of_sem_trajectories,num_of_users,num_of_activities,avg_distance_traveled,
       avg_travel_duration,avg_speed,avg_abs_acceleration,radius_of_gyration,crosst)
       select s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id,count(distinct s.semtraj_id),
              count(distinct s.user_id),count(distinct s.activity),
              sum(s.distance_traveled)/count(*),sum(s.duration)/count(*),sum(s.speed)/count(*)
              ,sum(s.acceleration)/count(*)
              ,sum(s.radius_of_gyration)/count(*)
               ,0
       from '||sdwTablePrefix||'_tmp_moves_fact s
       group by s.period_id, s.from_stop_sems_id,s.to_stop_sems_id,s.user_profile_id,s.move_sems_id';   
    execute immediate stmt;
    commit;
  end textmovesload;
  
  procedure updateauxiliarystops(sdwTablePrefix varchar2) is
    query varchar2(5000);
    rc sys_refcursor;
    type ids is table of pls_integer;
    poiids ids;
    timeids ids;
    userids ids;
    crosst pls_integer;
  begin
    query:='select distinct t.poi_id
            from '||sdwTablePrefix||'_stops_fact t
            order by t.poi_id';
    open rc for query;
    fetch rc bulk collect into poiids;
    close rc;
    query:='select distinct t.time_id
            from '||sdwTablePrefix||'_stops_fact t
            order by t.time_id';
    open rc for query;
    fetch rc bulk collect into timeids;
    close rc;
    query:='select distinct t.user_id
            from '||sdwTablePrefix||'_stops_fact t
            order by t.user_id';
    open rc for query;
    fetch rc bulk collect into userids;
    close rc;
    
    for p in poiids.first..poiids.last loop
      for t in timeids.first..timeids.last-1 loop--the last timeid is the end timepoint so no cell after that
        for u in userids.first..userids.last loop--in TDW this is not implemented
          if (t=1) then--first time_cell
            crosst:=0;
          else--hard coded values!!!(change them if you have time)
            query:='begin select count(*) into :crosst from(
              select distinct ss.user_id,ss.semtraj_id
              from '||sdwTablePrefix||'_tmp_stops_fact ss
              where ss.poi_id=:poiidsp and ss.user_profile_id=:useridsu 
              and ss.period_id=:timeidst1--exists on next time cell
              and (ss.user_id,ss.semtraj_id) in (--exists on previous time cell also
                select distinct s.user_id,s.semtraj_id
                from '||sdwTablePrefix||'_tmp_stops_fact s
                where s.period_id=timeidst
                and s.poi_id=poiidsp2
                and s.user_profile_id=useridsu2));end;
            ';
            execute immediate query using out crosst,in poiids(p),in userids(u),in timeids(t+1),in timeids(t),
              in poiids(p),in userids(u);
          end if;        
          
          query:='update '||sdwTablePrefix||'_stops_fact t
            set t.crosst=:crosst
            where t.period_id='||timeids(t)||'
            and t.poi_id='||poiids(p)||'
            and t.user_profile_id='||userids(u);
          execute immediate query using in crosst;
          commit;
        end loop;
      end loop;
    end loop;
  end updateauxiliarystops;
  
  procedure updateauxiliarymoves(sdwTablePrefix varchar2) is
    query varchar2(5000);
    rc sys_refcursor;
    type ids is table of pls_integer;
    poiids ids;
    timeids ids;
    userids ids;
    move_semsids ids;
    crosst pls_integer;
  begin
    query:='select distinct t.poi_id
            from '||sdwTablePrefix||'_moves_fact t
            order by t.poi_id';
    open rc for query;
    fetch rc bulk collect into poiids;
    close rc;
    query:='select distinct t.time_id
            from '||sdwTablePrefix||'_moves_fact t
            order by t.time_id';
    open rc for query;
    fetch rc bulk collect into timeids;
    close rc;
    query:='select distinct t.user_id
            from '||sdwTablePrefix||'_moves_fact t
            order by t.user_id';
    open rc for query;
    fetch rc bulk collect into userids;
    close rc;
    query:='select distinct t.move_semantic_id
            from '||sdwTablePrefix||'_moves_fact t
            order by t.move_semantic_id';
    open rc for query;
    fetch rc bulk collect into move_semsids;
    close rc;
    
    for pf in poiids.first..poiids.last loop
      for pt in poiids.first..poiids.last loop
        for t in timeids.first..timeids.last-1 loop--the last timeid is the end timepoint so no cell after that
          for u in userids.first..userids.last loop--in TDW this is not implemented
            for m in move_semsids.first..move_semsids.last loop--this is null for now
              if (t=1) then--first time_cell
                crosst:=0;
              else--hard coded values!!!(change them if you have time)
                query:='begin select count(*) into :crosst from(
                  select distinct ss.user_id,ss.semtraj_id
                  from '||sdwTablePrefix||'_tmp_moves_fact ss
                  where ss.from_poi_id=:poiidspf and ss.to_poi_id=:poiidspt
                  and ss.user_profile_id=:useridsu
                  and ss.move_semantic_id=:move_semsidsm
                  and ss.period_id=timeidst1--exists on next time cell
                  and (ss.user_id,ss.semtraj_id) in (--exists on previous time cell also
                    select distinct s.user_id,s.semtraj_id
                    from '||sdwTablePrefix||'_tmp_moves_fact s
                    where s.period_id=:timeidst
                    and s.from_poi_id=:poiidspf2 and s.to_poi_id=:poiidspt2
                    and s.user_profile_id=:useridsu2
                    and s.move_semantic_id=:move_semsidsm2
                    ));end;'
                ;
                execute immediate query using out crosst,in poiids(pf),in poiids(pt), in userids(u),
                  in move_semsids(m),in timeids(t+1),in timeids(t),in poiids(pf),in poiids(pt),
                  in userids(u),in move_semsids(m);
              end if;        
              
              query:='update '||sdwTablePrefix||'_moves_fact t
                set t.crosst=:crosst
                where t.period_id='||timeids(t)||'
                and t.from_poi_id='||poiids(pf)||' and t.to_poi_id='||poiids(pt)||'
                and t.user_profile_id='||userids(u)||'
                and t.move_semantic_id='||move_semsids(m);
              execute immediate query using in crosst;
              commit;
            end loop;
          end loop;
        end loop;
      end loop;
    end loop;
    
  end updateauxiliarymoves;
  
  function aggrstopscrosst(sdwTablePrefix varchar2,listofpois integer_nt,fromtimeid pls_integer,
    totimeid pls_integer,listofusers integer_nt) return number is
    crosst pls_integer:=0;stmt varchar2(4000);
  begin
    if (listofpois.count=0)or(listofusers.count=0)
      or(fromtimeid<=0)or(totimeid<=0)or(fromtimeid>totimeid)then--no aggregation
      return -1;
    end if;
    
    stmt:='begin select sum(t.crosst)
    into :crosst
    from '||sdwTablePrefix||'_stops_fact t
    where t.poi_id in (select column_value from table(:listofpois))
    and t.period_id = :fromtimeid--t=1
    and t.user_profile_id in (select column_value from table(:listofusers));end;';
    execute immediate stmt using out crosst,in listofpois,in fromtimeid,in listofusers;
    
    if crosst is null then crosst:=0; end if;
    dbms_output.put_line('crosst= '||crosst);
    
    return crosst;
  end aggrstopscrosst;
  
  function aggrstopsnumofsemtrajs(sdwTablePrefix varchar2,listofpois integer_nt,fromtimeid pls_integer,
    totimeid pls_integer,listofusers integer_nt) return number is
    plainaggregation pls_integer:=0;
    approxaggregation pls_integer:=0;stmt varchar2(4000);
    crosst pls_integer:=0;moves pls_integer:=0;
  begin
    if (listofpois.count=0)or(listofusers.count=0)
      or(fromtimeid<=0)or(totimeid<=0)or(fromtimeid>totimeid)then--no aggregation
      return -1;
    end if;
    
    stmt:='begin select sum(t.num_of_sem_trajectories)
    into :plainaggregation
    from '||sdwTablePrefix||'_stops_fact t
    where t.poi_id in (select column_value from table(:listofpois))
    and t.period_id between :fromtimeid and :totimeid
    and t.user_profile_id in (select column_value from table(:listofusers));end;';
    execute immediate stmt using out plainaggregation,in listofpois,in fromtimeid,in totimeid,in listofusers;
    
    if plainaggregation is null then plainaggregation:=0;end if;
    
    dbms_output.put_line('plain aggregation= '||plainaggregation);
    
    stmt:='begin select sum(t.crosst)
    into :crosst
    from '||sdwTablePrefix||'_stops_fact t
    where t.poi_id in (select column_value from table(:listofpois))
    and t.period_id > :fromtimeid and t.period_id <= :totimeid--t=2..n
    and t.user_profile_id in (select column_value from table(:listofusers));emd;';
    execute immediate stmt using out crosst,in listofpois,in fromtimeid,in totimeid,in listofusers;
    
    if crosst is null then crosst:=0;end if;
    
    stmt:='begin select sum(t.num_of_sem_trajectories)
    into :moves
    from '||sdwTablePrefix||'_moves_fact t
    where t.from_poi_id in (select column_value from table(listofpois))
    and t.to_poi_id in (select column_value from table(listofpois))
    and t.from_poi_id<>t.to_poi_id
    and t.period_id between fromtimeid and totimeid
    and t.user_profile_id in (select column_value from table(listofusers));end;';
    execute immediate stmt using out moves;
    
    if moves is null then moves:=0;end if;
    
    approxaggregation:=plainaggregation-crosst-moves;-- -crossp
    dbms_output.put_line('approx aggregation= '||approxaggregation);
    
    return approxaggregation;
  end aggrstopsnumofsemtrajs;
  
begin
  -- Initialization
  null;
end SDW;
/


