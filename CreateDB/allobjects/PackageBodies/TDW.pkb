Prompt Package Body TDW;
CREATE OR REPLACE package body TDW is

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

  PROCEDURE splitspace ( stepX IN number, stepY IN number, sourceTablePrefix varchar2)

   IS
        minX number;
        minY number;
        maxX number;
        maxY number;
        cminX number;
        cminY number;
        cmaxX number;
        cmaxY number;
        minxi number; maxxi number;minyi number;maxyi number;
        minxe number; maxxe number;minye number;maxye number;
        currentX number;
        currentY number;
        SRID pls_integer;
        stmt varchar2(5000);
BEGIN
    stmt :='begin select m.mpoint.srid into :srid from '||sourceTablePrefix||'_mpoints m
    where rownum=1;end;';--RULE: in table_mpoints there are mpoints with same SRID
    execute immediate stmt using out srid;
    --you should use the global statistics for better performance
    stmt := 'begin select min(u.m.xi), max(u.m.xi),min(u.m.yi), max(u.m.yi),min(u.m.xe), max(u.m.xe),min(u.m.ye), max(u.m.ye)
      into :minxi,:maxxi,:minyi,:maxyi,:minxe,:maxxe,:minye,:maxye from '
      ||sourceTablePrefix||'_mpoints m,table(m.mpoint.u_tab) u;end;';
    execute immediate stmt using out minxi,out maxxi,out minyi,out maxyi,out minxe,out maxxe,out minye,out maxye;
    if (minxi < minxe) then minx := minxi; else minx:= minxe; end if;
    if (minyi < minye) then miny := minyi; else miny:= minye; end if;
    if (maxxi > maxxe) then maxx := maxxi; else maxx:= maxxe; end if;
    if (maxyi > maxye) then maxy := maxyi; else maxy:= maxye; end if;

    currentX:= minX;
    currentY:= minY;


    WHILE (currentX <=maxX)
        LOOP
            WHILE (currentY <=maxY)
             LOOP
             cminX := currentX;
             cminY := currentY;
             cmaxX := cminX + stepX;
             cmaxY := cminY + stepY;
        --here we may use ||sourceTablePrefix||_REC_SEQ_ID.NEXTVAL instead though it does not matter
        stmt:='INSERT INTO '||sourcetableprefix||'_RECTANGLE(GEOGRAPHYID,X_DL,Y_DL,X_UR,Y_UR,RECGEO)
        VALUES('||REC_SEQ_ID.NEXTVAL||','||replace(cminX,',','.')||','||replace(cminY,',','.')||','||replace(cmaxX,',','.')||','||replace(cmaxY,',','.')||',
        :geom)';
        execute immediate stmt using in  MDSYS.SDO_GEOMETRY(2003,SRID,Null,
                MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
                MDSYS.sdo_ordinate_array(cminX,cminY,cmaxX,cmaxY));

        currentY := currentY + stepY; --update Y
            END LOOP;
        currentX := currentX + stepX; --update X
        currentY := minY;
END LOOP;

commit;
END splitspace;


  PROCEDURE splittime( secStep IN number, sourceTablePrefix varchar2)

   IS
    minYear number;
    maxYear number;
    minMonth char(2);
    maxMonth char(2);
    minDate timestamp;
    maxDate timestamp;
    mint timestamp;maxt timestamp;
    y number;
    m number;
    d number;
    h number;
    mi number;
    s number;
    stmt varchar2(5000);

