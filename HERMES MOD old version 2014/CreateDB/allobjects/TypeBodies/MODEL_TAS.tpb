Prompt Type Body MODEL_TAS;
CREATE OR REPLACE TYPE BODY MODEL_TAS IS


    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
      return id;
    END;


     MEMBER FUNCTION f_membership(mp Hermes.MOVING_POINT, traj_id NUMBER) RETURN NUMBER IS
          edge NUMBER;
          r BOOLEAN;
     BEGIN

          edge := u_tab.FIRST;
          r:=satisfyInterval(mp, traj_id,
                                 mp.f_initial_timepoint(),
                                 mp.f_final_timepoint(),
                                 edge);
          if (r) THEN RETURN 1; else RETURN 0; END IF;

     END;

     MEMBER FUNCTION getSegments(mp Hermes.Moving_Point, traj_id NUMBER) RETURN MOVING_POINT_SET IS
          seg MOVING_POINT_SET;
          i0  NUMBER;
          i1  NUMBER;
          x0  NUMBER;
          y0  NUMBER;
          x1  NUMBER;
          y1  NUMBER;
          cur HERMES.MOVING_POINT_TAB;
     BEGIN
          i0 := mp.u_tab.FIRST;
          cur:= new HERMES.MOVING_POINT_TAB();
          cur.EXTEND;
          cur(cur.Last) := mp.u_tab(i0);
          i1 := mp.u_tab.NEXT(i0);
          WHILE (i1 IS NOT NULL) LOOP
               x0 := mp.u_tab(i0).m.xe;
               y0 := mp.u_tab(i0).m.ye;
               x1 := mp.u_tab(i1).m.xi;
               y1 := mp.u_tab(i1).m.yi;
               if ((x0 = x1) AND (y0 = y1)) THEN
                    cur.EXTEND;
                    cur(cur.Last) := mp.u_tab(i1);
               ELSE
                    seg:= new MOVING_POINT_SET();
                    seg.EXTEND;
                    seg(seg.last) := HERMES.MOVING_POINT(cur, traj_id, mp.srid);
                    cur.DELETE;
                    cur.EXTEND;
                    cur(cur.Last) := mp.u_tab(i1);
               END IF;

               i0 := mp.u_tab.NEXT(i0);
               i1 := mp.u_tab.NEXT(i1);
          END LOOP;
          seg.EXTEND;
          seg(seg.last) := HERMES.MOVING_POINT(cur, traj_id, mp.srid);

          RETURN seg;
     END;

     MEMBER FUNCTION satisfyInterval(mp    Hermes.MOVING_POINT,
                                     traj_id NUMBER,
                                     t_min tau_tll.d_timepoint_sec,
                                     t_max tau_tll.d_timepoint_sec,
                                     edge  NUMBER) RETURN BOOLEAN AS
          trunc_mp Hermes.MOVING_POINT;
          region   MDSYS.SDO_GEOMETRY;
          enter    tau_tll.d_timepoint_sec;
          leave    tau_tll.d_timepoint_sec;
          i_min    tau_tll.d_interval;
          i_max    tau_tll.d_interval;
          next_min tau_tll.d_timepoint_sec;
          next_max tau_tll.d_timepoint_sec;
          segments moving_point_set;
          i        integer;
          res      BOOLEAN;
     BEGIN
          --Reach the End of Tas
          if (edge IS NULL) THEN
               --The Previous TAS properties to satisfy for second region
               region := u_tab(u_tab.LAST)
                        .u_regions(u_tab(u_tab.LAST).u_regions.LAST);
          ELSE
               --Current TAS properties to satisfy
               region := u_tab(edge).u_regions(u_tab(edge).u_regions.FIRST);
               i_min  := u_tab(edge)
                        .u_interval(u_tab(edge).u_interval.FIRST);
               i_max  := u_tab(edge)
                        .u_interval(u_tab(edge).u_interval.LAST);
          END IF;

          BEGIN
               trunc_mp := mp.f_intersection(region, 0.005);
          EXCEPTION
               WHEN OTHERS THEN
                    trunc_mp := null;
          END;

               --Check if the trajectory intersect the region
          if (trunc_mp IS NULL) THEN return FALSE;
     END IF;

     segments := moving_point_set();
     if      (trunc_mp.check_meet()) THEN segments.EXTEND;
     segments(1) := trunc_mp;
     ELSE     segments := getSegments(trunc_mp, traj_id);
END IF;

res := TRUE; i := segments.FIRST;

WHILE(i IS
NOT NULL AND res) LOOP
--Current moving_point segment which intersect the region
trunc_mp := segments(i);

--Current enter and leave timepoint
enter := trunc_mp.f_initial_timepoint(); leave := trunc_mp.f_final_timepoint();

--Intersect the ROI too late
/*Dbms_Output.put_line('Tempi t_min, tmax');
Dbms_Output.put_line(t_min.to_string());
Dbms_Output.put_line(t_max.to_string());
Dbms_Output.put_line('Tempi enter, leave');
Dbms_Output.put_line(enter.to_string());
Dbms_Output.put_line(leave.to_string());
if (edge is not null) THEN
Dbms_Output.put_line('Tempi i_min, i_max');
Dbms_Output.put_line(i_min.to_string());
Dbms_Output.put_line(i_max.to_string());
END IF;*/

if (enter.f_precedes(t_max, enter) > 0) THEN return FALSE;
END IF;

--Intersect the ROI too early
if (leave.f_precedes(leave, t_min) > 0) THEN return FALSE;
END IF;

-- if is the last and not FALSE then TRUE
if (edge is null) THEN RETURN TRUE;
END IF;

--Reduce the interval using the previous jump constraints
if (enter.f_precedes(enter, t_min) > 0) THEN enter := t_min;
END IF; if (t_max.f_precedes(t_max, leave) > 0) THEN leave := t_max;
END IF;

--Compute the next jump
next_min := enter; next_min.f_add_interval(i_min); next_max := leave; next_max.f_add_interval(i_max);

--Recursion on the next jump
res := satisfyInterval(mp, traj_id, next_min, next_max, u_tab.NEXT(edge));

--Depth First research
i := segments.NEXT(i);
END LOOP;

--Return the result (if at least a path is all TRUE => return TRUE)
RETURN res;

END;

MEMBER FUNCTION get_num_geometries RETURN NUMBER IS
BEGIN

RETURN u_tab.last+1;
END;

MEMBER FUNCTION get_geometry RETURN MDSYS.SDO_GEOMETRY IS
BEGIN

RETURN NULL;
END;

MEMBER FUNCTION get_nth_geometry(n NUMBER) RETURN MDSYS.SDO_GEOMETRY IS
BEGIN

RETURN NULL;
END;

MEMBER FUNCTION get_nth_time_interval(n NUMBER) RETURN UNIT_INTERVAL IS
BEGIN

RETURN NULL;
END;

MEMBER FUNCTION f_nth_geometry_violate(mp Hermes.MOVING_POINT) RETURN NUMBER IS
BEGIN

RETURN NULL;
END;

MEMBER FUNCTION f_geometry_violate(mp Hermes.MOVING_POINT) RETURN NUMBER_SET IS
BEGIN

RETURN NULL;
END;

MEMBER FUNCTION f_intervals_violate(mp Hermes.MOVING_POINT) RETURN NUMBER_SET IS
BEGIN

RETURN NULL;
END;

END;
/


