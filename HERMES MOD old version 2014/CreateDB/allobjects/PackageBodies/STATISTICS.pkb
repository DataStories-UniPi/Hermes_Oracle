Prompt Package Body STATISTICS;
CREATE OR REPLACE package body Statistics is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;*/
function timepoint2timestamp(timepoint tau_tll.d_timepoint_sec)
  return timestamp is
    resultimestamp timestamp;
  begin
    select to_timestamp(
     timepoint.m_y||'-'||
     timepoint.m_m||'-'||
     timepoint.m_d||' '||
     timepoint.m_h||':'||
     timepoint.m_min||':'||
     timepoint.m_sec,'yyyy-mm-dd hh24:mi:ss')
     into resultimestamp
     from dual;
    return resultimestamp;
  end timepoint2timestamp;

  procedure gathertimestatistics
    --time series histogram on trajectories
  is
  min_timepoint timestamp;max_timepoint timestamp;current_timepoint timestamp;
  previous_timepoint timestamp;countTrajs number;
begin
  delete from dataforstatisticgraphs;
  select min(mi), max(ma) into min_timepoint, max_timepoint
    from(
      select tf.traj_id traj_id, min(ts.datedes) mi, max(ts.datedes) ma
      from timeslots ts, tmpfacttbl tf
      where ts.timeid = tf.time_id
      group by tf.traj_id
      order by 1);

      insert into dataforstatisticgraphs values(0,0,0,0,0,-1,min_timepoint,0);
      insert into dataforstatisticgraphs values(0,0,0,0,0,-2,max_timepoint,0);

      previous_timepoint := min_timepoint;
      current_timepoint := min_timepoint + 1/24;--add 1 hour

      while current_timepoint < max_timepoint loop
        select count(traj_id) into countTrajs
        from(
          select tf.traj_id traj_id, min(ts.datedes) mi, max(ts.datedes) ma
          from timeslots ts, tmpfacttbl tf
          where ts.timeid = tf.time_id
          group by tf.traj_id
          order by 1)
        where (mi <= previous_timepoint and ma > previous_timepoint)
        or    (mi > previous_timepoint and mi < current_timepoint);

        insert into dataforstatisticgraphs values(0,0,0,0,0,countTrajs,current_timepoint,0);

        previous_timepoint := current_timepoint;
        current_timepoint := current_timepoint + 1/24;
      end loop;

