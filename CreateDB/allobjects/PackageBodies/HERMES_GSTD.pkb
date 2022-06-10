Prompt Package Body HERMES_GSTD;
CREATE OR REPLACE package body hermes_gstd is
       function he_GSTD_distance(x1 double precision, y1 double precision,
         x2 double precision, y2 double precision)
       return double precision is
       begin
         return sqrt(power(x1 - x2, 2.0) + power(y1 - y2, 2.0));
       end he_GSTD_distance;

       function he_GSTD_azimuth(x1 double precision, y1 double precision,
         x2 double precision, y2 double precision)
       return double precision is
         az double precision;
       begin
         if y2 - y1 = 0.0 then
           if x2 - x1 > 0.0 then
             az := acos(-1) / 2.0;
           else
             az := 3.0 * acos(-1) / 2.0;
           end if;
         else
           az := atan2(abs(x2 - x1), abs(y2 - y1));
         end if;
         if (x2 - x1) >= 0.0 and (y2 - y1) <= 0.0 then
           az := acos(-1) - az;
         elsif (x2 - x1) < 0.0 and (y2 - y1) < 0.0 then
           az := az + acos(-1);
         elsif (x2 - x1) < 0.0 and (y2 - y1) > 0.0 then
           az := 2.0 * acos(-1) - az;
         end if;

         if az = 2.0 * acos(-1) then
           az := 0.0;
         end if;
         return az;
       end he_GSTD_azimuth;

       function he_GSTD_random return double precision is
         fac double precision;
         r double precision;
         v1 double precision;
         v2 double precision;
       begin
         loop
           v1 := 2.0 * dbms_random.value - 1.0;
           v2 := 2.0 * dbms_random.value - 1.0;
           r := power(v1, 2.0) + power(v2, 2.0);
           exit when r < 1.0;
         end loop;
         fac := sqrt(-2.0 * ln(r) / r);
         return v2 * fac;
       end he_GSTD_random;

       function he_GSTD(fc_pts fc_pts_tab,
         NMO integer,  maximum_interval interval day to second,
         interval_mean interval day to second, interval_variance double precision,
         velocity_variance_fraction double precision,
         box sp_box_xy DEFAULT NULL
         )
       return out_type_tab pipelined is
         last_sp sp_point_xy;
         last_t timestamp;
         initial_interval interval day to second;
         iFPx double precision;
         iFPy double precision;
         velocity_mean double precision;
         velocity_variance double precision;
         dir_variance double precision;
         current_velocity double precision;
         current_interval interval day to second;
         current_length double precision;
         current_dir double precision;
         dx double precision;
         dy double precision;
         poi_id integer;
       begin
         if fc_pts is null or nmo is null or maximum_interval is null or interval_mean is null then
           return ;
         end if;

         last_sp := sp_point_xy(null, null);--init

         for i in 1..nmo loop
           last_sp.x := null;
           last_sp.y := null;
           last_t := null;
           initial_interval := round(((1.0 - extract(second from maximum_interval))
                     * dbms_random.value), 2 )
                     * interval '1' second;

           loop
             last_sp.x := fc_pts(1).x + fc_pts(1).spatial_variance * he_GSTD_random();
             last_sp.y := fc_pts(1).y + fc_pts(1).spatial_variance * he_GSTD_random();
             last_t := fc_pts(1).t + initial_interval;

             exit when box is null or (last_sp.x >= box.l.x
               and last_sp.x <= box.h.x
               and last_sp.y >= box.l.y
               and last_sp.y <= box.h.y);
           end loop;

           poi_id := 1;
           pipe row(out_type(i, 1, poi_id, spt_point_xy(last_t, last_sp)));

           for ifp in 2..fc_pts.count loop
             ifpx := fc_pts(ifp).x + fc_pts(ifp).spatial_variance * he_gstd_random();
             ifpy := fc_pts(ifp).y + fc_pts(ifp).spatial_variance * he_gstd_random();
             dir_variance := fc_pts(ifp).dir * acos(-1) / 200.0;

             while last_t < fc_pts(ifp).t + initial_interval loop
               loop
                 loop
                   if interval_variance is null then
                     current_interval := interval_mean * dbms_random.value * 2.0;
                   else
                     current_interval := interval_mean + interval_variance * he_gstd_random() *
                                interval '1' second;
                   end if;

                   exit when round(extract(second from current_interval), 6) > 0.0;
                 end loop;

                 current_dir := he_GSTD_azimuth(last_sp.x, last_sp.y, iFPx, iFPy);
                 current_dir := current_dir + dir_variance * he_gstd_random();

                 --divise by zero?
                 begin
                   velocity_mean := he_gstd_distance(last_sp.x, last_sp.y, ifpx, ifpy)
                                  / extract(second from fc_pts(ifp).t + initial_interval - last_t);
                 exception
                   when zero_divide then
                     --do something
                     null;
                 end;

                 loop
                   if velocity_variance_fraction is null then
                     current_velocity := velocity_mean * dbms_random.value * 2.0;
                   else
                     velocity_variance := velocity_mean * velocity_variance_fraction;
                     current_velocity := velocity_mean + velocity_variance * he_gstd_random();
                   end if;

                   exit when current_velocity > 0.0;
                 end loop;

                 current_length := extract(second from current_interval) * current_velocity;

                 if last_t + current_interval > fc_pts(ifp).t + initial_interval then
                   current_length := current_length * extract(second from fc_pts(ifp).t
                           + initial_interval - last_t)
                           / extract(second from current_interval);
                   current_interval := fc_pts(ifp).t + initial_interval - last_t;
                 end if;

                 dx := current_length * sin(current_dir);
                 dy := current_length * cos(current_dir);

                 exit when box is null or (last_sp.x + dx >= box.l.x
                     and last_sp.x + dx <= box.h.x
                     and last_sp.y + dy >= box.l.y
                     and last_sp.y + dy <= box.h.y
                   );
               end loop;

               last_sp.x := last_sp.x + dx;
               last_sp.y := last_sp.y + dy;
               last_t := last_t + current_interval;

               poi_id := poi_id + 1;
               pipe row(out_type(i, 1, poi_id, spt_point_xy(last_t, last_sp)));
             end loop;
           end loop;
         end loop;
         return;
       end he_gstd;

  procedure he_gstdtompoints(gstdparameters in varchar2, out_table in varchar2)
         is
  gstdtbl out_type_tab;
  tmp_mpoint moving_point;
  tmp_unit_function unit_function;
  tmp_period_sec tau_tll.d_period_sec;
  tmp_unit_mpoint unit_moving_point;
  tmp_mpoint_tab moving_point_tab:=moving_point_tab();
  prevobj integer:=-1;prevtraj integer:=-1;curobj integer:=-1;curtraj integer:=-1;
  sql_stmt varchar2(200);
  begin
    --get gstd output
    execute immediate '
    select out_type(t.obj_id, t.traj_id, t.poi_id,spt_point_xy(t.poi.t,sp_point_xy(t.poi.sp.x,t.poi.sp.y)))
    from table(hermes_gstd.he_GSTD('||gstdparameters||')) t' bulk collect into gstdtbl;

    --build moving points
    for gstdrow in gstdtbl.first..(gstdtbl.last-1) loop
      prevobj:=gstdtbl(gstdrow).obj_id;
      prevtraj:=gstdtbl(gstdrow).traj_id;
      curobj:=gstdtbl(gstdrow+1).obj_id;
      curtraj:=gstdtbl(gstdrow+1).traj_id;

      if (curobj=prevobj) then
        if (curtraj=prevtraj) then
          tmp_unit_function:=unit_function(gstdtbl(gstdrow).poi.sp.x, gstdtbl(gstdrow).poi.sp.y,
                                     gstdtbl(gstdrow+1).poi.sp.x, gstdtbl(gstdrow).poi.sp.y,
                                     null,null,null,null,null,'PLNML_1');
          tmp_period_sec:=tau_tll.d_period_sec(tau_tll.d_timepoint_sec(extract(year from gstdtbl(gstdrow).poi.t),
                                                                 extract(month from gstdtbl(gstdrow).poi.t),
                                                                 extract(day from gstdtbl(gstdrow).poi.t),
                                                                 extract(hour from gstdtbl(gstdrow).poi.t),
                                                                 extract(minute from gstdtbl(gstdrow).poi.t),
                                                                 extract(second from gstdtbl(gstdrow).poi.t)),
                                         tau_tll.d_timepoint_sec(extract(year from gstdtbl(gstdrow+1).poi.t),
                                                                 extract(month from gstdtbl(gstdrow+1).poi.t),
                                                                 extract(day from gstdtbl(gstdrow+1).poi.t),
                                                                 extract(hour from gstdtbl(gstdrow+1).poi.t),
                                                                 extract(minute from gstdtbl(gstdrow+1).poi.t),
                                                                 extract(second from gstdtbl(gstdrow+1).poi.t)));
          tmp_unit_mpoint:= unit_moving_point(tmp_period_sec,tmp_unit_function);
          tmp_mpoint_tab.extend(1);
          tmp_mpoint_tab(tmp_mpoint_tab.last):=tmp_unit_mpoint;
        else--curtraj<>prevtraj
          tmp_mpoint:=moving_point(tmp_mpoint_tab,prevtraj, null);
          sql_stmt := 'INSERT INTO '||out_table||' VALUES (:1, :2, :3)';
          execute immediate sql_stmt USING prevobj, prevtraj, tmp_mpoint;
          tmp_mpoint_tab.delete;
        end if;--curtraj=prevtraj
      else--curobj<>prevobj
        tmp_mpoint:=moving_point(tmp_mpoint_tab,prevtraj, null);
        sql_stmt := 'INSERT INTO '||out_table||' VALUES (:1, :2, :3)';
        execute immediate sql_stmt USING prevobj, prevtraj, tmp_mpoint;
        tmp_mpoint_tab.delete;
      end if;--curobj=prevobj
    end loop;
    --last gstd row only if are equal make mpoint
    if (curobj=prevobj) then
      if (curtraj=prevtraj) then
        tmp_mpoint:=moving_point(tmp_mpoint_tab,prevtraj, null);
        sql_stmt := 'INSERT INTO '||out_table||' VALUES (:1, :2, :3)';
        execute immediate sql_stmt USING prevobj, prevtraj, tmp_mpoint;
        tmp_mpoint_tab.delete;
      end if;
    end if;
    commit;
  end he_gstdtompoints;

end hermes_gstd;
/


