Prompt Type Body MOVING_POINT;
CREATE OR REPLACE TYPE BODY moving_point
IS
    MEMBER FUNCTION to_clob RETURN CLOB IS
  i   PLS_INTEGER;
  str CLOB;
  BEGIN
    FOR i IN u_tab.FIRST .. u_tab.LAST LOOP
      str := str || '(' || SUBSTR(TO_CHAR (u_tab(i).m.xi), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.yi), 0, 10) || ') - (' || SUBSTR(TO_CHAR (u_tab(i).m.xe), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.ye), 0, 10) || ') # ' || TO_CHAR(u_tab(i).p.b.M_Y) || '/' || TO_CHAR(u_tab(i).p.b.M_M) || '/' || TO_CHAR(u_tab(i).p.b.M_D) || ' - ' || TO_CHAR(u_tab(i).p.b.M_H) || ':' || TO_CHAR(u_tab(i).p.b.M_MIN) || ':' || TO_CHAR(u_tab(i).p.b.M_SEC) || TO_CHAR(u_tab(i).p.e.M_Y) || '/' || TO_CHAR(u_tab(i).p.e.M_M) || '/' || TO_CHAR(u_tab(i).p.e.M_D) || ' - ' || TO_CHAR(u_tab(i).p.e.M_H) || ':' || TO_CHAR(u_tab(i).p.e.M_MIN) || ':' || TO_CHAR(u_tab(i).p.e.M_SEC);
    END LOOP;
  return str;
  END;

  MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    i   PLS_INTEGER;
    str VARCHAR2(32767) := '';
    BEGIN
        FOR i IN u_tab.FIRST .. u_tab.LAST LOOP
            str := str || '(' || SUBSTR(TO_CHAR (u_tab(i).m.xi), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.yi), 0, 10) || ') - (' || SUBSTR(TO_CHAR (u_tab(i).m.xe), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.ye), 0, 10) || ') # '
            || TO_CHAR(u_tab(i).p.b.M_Y) || '/' || TO_CHAR(u_tab(i).p.b.M_M) || '/' || TO_CHAR(u_tab(i).p.b.M_D) || ' - ' || TO_CHAR(u_tab(i).p.b.M_H) || ':' || TO_CHAR(u_tab(i).p.b.M_MIN) || ':' || TO_CHAR(u_tab(i).p.b.M_SEC)
            || TO_CHAR(u_tab(i).p.e.M_Y) || '/' || TO_CHAR(u_tab(i).p.e.M_M) || '/' || TO_CHAR(u_tab(i).p.e.M_D) || ' - ' || TO_CHAR(u_tab(i).p.e.M_H) || ':' || TO_CHAR(u_tab(i).p.e.M_MIN) || ':' || TO_CHAR(u_tab(i).p.e.M_SEC);
        END LOOP;

        return str;
    END;

    MEMBER PROCEDURE print_moving_point IS
    i   PLS_INTEGER;
    BEGIN
        FOR i IN u_tab.FIRST .. u_tab.LAST LOOP
            DBMS_OUTPUT.put_line ('(' || SUBSTR(TO_CHAR (u_tab(i).m.xi), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.yi), 0, 10) || ') - (' || SUBSTR(TO_CHAR (u_tab(i).m.xe), 0, 10) || ',  ' || SUBSTR(TO_CHAR (u_tab(i).m.ye), 0, 10) || ') # '
            || TO_CHAR(u_tab(i).p.b.M_Y) || '/' || TO_CHAR(u_tab(i).p.b.M_M) || '/' || TO_CHAR(u_tab(i).p.b.M_D) || ' - ' || TO_CHAR(u_tab(i).p.b.M_H) || ':' || TO_CHAR(u_tab(i).p.b.M_MIN) || ':' || TO_CHAR(u_tab(i).p.b.M_SEC)
            || TO_CHAR(u_tab(i).p.e.M_Y) || '/' || TO_CHAR(u_tab(i).p.e.M_M) || '/' || TO_CHAR(u_tab(i).p.e.M_D) || ' - ' || TO_CHAR(u_tab(i).p.e.M_H) || ':' || TO_CHAR(u_tab(i).p.e.M_MIN) || ':' || TO_CHAR(u_tab(i).p.e.M_SEC)
            );
        END LOOP;
    END;

   MEMBER PROCEDURE add_unit (new_unit unit_moving_point) IS
      prev_last_unit   unit_moving_point;
   BEGIN
      prev_last_unit := u_tab (u_tab.LAST);

      -- check_sorting and disjoint
      IF     (prev_last_unit.p.f_l (prev_last_unit.p, new_unit.p) = 1)
         AND (prev_last_unit.p.f_overlaps (prev_last_unit.p, new_unit.p) != 1
             )
      THEN
         --DBMS_OUTPUT.put_line ('Adding new unit moving point');
         u_tab.EXTEND;
         u_tab (u_tab.LAST) := new_unit;
      END IF;
   END;                                                            -- add_unit

   MEMBER FUNCTION merge_moving_points (mp1 moving_point, mp2 moving_point) RETURN moving_point IS
      m_u_tab   moving_point_tab;
      gluesegment unit_moving_point;--sider
      last_tp tau_tll.d_timepoint_sec;
      first_tp tau_tll.d_timepoint_sec;
   BEGIN
     if (mp1.srid <> mp2.srid) then
       raise_application_error(-20199, 'C$HERMES-00*: Can not merge moving_points with different srids');
     end if;
      IF mp1.u_tab (mp1.u_tab.LAST).p.f_l (mp1.u_tab (mp1.u_tab.LAST).p,
                                           mp2.u_tab (mp2.u_tab.FIRST).p
                                          ) = 1
      THEN
         -- to mp1 proigitai xronika
         --DBMS_OUTPUT.put_line ('merge_moving_points: mp1 first');
         FOR i IN mp1.u_tab.FIRST .. mp1.u_tab.LAST
         LOOP
            IF i = mp1.u_tab.FIRST
            THEN
               m_u_tab := moving_point_tab (mp1.u_tab (i));
            ELSE
               m_u_tab.EXTEND;
               m_u_tab (m_u_tab.last) := mp1.u_tab (i);
            END IF;
         END LOOP;
         
         last_tp := mp1.u_tab(mp1.u_tab.last).p.e;
         first_tp := mp2.u_tab(mp2.u_tab.first).p.b;
         gluesegment:=unit_moving_point(tau_tll.d_period_sec(last_tp,first_tp),unit_function(
                  mp1.u_tab(mp1.u_tab.last).m.xe,mp1.u_tab(mp1.u_tab.last).m.ye,
                  mp2.u_tab(mp2.u_tab.first).m.xi,mp2.u_tab(mp2.u_tab.first).m.yi,
                  null,null,null,null,null,'PLNML_1'));           
         m_u_tab.EXTEND;
         m_u_tab (m_u_tab.last) := gluesegment;

         FOR i IN mp2.u_tab.FIRST .. mp2.u_tab.LAST
         LOOP
            m_u_tab.EXTEND;
            m_u_tab (m_u_tab.last) := mp2.u_tab (i);
         END LOOP;

         RETURN moving_point (m_u_tab, null, mp1.srid);
      ELSIF mp1.u_tab (mp1.u_tab.LAST).p.f_l (mp2.u_tab (mp2.u_tab.LAST).p,
                                              mp1.u_tab (mp1.u_tab.FIRST).p
                                             ) = 1
      THEN
         -- to mp2 proigitai xronika
         --DBMS_OUTPUT.put_line ('merge_moving_points: mp2 first');
         FOR i IN mp2.u_tab.FIRST .. mp2.u_tab.LAST
         LOOP
            IF i = mp2.u_tab.FIRST
            THEN
               m_u_tab := moving_point_tab (mp2.u_tab (i));
            ELSE
               m_u_tab.EXTEND;
               m_u_tab (m_u_tab.last) := mp2.u_tab (i);
            END IF;
         END LOOP;
         
         last_tp := mp2.u_tab(mp2.u_tab.last).p.e;
         first_tp := mp1.u_tab(mp1.u_tab.first).p.b;
         gluesegment:=unit_moving_point(tau_tll.d_period_sec(last_tp,first_tp),unit_function(
                  mp2.u_tab(mp2.u_tab.last).m.xe,mp2.u_tab(mp2.u_tab.last).m.ye,
                  mp1.u_tab(mp1.u_tab.first).m.xi,mp1.u_tab(mp1.u_tab.first).m.yi,
                  null,null,null,null,null,'PLNML_1'));
         m_u_tab.EXTEND;
         m_u_tab (m_u_tab.last) := gluesegment;

         FOR i IN mp1.u_tab.FIRST .. mp1.u_tab.LAST
         LOOP
            m_u_tab.EXTEND;
            m_u_tab (m_u_tab.last) := mp1.u_tab (i);
         END LOOP;

         RETURN moving_point (m_u_tab, null, mp1.srid);
      ELSE
         --cannot merge
         --DBMS_OUTPUT.put_line ('merge_moving_points:merge = NULL..!!!');
         RETURN NULL;
      END IF;
   END;                                                  --merge_moving_points

   MEMBER FUNCTION check_sorting RETURN BOOLEAN IS
      RESULT      BOOLEAN     := TRUE;
      i           PLS_INTEGER;
      sort_flag   PLS_INTEGER;
   BEGIN
      IF u_tab.FIRST <> u_tab.LAST
      THEN
         i := u_tab.FIRST + 1;              -- get subscript of first element

         WHILE i IS NOT NULL
         LOOP
            sort_flag := u_tab (i - 1).p.f_l (u_tab (i - 1).p, u_tab (i).p);

            IF sort_flag <> 1
            THEN
               result := false;
               dbms_output.put_line('Error on checking sorting for obj:'||self.traj_id||' u_tab:'||i);
               EXIT;
            END IF;

            i := u_tab.NEXT (i);              -- get subscript of next element
         END LOOP;
      END IF;

      RETURN RESULT;
     /* exception
        when others then
          dbms_output.put_line('Error on checking sorting for obj:'||self.traj_id||' u_tab:'||i);
          --return FALSE;*/
   END;

   MEMBER FUNCTION check_disjoint RETURN BOOLEAN IS
      RESULT         BOOLEAN     := TRUE;
      i              PLS_INTEGER;
      overlap_flag   PLS_INTEGER;
   BEGIN
      IF u_tab.FIRST <> u_tab.LAST
      THEN
         i := u_tab.FIRST + 1;              -- get subscript of first element

         WHILE i IS NOT NULL
         LOOP
            overlap_flag :=
                    u_tab (i - 1).p.f_overlaps (u_tab (i - 1).p, u_tab (i).p);

            IF overlap_flag = 1
            THEN
               RESULT := FALSE;
               EXIT;
            END IF;

            i := u_tab.NEXT (i);              -- get subscript of next element
         END LOOP;
      END IF;

      RETURN RESULT;
   END;

   MEMBER FUNCTION f_duration RETURN NUMBER is
    i pls_integer;
    dur number := 0;
    begin
        i := u_tab.FIRST;
        WHILE i IS NOT NULL LOOP
            dur := dur + u_tab(i).p.duration().m_Value;
            i := u_tab.NEXT(i);
        END LOOP;

        if dur = 0 then
          raise_application_error(-20100, 'C$HERMES-00*: Zero duration/lifespan of moving point');
        else
          return dur;
        end if;
    end;

   MEMBER FUNCTION check_meet RETURN BOOLEAN IS
      RESULT      BOOLEAN     := TRUE;
      i           PLS_INTEGER;
      meet_flag   PLS_INTEGER;
   BEGIN
      IF u_tab.FIRST <> u_tab.LAST
      THEN
         i := u_tab.FIRST + 1;              -- get subscript of first element

         WHILE i IS NOT NULL
         LOOP
            meet_flag :=
                       u_tab (i - 1).p.f_meets (u_tab (i - 1).p, u_tab (i).p);

            IF meet_flag <> 1
            THEN
               RESULT := FALSE;
               EXIT;
            END IF;

            i := u_tab.NEXT (i);              -- get subscript of next element
         END LOOP;
      END IF;

      RETURN RESULT;
   END;

   MEMBER FUNCTION unit_type (tp tau_tll.d_timepoint_sec) RETURN unit_moving_point IS
      RESULT          unit_moving_point;
      i               PLS_INTEGER;
      contain_flag    PLS_INTEGER;
      sort_flag       BOOLEAN           := FALSE;
      disjoint_flag   BOOLEAN           := FALSE;
      meet_flag       BOOLEAN           := FALSE;
   BEGIN
      sort_flag := check_sorting ();

      IF sort_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-004:Periods in the nested table of type Moving_Point_Tab are NOT sorted'
            );
      END IF;

      disjoint_flag := check_disjoint ();

      IF disjoint_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-005:Periods in the nested table of type Moving_Point_Tab are NOT disjoint'
            );
      END IF;

      -- an prokeitai gia tin teleutaia periodo tote epistrefo to teleutaio
      -- unit_moving_point
      IF tp.f_equal (tp, u_tab (u_tab.LAST).p.e) = 1
      THEN
         RETURN u_tab (u_tab.LAST);
      END IF;

      i := u_tab.FIRST;                      -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP
         contain_flag := u_tab (i).p.f_contains (u_tab (i).p, tp);

         IF contain_flag = 1
         THEN
            RESULT := u_tab (i);
            EXIT;
         END IF;

         i := u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      IF RESULT IS NOT NULL
      THEN
         RETURN RESULT;
      ELSE
         raise_application_error
            (-20100,
             'C$HERMES-009:The Timepoint is NOT contained in any of the Periods in the nested table of type Moving_Point_Tab'
            );
      END IF;
   END;                                                            --unit type
   
   member function sortbytime (ingeom in out mdsys.sdo_geometry) return mdsys.sdo_geometry is
     srid pls_integer;
     mpoint_info   sdo_elem_info_array;
     mpoint_ords   sdo_ordinate_array;
     inelems pls_integer;
     cur_elem_info sdo_elem_info_array;
     next_elem_info sdo_elem_info_array;
     cur_line sdo_geometry;
     k pls_integer;
     l pls_integer;
     t pls_integer;
     coordstimes_var cluster_pair:=cluster_pair(-1,-1);
     coordstimes cluster_list:=cluster_list();
     coordstimes_ordered cluster_list:=cluster_list();
     elemstimes cluster_list:=cluster_list();
     elemstimes_ordered cluster_list:=cluster_list();
     cur_time number;
     stmt varchar2(4000);
     res sdo_geometry;
     res_ordered sdo_geometry;  
     startord number;
     endord number; 
   begin     
     srid:=self.srid;
     --if geometry is point
     if ingeom.sdo_gtype = 1
       or ingeom.sdo_gtype = 2001
       or ingeom.sdo_ordinates.count <= 2
     then
       mpoint_info := mdsys.sdo_elem_info_array ();
       mpoint_info.extend (3);
       mpoint_info (1) := 1;
       mpoint_info (2) := 1;
       mpoint_info (3) := 1;
       mpoint_ords := mdsys.sdo_ordinate_array ();
       mpoint_ords.extend (2);

       if ingeom.sdo_point is not null
       then
         mpoint_ords (1) := ingeom.sdo_point.x;
         mpoint_ords (2) := ingeom.sdo_point.y;
       else
         mpoint_ords (1) := ingeom.sdo_ordinates (1);
         mpoint_ords (2) := ingeom.sdo_ordinates (2);
       end if;
       return mdsys.sdo_geometry (2005, srid, null, mpoint_info, mpoint_ords);
     end if;
     --else expect to be a multiline 2006 type
     res:=ingeom;
     inelems:=sdo_util.getnumelem(ingeom);
     --first sort each element of multiline
     for i in 1..inelems loop
       coordstimes.delete;
       coordstimes_ordered.delete;
       if i = inelems then
         cur_elem_info:=sdo_elem_info_array(ingeom.sdo_elem_info(i*3-2),ingeom.sdo_elem_info(i*3-1),ingeom.sdo_elem_info(i*3));
         t:=cur_elem_info(1);
         while t < ingeom.sdo_ordinates.count loop
           cur_time := get_time_point(ingeom.sdo_ordinates (t),ingeom.sdo_ordinates (t + 1)).get_abs_date ();
           coordstimes_var.value := cur_time;
           coordstimes_var.id := t;
           coordstimes.extend();
           coordstimes(coordstimes.last):=coordstimes_var;
           t:=t+2;
         end loop;
         select cluster_pair(t.id,t.value)
           bulk collect into coordstimes_ordered
           from table(coordstimes) t order by t.value;
         k:=cur_elem_info(1);
         for t in coordstimes_ordered.first..coordstimes_ordered.last loop
           res.sdo_ordinates(k):=ingeom.sdo_ordinates(coordstimes_ordered(t).id);
           res.sdo_ordinates(k+1):=ingeom.sdo_ordinates(coordstimes_ordered(t).id+1);
           k:=k+2;
         end loop;
       else
         cur_elem_info:=sdo_elem_info_array(ingeom.sdo_elem_info(i*3-2),ingeom.sdo_elem_info(i*3-1),ingeom.sdo_elem_info(i*3));
         next_elem_info:=sdo_elem_info_array(ingeom.sdo_elem_info((i+1)*3-2),ingeom.sdo_elem_info((i+1)*3-1),ingeom.sdo_elem_info((i+1)*3)); 
         t:=cur_elem_info(1);
         while t < next_elem_info(1)-1 loop
           cur_time := get_time_point(ingeom.sdo_ordinates (t),ingeom.sdo_ordinates (t + 1)).get_abs_date ();
           coordstimes_var.value := cur_time;
           coordstimes_var.id := t;
           coordstimes.extend();
           coordstimes(coordstimes.last):=coordstimes_var;
           t:=t+2;
         end loop;
         select cluster_pair(t.id,t.value)
           bulk collect into coordstimes_ordered
           from table(coordstimes) t order by t.value;
         k:=cur_elem_info(1);
         for t in coordstimes_ordered.first..coordstimes_ordered.last loop
           res.sdo_ordinates(k):=ingeom.sdo_ordinates(coordstimes_ordered(t).id);
           res.sdo_ordinates(k+1):=ingeom.sdo_ordinates(coordstimes_ordered(t).id+1);
           k:=k+2;
         end loop;
       end if;
       --to be used in outer sorting below
       cur_time := get_time_point(res.sdo_ordinates (cur_elem_info(1)),res.sdo_ordinates (cur_elem_info(1) + 1)).get_abs_date ();
       coordstimes_var.value := cur_time;
       coordstimes_var.id := i;
       elemstimes.extend();
       elemstimes(elemstimes.last):=coordstimes_var;
     end loop;
     --now sort elements in between them
     select cluster_pair(t.id,t.value)
       bulk collect into elemstimes_ordered
       from table(elemstimes) t order by t.value;
     res_ordered:=sdo_geometry(res.sdo_gtype,res.sdo_srid,null,sdo_elem_info_array(),sdo_ordinate_array());
     for i in elemstimes_ordered.first..elemstimes_ordered.last loop
       if i = 1 then
         res_ordered.sdo_elem_info.extend(3);
         res_ordered.sdo_elem_info(1):=1;
         res_ordered.sdo_elem_info(2):=2;
         res_ordered.sdo_elem_info(3):=1;
         startord:=res.sdo_elem_info(elemstimes_ordered(i).id*3-2);
         if (elemstimes_ordered(i).id*3 = res.sdo_elem_info.count) then
           endord := res.sdo_ordinates.count;
         else
           endord := res.sdo_elem_info(elemstimes_ordered(i).id*3+1)-1;
         end if;
         for j in startord..endord loop
           res_ordered.sdo_ordinates.extend();
           res_ordered.sdo_ordinates(res_ordered.sdo_ordinates.last):=res.sdo_ordinates(j);
         end loop;
       else
         res_ordered.sdo_elem_info.extend(3);
         res_ordered.sdo_elem_info(res_ordered.sdo_elem_info.last-2):=res_ordered.sdo_ordinates.count+1;
         res_ordered.sdo_elem_info(res_ordered.sdo_elem_info.last-1):=2;
         res_ordered.sdo_elem_info(res_ordered.sdo_elem_info.last):=1;
         startord:=res.sdo_elem_info(elemstimes_ordered(i).id*3-2);
         if (elemstimes_ordered(i).id*3 = res.sdo_elem_info.count) then
           endord := res.sdo_ordinates.count;
         else
           endord := res.sdo_elem_info(elemstimes_ordered(i).id*3+1)-1;
         end if;
         for j in startord..endord loop
           res_ordered.sdo_ordinates.extend();
           res_ordered.sdo_ordinates(res_ordered.sdo_ordinates.last):=res.sdo_ordinates(j);
         end loop;
       end if;
     end loop;
     ingeom:=res_ordered;--for out only
     return res_ordered;
   end sortbytime;

   MEMBER FUNCTION sort_by_time (mpoint IN OUT MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
      i             PLS_INTEGER;
      k             PLS_INTEGER;
      min_time      DOUBLE PRECISION          := 0.0;
      min_i         PLS_INTEGER               := 1;
      cur_time      DOUBLE PRECISION          := 0.0;
      temp_x        NUMBER                    := 0.0;
      temp_y        NUMBER                    := 0.0;
      swap          BOOLEAN                   := FALSE;
      mpoint_info   MDSYS.sdo_elem_info_array;
      mpoint_ords   MDSYS.sdo_ordinate_array;
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      IF    mpoint.sdo_gtype = 1
         OR mpoint.sdo_gtype = 2001
         OR mpoint.sdo_ordinates.COUNT <= 2
      THEN
         mpoint_info := MDSYS.sdo_elem_info_array ();
         mpoint_info.EXTEND (3);
         mpoint_info (1) := 1;
         mpoint_info (2) := 1;
         mpoint_info (3) := 1;
         mpoint_ords := MDSYS.sdo_ordinate_array ();
         mpoint_ords.EXTEND (2);

         IF mpoint.sdo_point IS NOT NULL
         THEN
            mpoint_ords (1) := mpoint.sdo_point.x;
            mpoint_ords (2) := mpoint.sdo_point.y;
         ELSE
            mpoint_ords (1) := mpoint.sdo_ordinates (1);
            mpoint_ords (2) := mpoint.sdo_ordinates (2);
         END IF;

         RETURN MDSYS.SDO_GEOMETRY (2005, SRID, NULL, mpoint_info, mpoint_ords);
      END IF;

      k := mpoint.sdo_ordinates.FIRST;

      WHILE k IS NOT NULL
      LOOP
         i := k;
         
         min_time :=
            get_time_point (mpoint.sdo_ordinates (i),
                            mpoint.sdo_ordinates (i + 1)
                           ).get_abs_date ();

         WHILE i IS NOT NULL
         LOOP
           dbms_output.put_line(mpoint.sdo_ordinates (i)||'-'||mpoint.sdo_ordinates (i + 1));
            cur_time :=
               get_time_point (mpoint.sdo_ordinates (i),
                               mpoint.sdo_ordinates (i + 1)
                              ).get_abs_date ();

            IF cur_time < min_time
            THEN
               min_time := cur_time;
               min_i := i;
               swap := TRUE;
            END IF;

            i := mpoint.sdo_ordinates.NEXT (i + 1);
         END LOOP;

         IF swap
         THEN
            temp_x := mpoint.sdo_ordinates (k);
            temp_y := mpoint.sdo_ordinates (k + 1);
            mpoint.sdo_ordinates (k) := mpoint.sdo_ordinates (min_i);
            mpoint.sdo_ordinates (k + 1) := mpoint.sdo_ordinates (min_i + 1);
            mpoint.sdo_ordinates (min_i) := temp_x;
            mpoint.sdo_ordinates (min_i + 1) := temp_y;
            swap := FALSE;
         END IF;

         k := mpoint.sdo_ordinates.NEXT (k + 1);
      END LOOP;

      RETURN mpoint;
   END;                                                       --  sort_by_time

   MEMBER FUNCTION get_enter_leave_points (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
      enters            MDSYS.SDO_GEOMETRY;
      multipoint              MDSYS.SDO_GEOMETRY;
      leaves               MDSYS.SDO_GEOMETRY;
      number_of_linestrings   INT;
      multipoint_ordinates    MDSYS.sdo_ordinate_array;
      ix                      NUMBER                   := 0;
      iy                      NUMBER                   := 0;
      p                       PLS_INTEGER              := 0;
      tolerance               NUMBER                   := 0.1;
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      --get the multipoints from already functions

      enters := f_enterpoints(geom);
      leaves := f_leavepoints(geom);


      IF enters IS NULL and leaves is null THEN
         RETURN NULL;
      elsif enters is null then
        multipoint := leaves;
      elsif leaves is null then
        multipoint := enters;
      else
        multipoint := sdo_aggr_set_union(sdo_geometry_array(enters,leaves),0.05);
      end if;
      
      --UTILITIES.print_geometry(multipoint,'MULTIPOINT');
/*
      p := intersection.sdo_ordinates.FIRST;
      ix := intersection.sdo_ordinates (p);
      p := intersection.sdo_ordinates.NEXT (p);
      iy := intersection.sdo_ordinates (p);
      multipoint :=
          MDSYS.SDO_GEOMETRY (2001, NULL, NULL, sdo_elem_info_array (1, 1, intersection.sdo_ordinates.COUNT / 2), intersection.sdo_ordinates);
      p := intersection.sdo_ordinates.NEXT (p);

      IF p IS NOT NULL THEN
         ix := intersection.sdo_ordinates (p);
      END IF;

      p := intersection.sdo_ordinates.NEXT (p);

      IF p IS NOT NULL THEN
         iy := intersection.sdo_ordinates (p);
      END IF;

      WHILE p IS NOT NULL LOOP
         cur_point :=
            MDSYS.SDO_GEOMETRY (2001,
                          NULL,
                          sdo_point_type (ix, iy, NULL),
                          NULL,
                          NULL
                         );

         -- H sdo_geom.relate (cur_point, 'TOUCH', geom, tolerance)
         -- epistrefei 'TOUCH' otan to shmeio einai sta sunora tis geom kai
         -- 'FALSE' allios...
         IF MDSYS.sdo_geom.relate (cur_point, 'TOUCH', geom, tolerance) != 'FALSE'
         THEN
            --DBMS_OUTPUT.put_line ('p=' || TO_CHAR (p));
            multipoint := MDSYS.sdo_geom.sdo_union (multipoint, cur_point, tolerance);
         END IF;

         p := intersection.sdo_ordinates.NEXT (p);

         IF p IS NOT NULL THEN
            ix := intersection.sdo_ordinates (p);
         END IF;

         p := intersection.sdo_ordinates.NEXT (p);

         IF p IS NOT NULL THEN
            iy := intersection.sdo_ordinates (p);
         END IF;
      END LOOP;

       -- Gia kapoio logo to geom pou ptokeiptei apo to union eno einai sosto geom
      -- den emfanizetai sto mapviewer kai gi'auto tou dirthono ton sdo_elem_info.
      multipoint.sdo_elem_info := sdo_elem_info_array (1, 1, multipoint.sdo_ordinates.COUNT / 2); */
      RETURN multipoint;
   END;

   MEMBER FUNCTION at_instant (tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
      RESULT          MDSYS.SDO_GEOMETRY;
      xy              coords             := coords (0.0, 0.0);
      i               PLS_INTEGER;
      contain_flag    PLS_INTEGER;
      sort_flag       BOOLEAN            := FALSE;
      disjoint_flag   BOOLEAN            := FALSE;
      meet_flag       BOOLEAN            := FALSE;
      err_msg         VARCHAR2 (512);
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      sort_flag := check_sorting ();

      IF sort_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-004:Periods in the nested table of type Moving_Point_Tab are NOT sorted'
            );
      END IF;

      disjoint_flag := check_disjoint ();

      IF disjoint_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-005:Periods in the nested table of type Moving_Point_Tab are NOT disjoint'
            );
      END IF;

      IF tp.f_equal (tp, u_tab (u_tab.LAST).p.e) = 1
      THEN
         RETURN MDSYS.SDO_GEOMETRY
                              (2001,         -- SDO_GTYPE: 2-Dimensional point
                               SRID,    -- SDO_SRID:  Spatial Reference System
                               MDSYS.sdo_point_type (u_tab (u_tab.LAST).m.xe,
                                                     u_tab (u_tab.LAST).m.ye,
                                                     NULL
                                                    ),
                               -- SDO_POINT: X and Y coordinates of the 2-D point
                               NULL,                         -- SDO_ELEM_INFO:
                               NULL                          -- SDO_ORDINATES:
                              );
      END IF;

      i := u_tab.FIRST;                      -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP
         contain_flag := u_tab (i).p.f_contains (u_tab (i).p, tp);

         IF contain_flag = 1
         THEN
            xy := u_tab (i).f_interpolate (tp);
            RESULT :=
               MDSYS.SDO_GEOMETRY
                                 (2001,      -- SDO_GTYPE: 2-Dimensional point
                                  SRID, -- SDO_SRID:  Spatial Reference System
                                  MDSYS.sdo_point_type (xy (1), xy (2), NULL),
                                  -- SDO_POINT: X and Y coordinates of the 2-D point
                                  NULL,                      -- SDO_ELEM_INFO:
                                  NULL                       -- SDO_ORDINATES:
                                 );
            EXIT;
         END IF;

         i := u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      IF RESULT IS NOT NULL
      THEN
         err_msg := MDSYS.sdo_geom.validate_geometry (RESULT, 0.001);

         IF err_msg = 'TRUE'
         THEN
            RETURN RESULT;
         ELSIF err_msg = 'FALSE'
         THEN
            raise_application_error
                                   (-20100,
                                    'C$HERMES-007:Geometry validation failed'
                                   );
         ELSE
            err_msg := SQLERRM (-TO_NUMBER (err_msg));
            raise_application_error (-20100, 'C$HERMES-008:' || err_msg);
         END IF;
      ELSE
         RETURN NULL;
      /*raise_application_error
         (-20100,
          'C$HERMES-009:The Timepoint is NOT contained in any of the Periods in the nested table of type Moving_Point_Tab'
         );*/
      END IF;
   END;                                                           --at_instant

   MEMBER FUNCTION at_period (per tau_tll.d_period_sec) RETURN moving_point IS
      res_point      moving_point_tab;
      new_per        tau_tll.d_period_sec;
      b_tp           tau_tll.d_timepoint_sec;
      e_tp           tau_tll.d_timepoint_sec;
      contain_flag   PLS_INTEGER;
      new_v          NUMBER;
      t              NUMBER           := 0.0;              -- time in seconds
      xy             coords           := coords (0.0, 0.0);
      i              PLS_INTEGER;
      first_tab      PLS_INTEGER;
      last_tab       PLS_INTEGER;
      j              PLS_INTEGER      := 1;
      count_utabs integer;
      res_extend_size integer;
      rc integer;
   BEGIN
      count_utabs:=u_tab.count;
      IF per is null OR per.b is null OR per.e is null THEN return NULL; END IF;
      --DBMS_OUTPUT.put_line (per.b.to_string());
      --DBMS_OUTPUT.put_line (per.e.to_string());

      b_tp := tau_tll.d_timepoint_sec(per.b.m_y,per.b.m_m,per.b.m_d,per.b.m_h,per.b.m_min,FLOOR(per.b.m_sec));
      e_tp := tau_tll.d_timepoint_sec(per.e.m_y,per.e.m_m,per.e.m_d,per.e.m_h,per.e.m_min,FLOOR(per.e.m_sec));
      IF b_tp.f_eq(b_tp, e_tp) = 1 THEN return NULL; END IF;
      IF b_tp.f_l(b_tp, e_tp) = 1 THEN
        new_per := tau_tll.d_period_sec(b_tp, e_tp);
      ELSE
        new_per := tau_tll.d_period_sec(e_tp, b_tp);
      END IF;
      --DBMS_OUTPUT.put_line (new_per.b.to_string());
      --DBMS_OUTPUT.put_line (new_per.e.to_string());

      IF ( (new_per.b.get_abs_date () = u_tab (u_tab.FIRST).p.b.get_abs_date ()) AND (new_per.e.get_abs_date () = u_tab (count_utabs).p.e.get_abs_date ()) )
         OR new_per.f_contains(new_per, tau_tll.d_period_sec(u_tab(u_tab.FIRST).p.b, u_tab(count_utabs).p.e)) = 1 THEN
         RETURN moving_point (u_tab, self.traj_id, self.srid);
      END IF;

      i := u_tab.FIRST;

      -- Euresi tou 1ou tab pou periexei tin dosmeni timepoint
      WHILE i IS NOT NULL AND u_tab (i).p.f_contains (u_tab (i).p, new_per.b) != 1 LOOP
         --DBMS_OUTPUT.put_line (u_tab (i).p.to_string());
         i := u_tab.NEXT (i);
      END LOOP;

      if i is null then
        --new_per.b is not in u_tab so it is either before start or after, equal with the end of u_tab
        if new_per.b.f_l(new_per.b, u_tab(u_tab.first).p.b) = 1 then
          -- it is before the start so
          i := u_tab.first;
        elsif (new_per.b.f_b(new_per.b, u_tab(u_tab.last).p.e) = 1)
        or (new_per.b.get_abs_date () = u_tab (u_tab.last).p.e.get_abs_date ())  then
          --it is after the end so
          --DBMS_OUTPUT.put_line ('Period not contained(begin)');
          return null;
        end if;
      END IF;

      first_tab := i;

      -- Euresi tou teleutaiou tab pou periexei tin dosmeni timepoint
      WHILE i IS NOT NULL AND u_tab (i).p.f_contains (u_tab (i).p, new_per.e) != 1 LOOP
        --DBMS_OUTPUT.put_line (u_tab (i).p.to_string());
         i := u_tab.NEXT (i);
      END LOOP;

      if i is null then
        --new_per.e is either after the end of u_tab or equal with u_tab(u_tab.last).p.e
        --or before the begining of u_tab so
         if (new_per.e.f_b(new_per.e, u_tab(u_tab.last).p.e) = 1)
         or (new_per.e.get_abs_date () = u_tab (count_utabs).p.e.get_abs_date ()) then
           --if after the end
        i := count_utabs;
        elsif new_per.e.f_l(new_per.e, u_tab(u_tab.first).p.b) = 1 then
          --is before the begining
          return null;
        end if;
      END IF;

      if i is null then
        --some strange with self.u_tab.p happens (could not find where new_per is)
        return null;
      end if;
      
      IF new_per.e.get_abs_date () = u_tab (i).p.b.get_abs_date () THEN
         if (i>1)then
          last_tab := i - 1;
        else
          last_tab:=i;
        end if;
      ELSE
         last_tab := i;
      END IF;
      -- To teleutaio second kathe periodou periexetai sto telos kathe unit period
      -- kai stin arxi tou epomenou. An mia periodos ftanei sto teleutaio sec
      -- mias unit period den theoroume oti mpainei stin epomeni...
      -- ektos an eimaste sto teleutaio tab...
      /*IF     i != u_tab.LAST AND new_per.e.get_abs_date () = u_tab (i).p.b.get_abs_date ()
      THEN
         last_tab := i - 1;
      ELSE
         last_tab := i;
      END IF;*/

      --
      -- Antigrafi ton tab pou periexontai stin periodo, sto neo moving_point
      res_point := moving_point_tab ();

      res_extend_size:=last_tab-first_tab;
      res_point.extend(res_extend_size+1);
      FOR i IN first_tab .. last_tab
      LOOP
        -- res_point.EXTEND (1);
         res_point (j) := u_tab (i);
         j := j + 1;
      END LOOP;

      -- Diorthosi ton 'akraion' tab tou neou moving point to do : na ftiaxno kai ta mesaia shmeia
      -- 1o Tab

      IF new_per.b.f_b(new_per.b, u_tab (first_tab).p.b) = 1 THEN
         xy := u_tab (first_tab).f_interpolate (new_per.b);
         t := new_per.b.get_abs_date () - u_tab (first_tab).p.b.get_abs_date ();
         new_v := u_tab (first_tab).m.v + t * u_tab (first_tab).m.a;
         res_point (1).m.xi := xy (1);
         res_point (1).m.yi := xy (2);
         res_point (1).m.v := new_v;
         res_point (1).p.b := new_per.b;
      END IF;

   rc:=res_point.count;

      -- Teleutaio Tab
      IF new_per.e.f_l(new_per.e, u_tab (last_tab).p.e) = 1 THEN
         xy := u_tab (last_tab).f_interpolate (new_per.e);
         res_point (rc).m.xe := xy (1);
         res_point (rc).m.ye := xy (2);
         res_point (rc).p.e := new_per.e;
      END IF;

      RETURN moving_point (res_point, self.traj_id, self.srid);
   END;

   MEMBER FUNCTION at_period_no_lib (per tau_tll.d_period_sec) RETURN moving_point IS
      res_point      moving_point_tab;
      new_per        tau_tll.d_period_sec;
      tmp_tpb        timestamp;
      tmp_tpe        timestamp;
      tmp_tpf        timestamp;
      tmp_tpl        timestamp;
      b_tp           timestamp;
      e_tp           timestamp;
      contain_flag   PLS_INTEGER;
      new_v          NUMBER;
      t              NUMBER           := 0.0;              -- time in seconds
      xy             coords           := coords (0.0, 0.0);
      i              PLS_INTEGER;
      first_tab      PLS_INTEGER;
      last_tab       PLS_INTEGER;
      j              PLS_INTEGER      := 1;
      count_utabs integer;
      res_extend_size integer;
      rc integer;
   BEGIN
      count_utabs:=u_tab.count;
      IF per is null OR per.b is null OR per.e is null THEN return NULL; END IF;

      b_tp := to_timestamp(per.b.m_y||'-'||per.b.m_m||'-'||per.b.m_d||'-'||
        per.b.m_h||'-'||per.b.m_min||'-'||FLOOR(per.b.m_sec),'yyyy-mm-dd hh24:mi:ss');--sec are floored!
      e_tp := to_timestamp(per.e.m_y||'-'||per.e.m_m||'-'||per.e.m_d||'-'||
        per.e.m_h||'-'||per.e.m_min||'-'||FLOOR(per.e.m_sec),'yyyy-mm-dd hh24:mi:ss');
      IF (b_tp=e_tp) THEN 
        return NULL; 
      END IF;
      
      new_per := tau_tll.d_period_sec(per.b, per.e);
      IF (b_tp>e_tp) THEN
        tmp_tpb := b_tp;
        b_tp:=e_tp;
        e_tp:=tmp_tpb;
        new_per := tau_tll.d_period_sec(per.e, per.b);
      END IF;

      tmp_tpf:=to_timestamp(u_tab (u_tab.FIRST).p.b.m_y||'-'||u_tab (u_tab.FIRST).p.b.m_m||'-'||
        u_tab (u_tab.FIRST).p.b.m_d||'-'||u_tab (u_tab.FIRST).p.b.m_h||'-'||
        u_tab (u_tab.FIRST).p.b.m_min||'-'||FLOOR(u_tab (u_tab.FIRST).p.b.m_sec),
        'yyyy-mm-dd hh24:mi:ss');
      tmp_tpl:=to_timestamp(u_tab (count_utabs).p.e.m_y||'-'||u_tab (count_utabs).p.e.m_m||'-'||
          u_tab (count_utabs).p.e.m_d||'-'||u_tab (count_utabs).p.e.m_h||'-'||
          u_tab (count_utabs).p.e.m_min||'-'||FLOOR(u_tab (count_utabs).p.e.m_sec),
          'yyyy-mm-dd hh24:mi:ss');
      --implies correct utab structure
      IF ((b_tp<=tmp_tpf) and (e_tp>=tmp_tpl)) then
        RETURN moving_point (u_tab, self.traj_id, self.srid);
      end if;

      i := u_tab.FIRST;--per segment

      tmp_tpb:=to_timestamp(u_tab (i).p.b.m_y||'-'||u_tab (i).p.b.m_m||'-'||
        u_tab (i).p.b.m_d||'-'||u_tab (i).p.b.m_h||'-'||
        u_tab (i).p.b.m_min||'-'||FLOOR(u_tab (i).p.b.m_sec),
        'yyyy-mm-dd hh24:mi:ss');
      tmp_tpe:=to_timestamp(u_tab (i).p.e.m_y||'-'||u_tab (i).p.e.m_m||'-'||
        u_tab (i).p.e.m_d||'-'||u_tab (i).p.e.m_h||'-'||
        u_tab (i).p.e.m_min||'-'||FLOOR(u_tab (i).p.e.m_sec),
        'yyyy-mm-dd hh24:mi:ss');
      -- Euresi tou 1ou tab pou periexei tin dosmeni timepoint
      WHILE i IS NOT NULL AND not ((tmp_tpb<=b_tp) and (tmp_tpe>b_tp))--f_contains works this way!!
        LOOP
         i := u_tab.NEXT (i);
         if (i is not null) then
           tmp_tpb:=to_timestamp(u_tab (i).p.b.m_y||'-'||u_tab (i).p.b.m_m||'-'||
             u_tab (i).p.b.m_d||'-'||u_tab (i).p.b.m_h||'-'||
             u_tab (i).p.b.m_min||'-'||FLOOR(u_tab (i).p.b.m_sec),
             'yyyy-mm-dd hh24:mi:ss');
           tmp_tpe:=to_timestamp(u_tab (i).p.e.m_y||'-'||u_tab (i).p.e.m_m||'-'||
             u_tab (i).p.e.m_d||'-'||u_tab (i).p.e.m_h||'-'||
             u_tab (i).p.e.m_min||'-'||FLOOR(u_tab (i).p.e.m_sec),
             'yyyy-mm-dd hh24:mi:ss');
         end if;  
      END LOOP;

      if i is null then
        --b_tp is not in u_tab so it is either before start or after, equal with the end of u_tab
        if (b_tp<tmp_tpf) then
          -- it is before the start so
          i := u_tab.first;
        elsif (b_tp>=tmp_tpl) then
          --it is after the end so
          --DBMS_OUTPUT.put_line ('Period not contained(begin)');
          return null;
        end if;
      END IF;

      first_tab := i;
      tmp_tpb:=to_timestamp(u_tab (i).p.b.m_y||'-'||u_tab (i).p.b.m_m||'-'||
        u_tab (i).p.b.m_d||'-'||u_tab (i).p.b.m_h||'-'||
        u_tab (i).p.b.m_min||'-'||FLOOR(u_tab (i).p.b.m_sec),
        'yyyy-mm-dd hh24:mi:ss');
      tmp_tpe:=to_timestamp(u_tab (i).p.e.m_y||'-'||u_tab (i).p.e.m_m||'-'||
        u_tab (i).p.e.m_d||'-'||u_tab (i).p.e.m_h||'-'||
        u_tab (i).p.e.m_min||'-'||FLOOR(u_tab (i).p.e.m_sec),
        'yyyy-mm-dd hh24:mi:ss');

      -- Euresi tou teleutaiou tab pou periexei tin dosmeni timepoint
      WHILE i IS NOT NULL AND not ((tmp_tpb<=e_tp) and (tmp_tpe>e_tp))
        LOOP
         i := u_tab.NEXT (i);
         if (i is not null) then
           tmp_tpb:=to_timestamp(u_tab (i).p.b.m_y||'-'||u_tab (i).p.b.m_m||'-'||
             u_tab (i).p.b.m_d||'-'||u_tab (i).p.b.m_h||'-'||
             u_tab (i).p.b.m_min||'-'||FLOOR(u_tab (i).p.b.m_sec),
             'yyyy-mm-dd hh24:mi:ss');
           tmp_tpe:=to_timestamp(u_tab (i).p.e.m_y||'-'||u_tab (i).p.e.m_m||'-'||
             u_tab (i).p.e.m_d||'-'||u_tab (i).p.e.m_h||'-'||
             u_tab (i).p.e.m_min||'-'||FLOOR(u_tab (i).p.e.m_sec),
             'yyyy-mm-dd hh24:mi:ss');
         end if;
      END LOOP;

      if i is null then
        --new_per.e is either after the end of u_tab or equal with u_tab(u_tab.last).p.e
        --or before the begining of u_tab so
         if (e_tp>=tmp_tpl)then
           --if after the end
        i := count_utabs;
        elsif (e_tp<tmp_tpf)then
          --is before the begining
          return null;
        end if;
      END IF;

      tmp_tpb:=to_timestamp(u_tab (i).p.b.m_y||'-'||u_tab (i).p.b.m_m||'-'||
         u_tab (i).p.b.m_d||'-'||u_tab (i).p.b.m_h||'-'||
         u_tab (i).p.b.m_min||'-'||FLOOR(u_tab (i).p.b.m_sec),
         'yyyy-mm-dd hh24:mi:ss');
      
      IF (e_tp=tmp_tpb)THEN
        if (i>1)then
          last_tab := i - 1;
        else
          last_tab:=i;
        end if;
      ELSE
         last_tab := i;
      END IF;
      -- To teleutaio second kathe periodou periexetai sto telos kathe unit period
      -- kai stin arxi tou epomenou. An mia periodos ftanei sto teleutaio sec
      -- mias unit period den theoroume oti mpainei stin epomeni...
      -- ektos an eimaste sto teleutaio tab...
      /*IF     i != u_tab.LAST AND new_per.e.get_abs_date () = u_tab (i).p.b.get_abs_date ()
      THEN
         last_tab := i - 1;
      ELSE
         last_tab := i;
      END IF;*/

      --
      -- Antigrafi ton tab pou periexontai stin periodo, sto neo moving_point
      res_point := moving_point_tab ();

      res_extend_size:=last_tab-first_tab;
      res_point.extend(res_extend_size+1);
      FOR i IN first_tab .. last_tab
      LOOP
        -- res_point.EXTEND (1);
         res_point (j) := u_tab (i);
         j := j + 1;
      END LOOP;

      -- Diorthosi ton 'akraion' tab tou neou moving point to do : na ftiaxno kai ta mesaia shmeia
      -- 1o Tab

      tmp_tpb:=to_timestamp(u_tab (first_tab).p.b.m_y||'-'||u_tab (first_tab).p.b.m_m||'-'||
         u_tab (first_tab).p.b.m_d||'-'||u_tab (first_tab).p.b.m_h||'-'||
         u_tab (first_tab).p.b.m_min||'-'||FLOOR(u_tab (first_tab).p.b.m_sec),
         'yyyy-mm-dd hh24:mi:ss');
         
      IF (b_tp>tmp_tpb) THEN
         xy := u_tab (first_tab).f_plnml_1 (new_per.b);--m.descr = 'PLNML_1'
         t := new_per.b.get_abs_date () - u_tab (first_tab).p.b.get_abs_date ();
         new_v := u_tab (first_tab).m.v + t * u_tab (first_tab).m.a;
         res_point (1).m.xi := xy (1);
         res_point (1).m.yi := xy (2);
         res_point (1).m.v := new_v;
         res_point (1).p.b := new_per.b;
      END IF;

   rc:=res_point.count;

      tmp_tpe:=to_timestamp(u_tab (last_tab).p.e.m_y||'-'||u_tab (last_tab).p.e.m_m||'-'||
        u_tab (last_tab).p.e.m_d||'-'||u_tab (last_tab).p.e.m_h||'-'||
        u_tab (last_tab).p.e.m_min||'-'||FLOOR(u_tab (last_tab).p.e.m_sec),
        'yyyy-mm-dd hh24:mi:ss');
        
      -- Teleutaio Tab
      IF (e_tp<tmp_tpe) THEN
         xy := u_tab (last_tab).f_plnml_1 (new_per.e);--m.descr = 'PLNML_1'
         res_point (rc).m.xe := xy (1);
         res_point (rc).m.ye := xy (2);
         res_point (rc).p.e := new_per.e;
      END IF;

      RETURN moving_point (res_point, self.traj_id, self.srid);
   END at_period_no_lib;

   MEMBER FUNCTION at_temp_element (te tau_tll.d_temp_element_sec)  RETURN moving_point IS
      m_point           moving_point;
      m_point2          moving_point;
      intersection_te   tau_tll.d_temp_element_sec;
      i                 PLS_INTEGER;
   BEGIN
      --intersection_te := f_temp_element ();
      --intersection_te := intersection_te.intersects (intersection_te, te);
      intersection_te := te;
      i := intersection_te.te.FIRST;
      IF intersection_te.te (i) IS NOT NULL THEN
        m_point := at_period (intersection_te.te (i));
        i := intersection_te.te.NEXT (i);
      END IF;

      --DBMS_OUTPUT.put_line ('first period ok');
      WHILE i IS NOT NULL AND intersection_te.te (i) IS NOT NULL LOOP
         m_point2 := at_period (intersection_te.te (i));
         IF m_point IS NOT NULL AND m_point2 IS NOT NULL THEN
            m_point := merge_moving_points (m_point, m_point2);
            m_point.traj_id:=self.traj_id;
         END IF;
         i := intersection_te.te.NEXT (i);
      END LOOP;
      

      RETURN m_point;
   END;                                                      --at_temp_element

   MEMBER FUNCTION at_linestring (line MDSYS.SDO_GEOMETRY) RETURN moving_point IS
      m_point moving_point;
      m_point2 moving_point;
      intersectionlines geom_tbl;
      commonline sdo_geometry;
   BEGIN
     --check if given geometry is a linestring
     if (line.SDO_GTYPE = 2002) then
       --get parts of moving_point intersecting given geometry and are lines (expected to have only 4 ords 
       --as intersecting segment with line should return point,multipoint or simple line)
       select sdo_geom.sdo_intersection(line,
         sdo_geometry(2002,self.srid,null,sdo_elem_info_array(1,2,1),sdo_ordinate_array(u.m.xi,u.m.yi,u.m.xe,u.m.ye)),0.001)
         bulk collect into intersectionlines
         from table(self.u_tab) u
         where sdo_geom.sdo_intersection(line,
         sdo_geometry(2002,self.srid,null,sdo_elem_info_array(1,2,1),sdo_ordinate_array(u.m.xi,u.m.yi,u.m.xe,u.m.ye)),0.001).sdo_gtype=2002; 
       --form 1st moving_point
       if (intersectionlines.count=0) then
         dbms_output.put_line('Intersection returned no lines.@at_linestring of moving_point');
         return null;
       end if;
       commonline:=intersectionlines(1);
       --do not trust sdo_intersection returned order
       commonline:=sortbytime(commonline);
       m_point:=moving_point(moving_point_tab(unit_moving_point(
         tau_tll.d_period_sec(self.get_time_point(commonline.sdo_ordinates(1),commonline.sdo_ordinates(2))
           ,self.get_time_point(commonline.sdo_ordinates(3),commonline.sdo_ordinates(4))),
         unit_function(commonline.sdo_ordinates(1),commonline.sdo_ordinates(2),
           commonline.sdo_ordinates(3),commonline.sdo_ordinates(4),null,null,null,null,null,'PLNML_1'))),self.traj_id,self.srid);
       --form next moving_point
       for i in intersectionlines.first+1..intersectionlines.last loop
         commonline:=intersectionlines(i);
         --do not trust sdo_intersection returned order
         commonline:=sortbytime(commonline);
         m_point2:=moving_point(moving_point_tab(unit_moving_point(
           tau_tll.d_period_sec(self.get_time_point(commonline.sdo_ordinates(1),commonline.sdo_ordinates(2))
             ,self.get_time_point(commonline.sdo_ordinates(3),commonline.sdo_ordinates(4))),
           unit_function(commonline.sdo_ordinates(1),commonline.sdo_ordinates(2),
             commonline.sdo_ordinates(3),commonline.sdo_ordinates(4),null,null,null,null,null,'PLNML_1'))),self.traj_id,self.srid);
         --pass them to merge_moving_points
         if (m_point is null) then
           dbms_output.put_line('An error occurred while merging moving points.@at_linestring of moving_point'||i);
           return null;
         elsif (m_point2 is null) then
           continue;
         end if;
         m_point:=merge_moving_points(m_point,m_point2);
       end loop;
       --update traj_id cause is null due to merge_moving_points
       m_point.traj_id:= self.traj_id;     
       return m_point;
     else
       dbms_output.put_line('Given geometry not a LineString.');
       return null;
     end if;
   END at_linestring;

   MEMBER FUNCTION f_final_timepoint RETURN tau_tll.d_timepoint_sec IS
   BEGIN
      RETURN u_tab (u_tab.LAST).p.e;
   END;                                                    --f_final_timepoint

   MEMBER FUNCTION f_initial_timepoint RETURN tau_tll.d_timepoint_sec IS
   BEGIN
      RETURN u_tab (u_tab.FIRST).p.b;
   END;                                                    --f_final_timepoint

   MEMBER FUNCTION get_time_point (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec IS
      RESULT   tau_tll.d_timepoint_sec := NULL;
      i        PLS_INTEGER;
   BEGIN
      IF check_sorting () <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-004:Periods in the nested table of type Moving_Point_Tab are NOT sorted'
            );
      END IF;

      IF check_disjoint () <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-005:Periods in the nested table of type Moving_Point_Tab are NOT disjoint'
            );
      END IF;

      i := u_tab.FIRST;

      /*DBMS_OUTPUT.put_line (   '@ MP get_time_point -> x,y='
                            || TO_CHAR (x)
                            || ' , '
                            || TO_CHAR (y)
                           );*/
      WHILE i IS NOT NULL
      LOOP
         IF u_tab (i).f_contains (x, y)
         THEN
            --DBMS_OUTPUT.put_line (   '@ MP get_time_point -> Found in Tab=' || TO_CHAR (i)   );
            RESULT := u_tab (i).get_time_point (x, y);
            EXIT;
         END IF;

         i := u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      --DBMS_OUTPUT.put_line ('@ MP get_time_point -> XY  not found ');
      IF i IS NULL
      THEN
         raise_application_error
                       (-20100,
                        'C$HERMES-00x:Point not on moving point s trajectory '||self.traj_id
                        ||',x='||x||',y='||y
                       );
      ELSE
         RETURN RESULT;
      END IF;
   END;

   MEMBER FUNCTION f_trajectory RETURN MDSYS.SDO_GEOMETRY IS
      angle_i      NUMBER             := 0.0;
      angle_e      NUMBER             := 0.0;
      trajectory   MDSYS.SDO_GEOMETRY;
      i_xy         coords             := coords (0.0, 0.0);
      m_xy         coords             := coords (0.0, 0.0);
      e_xy         coords             := coords (0.0, 0.0);
      i            PLS_INTEGER;
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      --DBMS_OUTPUT.put_line ('###### TRAJECOTRY ######');
      --
      --
      i := u_tab.FIRST;
      i_xy (1) := u_tab (i).m.xi;
      i_xy (2) := u_tab (i).m.yi;
      e_xy (1) := u_tab (i).m.xe;
      e_xy (2) := u_tab (i).m.ye;
      m_xy := u_tab (i).get_midle_point ();

      IF utilities.check_colinear (i_xy (1),
                                   i_xy (2),
                                   m_xy (1),
                                   m_xy (2),
                                   e_xy (1),
                                   e_xy (2)
                                  )
      THEN
         --DBMS_OUTPUT.put_line ('Tab ' || TO_CHAR (i) || ' is '||u_tab (i).m.descr);
         trajectory :=
            MDSYS.SDO_GEOMETRY (2002,
                          SRID,
                          NULL,
                          sdo_elem_info_array (1, 2, 1),
                          sdo_ordinate_array (i_xy (1),
                                              i_xy (2),
                                              e_xy (1),
                                              e_xy (2)
                                             )
                         );
      ELSE
         --DBMS_OUTPUT.put_line ('Tab ' || TO_CHAR (i) || ' is '||u_tab (i).m.descr);
         trajectory :=
            MDSYS.SDO_GEOMETRY (2002,
                          SRID,
                          NULL,
                          sdo_elem_info_array (1, 2, 2),
                          sdo_ordinate_array (i_xy (1),
                                              i_xy (2),
                                              m_xy (1),
                                              m_xy (2),
                                              e_xy (1),
                                              e_xy (2)
                                             )
                         );
      END IF;

      i := u_tab.NEXT (i);

      WHILE i IS NOT NULL
      LOOP
         i_xy (1) := u_tab (i).m.xi;
         i_xy (2) := u_tab (i).m.yi;
         e_xy (1) := u_tab (i).m.xe;
         e_xy (2) := u_tab (i).m.ye;
         m_xy := u_tab (i).get_midle_point ();

         IF utilities.check_colinear (i_xy (1),
                                      i_xy (2),
                                      m_xy (1),
                                      m_xy (2),
                                      e_xy (1),
                                      e_xy (2)
                                     )
         THEN
            --DBMS_OUTPUT.put_line ('Tab ' || TO_CHAR (i) || ' is '||u_tab (i).m.descr);
            trajectory :=
               MDSYS.sdo_geom.sdo_union
                                 (trajectory,
                                  MDSYS.SDO_GEOMETRY (2002,
                                                SRID,
                                                NULL,
                                                sdo_elem_info_array (1, 2, 1),
                                                sdo_ordinate_array (i_xy (1),
                                                                    i_xy (2),
                                                                    e_xy (1),
                                                                    e_xy (2)
                                                                   )
                                               ),
                                  0.00001
                                 );
         ELSE
            --DBMS_OUTPUT.put_line ('Tab ' || TO_CHAR (i) || ' is '||u_tab (i).m.descr);
            trajectory :=
               MDSYS.sdo_geom.sdo_union
                                 (trajectory,
                                  MDSYS.SDO_GEOMETRY (2002,
                                                SRID,
                                                NULL,
                                                sdo_elem_info_array (1, 2, 2),
                                                sdo_ordinate_array (i_xy (1),
                                                                    i_xy (2),
                                                                    m_xy (1),
                                                                    m_xy (2),
                                                                    e_xy (1),
                                                                    e_xy (2)
                                                                   )
                                               ),
                                  0.00001
                                 );
         END IF;

         i := u_tab.NEXT (i);
      END LOOP;

      RETURN trajectory;
   END;

   MEMBER FUNCTION f_trajectory2 RETURN MDSYS.SDO_GEOMETRY IS
      RESULT             MDSYS.SDO_GEOMETRY;
      elem_info          MDSYS.sdo_elem_info_array;
      ordinates          MDSYS.sdo_ordinate_array;
      i_xy               coords                    := coords (0.0, 0.0);
      e_xy               coords                    := coords (0.0, 0.0);
      elem_info_offset   PLS_INTEGER               := 1;
      ordinates_offset   PLS_INTEGER               := 1;
      i                  PLS_INTEGER;
      j             pls_integer := 1;
      pre_x     number := -1234.121;
      pre_y     number := -4321.131;
      prepre_x  number := -5678.141;
      prepre_y  number := -8765.151;
      NewL_ords MDSYS.SDO_ORDINATE_ARRAY;
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      elem_info := MDSYS.sdo_elem_info_array ();
      elem_info.EXTEND (3); elem_info(1) := 1; elem_info(2) := 2; elem_info(3) := 1;
      ordinates := MDSYS.sdo_ordinate_array ();

      i := u_tab.FIRST;
      WHILE i IS NOT NULL
      LOOP
         i_xy (1) := u_tab (i).m.xi;
         i_xy (2) := u_tab (i).m.yi;
         e_xy (1) := u_tab (i).m.xe;
         e_xy (2) := u_tab (i).m.ye;

         IF i = u_tab.FIRST
         THEN
            ordinates.EXTEND (2);
            ordinates (ordinates_offset) := i_xy (1);
            ordinates (ordinates_offset + 1) := i_xy (2);
            ordinates_offset := ordinates_offset + 2;
         END IF;

         ordinates.EXTEND (2);
         ordinates (ordinates_offset) := e_xy (1);
         ordinates (ordinates_offset + 1) := e_xy (2);
         ordinates_offset := ordinates_offset + 2;

         i := u_tab.NEXT(i);
      END LOOP;
        /*
        -- SMOOTHLINE
        i := 1;
        NewL_ords := MDSYS.SDO_ORDINATE_ARRAY();
        WHILE i <= ordinates.COUNT - 1 LOOP
            IF ordinates(i) = pre_x AND ordinates(i+1) = pre_y THEN
                NULL;
            ELSIF UTILITIES.check_colinear(prepre_x, prepre_y, pre_x, pre_y, ordinates(i), ordinates(i+1)) = TRUE THEN
                NULL;
            ELSE
                NewL_ords.EXTEND(2);
                NewL_ords(j)   := ordinates(i);
                NewL_ords(j+1) := ordinates(i+1);
                prepre_x := pre_x;
                prepre_y := pre_y;
                pre_x := NewL_ords(j);
                pre_y := NewL_ords(j+1);
                j := j + 2;
            END IF;
            i := i + 2;
        END LOOP;*/

      RESULT := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, elem_info, ordinates);
      RETURN RESULT;
   END;

   MEMBER FUNCTION f_temp_element RETURN tau_tll.d_temp_element_sec IS
      RESULT   tau_tll.d_temp_element_sec;
      i        PLS_INTEGER;
   BEGIN
      i := u_tab.FIRST;                     -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP
         IF i = u_tab.FIRST
         THEN
            RESULT :=
               tau_tll.d_temp_element_sec
                                        (tau_tll.temp_element_sec (u_tab (i).p)
                                        );
         ELSE
            --RESULT.f_add_period (u_tab (i).p);
            RESULT.te.extend;
            RESULT.te(i) := u_tab (i).p;
         END IF;

         i := u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      RETURN RESULT;
   END;                                                       --f_temp_element

   MEMBER FUNCTION f_initial RETURN MDSYS.SDO_GEOMETRY IS
      RESULT   MDSYS.SDO_GEOMETRY;
      i        PLS_INTEGER;
   BEGIN
      i := u_tab.FIRST;
      RESULT := at_instant (u_tab (i).p.b);
      RETURN RESULT;
   END;                                                            --f_initial

   MEMBER FUNCTION f_final RETURN MDSYS.SDO_GEOMETRY IS
      RESULT   MDSYS.SDO_GEOMETRY;
      tp       tau_tll.d_timepoint_sec;
      i        PLS_INTEGER;
   BEGIN
      i := u_tab.LAST;
      tp := u_tab (i).p.e;
      RESULT := at_instant (tp);
      RETURN RESULT;
   END;                                                              --f_final

   MEMBER FUNCTION f_direction (tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
      ump           unit_moving_point;
      delta_angle   NUMBER;
      xy            coords;
      r_angle       NUMBER;
   --linear_angle   NUMBER;
   BEGIN
      ump := unit_type (tp);

      IF ump IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF ump.m.descr = 'PLNML_1'
      THEN
         delta_angle :=
                 utilities.direction (ump.m.xi, ump.m.yi, ump.m.xe, ump.m.ye);
      ELSE
         -- to do na ftiakso kai gia kikliki kinisi...
         --DBMS_OUTPUT.put_line('@f_direction -> Direction Kiklikis kinisis...');
         xy := ump.f_interpolate (tp);
         r_angle := utilities.direction (ump.m.xm, ump.m.ym, xy (1), xy (2));

         --DBMS_OUTPUT.put_line ('r_angle=' || TO_CHAR (r_angle));
         /*linear_angle :=
                     utilities.direction (xy (1), xy (2), ump.m.xe, ump.m.ye);
         DBMS_OUTPUT.put_line ('linear_angle=' || TO_CHAR (linear_angle));*/

         --
         IF r_angle <= 90
         THEN
            --DBMS_OUTPUT.put_line ('Case 1');
            --r_angle:=r_angle;
            delta_angle := r_angle + 90;

            IF xy (1) < ump.m.xe and xy (2) > ump.m.ye
            THEN
               --DBMS_OUTPUT.put_line ('b');
               delta_angle := 180 + delta_angle;
            END IF;
         ELSIF r_angle > 90 AND r_angle <= 180
         THEN
            --DBMS_OUTPUT.put_line ('Case 2');
            --r_angle:=180-r_angle;
            delta_angle := r_angle - 90;
            IF xy (1) > ump.m.xe and xy (2) > ump.m.ye
            THEN
               --DBMS_OUTPUT.put_line ('b');
               delta_angle := 180 + delta_angle;
            END IF;
         ELSIF r_angle > 180 AND r_angle <= 270
         THEN
            --DBMS_OUTPUT.put_line ('Case 3');
            r_angle := r_angle - 180;
            delta_angle := r_angle + 90;
            --DBMS_OUTPUT.put_line ('x='||to_char(xy (1))||' xe='||to_char(ump.m.xe));
            IF xy (1) > ump.m.xe and xy (2) > ump.m.ye
            THEN
               --DBMS_OUTPUT.put_line ('b');
               delta_angle := 180 + delta_angle;
            END IF;
         ELSIF r_angle > 270 AND r_angle <= 360
         THEN
            --DBMS_OUTPUT.put_line ('Case 4');
            r_angle := 360 - r_angle;
            delta_angle := 180 - 90 - r_angle;
            IF xy (1) > ump.m.xe and xy (2) > ump.m.ye
            THEN
               --DBMS_OUTPUT.put_line ('b');
               delta_angle := 180 + delta_angle;
            END IF;
         END IF;
      END IF;

      RETURN delta_angle;
   END;                                                          --f_direction

   MEMBER FUNCTION f_east (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   begin
     return f_east(geom, tp, null, null);
   end f_east;
   
   MEMBER FUNCTION f_east (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER,angle_max NUMBER) RETURN NUMBER IS
      azimuth             NUMBER;
      angle_min_final   NUMBER := 5;
      angle_max_final   NUMBER := 175;
      centroid_point    MDSYS.SDO_GEOMETRY;
      to_degrees number:=180/acos(-1);
   BEGIN
      CASE geom.sdo_gtype
         WHEN 2001                                     -- to geom einai point
         THEN
            centroid_point := geom;
         WHEN 2005                                 -- to geom einai multipoint
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         WHEN 2003                                    -- to geom einai polygon
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         WHEN 2007                               -- to geom einai multipolygon
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         ELSE            -- h centroid den douleuei gia allou tupou geometries
            RETURN NULL;
      END CASE;

      azimuth := utilities.azimuth(at_instant(tp), centroid_point);
      dbms_output.put_line('rad='||azimuth);
      azimuth := azimuth * to_degrees;
      dbms_output.put_line('degr='||azimuth);
      -- 
      IF (azimuth <= angle_max_final and azimuth >= angle_min_final)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;       
   
   MEMBER FUNCTION f_west (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   begin
     return f_west(geom, tp, null, null);
   end f_west;                                                        --f_west

   MEMBER FUNCTION f_west (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER IS
      azimuth             NUMBER;
      angle_min_final   NUMBER := 185;
      angle_max_final   NUMBER := 355;
      centroid_point    MDSYS.SDO_GEOMETRY;
      to_degrees number:=180/acos(-1);
   BEGIN
      CASE geom.sdo_gtype
         -- to geom einai point
      WHEN 2001
         THEN
            centroid_point := geom;
         -- to geom einai multipoint
      WHEN 2005
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai polygon
      WHEN 2003
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai multipolygon
      WHEN 2007
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- h centroid den douleuei gia allou tupou geometries
      ELSE
            RETURN NULL;
      END CASE;

      azimuth := utilities.azimuth(at_instant(tp), centroid_point);
      dbms_output.put_line('rad='||azimuth);
      azimuth := azimuth * to_degrees;
      dbms_output.put_line('degr='||azimuth);
      --
      IF (azimuth >= angle_min_final AND azimuth <= angle_max_final)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;
   
   MEMBER FUNCTION f_south (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   begin
     return f_south(geom, tp, null, null);
   end f_south; 
                                                                      --f_west
   MEMBER FUNCTION f_south (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER IS
      azimuth             NUMBER;
      angle_min_final   NUMBER := 95;
      angle_max_final   NUMBER := 265;
      centroid_point    MDSYS.SDO_GEOMETRY;
      to_degrees number:=180/acos(-1);
   BEGIN
      CASE geom.sdo_gtype
         -- to geom einai point
      WHEN 2001
         THEN
            centroid_point := geom;
         -- to geom einai multipoint
      WHEN 2005
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai polygon
      WHEN 2003
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai multipolygon
      WHEN 2007
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- h centroid den douleuei gia allou tupou geometries
      ELSE
            RETURN NULL;
      END CASE;

      azimuth := utilities.azimuth(at_instant(tp), centroid_point);
      dbms_output.put_line('rad='||azimuth);
      azimuth := azimuth * to_degrees;
      dbms_output.put_line('degr='||azimuth);
      --
      IF (azimuth >= angle_min_final AND azimuth <= angle_max_final)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;                                                              --f_south

   MEMBER FUNCTION f_north (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   begin
     return f_north(geom, tp, null, null);
   end f_north;
   
   MEMBER FUNCTION f_north (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER IS
      azimuth             NUMBER;
      angle_min_final   NUMBER := 85;
      angle_max_final   NUMBER := 275;
      centroid_point    MDSYS.SDO_GEOMETRY;
      to_degrees number:=180/acos(-1);
   BEGIN
      CASE geom.sdo_gtype
         -- to geom einai point
      WHEN 2001
         THEN
            centroid_point := geom;
         -- to geom einai multipoint
      WHEN 2005
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai polygon
      WHEN 2003
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- to geom einai multipolygon
      WHEN 2007
         THEN
            centroid_point := MDSYS.sdo_geom.sdo_centroid (geom, 0.001);
         -- h centroid den douleuei gia allou tupou geometries
      ELSE
            RETURN NULL;
      END CASE;

      azimuth := utilities.azimuth(at_instant(tp), centroid_point);
      dbms_output.put_line('rad='||azimuth);
      azimuth := azimuth * to_degrees;
      dbms_output.put_line('degr='||azimuth);
      --
      IF (azimuth >= 0 AND azimuth <= angle_min_final)
        or (azimuth >= angle_max_final  AND azimuth <= 360)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;                                                              --f_north

   MEMBER FUNCTION f_between (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
      mbr   MDSYS.SDO_GEOMETRY;
   BEGIN
      IF NOT (   geom.sdo_gtype = 2004
              OR geom.sdo_gtype = 2005
              OR geom.sdo_gtype = 2006
              OR geom.sdo_gtype = 2007
             )
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-00x:The geometry must be multipoint, multiline or heterogeneous collection of elements.'
            );
      END IF;

      -- euresi tou elaxistou tetragonou pou perikleiei tin poly-geometria (mbr)
      mbr := MDSYS.sdo_geom.sdo_mbr (geom, NULL);

      -- an to shmeio se xrono tp vrisketai mesa sto mbr tote einai anamesa stin
      -- poly-geometria
      IF MDSYS.sdo_geom.relate (at_instant (tp), 'INSIDE', mbr, 0.001) = 'TRUE'
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   END;

   MEMBER FUNCTION f_speed (tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
      contain_flag   PLS_INTEGER;
      i              PLS_INTEGER;
   BEGIN
      i := u_tab.FIRST;                     -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP
         contain_flag := u_tab (i).p.f_contains (u_tab (i).p, tp);

         IF contain_flag = 1
         THEN
            RETURN u_tab (i).get_speed (tp);
         END IF;

         i := u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      RETURN NULL;
   END;                                                              --f_speed


   MEMBER FUNCTION f_buffer (distance NUMBER, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_buffer (at_instant (tp), distance, tolerance, NULL);
   END;                                                             --f_buffer

   MEMBER FUNCTION f_distance (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_distance (at_instant (tp),
                                    moving_point.at_instant (tp),
                                    tolerance,
                                    NULL
                                   );
   END;                                                           --f_distance

   MEMBER FUNCTION f_distance (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_distance (at_instant (tp), geom, tolerance, NULL);
   END;                                                           --f_distance

   MEMBER FUNCTION f_within_distance (distance NUMBER, moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2 IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.within_distance (at_instant (tp),
                                       distance,
                                       moving_point.at_instant (tp),
                                       tolerance,
                                       NULL
                                      );
   END;                                                   -- f_within_distance

   MEMBER FUNCTION f_within_distance (distance NUMBER, geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2 IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.within_distance (at_instant (tp),
                                       distance,
                                       geom,
                                       tolerance,
                                       NULL
                                      );
   END;                                                   -- f_within_distance

   MEMBER FUNCTION f_relate (MASK VARCHAR2, moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2 IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.relate (at_instant (tp),
                              MASK,
                              moving_point.at_instant (tp),
                              tolerance
                             );
   END;                                                             --f_relate

   MEMBER FUNCTION f_relate (MASK VARCHAR2, geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2 IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.relate (at_instant (tp), MASK, geom, tolerance);
   END;                                                             --f_relate

   MEMBER FUNCTION f_intersection (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_intersection (at_instant (tp),
                                        moving_point.at_instant (tp),
                                        tolerance
                                       );
   END;                                                       --f_intersection

   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_intersection (at_instant (tp), geom, tolerance);
   END;                                                       --f_intersection

   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER) RETURN moving_point IS
   line_in mdsys.sdo_geometry;
   initial_point_in mdsys.sdo_geometry;
   final_point_in mdsys.sdo_geometry;
   m Moving_Point;
   sm moving_point;
   t1 tau_tll.d_timepoint_sec;
   t2 tau_tll.d_timepoint_sec;
   abs_t1 double precision;
   abs_t2 double precision;
   ordinates_count pls_integer;
   i pls_integer;
   j pls_integer;
   k pls_integer;
   begin

   -- TO DO:INTERPOLATE TIME AND AND AND FIND PROPER DIRECTION IDENTIFICATION FOR THE LAST ELSE
        m :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(NULL,NULL),
          unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))), self.traj_id, self.srid);
        sm:=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(NULL,NULL),
          unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))), self.traj_id, self.srid);

        line_in := MDSYS.sdo_geom.sdo_intersection (geom, f_trajectory2(), tolerance);

       IF line_in IS NOT NULL THEN
            i:=u_tab.COUNT;
            j:=1;
            k:=1; -- just used to avoid counting m.u_tab entries
            WHILE j<=i LOOP
                sm:=moving_point(moving_point_tab(u_tab(j)), self.traj_id, self.srid);
                line_in:=MDSYS.sdo_geom.sdo_intersection (geom, sm.f_trajectory2(), tolerance);

                IF (line_in is not null) THEN
                    IF (k=1) THEN
                        m:=moving_point(moving_point_tab(u_tab(j)), self.traj_id, self.srid);
                        k:=k+1;
                    ELSE
                        m.u_tab(m.u_tab.last):=sm.u_tab(sm.u_tab.first);
                    END IF;

                END IF;

                --if the current trajectory segment is not fully contained in the given geom
                IF (line_in is not null) AND (MDSYS.SDO_GEOM.RELATE(sm.f_trajectory2(), 'INSIDE',geom , tolerance)='FALSE')  THEN
                    --used to check whether the initial point of the segment intersects the given geometry
                    initial_point_in:=SDO_GEOMETRY(2001,SRID,SDO_POINT_TYPE(sm.u_tab(sm.u_tab.first).m.xi, sm.u_tab(sm.u_tab.first).m.yi, NULL),NULL,NULL);
                    final_point_in:=SDO_GEOMETRY(2001,SRID,SDO_POINT_TYPE(sm.u_tab(sm.u_tab.first).m.xe, sm.u_tab(sm.u_tab.first).m.ye, NULL),NULL,NULL);

                    --if the initial point of the trajectory segment intersects the given geometry then we should check in the middle of the segment
                    --for the final point that simultaneously participates in the intersection
                    ordinates_count:=line_in.sdo_ordinates.COUNT;
                    IF MDSYS.sdo_geom.sdo_intersection (geom, initial_point_in, tolerance) IS NOT NULL THEN
                       IF (Abs((line_in.sdo_ordinates(ordinates_count-1)-m.u_tab(m.u_tab.last).m.xi)+(line_in.sdo_ordinates(ordinates_count)-m.u_tab(m.u_tab.last).m.yi))>tolerance) THEN
                          m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(m.u_tab(m.u_tab.last).p.b,get_time_point (line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count))),
                                              unit_function(m.u_tab(m.u_tab.last).m.xi,m.u_tab(m.u_tab.last).m.yi,line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count),NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                        ELSE
                          m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(m.u_tab(m.u_tab.last).p.b,get_time_point (line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1))),
                                              unit_function(m.u_tab(m.u_tab.last).m.xi,m.u_tab(m.u_tab.last).m.yi,line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1),NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                        END IF;
                    --if the final point of the trajectory segment intersects the given geometry then we should check in the middle of the segment
                    --for the initial point that simultaneously participates in the intersection
                    ELSIF MDSYS.sdo_geom.sdo_intersection (geom, final_point_in, tolerance) IS NOT NULL THEN

                       IF (Abs((line_in.sdo_ordinates(line_in.sdo_ordinates.first)-m.u_tab(m.u_tab.last).m.xe)+(line_in.sdo_ordinates(line_in.sdo_ordinates.first+1)-m.u_tab(m.u_tab.last).m.ye))>tolerance)
                       THEN
                            m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(get_time_point (line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1)),m.u_tab(m.u_tab.last).p.e),
                                              unit_function(line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1),m.u_tab(m.u_tab.last).m.xe,m.u_tab(m.u_tab.last).m.ye,NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                        ELSE
                            m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(get_time_point (line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count)),m.u_tab(m.u_tab.last).p.e),
                                              unit_function(line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count),m.u_tab(m.u_tab.last).m.xe,m.u_tab(m.u_tab.last).m.ye,NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                        END IF;
                    --else we should check in the middle of the segment for the initial and final points of the segment that participate in the intersection
                    ELSE
                            t1:=get_time_point(line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1));
                            t2:=get_time_point(line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count));
                            abs_t1:=tau_tll.D_timepoint_Sec_package.get_abs_date(t1.m_y,t1.m_m,t1.m_d,t1.m_h,t1.m_min,t1.m_sec);
                            abs_t2:=tau_tll.D_timepoint_Sec_package.get_abs_date(t2.m_y,t2.m_m,t2.m_d,t2.m_h,t2.m_min,t2.m_sec);
                            IF (abs_t1<abs_t2) THEN
                               m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(t1,t2),
                                              unit_function(line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1),line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count),NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                            ELSE
                               m.u_tab(m.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(t2,t1),
                                              unit_function(line_in.sdo_ordinates(ordinates_count-1),line_in.sdo_ordinates(ordinates_count),line_in.sdo_ordinates(line_in.sdo_ordinates.first),line_in.sdo_ordinates(line_in.sdo_ordinates.first+1),NULL,NULL,NULL,NULL,NULL,'PLNML_1'));
                            END IF;
                    END IF;
                END IF;
                IF m.u_tab(m.u_tab.last).p.b.m_y is null THEN
                    null;
                ELSE
                    m.u_tab.extend(1);
                END IF;
                j:=j+1;
            END LOOP;
                m.u_tab.trim(1);
                RETURN m;
        ELSE
            RETURN NULL;
        END IF;
   END;

   MEMBER FUNCTION f_intersection2 (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER) RETURN moving_point IS   enter_points mdsys.sdo_geometry;
   leave_points mdsys.sdo_geometry;
   enter tau_tll.d_timepoint_sec;
   leave tau_tll.d_timepoint_sec;
   te tau_tll.temp_element_sec;
   i pls_integer;
   j pls_integer := 0;
   BEGIN
        te := tau_tll.temp_element_sec();
        enter_points := f_enterpoints (geom);
        leave_points := f_leavepoints (geom);
        IF enter_points is not null AND leave_points is not null THEN
            --UTILITIES.print_geometry(enter_points,'enter_points');
            --UTILITIES.print_geometry(leave_points,'leave_points');
            IF enter_points.sdo_ordinates.COUNT <= leave_points.sdo_ordinates.COUNT THEN
                i := enter_points.sdo_ordinates.FIRST;
            ELSE
                i := leave_points.sdo_ordinates.FIRST;
            END IF;
        ELSE
            RETURN NULL;
        END IF;

        WHILE i is not null LOOP
            enter := get_time_point (enter_points.sdo_ordinates (i), enter_points.sdo_ordinates (i+1));
            leave := get_time_point (leave_points.sdo_ordinates (i), leave_points.sdo_ordinates (i+1));

            IF enter is not null AND leave is not null THEN
                j := j + 1;
                --DBMS_OUTPUT.put_line('enter: ' || TO_CHAR(j) || enter.to_string());
                --DBMS_OUTPUT.put_line('leave: ' || TO_CHAR(j) || leave.to_string());
                te.extend;
                te(j) := TAU_TLL.D_Period_sec(enter, leave);
            ELSE
                exit;
            END IF;
            IF enter_points.sdo_ordinates.COUNT <= leave_points.sdo_ordinates.COUNT THEN
                i := enter_points.sdo_ordinates.NEXT(i+1);
            ELSE
                i := leave_points.sdo_ordinates.NEXT(i+1);
            END IF;
        END LOOP;

        IF j <> 0 THEN
            RETURN at_temp_element (TAU_TLL.d_temp_element_sec(te));
        ELSE
            RETURN NULL;
        END IF;

   END;                                                       --f_intersection

MEMBER PROCEDURE f_intersection (geom MDSYS.SDO_GEOMETRY, line_inside OUT MDSYS.SDO_GEOMETRY, period_inside OUT tau_tll.d_period_sec, tolerance NUMBER) IS
   line_in mdsys.sdo_geometry;
   period_in tau_tll.d_period_sec;
   enter tau_tll.d_timepoint_sec;
   leave tau_tll.d_timepoint_sec;
   i pls_integer;
   BEGIN
        line_in := MDSYS.sdo_geom.sdo_intersection (geom, f_trajectory2(), tolerance);

        IF line_in is not null AND (line_in.SDO_GTYPE = 2002 OR line_in.SDO_GTYPE = 2006) THEN
            --UTILITIES.print_geometry(line_in,'line_in');
            i := line_in.sdo_ordinates.FIRST;
            enter := get_time_point (line_in.sdo_ordinates (i), line_in.sdo_ordinates (i+1));
            i := line_in.sdo_ordinates.LAST;
            leave := get_time_point (line_in.sdo_ordinates (i-1), line_in.sdo_ordinates (i));

            IF enter is not null AND leave is not null THEN
                --DBMS_OUTPUT.put_line('enter: ' || TO_CHAR(j) || enter.to_string());
                --DBMS_OUTPUT.put_line('leave: ' || TO_CHAR(j) || leave.to_string());
                period_in := TAU_TLL.D_Period_sec(enter, leave);
            ELSE
                return;
            END IF;
        ELSE
            return;
        END IF;

        line_inside := line_in;
        period_inside := period_in;
   END;                                                       --f_intersection

   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, line_inside OUT MDSYS.SDO_GEOMETRY, period_inside OUT tau_tll.d_period_sec, tolerance NUMBER) RETURN moving_point IS
   line_in mdsys.sdo_geometry;
   period_in tau_tll.d_period_sec;
   enter tau_tll.d_timepoint_sec;
   leave tau_tll.d_timepoint_sec;
   i pls_integer;
   BEGIN
        line_in := MDSYS.sdo_geom.sdo_intersection (geom, f_trajectory2(), tolerance);

        IF line_in is not null AND (line_in.SDO_GTYPE = 2002 OR line_in.SDO_GTYPE = 2006) THEN
            --UTILITIES.print_geometry(line_in,'line_in');
            i := line_in.sdo_ordinates.FIRST;
            enter := get_time_point (line_in.sdo_ordinates (i), line_in.sdo_ordinates (i+1));
            i := line_in.sdo_ordinates.LAST;
            leave := get_time_point (line_in.sdo_ordinates (i-1), line_in.sdo_ordinates (i));

            IF enter is not null AND leave is not null THEN
                --DBMS_OUTPUT.put_line('enter: ' || TO_CHAR(j) || enter.to_string());
                --DBMS_OUTPUT.put_line('leave: ' || TO_CHAR(j) || leave.to_string());
                period_in := TAU_TLL.D_Period_sec(enter, leave);

                line_inside := line_in;
                period_inside := period_in;
                RETURN at_period (period_in);
            ELSE
                return null;
            END IF;
        ELSE
            return null;
        END IF;
   END;                                                       --f_intersection

   MEMBER FUNCTION f_union (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_union (at_instant (tp),
                                 moving_point.at_instant (tp),
                                 tolerance
                                );
   END;                                                              --f_union

   MEMBER FUNCTION f_union (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_union (at_instant (tp), geom, tolerance);
   END;                                                              --f_union

   MEMBER FUNCTION f_xor (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_xor (at_instant (tp),
                               moving_point.at_instant (tp),
                               tolerance
                              );
   END;                                                                --f_xor

   MEMBER FUNCTION f_xor (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY IS
   BEGIN
      -- to do: checks
      RETURN MDSYS.sdo_geom.sdo_xor (at_instant (tp), geom, tolerance);
   END;                                                                --f_xor

    MEMBER FUNCTION f_enterpoints (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
    multiline       MDSYS.SDO_GEOMETRY;
    ords            MDSYS.sdo_ordinate_array;
    i               PLS_INTEGER       := 1;
    ords_offset     PLS_INTEGER       := 1;
    SRID pls_integer;
   begin
        --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
        srid:=self.srid;

        --DBMS_OUTPUT.put_line('@f_enterpoints -> Euresi ton simeion eisodou eksoodou...');
        --enter_leave_multipoint := get_enter_leave_points (geom);
        multiline := MDSYS.sdo_geom.sdo_intersection (geom, f_trajectory2(), 0.001);

        --DBMS_OUTPUT.put_line ('@f_enterpoints -> ok...');
        IF multiline IS NULL THEN
            --DBMS_OUTPUT.put_line ('multiline IS NULL');
            RETURN NULL;
        END IF;

        /*DBMS_OUTPUT.put_line ('@f_enterpoints -> Taksinomisi ton simeion me basi to xrono...');*/
        -- CHECK and UNCOMMENT
        --multiline := sort_by_time (multiline);
        --changed to a faster way??? sider
        multiline := sortbytime (multiline);

        ords := MDSYS.sdo_ordinate_array ();
        IF multiline.SDO_GTYPE = 2002 THEN
            ords.EXTEND (2);
            ords (ords_offset) := multiline.sdo_ordinates (1);
            ords (ords_offset + 1) := multiline.sdo_ordinates (2);
            --UTILITIES.print_geometry(MDSYS.SDO_GEOMETRY (2005, NULL, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords),'ENTERPOINTS');
            RETURN MDSYS.SDO_GEOMETRY (2005, SRID, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords);
        ELSIF multiline.SDO_GTYPE = 2006 THEN
            WHILE i <= multiline.sdo_elem_info.COUNT / 3 LOOP
                ords.EXTEND (2);
                ords (ords_offset) := multiline.sdo_ordinates (multiline.sdo_elem_info(3*i-2));
                ords (ords_offset + 1) := multiline.sdo_ordinates (multiline.sdo_elem_info(3*i-2) + 1);
                ords_offset := ords_offset + 2;
                i := i + 1;
            END LOOP;
            --UTILITIES.print_geometry(MDSYS.SDO_GEOMETRY (2005, NULL, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords),'ENTERPOINTS');
            RETURN MDSYS.SDO_GEOMETRY (2005, SRID, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords);
        ELSE
            RETURN NULL;
        END IF;

   END;                                                        --f_enterpoints

   MEMBER FUNCTION f_leavepoints (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
    multiline       MDSYS.SDO_GEOMETRY;
    ords            MDSYS.sdo_ordinate_array;
    i               PLS_INTEGER       := 1;
    ords_offset     PLS_INTEGER       := 1;
    SRID pls_integer;
    t number;
   begin
        --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
        srid:=self.srid;

        /*DBMS_OUTPUT.put_line('@f_leavepoints -> Euresi ton simeion eisodou eksoodou...');*/
        --enter_leave_multipoint := get_enter_leave_points (geom);
        multiline := MDSYS.sdo_geom.sdo_intersection (geom, f_trajectory2 (), 0.001);

        --DBMS_OUTPUT.put_line ('@f_leavepoints -> ok...');
        IF multiline IS NULL THEN
            --DBMS_OUTPUT.put_line ('multiline IS NULL');
            RETURN NULL;
        END IF;

        /*DBMS_OUTPUT.put_line ('@f_leavepoints -> Taksinomisi ton simeion me basi to xrono...');*/
        -- CHECK and UNCOMMENT
        --multiline := sort_by_time (multiline);
        --changed to a faster way??? sider
        multiline := sortbytime (multiline);

        ords := MDSYS.sdo_ordinate_array ();
        IF multiline.SDO_GTYPE = 2002 THEN
            ords.EXTEND (2);
            t:=multiline.sdo_ordinates (multiline.sdo_ordinates.LAST - 1);
            ords (ords_offset) := multiline.sdo_ordinates (multiline.sdo_ordinates.LAST - 1);
            t:=multiline.sdo_ordinates (multiline.sdo_ordinates.LAST);
            ords (ords_offset + 1) := multiline.sdo_ordinates (multiline.sdo_ordinates.LAST);
            --UTILITIES.print_geometry(MDSYS.SDO_GEOMETRY (2005, NULL, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords),'LEAVEPOINTS');
            RETURN MDSYS.SDO_GEOMETRY (2005, SRID, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords);
            --this could be a simple point also!!!
        ELSIF multiline.SDO_GTYPE = 2006 THEN
            WHILE i < multiline.sdo_elem_info.COUNT / 3 LOOP
                ords.EXTEND (2);
                t:=multiline.sdo_ordinates (multiline.sdo_elem_info(3*i+1) - 2);
                ords (ords_offset) := multiline.sdo_ordinates (multiline.sdo_elem_info(3*i+1) - 2);
                t:=multiline.sdo_ordinates (multiline.sdo_elem_info(3*i+1) - 1);
                ords (ords_offset + 1) := multiline.sdo_ordinates (multiline.sdo_elem_info(3*i+1) - 1);
                ords_offset := ords_offset + 2;
                i := i + 1;
            END LOOP;
            ords.EXTEND (2);
            t:=multiline.sdo_ordinates (multiline.sdo_ordinates.LAST - 1);
            ords (ords_offset) := multiline.sdo_ordinates (multiline.sdo_ordinates.LAST - 1);
            t:=multiline.sdo_ordinates (multiline.sdo_ordinates.LAST);
            ords (ords_offset + 1) := multiline.sdo_ordinates (multiline.sdo_ordinates.LAST);
            --UTILITIES.print_geometry(MDSYS.SDO_GEOMETRY (2005, NULL, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords),'LEAVEPOINTS');
            RETURN MDSYS.SDO_GEOMETRY (2005, SRID, NULL, sdo_elem_info_array (1, 1, ords.COUNT / 2), ords);
        ELSE
            RETURN NULL;
        END IF;

   END;                                                        --f_leavepoints

   MEMBER FUNCTION f_enter (geom MDSYS.SDO_GEOMETRY) RETURN tau_tll.d_timepoint_sec IS
      enter_time_point   tau_tll.d_timepoint_sec;
      enter_points       MDSYS.SDO_GEOMETRY;
   BEGIN
      enter_points := f_enterpoints (geom);

      IF enter_points IS NULL THEN
         RETURN NULL;
      END IF;

      enter_time_point :=
         get_time_point (enter_points.sdo_ordinates (1),
                         enter_points.sdo_ordinates (2)
                        );
      RETURN enter_time_point;
   END;

   MEMBER FUNCTION f_leave (geom MDSYS.SDO_GEOMETRY) RETURN tau_tll.d_timepoint_sec IS
      leave_time_point   tau_tll.d_timepoint_sec;
      leave_points       MDSYS.SDO_GEOMETRY;
      i                  PLS_INTEGER;
   BEGIN
      leave_points := f_leavepoints (geom);

      IF leave_points IS NULL
      THEN
         RETURN NULL;
      END IF;

      i := leave_points.sdo_ordinates.LAST;
      leave_time_point :=
         get_time_point (leave_points.sdo_ordinates (i - 1),
                         leave_points.sdo_ordinates (i)
                        );
      RETURN leave_time_point;
   END;

    MEMBER FUNCTION transfer2(Qm moving_point, Sm IN OUT moving_point) return moving_point is
    i pls_integer;
    dx number;
    dy number;
    begin
        dx := Qm.u_tab(1).m.xi - Sm.u_tab(1).m.xi;
        dy := Qm.u_tab(1).m.yi - Sm.u_tab(1).m.yi;

        i := Sm.u_tab.FIRST;
        WHILE i IS NOT NULL LOOP
            Sm.u_tab(i).m.xi := Sm.u_tab(i).m.xi + dx;
            Sm.u_tab(i).m.yi := Sm.u_tab(i).m.yi + dy;
            Sm.u_tab(i).m.xe := Sm.u_tab(i).m.xe + dx;
            Sm.u_tab(i).m.ye := Sm.u_tab(i).m.ye + dy;

            i := Sm.u_tab.NEXT(i);
        END LOOP;

        return Sm;
    end;

    member function f_speed_var return number is
      avg_speed number:=f_avg_speed();
      tmp_speed number;
      diff number:=0;
      i pls_integer;
    begin
      i:=u_tab.first;
      while i is not null loop
        tmp_speed:=mdsys.sdo_geom.sdo_distance(
             mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xi,u_tab(i).m.yi,null),null,null),
             mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xe,u_tab(i).m.ye,null),null,null),
             0.0005)/u_tab(i).p.duration().m_Value;--meters per seconds
        diff:= diff + power((avg_speed-tmp_speed),2);
        i:=u_tab.next(i);
      end loop;
      return diff/u_tab.count;
    end f_speed_var;

    MEMBER FUNCTION f_avg_speed RETURN NUMBER is
    i pls_integer;
    len number := 0;
    dur number := 0;
    begin
        i := u_tab.FIRST;
        WHILE i IS NOT NULL LOOP
          --len := len + UTILITIES.distance(u_tab(i).m.xi, u_tab(i).m.yi, u_tab(i).m.xe, u_tab(i).m.ye);
          --more precise when
          len:=len+mdsys.sdo_geom.sdo_distance(
                 mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xi,u_tab(i).m.yi,null),null,null),
                 mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xe,u_tab(i).m.ye,null),null,null),
                 0.0005);                   
          dur := dur + u_tab(i).p.duration().m_Value;

          i := u_tab.NEXT(i);
        END LOOP;

        IF dur <> 0 THEN return len / dur;
        ELSE raise_application_error(-20100, 'C$HERMES-00*: Zero duration/lifespan of moving point'); END IF;
    end;

    MEMBER FUNCTION f_avg_acceleration RETURN NUMBER is
    i pls_integer;
    u1 number := 0;
    u2 number := 0;
    len number := 0;
    dur number := 0;
    avg_acc number := 0;
    begin
        i := u_tab.FIRST + 1;
        WHILE i <= u_tab.COUNT LOOP
            len := UTILITIES.distance(u_tab(i-1).m.xi, u_tab(i-1).m.yi, u_tab(i-1).m.xe, u_tab(i-1).m.ye);
            dur := u_tab(i-1).p.duration().m_Value;
            IF dur <> 0 THEN u1 :=  len / dur; END IF;

            len := UTILITIES.distance(u_tab(i).m.xi, u_tab(i).m.yi, u_tab(i).m.xe, u_tab(i).m.ye);
            dur := u_tab(i).p.duration().m_Value;
            IF dur <> 0 THEN u2 :=  len / dur; END IF;

            avg_acc := avg_acc + abs(u2 - u1);

            i := u_tab.NEXT(i);
        END LOOP;

        dur := TAU_TLL.D_Period_sec(u_tab(u_tab.FIRST).p.b, u_tab(u_tab.LAST).p.e).duration().m_Value;

        IF dur <> 0 THEN return avg_acc / dur;
        ELSE return 0; END IF;
    end;

    MEMBER FUNCTION f_avg_direction RETURN NUMBER is
    i pls_integer;
    dir number := 0;
    len number := 0;
    all_len number := 0;
    avg_dir number := 0;
    begin
        all_len := SDO_GEOM.SDO_LENGTH(f_trajectory2(), 0.00005);

        i := u_tab.FIRST;
        WHILE i IS NOT NULL LOOP
            dir := UTILITIES.direction(u_tab(i).m.xi, u_tab(i).m.yi, u_tab(i).m.xe, u_tab(i).m.ye);
            len := UTILITIES.distance(u_tab(i).m.xi, u_tab(i).m.yi, u_tab(i).m.xe, u_tab(i).m.ye);
            avg_dir := avg_dir + dir * (len / all_len);

            i := u_tab.NEXT(i);
        END LOOP;

        return avg_dir;
    end;

    MEMBER FUNCTION f_timepoint(line MDSYS.SDO_GEOMETRY, x number, y number, old_pos pls_integer, new_pos OUT pls_integer) return TAU_TLL.D_Timepoint_Sec is
    i           pls_integer;
    point       MDSYS.SDO_GEOMETRY;
    seg         MDSYS.SDO_GEOMETRY;
    L NUMBER := 0.0;
    v NUMBER := 0.0;
    t NUMBER := 0.0;
    ORD_COUNT   pls_integer;
    SRID pls_integer;
    begin
        --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
        srid:=self.srid;

        point := MDSYS.SDO_GEOMETRY(2001, SRID, SDO_POINT_TYPE(x, y, NULL), NULL, NULL);
        new_pos := old_pos;
        i := 2*old_pos - 1;
        ORD_COUNT := line.SDO_ORDINATES.COUNT;
        WHILE i <= ORD_COUNT - 3 LOOP
            seg := UTILITIES.f_segment(line.SDO_ORDINATES(i), line.SDO_ORDINATES(i+1), line.SDO_ORDINATES(i+2), line.SDO_ORDINATES(i+3));
            IF MDSYS.SDO_GEOM.RELATE(seg,'ANYINTERACT', point, 0.00005) = 'TRUE' THEN
                L := sqrt(power(y - u_tab(i).m.yi, 2) + power(x - u_tab(i).m.xi, 2));
                IF v <> 0 THEN t := L / v; END IF;

                new_pos := i;
                return u_tab(new_pos).p.b.f_add(u_tab(new_pos).p.b, TAU_TLL.D_Interval(t));
            END IF;
            i := line.SDO_ORDINATES.NEXT(i+1);
        END LOOP;

        --dbms_output.put_line('TIMEPOINT NOT FOUND!!!');
        return TAU_TLL.D_Timepoint_Sec(0,0,0,0,0,0);
    end;

    MEMBER FUNCTION LIP(m_point Moving_Point, trans boolean) return number is
    Q MDSYS.SDO_GEOMETRY;
    S MDSYS.SDO_GEOMETRY;
    Q_LEN       number := 0.0;
    S_LEN       number := 0.0;
    begin
        Q := f_trajectory2();
        S := m_point.f_trajectory2();
        Q_LEN := MDSYS.SDO_GEOM.SDO_LENGTH(Q, 0.00005);
        S_LEN := MDSYS.SDO_GEOM.SDO_LENGTH(S, 0.00005);
        return UTILITIES.LIP(Q, S, trans, Q_LEN, S_LEN);
    end;

    MEMBER FUNCTION STLIP(S IN OUT Moving_Point, trans boolean, t TAU_TLL.D_Interval, Q_LEN number, S_LEN   number, kapa number) return number is
    Q           Moving_Point;
    Q_TRAJ      MDSYS.SDO_GEOMETRY;
    S_TRAJ      MDSYS.SDO_GEOMETRY;
    Q_TE        TAU_TLL.D_Period_Sec;
    S_TE        TAU_TLL.D_Period_Sec;
    Q_Sec       number;
    S_Sec       number;
    intersection_TE_Sec number;
    intersection_TE TAU_TLL.D_Period_Sec;
    i           pls_integer;
    j           pls_integer := 1;
    k           pls_integer;
    m           pls_integer;
    pos         pls_integer;
    old_pos_S   pls_integer := 1;
    new_pos_S   pls_integer := 1;
    old_pos_Q   pls_integer := 1;
    new_pos_Q   pls_integer := 1;
    flag        boolean := TRUE;
    firstseg    boolean := TRUE;
    add_last    boolean := FALSE;
    seg         MDSYS.SDO_GEOMETRY;
    seg_info    MDSYS.SDO_ELEM_INFO_ARRAY;
    seg_ords    MDSYS.SDO_ORDINATE_ARRAY;
    trace       MDSYS.SDO_GEOMETRY;
    poly        MDSYS.SDO_GEOMETRY;
    poly_info   MDSYS.SDO_ELEM_INFO_ARRAY;
    poly_ords   MDSYS.SDO_ORDINATE_ARRAY;
    start_x     number := 0.0;
    start_y     number := 0.0;
    prev_x      number := 0.0;
    prev_y      number := 0.0;
    area        number := 0.0;
    all_area    number := 0.0;
    dist        number := 0.0;
    all_dist    number := 0.0;
    sim         number := 0.0;
    sum_sim     number := 0.0;
    temp_res    number := 0.0;
    IP          pls_integer := 1;
    first_time_trace_null boolean := TRUE;
    point1      MDSYS.SDO_GEOMETRY;
    point2      MDSYS.SDO_GEOMETRY;
    zerodist    boolean := FALSE;
    durationQ   number := 0.0;
    durationS   number := 0.0;
    TLIP        number := 0.0;
    all_duration number := 0.0;
    startQ_tp   TAU_TLL.D_Timepoint_Sec;
    startS_tp   TAU_TLL.D_Timepoint_Sec;
    endQ_tp     TAU_TLL.D_Timepoint_Sec;
    endS_tp     TAU_TLL.D_Timepoint_Sec;
    --Q_per       TAU_TLL.D_Period_Sec;
    --S_per       TAU_TLL.D_Period_Sec;
    --S_per_plus  TAU_TLL.D_Period_Sec;
    --S_per_minus TAU_TLL.D_Period_Sec;
    --intersection_per TAU_TLL.D_Period_Sec;
    --intersection_Sec number;
    --intersection_Sec_plus number;
    --intersection_Sec_minus number;
    mdi number;
    S_ORD_LAST  pls_integer;
    Q_ORD_COUNT pls_integer;
    SRID pls_integer;
    begin
        --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
        srid:=self.srid;

        Q_TE := TAU_TLL.D_Period_sec(u_tab(u_tab.FIRST).p.b, u_tab(u_tab.LAST).p.e);
        Q_Sec := Q_TE.duration().m_Value;
        S_TE := TAU_TLL.D_Period_sec(S.u_tab(S.u_tab.FIRST).p.b, S.u_tab(S.u_tab.LAST).p.e);
        S_Sec := S_TE.duration().m_Value;
        intersection_TE := Q_TE.intersects(Q_TE, S_TE);
        intersection_TE_Sec := intersection_TE.duration().m_Value;
        Q := at_period(intersection_TE);
        S := S.at_period(intersection_TE);
        delete debug_mpoints;
        insert into debug_mpoints(traj_id,mpoint)values(q.traj_id,q);
        insert into debug_mpoints(traj_id,mpoint)values(s.traj_id,s);
        commit;
        Q_TRAJ := Q.f_trajectory2();
        S_TRAJ := S.f_trajectory2();

        --dbms_output.put_line('INSIDE    STLIP!!!');
        --dbms_output.put_line('Q_TE=' || Q_TE.to_string());dbms_output.put_line('S_TE=' || S_TE.to_string());dbms_output.put_line('intersection_TE=' || intersection_TE.to_string());

        i := Q_TRAJ.SDO_ORDINATES.FIRST;
        start_x := Q_TRAJ.SDO_ORDINATES(i);
        start_y := Q_TRAJ.SDO_ORDINATES(i+1);
        startQ_tp := u_tab(u_tab.FIRST).p.b;
        startS_tp := startQ_tp;
        S_ORD_LAST := S_TRAJ.SDO_ORDINATES.LAST;
        IF trans THEN
            S_TRAJ := UTILITIES.transfer2(Q_TRAJ, S_TRAJ);
        ELSE
            IF MDSYS.SDO_GEOM.RELATE(Q_TRAJ,'ANYINTERACT', S_TRAJ, 0.00005) = 'FALSE' THEN
                -- Construct poly between the two trajectories
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();
                j := 1;
                WHILE j <= S_ORD_LAST LOOP
                    poly_ords.EXTEND(1);poly_ords(j) := S_TRAJ.SDO_ORDINATES(j);
                    j := j + 1;
                END LOOP;

                i := Q_TRAJ.SDO_ORDINATES.LAST;
                WHILE i >= 1 LOOP
                    poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i-1);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i);j:=j+2;
                    i := Q_TRAJ.SDO_ORDINATES.PRIOR(i-1);
                END LOOP;
                poly_ords.EXTEND(2);poly_ords(j) := poly_ords(1);poly_ords(j+1) := poly_ords(2);j:=j+2;
                poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords);
                all_area := MDSYS.SDO_GEOM.SDO_AREA(poly, 0.00005);

                IF Q_TE.e.f_b(Q_TE.e, Q_TE.b) >= 1 AND S_TE.e.f_b(S_TE.e, S_TE.b) >= 1 THEN
                    mdi := UTILITIES.compute_MDI (Q_TE.b, Q_TE.e, S_TE.b, S_TE.e, t);
                END IF;

                IF Q_LEN+S_LEN <> 0 THEN
                    TLIP := abs(1 - 2 * ( mdi / (Q_Sec + S_Sec) ) );
                    --dbms_output.put_line('NO INTERSECTION!!!');
                    --dbms_output.put_line('mdi=' || TO_CHAR(mdi));
                    --dbms_output.put_line('Q_Sec=' || TO_CHAR(Q_Sec));
                    --dbms_output.put_line('S_Sec=' || TO_CHAR(S_Sec));
                    --dbms_output.put_line('temporal LIP=' || TO_CHAR(TLIP));
                    --dbms_output.put_line('local sim=' || TO_CHAR((all_area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) * (1 + kapa * TLIP)));
                    temp_res := (all_area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) * (1 + kapa * TLIP);
                    IF temp_res IS NULL THEN return 0; ELSE return temp_res; END IF;
                ELSE return all_area; END IF;
            END IF;
        END IF;

        UTILITIES.SmoothLine(S_TRAJ);

        Q_ORD_COUNT := Q_TRAJ.SDO_ORDINATES.COUNT;
        WHILE i <= Q_ORD_COUNT - 3 LOOP
            seg  := UTILITIES.f_segment(Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1), Q_TRAJ.SDO_ORDINATES(i+2), Q_TRAJ.SDO_ORDINATES(i+3));
            point1 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1), NULL), NULL, NULL);
            point2 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_TRAJ.SDO_ORDINATES(i+2), Q_TRAJ.SDO_ORDINATES(i+3), NULL), NULL, NULL);
            IF (MDSYS.SDO_GEOM.RELATE(S_TRAJ, 'ANYINTERACT', point1, 0.00005) = 'TRUE' AND MDSYS.SDO_GEOM.RELATE(S_TRAJ, 'ANYINTERACT', point2, 0.00005) = 'TRUE') OR
               (Q_TRAJ.SDO_ORDINATES(i)=Q_TRAJ.SDO_ORDINATES(i+2) AND Q_TRAJ.SDO_ORDINATES(i+1)=Q_TRAJ.SDO_ORDINATES(i+3))
            THEN zerodist := TRUE; GOTO PROBLEM; END IF;

            IF flag THEN
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                dist := 0.0; sim := 0.0; TLIP := 0.0;
                flag := FALSE;
            END IF;

            --UTILITIES.print_geometry(seg, 'seg');UTILITIES.print_geometry(S, 'S');
            trace := MDSYS.SDO_GEOM.SDO_INTERSECTION(S_TRAJ, seg, 0.000005);    --UTILITIES.print_geometry(trace, 'trace');
            IF trace IS NOT NULL THEN
                trace := UTILITIES.f_sort(trace, seg);
                IF add_last THEN
                    poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i+1);j:=j+2;
                    dist := dist + UTILITIES.distance(Q_TRAJ.SDO_ORDINATES(i-2), Q_TRAJ.SDO_ORDINATES(i-1), Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1));
                    add_last := FALSE;
                END IF;

                k := trace.SDO_ORDINATES.FIRST;
                WHILE k IS NOT NULL LOOP
                    IF flag THEN
                        poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                        poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);
                        poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                        dist := 0.0; sim := 0.0; TLIP := 0;
                        flag := FALSE;
                    END IF;
                    dist := dist + UTILITIES.distance(poly_ords(j-2), poly_ords(j-1), trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1));
                    poly_ords.EXTEND(2);poly_ords(j) := trace.SDO_ORDINATES(k);poly_ords(j+1) := trace.SDO_ORDINATES(k+1);j:=j+2;

                    pos := UTILITIES.position(S_traj, trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1), old_pos_S);
                    m := pos;
                    WHILE old_pos_S < m LOOP
                        poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(2*m);j:=j+2;

                        m := S_TRAJ.SDO_ORDINATES.PRIOR(m);
                    END LOOP;
                    old_pos_S := pos;
                    poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

                    flag := TRUE;
                    first_time_trace_null := TRUE;
                    poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
                    area := MDSYS.SDO_GEOM.SDO_AREA(poly, 0.00005);
                    all_area := all_area + area;
                    all_dist := all_dist + dist;
                    IP := IP + 1;
                    start_x := trace.SDO_ORDINATES(k);
                    start_y := trace.SDO_ORDINATES(k+1);
                    j := 1;

                    -- Find final timepoint at new (start_x, start_y)
                    dbms_output.put_line('get_time_point at=' || start_x||','||start_y||' of traj '||q.traj_id);
                    dbms_output.put_line('get_time_point at=' || start_x||','||start_y||' of traj '||s.traj_id);
                    endQ_tp := Q.get_time_point(start_x, start_y);
                    endS_tp := S.get_time_point(start_x, start_y);
                    dbms_output.put_line('endQ_tp=' || endQ_tp.to_string());dbms_output.put_line('endS_tp=' || endS_tp.to_string()||' ok.');

                    IF endQ_tp.f_b(endQ_tp, startQ_tp) >= 1 AND endS_tp.f_b(endS_tp, startS_tp) >= 1 THEN
                        mdi := UTILITIES.compute_MDI (startQ_tp, endQ_tp, startS_tp, endS_tp, t);
                    END IF;

                    IF Q_LEN+S_LEN <> 0 THEN
                        IF endQ_tp.f_b(endQ_tp, startQ_tp) >= 1 THEN durationQ := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp).duration().m_Value;
                        ELSE durationQ := 0; END IF;
                        IF endS_tp.f_b(endS_tp, startS_tp) >= 1 THEN durationS := TAU_TLL.D_Period_sec(startS_tp, endS_tp).duration().m_Value;
                        ELSE durationS := 0; END IF;
                        IF durationQ + durationS <> 0 THEN TLIP := abs(1 - 2 * (mdi / (durationQ + durationS))); ELSE TLIP := 1; END IF;
                        sim  := (area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) * (1 + kapa * TLIP);
                    ELSE
                        sim  := 0;
                    END IF;

                    --dbms_output.put_line('durationQ=' || TO_CHAR(durationQ));
                    --dbms_output.put_line('durationS=' || TO_CHAR(durationS));
                    --dbms_output.put_line('mdi=' || TO_CHAR(mdi));
                    --dbms_output.put_line('temporal LIP=' || TO_CHAR(TLIP));
                    --dbms_output.put_line('local sim=' || TO_CHAR(sim));
                    sum_sim := sum_sim + sim;

                    startQ_tp := endQ_tp;
                    startS_tp := endS_tp;

                    k := trace.SDO_ORDINATES.NEXT(k+1);
                END LOOP;
            ELSE
                IF first_time_trace_null THEN
                    prev_x := start_x; prev_y := start_y; first_time_trace_null := FALSE;
                ELSE
                    prev_x := Q_TRAJ.SDO_ORDINATES(i-2); prev_y := Q_TRAJ.SDO_ORDINATES(i-1);
                END IF;
                IF NOT firstseg THEN poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i+1);j:=j+2; ELSE firstseg := FALSE; END IF;
                dist := dist + UTILITIES.distance(prev_x, prev_y, Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1));
            END IF;

            add_last := TRUE;firstseg := FALSE;
            <<PROBLEM>>
            i := Q_TRAJ.SDO_ORDINATES.NEXT(i+1);
            IF zerodist = TRUE AND i > Q_ORD_COUNT - 3 THEN GOTO BYPASSPROBLEM; END IF;
            zerodist := FALSE;
        END LOOP;

        -- Form the polygon after the last interesection point
        IF flag THEN
          poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
            poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
          dist := 0.0; sim := 0.0; TLIP := 0;
        END IF;
        dist := dist + UTILITIES.distance(poly_ords(j-2), poly_ords(j-1), Q_TRAJ.SDO_ORDINATES(Q_ORD_COUNT-1), Q_TRAJ.SDO_ORDINATES(Q_ORD_COUNT));
        poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(Q_ORD_COUNT-1);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(Q_ORD_COUNT);j:=j+2;

        poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(S_ORD_LAST-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(S_ORD_LAST);j:=j+2;
        pos := UTILITIES.position(S_TRAJ, S_TRAJ.SDO_ORDINATES(S_ORD_LAST-1), S_TRAJ.SDO_ORDINATES(S_ORD_LAST), old_pos_S);
    m := pos;
        WHILE old_pos_S < m LOOP
            poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(2*m);j:=j+2;

            m := S_TRAJ.SDO_ORDINATES.PRIOR(m);
        END LOOP;
        poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

        poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
        area := MDSYS.SDO_GEOM.SDO_AREA(poly, 0.00005);
        all_area := all_area + area;
        all_dist := all_dist + dist;

        endQ_tp := u_tab(u_tab.LAST).p.e;
        endS_tp := endQ_tp;
        IF endQ_tp.f_b(endQ_tp, startQ_tp) >= 1 AND endS_tp.f_b(endS_tp, startS_tp) >= 1 THEN
            mdi := UTILITIES.compute_MDI (startQ_tp, endQ_tp, startS_tp, endS_tp, t);
        END IF;

        IF Q_LEN+S_LEN <> 0 THEN
            IF endQ_tp.f_b(endQ_tp, startQ_tp) >= 1 THEN durationQ := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp).duration().m_Value;
            ELSE durationQ := 0; END IF;
            IF endS_tp.f_b(endS_tp, startS_tp) >= 1 THEN durationS := TAU_TLL.D_Period_sec(startS_tp, endS_tp).duration().m_Value;
            ELSE durationS := 0; END IF;
            IF durationQ + durationS <> 0 THEN TLIP := abs(1 - 2 * (mdi / (durationQ + durationS))); ELSE TLIP := 1; END IF;
            sim  := (area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) * (1 + kapa * TLIP);
        ELSE
            sim  := 0;
        END IF;

        --dbms_output.put_line('LAST POLYGON!!!');
        --dbms_output.put_line('durationQ=' || TO_CHAR(durationQ));
        --dbms_output.put_line('durationS=' || TO_CHAR(durationS));
        --dbms_output.put_line('mdi=' || TO_CHAR(mdi));
        --dbms_output.put_line('temporal LIP=' || TO_CHAR(TLIP));
        --dbms_output.put_line('local sim=' || TO_CHAR(sim));

        <<BYPASSPROBLEM>>
        sum_sim := sum_sim + sim;
        IF sum_sim IS NULL THEN return 0; ELSE return sum_sim; END IF;
    end;

    MEMBER FUNCTION SPSTLIP(S IN OUT Moving_Point, trans boolean, t TAU_TLL.D_Interval, Q_LEN number, S_LEN number) return number is
    Q           Moving_Point;
    Q_TRAJ      MDSYS.SDO_GEOMETRY;
    S_TRAJ      MDSYS.SDO_GEOMETRY;
    Q_TE        TAU_TLL.D_Temp_Element_Sec;
    S_TE        TAU_TLL.D_Temp_Element_Sec;
    Q_Sec       number;
    intersection_TE_Sec number;
    intersection_TE TAU_TLL.D_Temp_Element_Sec;
    i           pls_integer;
    j           pls_integer := 1;
    k           pls_integer;
    m           pls_integer;
    pos         pls_integer;
    old_pos_S   pls_integer := 1;
    new_pos_S   pls_integer := 1;
    old_pos_Q   pls_integer := 1;
    new_pos_Q   pls_integer := 1;
    flag        boolean := TRUE;
    firstseg    boolean := TRUE;
    add_last    boolean := FALSE;
    seg         MDSYS.SDO_GEOMETRY;
    seg_info    MDSYS.SDO_ELEM_INFO_ARRAY;
    seg_ords    MDSYS.SDO_ORDINATE_ARRAY;
    trace       MDSYS.SDO_GEOMETRY;
    poly        MDSYS.SDO_GEOMETRY;
    poly_info   MDSYS.SDO_ELEM_INFO_ARRAY;
    poly_ords   MDSYS.SDO_ORDINATE_ARRAY;
    start_x     number := 0.0;
    start_y     number := 0.0;
    prev_x      number := 0.0;
    prev_y      number := 0.0;
    area        number := 0.0;
    all_area    number := 0.0;
    dist        number := 0.0;
    all_dist    number := 0.0;
    S_dist      number := 0.0;
    sim         number := 0.0;
    sum_sim     number := 0.0;
    IP          pls_integer := 1;
    first_time_trace_null boolean := TRUE;
    point1      MDSYS.SDO_GEOMETRY;
    point2      MDSYS.SDO_GEOMETRY;
    zerodist    boolean := FALSE;
    duration    number := 0.0;
    temp_sim    number := 0.0;
    va_sim      number := 0.0;
    all_duration number := 0.0;
    startQ_tp   TAU_TLL.D_Timepoint_Sec;
    startS_tp   TAU_TLL.D_Timepoint_Sec;
    endQ_tp     TAU_TLL.D_Timepoint_Sec;
    endS_tp     TAU_TLL.D_Timepoint_Sec;
    Q_per       TAU_TLL.D_Period_Sec;
    S_per       TAU_TLL.D_Period_Sec;
    S_per_plus  TAU_TLL.D_Period_Sec;
    S_per_minus TAU_TLL.D_Period_Sec;
    intersection_per TAU_TLL.D_Period_Sec;
    intersection_Sec number;
    intersection_Sec_plus number;
    intersection_Sec_minus number;
    mdi number;
    SRID pls_integer;
    begin
        --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
        srid:=self.srid;

        Q_TE := f_temp_element();
        Q_Sec := Q_TE.duration().m_Value;
        S_TE := S.f_temp_element();
        intersection_TE := Q_TE.intersects(Q_TE, S_TE);
        intersection_TE_Sec := intersection_TE.duration().m_Value;
        Q := at_temp_element(intersection_TE);
       S := S.at_temp_element(intersection_TE);
        Q_TRAJ := Q.f_trajectory2();
        S_TRAJ := S.f_trajectory2();

        i := Q_TRAJ.SDO_ORDINATES.FIRST;
        start_x := Q_TRAJ.SDO_ORDINATES(i);
        start_y := Q_TRAJ.SDO_ORDINATES(i+1);
        startQ_tp := Q.get_time_point(start_x, start_y);
        startS_tp := startQ_tp;
        IF trans THEN
            S_TRAJ := UTILITIES.transfer2(Q_TRAJ, S_TRAJ);
        ELSE
            IF SDO_GEOM.RELATE(Q_TRAJ,'ANYINTERACT', S_TRAJ, 0.00005) = 'FALSE' THEN
                -- Construct poly between the two trajectories
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();
                j := 1;
                WHILE j <= S_TRAJ.SDO_ORDINATES.LAST LOOP
                    poly_ords.EXTEND(1);poly_ords(j) := S_TRAJ.SDO_ORDINATES(j);
                    j := j + 1;
                END LOOP;

                i := Q_TRAJ.SDO_ORDINATES.LAST;
                WHILE i >= 1 LOOP
                    poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i-1);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i);j:=j+2;
                    i := Q_TRAJ.SDO_ORDINATES.PRIOR(i-1);
                END LOOP;
                poly_ords.EXTEND(2);poly_ords(j) := poly_ords(1);poly_ords(j+1) := poly_ords(2);j:=j+2;
                poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
                all_area := SDO_GEOM.SDO_AREA(poly, 0.00005);

                IF Q_LEN+S_LEN <> 0 THEN
                    return (all_area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) / ((intersection_TE_Sec / Q_Sec) * (1 - (ABS(Q_LEN - S_LEN) / Q_LEN)));
                ELSE
                    return all_area;
                END IF;
            END IF;
        END IF;

        UTILITIES.SmoothLine(S_TRAJ);
        WHILE i <= Q_TRAJ.SDO_ORDINATES.COUNT - 3 LOOP
            seg  := UTILITIES.f_segment(Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1), Q_TRAJ.SDO_ORDINATES(i+2), Q_TRAJ.SDO_ORDINATES(i+3));
            point1 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1), NULL), NULL, NULL);
            point2 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_TRAJ.SDO_ORDINATES(i+2), Q_TRAJ.SDO_ORDINATES(i+3), NULL), NULL, NULL);
            IF (MDSYS.SDO_GEOM.RELATE(S_TRAJ, 'ANYINTERACT', point1, 0.00005) = 'TRUE' AND MDSYS.SDO_GEOM.RELATE(S_TRAJ, 'ANYINTERACT', point2, 0.00005) = 'TRUE') OR
               (Q_TRAJ.SDO_ORDINATES(i)=Q_TRAJ.SDO_ORDINATES(i+2) AND Q_TRAJ.SDO_ORDINATES(i+1)=Q_TRAJ.SDO_ORDINATES(i+3))
            THEN zerodist := TRUE; GOTO PROBLEM; END IF;

            IF flag THEN
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                dist := 0.0; sim := 0.0; temp_sim := 0.0;  va_sim := 0.0;
                flag := FALSE;
            END IF;

            trace := MDSYS.SDO_GEOM.SDO_INTERSECTION(S_TRAJ, seg, 0.000005);
            IF trace IS NOT NULL THEN
                trace := UTILITIES.f_sort(trace, seg);
                IF add_last THEN
                    poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i+1);j:=j+2;
                    dist := dist + UTILITIES.distance(Q_TRAJ.SDO_ORDINATES(i-2), Q_TRAJ.SDO_ORDINATES(i-1), Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1));
                    add_last := FALSE;
                END IF;

                k := trace.SDO_ORDINATES.FIRST;
                WHILE k IS NOT NULL LOOP
                    IF flag THEN
                        poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                        poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);
                        poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                        dist := 0.0; sim := 0.0; temp_sim := 0;  va_sim := 0.0;
                        flag := FALSE;
                    END IF;
                    dist := dist + UTILITIES.distance(poly_ords(j-2), poly_ords(j-1), trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1));
                    poly_ords.EXTEND(2);poly_ords(j) := trace.SDO_ORDINATES(k);poly_ords(j+1) := trace.SDO_ORDINATES(k+1);j:=j+2;

                    pos := UTILITIES.position(S_traj, trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1), old_pos_S);
                    m := pos;
                    WHILE old_pos_S < m LOOP
                        poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(2*m);j:=j+2;

                        m := S_TRAJ.SDO_ORDINATES.PRIOR(m);
                    END LOOP;
                    old_pos_S := pos;
                    poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

                    flag := TRUE;
                    first_time_trace_null := TRUE;
                    poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords);
                    area := MDSYS.SDO_GEOM.SDO_AREA(poly, 0.00005);
                    all_area := all_area + area;
                    all_dist := all_dist + dist;
                    IP := IP + 1;
                    start_x := trace.SDO_ORDINATES(k);
                    start_y := trace.SDO_ORDINATES(k+1);
                    j := 1;

                    -- Find final timepoint at new (start_x, start_y)
                    endQ_tp := Q.get_time_point(start_x, start_y);
                    endS_tp := S.get_time_point(start_x, start_y);
                    Q_per := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp);
                    S_per := TAU_TLL.D_Period_sec(startS_tp, endS_tp);
                    S_per_plus := S_per;
                    S_per_minus := S_per;
                    intersection_per := Q_per.intersects(Q_per, S_per);
                    intersection_Sec := intersection_per.duration().m_Value;
                    mdi := intersection_Sec;
                    S_per_plus.f_add_interval(t);
                    S_per_minus.f_sub_interval(t);
                    intersection_per := Q_per.intersects(Q_per, S_per_plus);
                    intersection_Sec_plus := intersection_per.duration().m_Value;
                    IF intersection_Sec_plus > mdi THEN mdi := intersection_Sec_plus; END IF;
                    intersection_per := Q_per.intersects(Q_per, S_per_minus);
                    intersection_Sec_minus := intersection_per.duration().m_Value;
                    IF intersection_Sec_minus > mdi THEN mdi := intersection_Sec_minus; END IF;

                    S_dist := SDO_GEOM.SDO_LENGTH(S.at_period(TAU_TLL.D_Period_sec(startQ_tp, endQ_tp)).f_trajectory2(), 0.00005);

                    IF Q_LEN+S_LEN <> 0 THEN
                        duration := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp).duration().m_Value;
                        IF duration <> 0 THEN temp_sim := (mdi / duration); ELSE temp_sim := 0; END IF;
                        va_sim := 1 - (ABS(dist - S_dist) / dist);
                        IF temp_sim <> 0 AND va_sim <> 0 THEN
                            sim  := (area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) / (temp_sim * va_sim);
                        END IF;
                    ELSE
                       sim  := 0;
                    END IF;

                    sum_sim := sum_sim + sim;

                    startQ_tp := endQ_tp;
                    startS_tp := endS_tp;
                    S_dist := 0;

                    k := trace.SDO_ORDINATES.NEXT(k+1);
                END LOOP;
            ELSE
                IF first_time_trace_null THEN
                    prev_x := start_x; prev_y := start_y; first_time_trace_null := FALSE;
                ELSE
                    prev_x := Q_TRAJ.SDO_ORDINATES(i-2); prev_y := Q_TRAJ.SDO_ORDINATES(i-1);
                END IF;
                IF NOT firstseg THEN poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(i);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(i+1);j:=j+2; ELSE firstseg := FALSE; END IF;
                dist := dist + UTILITIES.distance(prev_x, prev_y, Q_TRAJ.SDO_ORDINATES(i), Q_TRAJ.SDO_ORDINATES(i+1));
            END IF;

            add_last := TRUE;firstseg := FALSE;
            <<PROBLEM>>
            i := Q_TRAJ.SDO_ORDINATES.NEXT(i+1);
            IF zerodist = TRUE AND i > Q_TRAJ.SDO_ORDINATES.COUNT - 3 THEN GOTO BYPASSPROBLEM; END IF;
            zerodist := FALSE;
        END LOOP;

        -- Form the polygon after the last interesection point
        IF flag THEN
            poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
            poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
            dist := 0.0; sim := 0.0; temp_sim := 0;  va_sim := 0.0;
        END IF;
        dist := dist + UTILITIES.distance(poly_ords(j-2), poly_ords(j-1), Q_TRAJ.SDO_ORDINATES(Q_TRAJ.SDO_ORDINATES.LAST-1), Q_TRAJ.SDO_ORDINATES(Q_TRAJ.SDO_ORDINATES.LAST));
        poly_ords.EXTEND(2);poly_ords(j) := Q_TRAJ.SDO_ORDINATES(Q_TRAJ.SDO_ORDINATES.LAST-1);poly_ords(j+1) := Q_TRAJ.SDO_ORDINATES(Q_TRAJ.SDO_ORDINATES.LAST);j:=j+2;

        poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(S_TRAJ.SDO_ORDINATES.LAST-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(S_TRAJ.SDO_ORDINATES.LAST);j:=j+2;
        pos := UTILITIES.position(S_TRAJ, S_TRAJ.SDO_ORDINATES(S_TRAJ.SDO_ORDINATES.LAST-1), S_TRAJ.SDO_ORDINATES(S_TRAJ.SDO_ORDINATES.LAST), old_pos_S);
        m := pos;
        WHILE old_pos_S < m LOOP
            poly_ords.EXTEND(2);poly_ords(j) := S_TRAJ.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S_TRAJ.SDO_ORDINATES(2*m);j:=j+2;

            m := S_TRAJ.SDO_ORDINATES.PRIOR(m);
        END LOOP;
        poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

        poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
        area := MDSYS.SDO_GEOM.SDO_AREA(poly, 0.00005);
        all_area := all_area + area;
        all_dist := all_dist + dist;

        endQ_tp := Q.u_tab(u_tab.LAST).p.e;
        endS_tp := endQ_tp;
        Q_per := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp);
        S_per := TAU_TLL.D_Period_sec(startS_tp, endS_tp);
        S_per_plus := S_per;
        S_per_minus := S_per;
        intersection_per := Q_per.intersects(Q_per, S_per);
        intersection_Sec := intersection_per.duration().m_Value;
        mdi := intersection_Sec;
        S_per_plus.f_add_interval(t);
        S_per_minus.f_sub_interval(t);
        intersection_per := Q_per.intersects(Q_per, S_per_plus);
        intersection_Sec_plus := intersection_per.duration().m_Value;
        IF intersection_Sec_plus > mdi THEN mdi := intersection_Sec_plus; END IF;
        intersection_per := Q_per.intersects(Q_per, S_per_minus);
        intersection_Sec_minus := intersection_per.duration().m_Value;
        IF intersection_Sec_minus > mdi THEN mdi := intersection_Sec_minus; END IF;

        S_dist := SDO_GEOM.SDO_LENGTH(S.at_period(TAU_TLL.D_Period_sec(startQ_tp, endQ_tp)).f_trajectory2(), 0.00005);

        IF Q_LEN+S_LEN <> 0 THEN
            duration := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp).duration().m_Value;
            IF duration <> 0 THEN temp_sim := (mdi / duration); ELSE temp_sim := 0; END IF;
            va_sim := 1 - (ABS(dist - S_dist) / dist);
            IF temp_sim <> 0 AND va_sim <> 0 THEN
                sim  := (area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN))) / (temp_sim * va_sim);
            END IF;
        ELSE
           sim  := 0;
        END IF;

        <<BYPASSPROBLEM>>
        sum_sim := sum_sim + sim;
        return sum_sim;
    end;
    --
    --
    MEMBER FUNCTION DDIST(m_point Moving_Point, policy pls_integer) return number is
    Q MDSYS.SDO_GEOMETRY;
    S MDSYS.SDO_GEOMETRY;
    begin
        Q := f_trajectory2();
        s := m_point.f_trajectory2();
        return UTILITIES.DDIST(Q, S, policy);
    end;

    MEMBER FUNCTION TDDIST(S IN OUT Moving_Point, policy pls_integer) return number is
    Q           Moving_Point;
    Q_tmp       Moving_Point;
    S_tmp       Moving_Point;
    Q_TE        TAU_TLL.D_Period_Sec;
    S_TE        TAU_TLL.D_Period_Sec;
    I_TE        TAU_TLL.D_Period_Sec;
    I_TE_2      TAU_TLL.D_Temp_ELement_Sec;
    Q_TRAJ      MDSYS.SDO_GEOMETRY;
    S_TRAJ      MDSYS.SDO_GEOMETRY;
    Q_traj_pro  MDSYS.SDO_GEOMETRY;
    S_traj_pro  MDSYS.SDO_GEOMETRY;
    Q_traj_meta MDSYS.SDO_GEOMETRY;
    S_traj_meta MDSYS.SDO_GEOMETRY;
    sim         number := 0.0;
    all_sim     number := 0.0;
    i           pls_integer;
    begin
        Q_TE := TAU_TLL.D_Period_sec(u_tab(u_tab.FIRST).p.b, u_tab(u_tab.LAST).p.e);         --dbms_output.put_line('Q_TE=' || Q_TE.to_string());
        S_TE := TAU_TLL.D_Period_sec(S.u_tab(S.u_tab.FIRST).p.b, S.u_tab(S.u_tab.LAST).p.e); --dbms_output.put_line('S_TE=' || S_TE.to_string());

        IF Q_TE.b.f_b(Q_TE.b, S_TE.e) >= 1 OR S_TE.b.f_b(S_TE.b, Q_TE.e) >= 1 THEN
            Q_TRAJ := at_period(Q_TE).f_trajectory2(); S_TRAJ := S.at_period(S_TE).f_trajectory2();
            sim := UTILITIES.DDIST(Q_TRAJ, S_TRAJ, policy) * 2;
            return sim;
        ELSE
            I_TE := Q_TE.intersects(Q_TE, S_TE);                   --dbms_output.put_line('I_TE=' || I_TE.to_string());
        END IF;

        IF I_TE IS NOT NULL THEN
            IF I_TE.b.f_b(I_TE.b, u_tab(u_tab.FIRST).p.b) >= 1 OR I_TE.b.f_b(I_TE.b, S.u_tab(S.u_tab.FIRST).p.b) >= 1 THEN
                IF I_TE.b.f_b(I_TE.b, u_tab(u_tab.FIRST).p.b) >= 1 THEN
                    Q_traj_pro := at_period(TAU_TLL.D_Period_Sec(u_tab(u_tab.FIRST).p.b, I_TE.b)).f_trajectory2();
                ELSE
                    Q_traj_pro := at_period(Q_TE).f_trajectory2();
                END IF;
                IF I_TE.b.f_b(I_TE.b, S.u_tab(S.u_tab.FIRST).p.b) >= 1 THEN
                    S_traj_pro := S.at_period(TAU_TLL.D_Period_Sec(S.u_tab(S.u_tab.FIRST).p.b, I_TE.b)).f_trajectory2();
                ELSE
                    S_traj_pro := S.f_trajectory2();
                END IF;
                IF SDO_GEOM.SDO_LENGTH(Q_traj_pro, 0.00005) <> 0 AND SDO_GEOM.SDO_LENGTH(S_traj_pro, 0.00005) <> 0 THEN
                    all_sim := all_sim + UTILITIES.DDIST(Q_traj_pro, S_traj_pro, policy) * 2;
                END IF;
            END IF;
            IF u_tab(u_tab.LAST).p.e.f_b(u_tab(u_tab.LAST).p.e, I_TE.e) >= 1 OR S.u_tab(S.u_tab.LAST).p.e.f_b(S.u_tab(S.u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                IF u_tab(u_tab.LAST).p.e.f_b(u_tab(u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                    Q_traj_meta := at_period(TAU_TLL.D_Period_Sec(I_TE.e, u_tab(u_tab.LAST).p.e)).f_trajectory2();
                ELSE
                    Q_traj_meta := at_period(Q_TE).f_trajectory2();
                END IF;
                IF S.u_tab(S.u_tab.LAST).p.e.f_b(S.u_tab(S.u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                    S_traj_meta := S.at_period(TAU_TLL.D_Period_Sec(I_TE.e, S.u_tab(S.u_tab.LAST).p.e)).f_trajectory2();
                ELSE
                    S_traj_meta := S.f_trajectory2();
                END IF;
                IF SDO_GEOM.SDO_LENGTH(Q_traj_pro, 0.00005) <> 0 AND SDO_GEOM.SDO_LENGTH(S_traj_pro, 0.00005) <> 0 THEN
                    all_sim := all_sim + UTILITIES.DDIST(Q_traj_pro, S_traj_pro, policy) * 2;
                END IF;
            END IF;

        Q := at_period(I_TE);
        IF Q IS NOT NULL AND S IS NOT NULL THEN
            S := S.at_period(I_TE);
        ELSE
            return sim; dbms_output.put_line('ERROR null reference 1');
        END IF;

        I_TE_2 := Q.f_temp_element();           --dbms_output.put_line(TO_CHAR(I_TE_2.te.COUNT));
        i := I_TE_2.te.FIRST;
        WHILE i IS NOT NULL LOOP
            Q_tmp := Q.at_period(I_TE_2.te(i));
            S_tmp := S.at_period(I_TE_2.te(i));
            --dbms_output.put_line('PERIOD = ' || I_TE_2.te(i).to_string());
            IF Q_tmp IS NOT NULL AND S_tmp IS NOT NULL THEN
                Q_TRAJ := Q_tmp.f_trajectory2();
                S_TRAJ := S_tmp.f_trajectory2();
                sim := UTILITIES.DDIST(Q_TRAJ, S_TRAJ, policy);
                all_sim := all_sim + sim;
            END IF;

            i := I_TE_2.te.NEXT(i);
        END LOOP;
        END IF;

        IF I_TE_2.te.COUNT <> 0 THEN return all_sim / I_TE_2.te.COUNT;
        ELSE return all_sim; END IF;

    end;

    MEMBER FUNCTION GenSTLIP_OSP(S_M IN OUT Moving_Point, trans boolean, policy pls_integer, Q_LEN number, S_LEN number, kapa number, delta number) return number is
    Q_M         Moving_Point;
    Q_pro       Moving_Point;
    Q_meta      Moving_Point;
    S_pro       Moving_Point;
    S_meta      Moving_Point;
    Q_traj_pro  MDSYS.SDO_GEOMETRY;
    Q_traj_meta MDSYS.SDO_GEOMETRY;
    S_traj_pro  MDSYS.SDO_GEOMETRY;
    S_traj_meta MDSYS.SDO_GEOMETRY;
    Q_TE        TAU_TLL.D_Period_Sec;
    S_TE        TAU_TLL.D_Period_Sec;
    I_TE        TAU_TLL.D_Period_Sec;
    Q           MDSYS.SDO_GEOMETRY;
    S           MDSYS.SDO_GEOMETRY;
    NewQ_ords   MDSYS.SDO_ORDINATE_ARRAY;
    NewS_ords   MDSYS.SDO_ORDINATE_ARRAY;
    Q_seg       MDSYS.SDO_GEOMETRY;
    Q_line      MDSYS.SDO_GEOMETRY;
    Q_line_info MDSYS.SDO_ELEM_INFO_ARRAY;
    Q_line_ords MDSYS.SDO_ORDINATE_ARRAY;
    S_seg       MDSYS.SDO_GEOMETRY;
    S_line      MDSYS.SDO_GEOMETRY;
    S_line_info MDSYS.SDO_ELEM_INFO_ARRAY;
    S_line_ords MDSYS.SDO_ORDINATE_ARRAY;
    Q_line_mov  Moving_Point;
    S_line_mov  Moving_Point;
    sim         number := 0.0;
    result      number := 0.0;
    last_Qx     number := 0.0;
    last_Qy     number := 0.0;
    last_Sx     number := 0.0;
    last_Sy     number := 0.0;
    Qj          pls_integer := 1;
    Sj          pls_integer := 1;
    last_good_Q pls_integer := 1;
    last_good_S pls_integer := 1;
    bad_Q       pls_integer := 1;
    bad_S       pls_integer := 1;
    i           pls_integer;
    k           pls_integer;
    j           pls_integer;
    q_counter   pls_integer;
    s_counter   pls_integer;
    c           pls_integer;
    cc          pls_integer := 1;
    m           pls_integer;
    QSfinish    boolean := false;
    Q_ORD_COUNT pls_integer;
    S_ORD_COUNT pls_integer;
    Q_start     MDSYS.SDO_GEOMETRY;
    Q_end       MDSYS.SDO_GEOMETRY;
    S_start     MDSYS.SDO_GEOMETRY;
    S_end       MDSYS.SDO_GEOMETRY;
    fi          number := 0.0;
    dir         number := 0.0;
    cost        number := 0.0;
    SRID pls_integer;
    begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      Q_TE := TAU_TLL.D_Period_sec(u_tab(u_tab.FIRST).p.b, u_tab(u_tab.LAST).p.e);                 --dbms_output.put_line('Q_TE=' || Q_TE.to_string());
        S_TE := TAU_TLL.D_Period_sec(S_M.u_tab(S_M.u_tab.FIRST).p.b, S_M.u_tab(S_M.u_tab.LAST).p.e); --dbms_output.put_line('S_TE=' || S_TE.to_string());

    IF Q_TE.b.f_b(Q_TE.b, S_TE.e) >= 1 OR S_TE.b.f_b(S_TE.b, Q_TE.e) >= 1 THEN
            Q := at_period(Q_TE).f_trajectory2(); S := S_M.at_period(S_TE).f_trajectory2();--dbms_output.put_line('***result***=' || to_char(result));
            result := result + (utilities.GenLIP(Q, S, false, policy, Q_LEN, S_LEN)) * (1 + kapa * 1) * 2;
            return result;
        ELSE
            I_TE := Q_TE.intersects(Q_TE, S_TE);                   --dbms_output.put_line('I_TE=' || I_TE.to_string());
        END IF;

        IF I_TE IS NOT NULL THEN
        IF trans = TRUE THEN
            IF I_TE.b.f_b(I_TE.b, u_tab(u_tab.FIRST).p.b) >= 1 OR I_TE.b.f_b(I_TE.b, S_M.u_tab(S_M.u_tab.FIRST).p.b) >= 1 THEN
                IF I_TE.b.f_b(I_TE.b, u_tab(u_tab.FIRST).p.b) >= 1 THEN
                    Q_pro := at_period(TAU_TLL.D_Period_Sec(u_tab(u_tab.FIRST).p.b, I_TE.b));
                    Q_traj_pro := Q_pro.f_trajectory2();
                ELSE
                    Q_traj_pro := at_period(Q_TE).f_trajectory2();
                END IF;
                IF I_TE.b.f_b(I_TE.b, S_M.u_tab(S_M.u_tab.FIRST).p.b) >= 1 THEN
                    S_pro := S_M.at_period(TAU_TLL.D_Period_Sec(S_M.u_tab(S_M.u_tab.FIRST).p.b, I_TE.b));
                    S_traj_pro := S_pro.f_trajectory2();
                ELSE
                    S_traj_pro := S_M.f_trajectory2();
                END IF;
                result := result + (utilities.GenLIP(Q_traj_pro, S_traj_pro, FALSE, policy, Q_LEN, S_LEN)) * (1 + kapa * 1) * 2;
            END IF;
            IF u_tab(u_tab.LAST).p.e.f_b(u_tab(u_tab.LAST).p.e, I_TE.e) >= 1 OR S_M.u_tab(S_M.u_tab.LAST).p.e.f_b(S_M.u_tab(S_M.u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                IF u_tab(u_tab.LAST).p.e.f_b(u_tab(u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                    Q_meta := at_period(TAU_TLL.D_Period_Sec(I_TE.e, u_tab(u_tab.LAST).p.e));
                    Q_traj_meta := Q_meta.f_trajectory2();
                ELSE
                    Q_traj_meta := at_period(Q_TE).f_trajectory2();
                END IF;
                IF S_M.u_tab(S_M.u_tab.LAST).p.e.f_b(S_M.u_tab(S_M.u_tab.LAST).p.e, I_TE.e) >= 1 THEN
                    S_meta := S_M.at_period(TAU_TLL.D_Period_Sec(I_TE.e, S_M.u_tab(S_M.u_tab.LAST).p.e));
                    S_traj_meta := S_meta.f_trajectory2();
                ELSE
                    S_traj_meta := S_M.f_trajectory2();
                END IF;
                result := result + (utilities.GenLIP(Q_traj_meta, S_traj_meta, FALSE, policy, Q_LEN, S_LEN)) * (1 + kapa * 1) * 2;
            END IF;
        END IF;

        Q_M := at_period(I_TE);
        IF Q_M IS NOT NULL AND S_M IS NOT NULL THEN
            S_M := S_M.at_period(I_TE);
        ELSE
            return result; dbms_output.put_line('ERROR null reference 1');
        END IF;

        Q := Q_M.f_trajectory2();
        IF Q IS NOT NULL AND S_M IS NOT NULL THEN
            S := S_M.f_trajectory2();
        ELSE
            return result; dbms_output.put_line('ERROR null reference 2');
        END IF;

        --fraction := fraction + (Q_LEN - SDO_GEOM.SDO_LENGTH(Q, 0.00005) + S_LEN - SDO_GEOM.SDO_LENGTH(Q, 0.00005)) / (Q_LEN + S_LEN);

        --UTILITIES.print_geometry(Q,'Q');UTILITIES.print_geometry(S,'S');
        IF trans THEN
            S := UTILITIES.transfer2(Q, S); --UTILITIES.print_geometry(S,'S_transfered');
            S_M := Q_M.transfer2(Q_M, S_M);
        END IF;

        q_counter := Q.SDO_ORDINATES.FIRST;
        s_counter := S.SDO_ORDINATES.FIRST;
        Q_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();Q_line_info.EXTEND(3);Q_line_info(1) := 1;Q_line_info(2) := 2;Q_line_info(3) := 1;Q_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
        S_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();S_line_info.EXTEND(3);S_line_info(1) := 1;S_line_info(2) := 2;S_line_info(3) := 1;S_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);
        Q_ORD_COUNT := Q.SDO_ORDINATES.COUNT; S_ORD_COUNT := S.SDO_ORDINATES.COUNT;
        WHILE q_counter <= Q_ORD_COUNT - 3 AND s_counter <= S_ORD_COUNT - 3 LOOP
            Q_seg  := UTILITIES.f_segment(Q.SDO_ORDINATES(q_counter), Q.SDO_ORDINATES(q_counter+1), Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3));
            S_seg  := UTILITIES.f_segment(S.SDO_ORDINATES(s_counter), S.SDO_ORDINATES(s_counter+1), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3));

          Q_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_seg.SDO_ORDINATES(1), Q_seg.SDO_ORDINATES(2), NULL), NULL, NULL);
          Q_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_seg.SDO_ORDINATES(3), Q_seg.SDO_ORDINATES(4), NULL), NULL, NULL);
          S_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(1), S_seg.SDO_ORDINATES(2), NULL), NULL, NULL);
          S_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(3), S_seg.SDO_ORDINATES(4), NULL), NULL, NULL);
          fi := UTILITIES.angle3(Q_start, Q_end, S_start, S_end);

          IF fi > 90 THEN
            dir := 1 - ((cos(fi) + 1) / 2);
            cost := UTILITIES.transfer_cost(Q_seg, S_seg, dir);
            result := result + cost;
            q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
            s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);
            GOTO RECALL;
          END IF;

          IF SDO_GEOM.RELATE(Q_seg,'ANYINTERACT', S_seg, 0.00005) = 'TRUE' THEN
                last_good_Q := (q_counter + 1) / 2;
                last_good_S := (s_counter + 1) / 2;
                Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;
                S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;
            ELSE
          Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
          S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
          IF UTILITIES.BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
                bad_Q := (q_counter + 1) / 2;
            bad_S := (s_counter + 1) / 2;
            k := 1;
            WHILE k <= policy LOOP
              IF q_counter <= Q_ORD_COUNT - 5 AND s_counter <= S_ORD_COUNT - 5 THEN
                            q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
                            Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
                            Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);

                IF UTILITIES.BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
                  bad_Q := (q_counter + 1) / 2;
                  bad_S := (s_counter + 1) / 2;
                ELSE
                  last_good_Q := (q_counter + 1) / 2;
                  last_good_S := (s_counter + 1) / 2;
                  Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;
                  q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
                  S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;
                                s_counter := S.SDO_ORDINATES.NEXT(s_counter+1);
                    exit;
                END IF;
              ELSE
                    QSfinish := true;
                    exit;
              END IF;
              k := k + 1;
            END LOOP;

              IF k < policy + 1 AND QSfinish = false THEN
                m := 1;
                WHILE m < k AND s_counter <= S_ORD_COUNT - 5 LOOP
                  s_counter := S.SDO_ORDINATES.NEXT(s_counter+1);
                  S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
                  S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                  m := m+1;
                END LOOP;

                WHILE m > 1 LOOP
                  last_Qx := Q.SDO_ORDINATES(Q_ORD_COUNT-1); last_Qy := Q.SDO_ORDINATES(Q_ORD_COUNT);
                  Q_line_ords.TRIM(2); Qj:=Qj-2; q_counter := q_counter-2; Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
                  S_line_ords.TRIM(2); Sj:=Sj-2; s_counter := s_counter-2; S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                  IF UTILITIES.BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
                    bad_Q := (q_counter + 1) / 2;
                    bad_S := (s_counter + 1) / 2;
                  ELSE
                    s_counter := S.SDO_ORDINATES.NEXT(s_counter+1);
                    S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
                    S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                    last_good_S := (s_counter + 1) / 2;
                    Q_line_ords.EXTEND(2);Q_line_ords(Qj) := last_Qx;Q_line_ords(Qj+1) := last_Qy;Qj:=Qj+2;
                    Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
                    exit;
                  END IF;
                  m := m-1;
                END LOOP;

                GOTO ENDLOOP;
              ELSE
                IF QSfinish = false THEN
                   WHILE bad_Q-1 > last_good_Q LOOP
                    Q_line_ords.TRIM(2); Qj:=Qj-2; q_counter := q_counter-2; --Q_line := MDSYS.SDO_GEOMETRY(2002, NULL, NULL, Q_line_info, Q_line_ords);
                    bad_Q := bad_Q - 1;
                  END LOOP;
                  WHILE bad_S-1 > last_good_S LOOP
                    S_line_ords.TRIM(2); Sj:=Sj-2; s_counter := s_counter-2; --S_line := MDSYS.SDO_GEOMETRY(2002, NULL, NULL, S_line_info, S_line_ords);
                    bad_S := bad_S - 1;
                  END LOOP;
                END IF;
                GOTO RECALL;
              END IF;
                ELSE
                last_good_Q := (q_counter + 1) / 2;
                last_good_S := (s_counter + 1) / 2;
                    Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;
                    S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;
                END IF;
            END IF;
            <<ENDLOOP>>
      q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
            s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);
        END LOOP;

        <<RECALL>>
        Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
        S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);

        --utilities.print_geometry(Q_M.f_trajectory2(),'Q_M');utilities.print_geometry(S_M.f_trajectory2(),'S_M');
        --utilities.print_geometry(Q_line,'Q_line');utilities.print_geometry(S_line,'S_line');

        if Q_m is null then
          return result;
        else
          Q_line_mov := Q_m.at_linestring(Q_line);
        end if;
        if S_m is null then
          return result;
        else
          S_line_mov := S_m.at_linestring(S_line);
        end if;

        --utilities.print_geometry(Q_line_mov.f_trajectory2(),'Q_line_mov');utilities.print_geometry(S_line_mov.f_trajectory2(),'S_line_mov');
        IF Q_line_mov IS NOT NULL AND S_line_mov IS NOT NULL THEN
            sim := Q_line_mov.STLIP(S_line_mov, false, TAU_TLL.D_Interval(delta), Q_LEN, S_LEN, kapa);
            result := result + sim;
        END IF;

        IF q_counter <= Q_ORD_COUNT - 3 AND s_counter <= S_ORD_COUNT - 3 THEN
            NewQ_ords := MDSYS.SDO_ORDINATE_ARRAY();
            FOR c IN q_counter .. Q_ORD_COUNT LOOP
                NewQ_ords.EXTEND(1); NewQ_ords(cc) := Q.SDO_ORDINATES(c); cc := cc + 1;
            END LOOP;
            Q := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q.SDO_ELEM_INFO, NewQ_ords);

            cc := 1;
            NewS_ords := MDSYS.SDO_ORDINATE_ARRAY();
            FOR c IN s_counter .. S_ORD_COUNT LOOP
                NewS_ords.EXTEND(1); NewS_ords(cc) := S.SDO_ORDINATES(c); cc := cc + 1;
            END LOOP;
            S := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S.SDO_ELEM_INFO, NewS_ords);

            --UTILITIES.print_geometry(Q,'REST Q');UTILITIES.print_geometry(S,'REST S');

            Q_m := Q_m.at_linestring(Q);
            S_m := S_m.at_linestring(S);

            --utilities.print_geometry(Q_m.f_trajectory2(),'Q_m NEW');utilities.print_geometry(S_m.f_trajectory2(),'S_m NEW');
            IF Q_m IS NULL OR S_m IS NULL THEN
                return result;
            END IF;
            result := result + Q_m.GenSTLIP_OSP(S_m, false, policy, Q_LEN, S_LEN, kapa, delta);
        END IF;

        ELSE
            Q := Q_M.f_trajectory2(); S := S_M.f_trajectory2();--dbms_output.put_line('***result***=' || to_char(result));
            result := result + (utilities.GenLIP(Q, S, false, policy, Q_LEN, S_LEN)) * (1 + kapa * 1);
        END IF;

        return result;
    end;
  MEMBER FUNCTION f_max_speed RETURN NUMBER IS
  i NUMBER;
  tmp_speed NUMBER;
  max_speed NUMBER;