BEGIN
  --you should use the global statistics for better performance
    stmt:='begin select min(to_timestamp(u.p.b.m_y||''-''||u.p.b.m_m||''-''||u.p.b.m_d||'' ''|| u.p.b.m_h||'':''
      || u.p.b.m_min||'':''||u.p.b.m_sec,''yyyy-mm-dd hh24:mi:ss'')),
      max(to_timestamp(u.p.e.m_y||''-''||u.p.e.m_m||''-''||u.p.e.m_d||'' ''|| u.p.e.m_h||'':''
      || u.p.e.m_min||'':''||u.p.e.m_sec,''yyyy-mm-dd hh24:mi:ss'')) into :mint,:maxt '
      ||'from '||sourceTablePrefix||'_mpoints m,table(m.mpoint.u_tab) u;end;';
    execute immediate stmt using out mint,out maxt;

    minyear:=extract(year from mint);
    maxYear:=extract(year from maxt);

    minMonth:=extract(month from mint);

    maxMonth:=extract(month from maxt);

    mindate :=  TO_TIMESTAMP('1/'||minMonth||'/'||minYear, 'dd/mm/yyyy hh24:mi:ss');

    IF maxMonth = 2 THEN
             maxDate :=  TO_TIMESTAMP('28/'||maxMonth||'/'||maxYear||' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
    ELSIF maxMonth = 4 or maxMonth = 6 or maxMonth = 9 or maxMonth = 11 THEN
             maxDate :=  TO_TIMESTAMP('30/'||maxMonth||'/'||maxYear||' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
    ELSE
             maxDate :=  TO_TIMESTAMP('31/'||maxMonth||'/'||maxYear||' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');
    END IF;

    while (mindate < maxDate)
    LOOP

    select EXTRACT(YEAR FROM minDate) into y from dual;
    select EXTRACT(MONTH FROM minDate) into m from dual;
    select EXTRACT(DAY FROM minDate) into d from dual;
    select EXTRACT(HOUR FROM minDate) into h from dual;
    select EXTRACT(MINUTE FROM minDate) into mi from dual;
    select EXTRACT(SECOND FROM minDate) into s from dual;

--dbms_output.put_line(to_char(minDate));
--'||sourceTablePrefix||'_
    stmt:='insert into '||sourceTablePrefix||'_timeslots (
    timeid, datedes, year, month, day, hour, minute, second)
    select '||timeslot_seq_id.NEXTVAL||','''||minDate||''','||y||','||m||','||d||',
    '||h||','||mi||','||s||' from dual';
    execute immediate stmt;

    mindate := mindate + secStep/86400;

    end loop;
commit;
END splittime;



PROCEDURE feed_tdw_mbr_BulkFeed(sourceTablePrefix varchar2) is
cv2 CursorType;
cv3 CursorType;
cvt CursorType;
TYPE ID IS TABLE OF INTEGER;
TIME_IDs ID;
CELL_IDs ID;
sttraj2 moving_point;
cell mdsys.sdo_geometry;
mbr mdsys.sdo_geometry;
lifespanFrom tau_tll.d_timepoint_sec;
lifespanTo tau_tll.d_timepoint_sec;
lifespanFromT timestamp;
lifespanToT timestamp;
tempperiod tau_tll.d_period_sec;
TRAJs ID;
OBJs ID;
traj moving_point;
s sdo_ordinate_array;
polyline mdsys.sdo_geometry;
tm mdsys.sdo_geometry;
dur number := 0;
len number := 0;
vel number := 0;
acc number := 0;
stper  tau_tll.d_period_sec;
stmt varchar2(5000);
incremental pls_integer;
begin
  IF NOT cv2%ISOPEN THEN
    OPEN cv2 FOR 'SELECT r.traj_id, r.object_id FROM '||sourceTablePrefix||'_MPOINTS r order by r.traj_id, r.object_id';
    FETCH cv2 BULK COLLECT INTO TRAJs, OBJs;
  END IF;

  FOR j IN TRAJs.FIRST .. TRAJs.LAST LOOP--assume traj_id=obj_id
    --incremental
    stmt:='begin select count(*) into :incr from '||sourceTablePrefix||'_tmpfacttbl r
    where r.obj_id = '||objs(j)||' and r.traj_id='||trajs(j)||';end;';
    execute immediate stmt using out incremental;
    if (incremental>0) then
      continue;
    end if;

    stmt:='begin select r.mpoint into :traj from '||sourceTablePrefix||'_MPOINTS r
    where r.object_id = '||objs(j)||' and r.traj_id='||trajs(j)||';end;';
    execute immediate stmt using out traj;

    IF traj.u_tab.COUNT > 0 then
      --get the MBR of the trajectory polyline
      mbr:=SDO_GEOM.SDO_MBR(TRAJ.route());
      --get the lifespan of the trajectory
      lifespanFrom:=TRAJ.f_initial_timepoint();
      lifespanTo:=TRAJ.f_final_timepoint();
      lifespanFromT := TO_TIMESTAMP(lifespanFrom.day||'/'||lifespanFrom.month||'/'||lifespanFrom.year||' '||lifespanFrom.hour||':'||lifespanFrom.minute||':'||lifespanFrom.second, 'dd/mm/yyyy hh24:mi:ss');
      lifespanToT := TO_TIMESTAMP(lifespanTo.day||'/'||lifespanTo.month||'/'||lifespanTo.year||' '||lifespanTo.hour||':'||lifespanTo.minute||':'||lifespanTo.second, 'dd/mm/yyyy hh24:mi:ss');
      --find which cells overlaps the MBR of the trajectory
      select mbr.sdo_ordinates into s from dual;
      if (s.count < 4) then
        --probably mbr is not rectangle but point
        continue;--go to next trajectory
      end if;
      IF NOT cv3%ISOPEN THEN
        --OPEN cv3 FOR 'select r.geographyid from rectangle r
        OPEN cv3 FOR 'select r.geographyid from '||sourceTablePrefix||'_rectangle r
          where
          (
              ('||s(2)||' <= r.y_dl And r.y_ur  <= '||s(4)||')or
              ('||s(4)||' >= r.y_ur  And r.y_ur  > '||s(2)||') Or
              ('||s(4)||' > r.y_dl And r.y_dl >= '||s(2)||') Or
              ('||s(4)||' <= r.y_ur  And r.y_dl < '||s(2)||')

          )
          and
          (
              ('||s(1)||' <= r.x_dl And r.x_ur  <= '||s(3)||')or
              ('||s(3)||' >= r.x_ur  And r.x_ur  > '||s(1)||') Or
              ('||s(3)||' > r.x_dl And r.x_dl >= '||s(1)||') Or
              ('||s(3)||' <= r.x_ur  And r.x_dl < '||s(1)||')
          )';

        FETCH cv3 BULK COLLECT INTO CELL_IDs;
      END IF;

      IF NOT cvt%ISOPEN THEN
        --stmt:='select t.timeid from time_periods t
        stmt:='select t.timeid from '||sourceTablePrefix||'_time_periods t
               where
               (
                  ('''||lifespanFromT||''' <= fromtimestamp And totimestamp <= '''||lifespanToT||''')or
                  ('''||lifespanToT||''' >= totimestamp And totimestamp > '''||lifespanFromT||''') Or
                  ('''||lifespanToT||''' > fromtimestamp And fromtimestamp >= '''||lifespanFromT||''') Or
                  ('''||lifespanToT||''' <= totimestamp And fromtimestamp < '''||lifespanFromT||'''))';
        OPEN cvt FOR stmt;
                  /*
                  same as--sider
                    where (
                      (lifespanFromT <= fromtimestamp And lifespanToT > fromtimestamp)or
                      (lifespanFromT > fromtimestamp And lifespanFromT <= totimestamp));
                  */
        FETCH cvt BULK COLLECT INTO TIME_IDs;
      END IF;

      if  (TIME_IDs.count=0) then
        return;
      end if;

      for m in time_ids.first .. time_ids.last loop
        stmt:='begin select tau_tll.d_period_sec(tau_tll.D_Timepoint_Sec(t.fy,t.fm,t.fd,t.fh,t.fmi,t.fs),
          tau_tll.D_Timepoint_Sec(t.ty,t.tm,t.td,t.th,t.tmi,t.ts))
        into :tempperiod
        from '||sourceTablePrefix||'_time_periods t where t.timeid='||time_ids(m)||';end;';
        execute immediate stmt using out tempperiod;
        sttraj2 := TRAJ.at_period(tempperiod);

        if (sttraj2 is not null) and (CELL_IDs.count>0) then
          --find the portion of trajectory inside cell
          polyline:=sttraj2.route();--exec for every time_id

          for k in cell_ids.first .. cell_ids.last loop
            stmt:='begin select r.recgeo into :cell from '||sourcetableprefix||'_rectangle r
            where r.geographyid='||cell_ids(k)||';end;';
            execute immediate stmt using out cell;

            select MDSYS.sdo_geom.sdo_intersection(cell,polyline,0.001) into tm from dual;
            --  insert into justmpoints select tbFunctions.tb_traj_in_spatiotemp_window2(TRAJ.traj_id,cell,tempperiod) from dual;
            IF tm is not null THEN
              --dbms_output.put_line(' lies into cell '||cell_ids(k)||' at period '||time_ids(m));

              len := SDO_GEOM.SDO_LENGTH(tm, 0.001);
              stper  := TAU_TLL.D_Period_sec(sttraj2.u_tab(sttraj2.u_tab.FIRST).p.b, sttraj2.u_tab(sttraj2.u_tab.LAST).p.e);
              dur := stper.duration().m_Value;
              IF dur <> 0 THEN vel := len / dur; END IF;
              acc := sttraj2.f_avg_acceleration();

              stmt:='INSERT INTO '||sourcetableprefix||'_tmpfacttbl (obj_id, traj_id, space_id, time_id, userprofile_id, time_duration,
              distance_traveled, speed, acceleration)
                VALUES ('||OBJs(j)||', '||TRAJs(j)||', '||CELL_IDs(k)||', '||TIME_IDs(m)||', '||OBJs(j)||','||dur||', '||len||','
                ||vel||', '||acc||')';
              execute immediate stmt;

            end if;
          END LOOP;
        end if;
      END LOOP;

        CLOSE cv3;
        CLOSE cvt;
    end if;
    commit;--incremental
  END LOOP;
    CLOSE cv2;

  stmt:='insert into '||sourcetableprefix||'_facttbl (time_id, space_id, trajectories, users,
       distance_traveled, time_duration, speed, acceleration)
       select time_id, space_id, count(distinct traj_id), count(distinct obj_id), sum(distance_traveled),
       sum(time_duration), cast(sum(speed)/count(*) as number(*,2)),avg(acceleration) from '||sourcetableprefix||'_tmpfacttbl
       group by time_id, space_id';--,acceleration;*/
  execute immediate stmt;
  commit;
