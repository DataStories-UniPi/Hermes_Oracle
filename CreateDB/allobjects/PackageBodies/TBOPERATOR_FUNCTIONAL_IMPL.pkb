Prompt Package Body TBOPERATOR_FUNCTIONAL_IMPL;
CREATE OR REPLACE PACKAGE BODY        tbOperator_Functional_Impl AS

    FUNCTION tb_multi_traj_unit_type_Func(mp moving_point, tp tau_tll.d_timepoint_sec) return number is
      RESULT          unit_moving_point;
      i               PLS_INTEGER;
      contain_flag    PLS_INTEGER;
      sort_flag       BOOLEAN           := FALSE;
      disjoint_flag   BOOLEAN           := FALSE;
      meet_flag       BOOLEAN           := FALSE;
   BEGIN
      sort_flag := mp.check_sorting ();

      IF sort_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-004:Periods in the nested table of type Moving_Point_Tab are NOT sorted'
            );
      END IF;

      disjoint_flag := mp.check_disjoint ();

      IF disjoint_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-005:Periods in the nested table of type Moving_Point_Tab are NOT disjoint'
            );
      END IF;

      -- an prokeitai gia tin teleutaia periodo tote epistrefo to teleutaio
      -- unit_moving_point
      IF tp.f_equal (tp, mp.u_tab (mp.u_tab.LAST).p.e) = 1
      THEN
         RETURN 1;
      END IF;

      i := mp.u_tab.FIRST;                      -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP
         contain_flag := mp.u_tab (i).p.f_contains (mp.u_tab (i).p, tp);

         IF contain_flag = 1
         THEN
            RESULT := mp.u_tab (i);
            EXIT;
         END IF;

         i := mp.u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

      IF RESULT IS NOT NULL
      THEN
         dbms_output.put_line('Functional Implementation used');
         RETURN 1;
      ELSE
         return 0;
         /*raise_application_error
            (-20100,
             'C$HERMES-009:The Timepoint is NOT contained in any of the Periods in the nested table of type Moving_Point_Tab'
            );*/
      END IF;
   END;

   Function tb_ntersects(mp moving_point, geom MDSYS.SDO_GEOMETRY) return number is
    intersection            MDSYS.SDO_GEOMETRY;
      multipoint              MDSYS.SDO_GEOMETRY;
      cur_point               MDSYS.SDO_GEOMETRY;
      number_of_linestrings   INT;
      multipoint_ordinates    MDSYS.sdo_ordinate_array;
      ix                      NUMBER                   := 0;
      iy                      NUMBER                   := 0;
      p                       PLS_INTEGER              := 0;
      tolerance               NUMBER                   := 0.1;
   BEGIN
      -- Ypologismos tou intersection tou polugonou(geom) me to trajectory tou
      -- moving point(einai ena multiline string)

      intersection := MDSYS.sdo_geom.sdo_intersection (geom, mp.route (), tolerance);
      dbms_output.put_line('Functional Implementation');
      --UTILITIES.print_geometry(intersection,'INTERSECTION');

      IF intersection IS NULL THEN
         RETURN 0;
      END IF;

      --multipoint := MDSYS.SDO_GEOMETRY (2005, NULL, NULL, sdo_elem_info_array (1, 1, intersection.sdo_ordinates.COUNT / 2), intersection.sdo_ordinates);
      --UTILITIES.print_geometry(multipoint,'MULTIPOINT');


      RETURN 1;
   END;

   Function tb_contains_Timeperiod_Func(mp moving_point,tp tau_tll.d_period_sec) return number is
   --RESULT          unit_moving_point;
      i               PLS_INTEGER;
      contain_flag_b    PLS_INTEGER:=0;
      contain_flag_e    PLS_INTEGER:=0;
      sort_flag       BOOLEAN           := FALSE;
      disjoint_flag   BOOLEAN           := FALSE;
      meet_flag       BOOLEAN           := FALSE;
      tpb tau_tll.D_Timepoint_Sec;
      tpe tau_tll.D_Timepoint_Sec;
   begin

    tpb:=tp.b;
    tpe:=tp.e;
    sort_flag := mp.check_sorting ();

      IF sort_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-004:Periods in the nested table of type Moving_Point_Tab are NOT sorted'
            );
      END IF;

      disjoint_flag := mp.check_disjoint ();

      IF disjoint_flag <> TRUE
      THEN
         raise_application_error
            (-20100,
             'C$HERMES-005:Periods in the nested table of type Moving_Point_Tab are NOT disjoint'
            );
      END IF;

      -- an prokeitai gia tin teleutaia periodo tote epistrefo to teleutaio
      -- unit_moving_point

      /*IF tp.f_equal (tp, mp.u_tab (mp.u_tab.LAST).p.e) = 1
      THEN
         RETURN 1;
      END IF;*/

      i := mp.u_tab.FIRST;                      -- get subscript of first element

      WHILE i IS NOT NULL
      LOOP

         --until we find a u_tab(i) which contains the initial timepoint of the given
         --period we only check the initial timepoint
         if contain_flag_b=0 then
         contain_flag_b := mp.u_tab (i).p.f_contains (mp.u_tab (i).p, tpb);
         end if;

         --after we have found a u_tab(i) that contains the initial timepoint of the given period
         --we go on searching for the u_tab(i) containing the end of the given period
         if contain_flag_b= 1 then
         contain_flag_e := mp.u_tab (i).p.f_contains (mp.u_tab (i).p, tpe);
         end if;

         IF contain_flag_b = 1 AND contain_flag_e = 1
         THEN
            return 1;
            EXIT;
         END IF;

         i := mp.u_tab.NEXT (i);                 -- get subscript of next element
      END LOOP;

         return 0;

   end tb_contains_Timeperiod_Func;

    --a function that returns the moving points that contain all the timeperiods included in the D_Temp_element_sec
    Function tb_contains_Temp_Element_Func(mp moving_point,tp tau_tll.D_Temp_Element_sec) return number is
    contain_flag pls_integer:=1;
    BEGIN
        --search the moving point to determine weather it contains all the timeperiod of the D_Temp_Element_Sec or not
        for i in tp.te.first..tp.te.last loop
            if tb_contains_Timeperiod_Func(mp,tp.te(i))=0 then
                contain_flag:=0;
                exit;
            end if;
        end loop;
        if contain_flag=0 then return 0;
        else return 1;
        end if;
    END tb_contains_Temp_Element_Func;

    --a function that returns the moving points itnercecting a given geometry and cosntrained in a certain time period
    Function tb_SpatioTemp_Wind_Func(mp moving_point,geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_Period_sec) return number is
    tolerance number:=0.001;
    BEGIN

     dbms_output.put_line('Functional Implementation');
    if (mp.f_intersection(geom,tolerance) is null) or (mp.at_period(tp) is null) then
    return 0;end if;
    return 1;

    END tb_SpatioTemp_Wind_Func;




END;
/