BEGIN
  max_speed := 0;
  i := u_tab.FIRST;
  WHILE i IS NOT NULL LOOP
    --tmp_speed := UTILITIES.distance(u_tab(i).m.xi, u_tab(i).m.yi, u_tab(i).m.xe, u_tab(i).m.ye) / u_tab(i).p.duration().m_Value;
    tmp_speed:=mdsys.sdo_geom.sdo_distance(
       mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xi,u_tab(i).m.yi,null),null,null),
       mdsys.sdo_geometry(2001,self.srid,sdo_point_type(u_tab(i).m.xe,u_tab(i).m.ye,null),null,null),
       0.0005) / u_tab(i).p.duration().m_Value;
    IF tmp_speed > max_speed THEN
      max_speed := tmp_speed;
    END IF;

    i := u_tab.NEXT(i);
  END LOOP;

  RETURN max_speed;
END;

 MEMBER FUNCTION number_of_times_close(tr2 moving_point, thr NUMBER, tol NUMBER) RETURN NUMBER IS
   mpoints mp_array;
   timepoints tau_timepoint_ntab:=tau_timepoint_ntab();
   i integer;times integer;
   j integer;
   atmpoint1 sdo_geometry;
   atmpoint2 sdo_geometry;
   distance number;
   cnt NUMBER := 0;