END feed_tdw_mbr_BulkFeed;



PROCEDURE feed_tdw_mbr_sjBulkFeed(sourceTablePrefix varchar2) is
cv2 CursorType;
cv3 CursorType;
cvt CursorType;
TYPE traj is TABLE OF moving_point;
TYPE ID IS TABLE OF INTEGER;
TYPE PERIOD IS TABLE OF tau_tll.d_period_sec;
TIME_IDs ID;
CELL_IDs ID;
PERIODs PERIOD;
sttraj moving_point;
sttraj2 moving_point;
cell mdsys.sdo_geometry;
TRAJs traj;
k number(10,0);
j number(10,0);
stmt varchar2(5000);

begin
    if not cv2%isopen then
        OPEN cv2 FOR 'SELECT r.mpoint FROM '||sourceTablePrefix||'_MPOINTS r';
        FETCH cv2 BULK COLLECT INTO TRAJs;
    END IF;

 if not cvt%isopen then
 OPEN cvt FOR 'SELECT t.timeid, tau_tll.d_period_sec(tau_tll.D_Timepoint_Sec(t.fy,t.fm,t.fd,t.fh,t.fmi,t.fs),
                                                           tau_tll.D_Timepoint_Sec(t.ty,t.tm,t.td,t.th,t.tmi,t.ts))
 FROM '||sourceTablePrefix||'_time_periods t order by t.timeid'; --lower level of temporal hierarchy
 FETCH cvt BULK COLLECT INTO TIME_IDs, PERIODs;
 END IF;

       FOR j IN TRAJs.FIRST .. TRAJs.LAST LOOP
            --get the trajectory polyline
            IF TRAJs(j).u_tab.COUNT <> 0 then
                --find which cells overlaps the MBR of the trajectory
                if not cv3%isopen then
                stmt:='select r.geographyid from '||sourcetableprefix||'_rectangle r
                  where SDO_RELATE(r.recgeo, SDO_GEOM.SDO_MBR(:traj), ''mask=ANYINTERACT'') = ''TRUE''';
                open cv3 for stmt using TRAJs(j).route();
                 FETCH cv3 BULK COLLECT INTO CELL_IDs;
                END IF;

                        FOR k IN CELL_IDs.LAST-1 .. CELL_IDs.LAST LOOP

                           stmt:='begin select r.recgeo into :cell from '||sourcetableprefix||'_rectangle r
                            where r.geographyid='||cell_ids(k);
                           execute immediate stmt using out cell;
                           --find the portion of trajectory inside cell
                           sttraj:=TRAJs(j).f_intersection(cell,0.001);

                           if sttraj is not null then
                                --decompose the portion into several time periods
                                FOR f IN TIME_IDs.LAST-1 .. TIME_IDs.LAST LOOP
                                    sttraj2 := sttraj.at_period(PERIODs(f));

                                    IF sttraj2 is not null THEN
                                        null;--dbms_output.put_line('trajectory '||j||' lies into cell '||k||' at period '||f);
                                    end if;
                                END LOOP;
                           end if;
                        END LOOP;
                        CLOSE cv3;
            END IF;
       END LOOP;
    CLOSE cv2;
    CLOSE cvt;
    END feed_tdw_mbr_sjBulkFeed;

PROCEDURE feed_tdw_tbtree_BulkFeed(sourceTablePrefix varchar2, tbtreenodes varchar2, tbtreeleafs varchar2) is
cv2 CursorType;
cv3 CursorType;
TYPE ID IS TABLE OF INTEGER;
TYPE GEOM IS TABLE OF mdsys.sdo_geometry;
TYPE PERIOD IS TABLE OF tau_tll.d_period_sec;
sttraj moving_point;
stline mdsys.sdo_geometry;
stper  tau_tll.d_period_sec;
GEOM_IDs ID;
RECTs GEOM;
TIME_IDs ID;
PERIODs PERIOD;
i pls_integer;
j pls_integer;
f pls_integer;
dur number := 0;
len number := 0;
vel number := 0;
acc number := 0;
mpa mp_array;
stmt varchar2(5000);
srid integer;

increment integer;
begin
  if not cv2%isopen then
      OPEN cv2 FOR 'SELECT distinct r.recgeo.sdo_srid FROM '||sourcetableprefix||'_rectangle r';
      FETCH cv2  INTO srid;
      close cv2;
  END IF;


    if not cv2%isopen then
        OPEN cv2 FOR 'SELECT r.geographyid, r.recgeo FROM '||sourcetableprefix||'_rectangle r order by r.geographyid'; --lower level of spatial hierarchy
        FETCH cv2 BULK COLLECT INTO GEOM_IDs, RECTs;
    END IF;



    if not cv3%isopen then
        OPEN cv3 FOR 'SELECT t.timeid, tau_tll.d_period_sec(tau_tll.D_Timepoint_Sec(t.fy,t.fm,t.fd,t.fh,t.fmi,t.fs),
                                                           tau_tll.d_timepoint_sec(t.ty,t.tm,t.td,t.th,t.tmi,t.ts))
                     FROM '||sourcetableprefix||'_time_periods t order by t.timeid'; --lower level of temporal hierarchy
        FETCH cv3 BULK COLLECT INTO TIME_IDs, PERIODs;
    END IF;



    FOR j IN GEOM_IDs.FIRST .. GEOM_IDs.LAST LOOP
        FOR f IN TIME_IDs.FIRST .. TIME_IDs.LAST LOOP

            /*SELECT moving_point(p.u_tab, p.traj_id)
            BULK COLLECT INTO mpa
            FROM TABLE(tbFunctions.range(RECTs(j),PERIODs(f))) p;*/
            select tbfunctions.range(rects(j),periods(f),srid,
              tbtreenodes, tbtreeleafs) into mpa from dual;

            if mpa is not null then

                FOR i IN 1 .. mpa.COUNT LOOP
                  --for incremental
                  stmt:='begin select count(*) into :incr from '||sourceTablePrefix||'_tmpfacttbl r
                  where r.obj_id = '||mpa(i).traj_id||' and r.traj_id='||mpa(i).traj_id||
                  ' and t.userprofile_id='||mpa(i).traj_id||' and t.space_id='||GEOM_IDs(j)||
                  ' and t.time_id='||TIME_IDs(f)||';end;';
                  execute immediate stmt using out increment;

                  if (increment>0) then
                    continue;
                  end if;

                      sttraj:=mpa(i);

                      stline := sttraj.route();
                      len := SDO_GEOM.SDO_LENGTH(stline, 0.001);
                      stper  := TAU_TLL.D_Period_sec(sttraj.u_tab(sttraj.u_tab.FIRST).p.b, sttraj.u_tab(sttraj.u_tab.LAST).p.e);
                      dur := stper.duration().m_Value;
                      IF dur <> 0 THEN vel := len / dur; END IF;
                      acc := sttraj.f_avg_acceleration();


                      stmt:='INSERT INTO '||sourcetableprefix||'_tmpfacttbl (obj_id, traj_id, space_id, time_id, userprofile_id,
                      time_duration, distance_traveled, speed, acceleration)
                      VALUES ((select m.object_id from '||sourcetableprefix||'_MPOINTS m
                      where m.traj_id=:trajid), :traj_id, '||GEOM_IDs(j)||', '||TIME_IDs(f)||', '||mpa(i).traj_id||', '||dur||', '||len||'
                      , '||vel||', '||acc||')';
                      execute immediate stmt using in mpa(i).traj_id, in  mpa(i).traj_id;
                      --OBJ_IDs(k)

                END LOOP;
            --  commit;
            end if;

        END LOOP;
    --  commit;
    END LOOP;

    CLOSE cv2;
    CLOSE cv3;

stmt:='insert into '||sourcetableprefix||'_facttbl (time_id, space_id, trajectories, users,
       distance_traveled, time_duration, speed, acceleration)
select time_id, space_id, count(distinct traj_id), count(distinct obj_id), sum(distance_traveled),
sum(time_duration), cast(sum(speed)/count(*) as number(*,2)),avg(acceleration) from '||sourcetableprefix||'_tmpfacttbl
group by time_id, space_id';
execute immediate stmt;
commit;
END feed_tdw_tbtree_BulkFeed;

  PROCEDURE CalculateAuxiliary_cl is
TYPE CursorType IS REF CURSOR;
cv2 CursorType;
cv3 CursorType;
TYPE ID IS TABLE OF INTEGER;
TIMEIDs ID;
RECIDs ID;
Xneigh integer;
Xneigh_count integer;
Yneigh integer;
Yneigh_count integer;
Tneigh integer;
Tneigh_count integer;

BEGIN

        IF NOT cv2%ISOPEN THEN
        OPEN cv2 FOR SELECT distinct f.time_id FROM facttbl f;
        FETCH cv2 BULK COLLECT INTO TIMEIDs;
    END IF;

        IF NOT cv3%ISOPEN THEN
        OPEN cv3 FOR SELECT distinct f.space_id FROM facttbl f;
        FETCH cv3 BULK COLLECT INTO RECIDs;
    END IF;


     FOR i IN TIMEIDs.FIRST .. TIMEIDs.LAST LOOP
        FOR j IN RECIDs.FIRST .. RECIDs.LAST LOOP
        --find the neighboroughs

        begin

        Xneigh_count :=0;
        Xneigh := -1;

        SELECT geographyid into Xneigh FROM rectangle
        WHERE (x_ur, y_dl, y_ur) in
        (select r1.x_dl, r1.y_dl, r1.y_ur
        from rectangle r1
        where r1.geographyid = RECIDs(j));

        exception
        when no_data_found then
        null;

        end;

        begin

        Yneigh_count :=0;
        Yneigh := -1;

        SELECT geographyid into Yneigh FROM rectangle
        WHERE (y_ur, x_dl, x_ur) in
        (select r2.y_dl, r2.x_dl, r2.x_ur
        from rectangle r2
        where r2.geographyid = RECIDs(j));

        exception
        when no_data_found then
        null;

        end;

        begin

        Tneigh_count :=0;
        Tneigh := -1;

        select timeid into Tneigh from time_periods where
        (ty, tm, td, th, tmi, ts) in
         (
           select fy, fm, fd, fh, fmi, fs from time_periods where
            timeid = TIMEIDs(i)
         );

        exception
        when no_data_found then
        null;

        end;

        if(Xneigh!=-1)
        then
        select count(*) into Xneigh_count from (
        select distinct obj_id, traj_id  from tmpfacttbl t where
        time_id = TIMEIDs(i) and space_id = Xneigh and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from tmpfacttbl t where
          time_id = TIMEIDs(i) and space_id = RECIDs(j)
         ));
         end if;

        if(Yneigh!=-1) then
         select count(*) into Yneigh_count from (
         select distinct obj_id, traj_id  from tmpfacttbl t where
        time_id = TIMEIDs(i) and space_id = Yneigh and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from tmpfacttbl t where
          time_id = TIMEIDs(i) and space_id = RECIDs(j)
         ));
        end if;

         if(Tneigh!=-1) then
         select count(*) into Tneigh_count from (
          select distinct obj_id, traj_id   from tmpfacttbl t where
        time_id = Tneigh and space_id = RECIDs(j) and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from tmpfacttbl t where
          time_id = TIMEIDs(i) and space_id = RECIDs(j)
         ));
         end if;

         update facttbl
         set crossx = Xneigh_count, crossY = Yneigh_count, crossT = Tneigh_count
         where TIME_ID = TIMEIDs(i) and SPACE_ID = RECIDs(j);

        commit;
        END LOOP;
     END LOOP;
  close cv2;
 close cv3;
END CalculateAuxiliary_cl;

PROCEDURE CalculateAuxiliary_cl(sourceTablePrefix varchar2) is
TYPE CursorType IS REF CURSOR;
cv2 CursorType;
cv3 CursorType;
TYPE ID IS TABLE OF INTEGER;
TIMEIDs ID;
RECIDs ID;
Xneigh integer;
Xneigh_count integer;
Yneigh integer;
Yneigh_count integer;
Tneigh integer;
tneigh_count integer;
stmt varchar2(5000);

BEGIN

        if not cv2%isopen then
        OPEN cv2 FOR 'SELECT distinct f.time_id FROM '||sourceTablePrefix||'_facttbl f';
        FETCH cv2 BULK COLLECT INTO TIMEIDs;
    END IF;

        if not cv3%isopen then
        OPEN cv3 FOR 'SELECT distinct f.space_id FROM '||sourceTablePrefix||'_facttbl f';
        FETCH cv3 BULK COLLECT INTO RECIDs;
    END IF;


     FOR i IN TIMEIDs.FIRST .. TIMEIDs.LAST LOOP
        FOR j IN RECIDs.FIRST .. RECIDs.LAST LOOP
        --find the neighboroughs

        begin

        Xneigh_count :=0;
        Xneigh := -1;

        stmt:='begin SELECT geographyid into :Xneigh FROM '||sourceTablePrefix||'_rectangle
        WHERE (x_ur, y_dl, y_ur) in
        (select r1.x_dl, r1.y_dl, r1.y_ur
        from '||sourceTablePrefix||'_rectangle r1
        where r1.geographyid = '||RECIDs(j)||');end;';
        execute immediate stmt using out Xneigh;

        exception
        when no_data_found then
        null;

        end;

        begin

        Yneigh_count :=0;
        Yneigh := -1;

        stmt:='begin SELECT geographyid into :Yneigh FROM '||sourceTablePrefix||'_rectangle
        WHERE (y_ur, x_dl, x_ur) in
        (select r2.y_dl, r2.x_dl, r2.x_ur
        from '||sourceTablePrefix||'_rectangle r2
        where r2.geographyid = '||RECIDs(j)||');end;';
        execute immediate stmt using out Yneigh;

        exception
        when no_data_found then
        null;

        end;

        begin

        Tneigh_count :=0;
        Tneigh := -1;

        stmt:='begin select timeid into :Tneigh from '||sourceTablePrefix||'_time_periods where
        (ty, tm, td, th, tmi, ts) in
         (
           select fy, fm, fd, fh, fmi, fs from '||sourceTablePrefix||'_time_periods where
            timeid = '||TIMEIDs(i)||'
         );end;';
         execute immediate stmt using out Tneigh;

        exception
        when no_data_found then
        null;

        end;

        if(Xneigh!=-1)
        then
        stmt:='begin select count(*) into :Xneigh_count from (
        select distinct obj_id, traj_id  from '||sourceTablePrefix||'_tmpfacttbl t where
        time_id = '||TIMEIDs(i)||' and space_id = '||Xneigh||' and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from '||sourceTablePrefix||'_tmpfacttbl t where
          time_id = '||TIMEIDs(i)||' and space_id = '||RECIDs(j)||'
         ));end;';
         execute immediate stmt using out Xneigh_count;
         end if;

        if(yneigh!=-1) then
         stmt:='begin select count(*) into :Yneigh_count from (
         select distinct obj_id, traj_id  from '||sourceTablePrefix||'_tmpfacttbl t where
        time_id = '||TIMEIDs(i)||' and space_id = '||Yneigh||' and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from '||sourceTablePrefix||'_tmpfacttbl t where
          time_id = '||TIMEIDs(i)||' and space_id = '||RECIDs(j)||'
         ));end;';
         execute immediate stmt using out Yneigh_count;
        end if;

         if(tneigh!=-1) then
         stmt:='begin select count(*) into :Tneigh_count from (
          select distinct obj_id, traj_id from '||sourceTablePrefix||'_tmpfacttbl t where
        time_id = '||Tneigh||' and space_id = '||RECIDs(j)||' and
          (obj_id, traj_id) in
         (
          select distinct obj_id, traj_id from '||sourceTablePrefix||'_tmpfacttbl t where
          time_id = '||TIMEIDs(i)||' and space_id = '||RECIDs(j)||'
         ));end;';
         execute immediate stmt using out Tneigh_count;
         end if;

         stmt:= 'update '||sourcetableprefix||'_facttbl
         set crossx = '||Xneigh_count||', crossY = '||Yneigh_count||', crossT = '||Tneigh_count||'
         where TIME_ID = '||TIMEIDs(i)||' and SPACE_ID = '||RECIDs(j)||'';
         execute immediate stmt;

        commit;
        END LOOP;
     END LOOP;
  close cv2;
 close cv3;
END CalculateAuxiliary_cl;


  procedure createTDW(sourceTablePrefix varchar2) is
    stmt varchar2(5000);
    begin
      --table rectangles
      stmt := 'CREATE TABLE '||sourceTablePrefix||'_RECTANGLE(GEOGRAPHYID NUMBER(22,2) NOT NULL,
      RECGEO MDSYS.SDO_GEOMETRY,X_DL NUMBER(22,10),Y_DL NUMBER(22,10),X_UR NUMBER(22,10),
      Y_UR NUMBER(22,10)) COLUMN RECGEO NOT SUBSTITUTABLE AT ALL LEVELS';
      execute immediate stmt;
      --table TIMESLOTS
      stmt := 'create table '||sourceTablePrefix||'_TIMESLOTS(TIMEID NUMBER(9) not null,
      DATEDES TIMESTAMP(7),YEAR NUMBER(4),MONTH NUMBER(2),DAY NUMBER(2),MINUTE NUMBER(2),
      SECOND NUMBER(2),HOUR NUMBER(2), constraint '||sourceTablePrefix||'_TIMESLOTS_PK primary key (TIMEID))';
      execute immediate stmt;
      --table TMPFACTTBL
      stmt:='create table '||sourceTablePrefix||'_TMPFACTTBL(TIME_ID INTEGER NOT NULL,SPACE_ID INTEGER NOT NULL,
                USERPROFILE_ID INTEGER NOT NULL,DISTANCE_TRAVELED NUMBER(22,2),TIME_DURATION INTEGER,
                SPEED INTEGER,ACCELERATION INTEGER,OBJ_ID INTEGER,TRAJ_ID INTEGER)';
      execute immediate stmt;
      stmt:='create index '||sourceTablePrefix||'_OBJ_TRAJ_IDS on
                '||sourceTablePrefix||'_TMPFACTTBL (OBJ_ID, TRAJ_ID)';
      execute immediate stmt;
      stmt:='create index '||sourceTablePrefix||'_TMP_PK_IX on
                '||sourceTablePrefix||'_TMPFACTTBL (TIME_ID, SPACE_ID, USERPROFILE_ID)';
      execute immediate stmt;
      --table FACTTBL
      stmt:='create table '||sourceTablePrefix||'_FACTTBL(TIME_ID INTEGER NOT NULL,SPACE_ID INTEGER NOT NULL,
                TRAJECTORIES INTEGER,USERS INTEGER,DISTANCE_TRAVELED NUMBER(22,2),TIME_DURATION INTEGER,
                SPEED INTEGER,ACCELERATION INTEGER,CROSSX NUMBER,CROSSY NUMBER,CROSST NUMBER,
                CONSTRAINT '||sourceTablePrefix||'_FACTTBL_IX PRIMARY KEY (TIME_ID, SPACE_ID))';
      execute immediate stmt;
      --view TIME_PERIODS
      stmt:='create or replace view '||sourceTablePrefix||'_time_periods as
                select a.timeid as timeID, a.year as fy, a.month as fm, a.day as fd, a.hour as fh, a.minute as fmi,
                a.second as fs,b.year as ty, b.month as tm, b.day as td, b.hour as th, b.minute as tmi, b.second as ts,
                a.datedes as fromtimestamp, b.datedes as totimestamp
                from '||sourceTablePrefix||'_timeslots a, '||sourceTablePrefix||'_timeslots b
                where b.timeid=a.timeid+1
                order by timeid';
      execute immediate stmt;
      --sequence REC_SEQ_ID
      stmt:='create sequence '||sourceTablePrefix||'_REC_SEQ_ID minvalue 1 maxvalue 999999999999999999999999999
                start with 32145 increment by 1';
      execute immediate stmt;
      --sequence TIMESLOT_SEQ_ID
      stmt:='create sequence '||sourceTablePrefix||'_TIMESLOT_SEQ_ID minvalue 1 maxvalue 999999999999999999999999999
                start with 2150921 increment by 1';
      execute immediate stmt;
    end createTDW;




begin
  -- Initialization
  null;
end TDW;
/