end gathertimestatistics;

  procedure AttributeValuesCalculation
    --when a boxandwhisker or a histogram plot to do
    (table_name in varchar2,
    selectedAttributes in number)
    is
    trajs mp_array;

    pos1 number;
    i number;
    length number := 0;
    duration number := 0;
    stmt varchar2(500);
    cv sys_refcursor;

    trajid number;

  begin
    stmt:='select m.mpoint from '|| table_name ||' m 
           --where m.object_id=3711
           --and m.traj_id=1
           ';
    delete from dataforstatisticgraphs;
    commit;
    open cv for stmt;
    loop
      fetch cv bulk collect into trajs limit 100;
      exit when trajs.count=0;
      for pos1 in trajs.first..trajs.last loop
        trajid := trajs(pos1).traj_id;--first mpoint
        i :=  trajs(pos1).u_tab.first;--first segment
        while i is not null loop
            /*length := length + utilities.distance( trajs(pos1).u_tab(i).m.xi,  trajs(pos1).u_tab(i).m.yi,
                 trajs(pos1).u_tab(i).m.xe,  trajs(pos1).u_tab(i).m.ye);*/--coords in meters
            length := length + sdo_geom.sdo_length(trajs(pos1).route(),
                   trajs(pos1).route().get_dims());--coords in degrees result in meters
            duration := duration +  trajs(pos1).u_tab(i).p.duration().m_Value;

            i :=  trajs(pos1).u_tab.next(i);--next segment
        end loop;
        
        case (selectedAttributes)
        when 0 then--no attribute
            null;
        when 1 then--duration
            insert into dataforstatisticgraphs (category, series1)
               values(trajid, duration);
        when 2 then--avgSpeed
            insert into dataforstatisticgraphs (category, series1)
               values(trajid, length/duration);
        when 3 then--length
            insert into dataforstatisticgraphs (category, series1)
               values(trajid, length);
        when 4 then--ALL--length, avgspeed, duration
            insert into dataforstatisticgraphs (category, series1, series2, series3)
               values(trajid, length, length/duration, duration);
        else--no attribute
            null;
      end case;
      
      length := 0;
      duration := 0;
      
      end loop;
      commit;
    end loop;
    close cv;

  end AttributeValuesCalculation;

  procedure XYDataFromAttributesValues
    --a correlation (scatter) plot to do
    (table_name in varchar2,
    xAttr in number,
    yAttr in number)
    is
    --xyAttr = 0 for length(series1), 1 for avgspeed(series2), 2 for duration(series3)
    xColumn varchar2(10);
    yColumn varchar2(10);

    begin
      AttributeValuesCalculation(table_name, 4);--selectedAttributes = 4

      case(xAttr)
        when 0 then--no attribute
            null;
        when 1 then
          xColumn := 'series1';
        when 2 then
          xColumn := 'series2';
        when 3 then
          xColumn := 'series3';
      end case;
      case(yAttr)
        when 0 then--no attribute
            null;
        when 1 then
          yColumn := 'series1';
        when 2 then
          yColumn := 'series2';
        when 3 then
          yColumn := 'series3';
      end case;


      execute immediate 'update dataforstatisticgraphs set xdata = '|| xColumn ||
                        ', ydata = '|| yColumn;

    end xydatafromattributesvalues;
    
    procedure createdatasetstats(sourcetable varchar2,for_sub_mpoints integer:=0)
    --for tables with moving_point or sub_moving_point types
    --columns=(object_id,traj_id,mpoint) or (o_id, subtraj_id, sub_mpoint)
    is
      outtable varchar2(100);
      headingbins number_set:= number_set(22.5, 45, 45, 45, 45, 45, 45, 45, 45);
    begin
      
      if (for_sub_mpoints=1) then
        createviewsubs2mpoints(sourcetable);
        outtable := createdimensiontables(sourcetable||'_view');
        fillDimensionTables(sourcetable||'_view',outtable, headingbins);
        --dropviewsubs2mpoints(sourcetable);
      else
        outtable:=createdimensiontables(sourcetable);
        fillDimensionTables(sourcetable,outtable, headingbins);
      end if;
    end createdatasetstats;
    
    procedure createviewsubs2mpoints(sourcetable varchar2) is
      stmt varchar2(4000);
    begin
      stmt:='create or replace view '||sourcetable||'_view as
                    select t.o_id object_id, t.subtraj_id traj_id, t.sub_mpoint mpoint from '||sourcetable||' t';
      execute immediate stmt;
      commit;
    end createviewsubs2mpoints;
    
    procedure dropviewsubs2mpoints(sourcetable varchar2) is
      stmt varchar2(4000);
    begin
      stmt:='drop view '||sourcetable||'_view';
      execute immediate stmt;
      commit;
    end dropviewsubs2mpoints;
    
    function createdimensiontables(sourcetable varchar2) return varchar2 is
    stmt varchar2(4000);
    toolong exception;
    srid integer;
    outtable varchar2(30);
    begin
      stmt := 'begin select m.mpoint.srid into :srid from '||sourcetable||' m where rownum<=1;end;';
      execute immediate stmt using out srid;
      
      if (length(sourcetable)>20) then
        null;
        --raise toolong;
      end if;
      --keep only first 10 letters
      outtable := substr(sourcetable,1,10);
      --create a global table
      stmt:='create table '||outtable||'_global(disksize number, numofpoints integer,numoftrajs integer, numofobjs integer,
        mint timestamp,maxt timestamp,minlon number, maxlon number, minlat number,maxlat number, centrlon number, centrlat number,
        srid integer, minx number, maxx number, miny number,maxy number, centrx number, centry number,
        mintrajsperobj integer, medtrajsperobj integer, avgtrajsperobj number, maxtrajsperobj integer,
        minsamplesperobj number, medsamplesperobj number, avgsamplesperobj number, maxsamplesperobj number,
        minpointspertraj integer, medpointspertraj integer, avgpointspertraj number, maxpointspertraj integer,
        minsamplespertraj number, medsamplespertraj number, avgsamplespertraj number, maxsamplespertraj number,
        mindurationpertraj number, meddurationpertraj number, avgdurationpertraj number, maxdurationpertraj number,
        minlengthpertraj number, medlengthpertraj number, avglengthpertraj number, maxlengthpertraj number,
        mindisplacementpertraj number, meddisplacementpertraj number, avgdisplacementpertraj number, maxdisplacementpertraj number,
        minspeedpertraj number, medspeedpertraj number, avgspeedpertraj number, maxspeedpertraj number,
        heading number_set
        )';
      execute immediate stmt;
      commit;
      --create a per trajectory table
      stmt:='create table '||outtable||'_pertraj(object_id integer,traj_id integer,
        mint timestamp,maxt timestamp,minlon number, maxlon number, minlat number,maxlat number, centrlon number, centrlat number,
        srid integer, minx number, maxx number, miny number,maxy number, centrx number, centry number,      
        numofpoints integer, samplesrate number, radiusofgyration number, startloc sdo_geometry,endloc sdo_geometry,
        mbb sem_mbb, duration number, length number, avgspeed number, displacement number, heading number
        )';
      execute immediate stmt;
      commit;
      --startloc
      stmt:='delete user_sdo_geom_metadata where upper(table_name)=upper('''||outtable||'_pertraj'')
        and upper(column_name)= upper(''startloc'')';
      execute immediate stmt;
      commit;
      stmt:='insert into user_sdo_geom_metadata(table_name, column_name, diminfo, srid) 
        values('''||outtable||'_pertraj'', ''startloc'',
        mdsys.sdo_dim_array(
          mdsys.sdo_dim_element(''Longitude'',-180,180,0.005),
          mdsys.sdo_dim_element(''Latitude'' ,-90,90,0.005)),
          '||srid||')';
      execute immediate stmt;
      commit;
      stmt:='create index '||outtable||'_startloc on '||outtable||'_pertraj(startloc) 
        indextype is mdsys.spatial_index';
      execute immediate stmt;
      --endloc
      stmt:='delete user_sdo_geom_metadata where upper(table_name)=upper('''||outtable||'_pertraj'')
        and upper(column_name)=upper( ''endloc'')';
      execute immediate stmt;
      commit;
      stmt:='insert into user_sdo_geom_metadata(table_name, column_name, diminfo, srid) 
        values('''||outtable||'_pertraj'', ''endloc'',
        mdsys.sdo_dim_array(
          mdsys.sdo_dim_element(''Longitude'',-180,180,0.005),
          mdsys.sdo_dim_element(''Latitude'' ,-90,90,0.005)),
          '||srid||')';
      execute immediate stmt;
      commit;
      stmt:='create index '||outtable||'_endloc on '||outtable||'_pertraj(endloc) 
        indextype is mdsys.spatial_index';
      execute immediate stmt;
      return outtable;
    
      exception
      when toolong then
        dbms_output.put_line('Prefix name is too long');
    end createdimensiontables;
    
    procedure filldimensiontables(sourcetable varchar2, outtable varchar2, headingbins number_set) is
    stmt varchar2(4000);
    traj_cv sys_refcursor;
    
    minxi number; maxxi number;minyi number;maxyi number;
    minxe number; maxxe number;minye number;maxye number;
    minx number; maxx number;miny number;maxy number;
    mint timestamp;maxt timestamp;samplesrate number;
    minlon number; maxlon number;minlat number;maxlat number;
    minpointlatlon sdo_geometry;maxpointlatlon sdo_geometry;
    centrx number; centry number;centrlon number; centrlat number;
    srid integer;numoftrajs integer;displacement number;
    startlocx number; startlocy number;endlocx number;endlocy number;
    startloc sdo_geometry;endloc sdo_geometry;
    mbb sem_mbb;duration number; length number; avgspeed number; numofpoints integer;
    radiusofgyration number;heading number;
    
    trajgeom sdo_geometry;
    type traj_rec is record(
      object_id    integer,
      traj_id integer,
      mpoint  moving_point);
    traj traj_rec;
    
    disksize number; numofobjs integer;
    mintrajsperobj number;medtrajsperobj number;avgtrajsperobj number;maxtrajsperobj number;
    minsamplesperobj number;medsamplesperobj number; avgsamplesperobj number; maxsamplesperobj number;
    minpointspertraj number; medpointspertraj number; avgpointspertraj number; maxpointspertraj number;
    minsamplespertraj number; medsamplespertraj number; avgsamplespertraj number; maxsamplespertraj number;
    mindurationpertraj number; meddurationpertraj number; avgdurationpertraj number; maxdurationpertraj number;
    minlengthpertraj number; medlengthpertraj number;avglengthpertraj number; maxlengthpertraj number;
    mindisplacementpertraj number; meddisplacementpertraj number; avgdisplacementpertraj number;
    maxdisplacementpertraj number; minspeedpertraj number; medspeedpertraj number; avgspeedpertraj number;
    maxspeedpertraj number; 
    headingresults number_set:=number_set();startbin number;binstart number; binend number;
    
    begin
      --get the mpoint srid
      stmt := 'begin select m.mpoint.srid into :srid from '||sourcetable||' m where rownum<=1;end;';
      execute immediate stmt using out srid;
      --fill the tables
      --fill the per trajectory table
      stmt:='select m.object_id,m.traj_id,m.mpoint from '|| sourcetable ||' m';
      open traj_cv for stmt;
      loop
        fetch traj_cv into traj;
        exit when traj_cv%notfound;
        numofpoints:=traj.mpoint.u_tab.count + 1;
        duration:=traj.mpoint.f_duration();
        samplesrate := numofpoints / duration;
        radiusofgyration := traj.mpoint.radius_of_gyration();
        avgspeed:=traj.mpoint.f_avg_speed();
        trajgeom:=traj.mpoint.route();--2002 type
        length:=sdo_geom.sdo_length(trajgeom,trajgeom.get_dims());
        
        startlocx :=traj.mpoint.u_tab(traj.mpoint.u_tab.first).m.xi;
        startlocy :=traj.mpoint.u_tab(traj.mpoint.u_tab.first).m.yi;
        startloc := sdo_geometry(2001,srid,sdo_point_type(startlocx,startlocy, null),null, null);
        endlocx :=traj.mpoint.u_tab(traj.mpoint.u_tab.last).m.xe;
        endlocy :=traj.mpoint.u_tab(traj.mpoint.u_tab.last).m.ye;
        endloc := sdo_geometry(2001,srid,sdo_point_type(endlocx,endlocy, null),null, null);
        
        heading := utilities.direction(startlocx, startlocy, endlocx, endlocy);
        
        stmt:='begin select min(to_timestamp(u.p.b.m_y||''-''||u.p.b.m_m||''-''||u.p.b.m_d||'' ''|| u.p.b.m_h||'':''
          || u.p.b.m_min||'':''||u.p.b.m_sec,''yyyy-mm-dd hh24:mi:ss'')), 
          max(to_timestamp(u.p.e.m_y||''-''||u.p.e.m_m||''-''||u.p.e.m_d||'' ''|| u.p.e.m_h||'':''
          || u.p.e.m_min||'':''||u.p.e.m_sec,''yyyy-mm-dd hh24:mi:ss'')) into :mint,:maxt '
          ||'from table(:u_tab) u;end;'; 
        execute immediate stmt using out mint,out maxt, in traj.mpoint.u_tab;
      
        stmt := 'begin select min(u.m.xi), max(u.m.xi),min(u.m.yi), max(u.m.yi),min(u.m.xe), max(u.m.xe),min(u.m.ye), max(u.m.ye)
          into :minxi,:maxxi,:minyi,:maxyi,:minxe,:maxxe,:minye,:maxye from 
          table(:u_tab) u;end;';
        execute immediate stmt using out minxi,out maxxi,out minyi,out maxyi,out minxe,out maxxe,out minye,out maxye,
          in traj.mpoint.u_tab;
        
        stmt := 'begin 
          select avg(x), avg(y) 
          into :centrx, :centry
          from (
            select u.m.xi x, u.m.yi y from table(:u_tab) u
            union
            select u.m.xe, u.m.ye from table(:u_tab) u
          )
          ;end;';
        execute immediate stmt using out centrx, out centry,
          in traj.mpoint.u_tab;
                
        if (minxi < minxe) then minx := minxi; else minx:= minxe; end if;
        if (minyi < minye) then miny := minyi; else miny:= minye; end if; 
        if (maxxi > maxxe) then maxx := maxxi; else maxx:= maxxe; end if;
        if (maxyi > maxye) then maxy := maxyi; else maxy:= maxye; end if; 
        
        minpointlatlon := sdo_cs.transform(sdo_geometry(2001, srid, sdo_point_type(minx, miny, null), null, null), 8307);
        maxpointlatlon := sdo_cs.transform(sdo_geometry(2001, srid, sdo_point_type(maxx, maxy, null), null, null), 8307);
        
        minlon := minpointlatlon.sdo_point.x;
        maxlon:= maxpointlatlon.sdo_point.x;
        minlat := minpointlatlon.sdo_point.y;
        maxlat := maxpointlatlon.sdo_point.y;
        centrlon:= sdo_cs.transform(sdo_geometry(2001, srid, sdo_point_type(centrx, 0, null), null, null), 8307).sdo_point.x;
        centrlat:= sdo_cs.transform(sdo_geometry(2001, srid, sdo_point_type(0, centry, null), null, null), 8307).sdo_point.y;
        
        mbb := sem_mbb(sem_st_point(minx,miny,traj.mpoint.u_tab(traj.mpoint.u_tab.first).p.b),
                        sem_st_point(maxx,maxy,traj.mpoint.u_tab(traj.mpoint.u_tab.last).p.e)); 
                    
        stmt:='insert into '||outtable||'_pertraj(object_id,traj_id,
          mint ,maxt ,minlon , maxlon , minlat ,maxlat , centrlon , centrlat ,
          srid , minx , maxx , miny ,maxy , centrx , centry ,      
          numofpoints , samplesrate , radiusofgyration , startloc ,endloc ,
          mbb , duration , length , avgspeed , displacement , heading)
          values(
            :object_id,:traj_id, :mbbmint, :mbbmaxt, :minlon, :maxlon, :minlat, :maxlat,:centrlon, :centrlat,
            :srid, :minx, :maxx, :miny, :maxy, :centrx, :centry, 
            :numofpoints, :samplesrate, :radiusofgyration, :startloc, :endloc,
            :mbb, :duration, :length, :avgspeed, :displacement, :heading
          )';
        execute immediate stmt using traj.object_id, traj.traj_id, mint, maxt, minlon, maxlon, minlat, maxlat, centrlon, centrlat,
          srid, minx, maxx, miny, maxy, centrx, centry, numofpoints, samplesrate, radiusofgyration, 
          startloc, endloc,
          mbb, duration, length, avgspeed, 
          sdo_geom.sdo_distance(startloc, endloc,0.05), 
          heading;
        commit;
      end loop;
      close traj_cv;
      --fill the global table -->>>mind that trajs migth be also subtrajs 
      disksize:=29.7;
      
      stmt:='begin select count(distinct object_id), count(*)
        into :numofobjs, :numoftrajs
        from '||outtable||'_pertraj p;end;';
      execute immediate stmt using out numofobjs, out numoftrajs;
      
      stmt:='begin select sum(p.numofpoints),
        min(mint), max(maxt), min(minlon), max(maxlon), min(minlat), max(maxlat),
        avg(centrlon), avg(centrlat), 
        min(minx), max(maxx), min(miny), max(maxy),avg(centrx), avg(centry)
        into :numofpoints, :mint, :maxt, :minlon, :maxlon, :minlat, :maxlat, :centrlon, :centrlat,
          :minx, :maxx, :miny, :maxy, :centrx, :centry
        from '||outtable||'_pertraj p;end;';
      execute immediate stmt using out numofpoints, out mint, out maxt, out minlon, out maxlon, out minlat, 
        out maxlat, out centrlon, out centrlat,out minx, out maxx, out miny, out maxy, out centrx, out centry;
      
      stmt:='begin select min(tr), median(tr), avg(tr), max(tr) 
        into :mintrajsperobj, :medtrajsperobj, :avgtrajsperobj, :maxtrajsperobj
        from(select object_id, count(traj_id) tr        
        from '||outtable||'_pertraj p
        group by object_id);end;';
      execute immediate stmt using out mintrajsperobj, out medtrajsperobj, out avgtrajsperobj, out maxtrajsperobj;
      
      stmt:='begin select min(points/seconds), median(points/seconds), avg(points/seconds), max(points/seconds) 
        into :minsamplesperobj, :medsamplesperobj, :avgsamplesperobj, :maxsamplesperobj
        from(select object_id, sum(numofpoints) points,
        extract(day from to_dsinterval(max(maxt)-min(mint)))*86400+extract(hour from to_dsinterval(max(maxt)-min(mint)))*3600
        +extract(minute from to_dsinterval(max(maxt)-min(mint)))*60+extract(second from to_dsinterval(max(maxt)-min(mint))) seconds       
        from '||outtable||'_pertraj p
        group by object_id);end;';
      execute immediate stmt using out minsamplesperobj, out medsamplesperobj, out avgsamplesperobj, out maxsamplesperobj;
      
      stmt:='begin select min(numofpoints), median(numofpoints), avg(numofpoints), max(numofpoints) 
        into :minpointspertraj, :medpointspertraj, :avgpointspertraj, :maxpointspertraj
        from(select traj_id, numofpoints     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out minpointspertraj, out medpointspertraj,out avgpointspertraj, out maxpointspertraj;
      
      stmt:='begin select min(samplesrate), median(samplesrate), avg(samplesrate), max(samplesrate) 
        into :minsamplespertraj, :medsamplespertraj, :avgsamplespertraj, :maxsamplespertraj
        from(select traj_id, samplesrate     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out minsamplespertraj, out medsamplespertraj, out avgsamplespertraj, out maxsamplespertraj;
      
      stmt:='begin select min(duration), median(duration), avg(duration), max(duration) 
        into :mindurationpertraj, :meddurationpertraj, :avgdurationpertraj, :maxdurationpertraj
        from(select traj_id, duration     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out mindurationpertraj, out meddurationpertraj, out avgdurationpertraj, out maxdurationpertraj;
      
      stmt:='begin select min(length), median(length), avg(length), max(length) 
        into :minlengthpertraj, :medlengthpertraj, :avglengthpertraj, :maxlengthpertraj
        from(select traj_id, length     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out minlengthpertraj, out medlengthpertraj,out avglengthpertraj,out maxlengthpertraj;
      
      stmt:='begin select min(displacement), median(displacement), avg(displacement), max(displacement) 
        into :mindisplacementpertraj, :meddisplacementpertraj, :avgdisplacementpertraj, :maxdisplacementpertraj
        from(select traj_id, displacement     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out mindisplacementpertraj,out meddisplacementpertraj,out avgdisplacementpertraj,out maxdisplacementpertraj;

      stmt:='begin select min(avgspeed), median(avgspeed), avg(avgspeed), max(avgspeed) 
        into :minspeedpertraj, :medspeedpertraj, :avgspeedpertraj, :maxspeedpertraj
        from(select traj_id, avgspeed     
        from '||outtable||'_pertraj p);end;';
      execute immediate stmt using out minspeedpertraj,out medspeedpertraj,out avgspeedpertraj,out maxspeedpertraj;

      for i in headingbins.first..headingbins.last loop
        --first number is the start
        if i = 1 then
          binstart := headingbins(i);
        else
          headingresults.extend(1);
          if (binstart + headingbins(i)) > 360 then
            binend := binstart + headingbins(i) - 360;
            stmt := 'begin select count(traj_id) into :trajsinbin from '||outtable||'_pertraj 
              where (heading >= :binstart and heading < 360) or (heading >= 0 and heading < :binend);end;';
            execute immediate stmt using out headingresults(headingresults.last), in binstart, in binend;
          else
            binend := binstart + headingbins(i);
            stmt := 'begin select count(traj_id) into :trajsinbin from '||outtable||'_pertraj 
              where heading >= :binstart and heading < :binend;end;';
            execute immediate stmt using out headingresults(headingresults.last), in binstart, in binend;
          end if;
          binstart := binend;
          if binstart = 360 then
            binstart := 0;
          end if;
        end if;
      end loop;
      
      stmt:='insert into '||outtable||'_global(disksize, numofpoints, numoftrajs, numofobjs,
        mint, maxt, minlon, maxlon, minlat, maxlat, centrlon, centrlat, srid, 
        minx, maxx, miny, maxy, centrx, centry, mintrajsperobj, medtrajsperobj, avgtrajsperobj, maxtrajsperobj,
        minsamplesperobj, medsamplesperobj, avgsamplesperobj, maxsamplesperobj, minpointspertraj, medpointspertraj,
        avgpointspertraj, maxpointspertraj, minsamplespertraj, medsamplespertraj, avgsamplespertraj, maxsamplespertraj,
        mindurationpertraj, meddurationpertraj, avgdurationpertraj, maxdurationpertraj, minlengthpertraj, medlengthpertraj,
        avglengthpertraj, maxlengthpertraj, mindisplacementpertraj, meddisplacementpertraj, avgdisplacementpertraj,
        maxdisplacementpertraj, minspeedpertraj, medspeedpertraj, avgspeedpertraj, maxspeedpertraj,
        heading ) 
        values (
          :disksize, :numofpoints, :numoftrajs, :numofobjs,
          :mint, :maxt, :minlon, :maxlon, :minlat, :maxlat, :centrlon, :centrlat, :srid, 
          :minx, :maxx, :miny, :maxy, :centrx, :centry, :mintrajsperobj, :medtrajsperobj, :avgtrajsperobj, :maxtrajsperobj,
          :minsamplesperobj, :medsamplesperobj, :avgsamplesperobj, :maxsamplesperobj, :minpointspertraj, :medpointspertraj,
          :avgpointspertraj, :maxpointspertraj, :minsamplespertraj, :medsamplespertraj, :avgsamplespertraj, :maxsamplespertraj,
          :mindurationpertraj, :meddurationpertraj, :avgdurationpertraj, :maxdurationpertraj, :minlengthpertraj, :medlengthpertraj,
          :avglengthpertraj, :maxlengthpertraj, :mindisplacementpertraj, :meddisplacementpertraj, :avgdisplacementpertraj,
          :maxdisplacementpertraj, :minspeedpertraj, :medspeedpertraj, :avgspeedpertraj, :maxspeedpertraj,
          :headingresults
        )';
      execute immediate stmt using disksize, numofpoints, numoftrajs, numofobjs,
        mint, maxt, minlon, maxlon, minlat, maxlat, centrlon, centrlat, srid,
        minx, maxx, miny, maxy, centrx, centry,mintrajsperobj, medtrajsperobj, avgtrajsperobj, maxtrajsperobj,
        minsamplesperobj, medsamplesperobj, avgsamplesperobj, maxsamplesperobj,
        minpointspertraj, medpointspertraj,avgpointspertraj, maxpointspertraj,
        minsamplespertraj, medsamplespertraj, avgsamplespertraj, maxsamplespertraj, 
        mindurationpertraj, meddurationpertraj, avgdurationpertraj, maxdurationpertraj,
        minlengthpertraj, medlengthpertraj,avglengthpertraj, maxlengthpertraj, 
        mindisplacementpertraj, meddisplacementpertraj, avgdisplacementpertraj,maxdisplacementpertraj, 
        minspeedpertraj, medspeedpertraj, avgspeedpertraj, maxspeedpertraj, 
        headingresults;
      commit;
      

    end fillDimensionTables;
    
    procedure dropdatasetstats(sourcetable varchar2) is
    stmt varchar2(4000);
    outtable varchar2(20);
    begin
      outtable := substr(sourcetable,1,10);
      stmt:='drop table '||outtable||'_global';
      execute immediate stmt;
      commit;
      --create a per trajectory table
      stmt:='drop table '||outtable||'_pertraj';
      execute immediate stmt;
      commit;
    end dropdatasetstats;


begin
  -- Initialization
  --<Statement>;
  null;
end Statistics;
/