BEGIN
  i:=self.u_tab.first;
  j:=tr2.u_tab.first;
  --build ordered times
  --move in both timepoints
  while (i is not null) and (j is not null) loop
    if (self.u_tab(i).p.b.get_abs_date() < tr2.u_tab(j).p.b.get_abs_date()) then
      timepoints.extend;
      timepoints(timepoints.last):=self.u_tab(i).p.b;
      i:=self.u_tab.next(i);
    elsif (self.u_tab(i).p.b.get_abs_date() > tr2.u_tab(j).p.b.get_abs_date()) then
      timepoints.extend;
      timepoints(timepoints.last):=tr2.u_tab(j).p.b;
      j:=tr2.u_tab.next(j);
    else
      timepoints.extend;
      timepoints(timepoints.last):=self.u_tab(i).p.b;
      i:=self.u_tab.next(i);
      j:=tr2.u_tab.next(j);
    end if;
  end loop;
  --add rest timepoints
  if (i is null) then
    while (j is not null) loop
      timepoints.extend;
      timepoints(timepoints.last):=tr2.u_tab(j).p.b;
      j:=tr2.u_tab.next(j);
    end loop;
    --also final timepoint
    timepoints.extend;
    timepoints(timepoints.last):=tr2.u_tab(tr2.u_tab.last).p.e;
  else--j is null
    while (i is not null) loop
      timepoints.extend;
      timepoints(timepoints.last):=self.u_tab(i).p.b;
      i:=self.u_tab.next(i);
    end loop;
    --also final timepoint
    timepoints.extend;
    timepoints(timepoints.last):=self.u_tab(self.u_tab.last).p.e;
  end if;
  times:=timepoints.count;
  --pass trajs as array and times to re_sample, get result to another array
  mpoints:=mp_array(self,tr2);
  --expect two mpoints in result
  select re_sample(mpoints,timepoints)--this cause table function not allowed in plsql scope
    into mpoints
    from dual;
  if (mpoints.count<>2) then
    dbms_output.put_line('Re_sample returned unexpected number of moving points');
    return -1;
  end if;
  --for each ordered time
  for t in timepoints.first..timepoints.last loop
  --if at_instant not null for both
    atmpoint1:=mpoints(1).at_instant(timepoints(t));
    atmpoint2:=mpoints(2).at_instant(timepoints(t));
    if (atmpoint1 is not null) and (atmpoint2 is not null) then
    --if distance below thr
      distance:=sdo_geom.sdo_distance(atmpoint1,atmpoint2,tol);
      dbms_output.put_line(distance);
      if (distance < thr) then
      --add to solution
        cnt:=cnt+1;
      end if;
    end if;
  end loop;
  return cnt;
END number_of_times_close;
  
  member function mass_center return sp_pos is
    center sp_pos:=sp_pos(0.0,0.0);
    complex varchar2(3):='yes';
  begin
    if (complex='no') then
      null;
    else
      --assume zero area for a line
      for i in self.u_tab.first..self.u_tab.last loop
          if ( i = 1) then--first tab =>middle
            center.x:=(u_tab(i).m.xi + u_tab(i).m.xe)/2;
            center.y:=(u_tab(i).m.yi + u_tab(i).m.ye)/2;
          else--next tabs =>consider the previous point
            center.x:=(center.x + (u_tab(i).m.xi + u_tab(i).m.xe)/2)/2;
            center.y:=(center.y + (u_tab(i).m.yi + u_tab(i).m.ye)/2)/2;
          end if;
      end loop;
      /*
      with tab as (select mdsys.sdo_geometry(2001,82087,
             sdo_point_type(t.m.xi,t.m.yi,0),null,null) geom
           from table(select m.mpoint.u_tab from mpoints m where m.traj_id=46) t)
      select mdsys.SDO_AGGR_CENTROID( MDSYS.SDOAGGRTYPE(tab.geom,0.005))
      from tab;
      */
      --pretty close the above centers
      --units are that of moving_point
    end if;
    return center;
  end mass_center;

  member function radius_of_gyration return number is
    rg number:=0;
    center sp_pos;
  begin
    center := mass_center();
    for i in self.u_tab.first..self.u_tab.last loop
      rg:=rg+power(
        mdsys.sdo_geom.sdo_distance(
          mdsys.sdo_geometry(2001,self.srid,
             sdo_point_type(center.x,center.y,0),null,null),
          mdsys.sdo_geometry(2001,self.srid,
             sdo_point_type(u_tab(i).m.xi,u_tab(i).m.yi,0),null,null),
          0.005),
          2);
    end loop;
    --plus the last point
    rg:=rg+power(
        mdsys.sdo_geom.sdo_distance(
          mdsys.sdo_geometry(2001,self.srid,
             sdo_point_type(center.x,center.y,0),null,null),
          mdsys.sdo_geometry(2001,self.srid,
             sdo_point_type(u_tab(u_tab.last).m.xe,u_tab(u_tab.last).m.ye,0),null,null),
          0.005),
          2);
    --avg
    rg:=rg/(u_tab.last+1);
    rg:=sqrt(rg); 
    --units or rg is meters (unless is defined in sdo_buffer function) 
    return rg;
  end radius_of_gyration;
  
  MEMBER FUNCTION route RETURN MDSYS.SDO_GEOMETRY IS
      RESULT             MDSYS.SDO_GEOMETRY;
      elem_info          MDSYS.sdo_elem_info_array;
      ordinates          MDSYS.sdo_ordinate_array;
      i_xy               coords                    := coords (0.0, 0.0);
      e_xy               coords                    := coords (0.0, 0.0);
      elem_info_offset   PLS_INTEGER               := 1;
      ordinates_offset   PLS_INTEGER               := 1;
      i                  PLS_INTEGER;
      j             pls_integer := 1;
      pre_x     number := -1234.121;
      pre_y     number := -4321.131;
      prepre_x  number := -5678.141;
      prepre_y  number := -8765.151;
      NewL_ords MDSYS.SDO_ORDINATE_ARRAY;
      SRID pls_integer;
   begin
      --select value into SRID from parameters where id='SRID' and table_name='MPOINTS';
      srid:=self.srid;

      elem_info := MDSYS.sdo_elem_info_array ();
      elem_info.EXTEND (3); elem_info(1) := 1; elem_info(2) := 2; elem_info(3) := 1;
      ordinates := MDSYS.sdo_ordinate_array ();

      i := u_tab.FIRST;
      WHILE i IS NOT NULL
      LOOP
         i_xy (1) := u_tab (i).m.xi;
         i_xy (2) := u_tab (i).m.yi;
         e_xy (1) := u_tab (i).m.xe;
         e_xy (2) := u_tab (i).m.ye;

         IF i = u_tab.FIRST
         THEN
            ordinates.EXTEND (2);
            ordinates (ordinates_offset) := i_xy (1);
            ordinates (ordinates_offset + 1) := i_xy (2);
            ordinates_offset := ordinates_offset + 2;
         END IF;

         ordinates.EXTEND (2);
         ordinates (ordinates_offset) := e_xy (1);
         ordinates (ordinates_offset + 1) := e_xy (2);
         ordinates_offset := ordinates_offset + 2;

         i := u_tab.NEXT(i);
      END LOOP;
        /*
        -- SMOOTHLINE
        i := 1;
        NewL_ords := MDSYS.SDO_ORDINATE_ARRAY();
        WHILE i <= ordinates.COUNT - 1 LOOP
            IF ordinates(i) = pre_x AND ordinates(i+1) = pre_y THEN
                NULL;
            ELSIF UTILITIES.check_colinear(prepre_x, prepre_y, pre_x, pre_y, ordinates(i), ordinates(i+1)) = TRUE THEN
                NULL;
            ELSE
                NewL_ords.EXTEND(2);
                NewL_ords(j)   := ordinates(i);
                NewL_ords(j+1) := ordinates(i+1);
                prepre_x := pre_x;
                prepre_y := pre_y;
                pre_x := NewL_ords(j);
                pre_y := NewL_ords(j+1);
                j := j + 2;
            END IF;
            i := i + 2;
        END LOOP;*/

      RESULT := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, elem_info, ordinates);
      return result;
   END route;
   
   member function potential_activity_area return mdsys.sdo_geometry is
    geometry_array sdo_geometry_array:=sdo_geometry_array();
    beginpoint sdo_geometry;endpoint sdo_geometry;
    ellipse sdo_geometry;
    centerx number;centery number;azimuth number;--ellipse center,magor axis azimuth
    a number;b number;c number;tol number:=0.05;--major,minor,foci distance,tolerance
    vmax number;paa sdo_geometry;
   begin
    vmax:=self.f_max_speed;
    for i in self.u_tab.first..self.u_tab.last loop
      if (self.u_tab(i).m.xi = self.u_tab(i).m.xe) and (self.u_tab(i).m.yi = self.u_tab(i).m.ye) then
        --geometry_array.extend;
        --geometry_array(geometry_array.last):=sdo_geometry(2001,self.srid,sdo_point_type(self.u_tab(i).m.xi,self.u_tab(i).m.yi,null),null,null);
        continue;
      else
        --oracle ellipse is returned in 8307 srid
        beginpoint:=sdo_cs.transform(sdo_geometry(2001,self.srid,sdo_point_type(self.u_tab(i).m.xi,self.u_tab(i).m.yi,null),null,null),8307);
        endpoint:=sdo_cs.transform(sdo_geometry(2001,self.srid,sdo_point_type(self.u_tab(i).m.xe,self.u_tab(i).m.ye,null),null,null),8307);
        centerx:=(beginpoint.sdo_point.x+endpoint.sdo_point.x)/2;
        --dbms_output.put_line('x='||centerx);
        centery:=(beginpoint.sdo_point.y+endpoint.sdo_point.y)/2;
        --dbms_output.put_line('y='||centery);
        c:=sdo_geom.sdo_distance(beginpoint,endpoint,tol)/2;
        --this is to overcome data errors or data peculiarities
        if (c = 0) then
          c := 0.001;
        end if;
        --dbms_output.put_line('c='||c);
        a:=vmax*(self.u_tab(i).p.e.get_abs_date()-self.u_tab(i).p.b.get_abs_date());
        --dbms_output.put_line('a='||a);
        b:=sqrt(4*a*a-4*c*c)/2;
        --dbms_output.put_line('b='||b);
        azimuth:=utilities.azimuth(self.u_tab(i).m.xi,self.u_tab(i).m.yi,self.u_tab(i).m.xe,self.u_tab(i).m.ye);
        --oracle ellipse azimuth between 0 and 180 in degrees so
        if (azimuth > acos(-1)) then
          azimuth := azimuth - acos(-1);
        end if;
        azimuth:= sdo_util.convert_unit(azimuth, 'Radian', 'Degree');
        --dbms_output.put_line('azimuth='||azimuth);
        --sdo_util.ellipse_polygon returns a geom in 8307!!!
        ellipse := sdo_util.ellipse_polygon(centerx, centery, a, b, azimuth, tol);
        if (ellipse.sdo_gtype = 2002) then
          continue;
        end if;
        geometry_array.extend;
        geometry_array(geometry_array.last):=ellipse;
      end if;
    end loop;
    --should be aware of sdo_aggr_set_union function on different geometries
    paa:=sdo_aggr_set_union(geometry_array,tol);
    --dbms_output.put_line(paa.SDO_SRID);
    return paa;
   end potential_activity_area;
   


END;
-- END OF MOVING_MPOINT BODY
/


