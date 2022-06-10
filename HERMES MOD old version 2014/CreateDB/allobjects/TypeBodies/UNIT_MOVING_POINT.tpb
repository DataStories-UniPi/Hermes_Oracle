Prompt Type Body UNIT_MOVING_POINT;
CREATE OR REPLACE TYPE BODY unit_moving_point IS
   -- Polynomial of first degree
   MEMBER FUNCTION f_plnml_1 (tp tau_tll.d_timepoint_sec) RETURN coords IS
      l           NUMBER := 0.0;
      dx          NUMBER := 0.0;
      dy          NUMBER := 0.0;
      totaldist   NUMBER := 0.0;
      veloc       NUMBER := 0.0;
      accel       NUMBER := 0.0;
      timeinsec   NUMBER := 0.0;
   BEGIN
      totaldist := SQRT (POWER (m.ye - m.yi, 2) + POWER (m.xe - m.xi, 2));
      timeinsec := tp.get_abs_date () - p.b.get_abs_date ();
      --to avoid divisor zero. Should be cope better!!!
      if (totaldist<=0) then
        totaldist:=0.001;
      end if;

      IF timeinsec < 0
      THEN
         raise_application_error
                            (-20100,
                             'C$HERMES-009:The given time point is not valid'
                            );
      END IF;

      IF m.v IS NULL
      THEN                                                     -- Omali kinisi
         accel := 0.0;
         veloc := totaldist / (p.e.get_abs_date () - p.b.get_abs_date ());
      END IF;

      l := (veloc * timeinsec) + (0.5 * accel * (timeinsec * timeinsec));

      IF m.f IS NULL
      THEN
         dx := l * (m.xe - m.xi) / totaldist;
         dy := l * (m.ye - m.yi) / totaldist;
      ELSE
         dx := l * COS (m.f);
         dy := l * SIN (m.f);
      END IF;

      IF utilities.check_colinear (m.xi,    m.yi,     m.xi + dx, m.yi + dy,     m.xe,    m.ye) THEN -- just in case!!
        RETURN coords (m.xi + dx, m.yi + dy);
      ELSE
        RETURN coords (m.xi, m.yi);
      END IF;
   END;                                                            --f_plnml_1

   MEMBER FUNCTION r_f_plnml_1 (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec IS
      s             NUMBER                  := 0.0;
      avg_veloc     NUMBER                  := 0.0;
      totaldist     NUMBER                  := 0.0;
      totaltime     NUMBER                  := 0.0;
      time_in_sec   DOUBLE PRECISION        := 0.0;
      RESULT        tau_tll.d_timepoint_sec;
   BEGIN
      IF m.v IS NULL                --omali kinisi(metrame tin mesi taxytita)
      THEN
         totaldist := utilities.distance (m.xi, m.yi, m.xe, m.ye);
         totaltime := p.e.get_abs_date() - p.b.get_abs_date();
         --MESI_TAX=SINOLIKI_APOST / SINOLIKOS_XRONOS
         avg_veloc := totaldist / totaltime;
         s := utilities.distance (m.xi, m.yi, x, y);
         time_in_sec := p.b.get_abs_date () + s / avg_veloc;
         RESULT := tau_tll.d_timepoint_sec (1, 1, 1, 1, 1, 1);
         RESULT.set_abs_date (time_in_sec);
      ELSE                                                    --epitagxinomeni
         RESULT := NULL;
      END IF;

      RETURN RESULT;
   END;

   MEMBER FUNCTION f_plnml_3_1 (tp tau_tll.d_timepoint_sec) RETURN coords IS
      lt          NUMBER := 0.0;
      st          NUMBER := 0.0;
      r           NUMBER := 0.0;
      angle       NUMBER := 0.0;
      dx          NUMBER := 0.0;
      dy          NUMBER := 0.0;
      totaldist   NUMBER := 0.0;
      veloc       NUMBER := 0.0;
      accel       NUMBER := 0.0;
      timeinsec   NUMBER := 0.0;
   BEGIN
      timeinsec := tp.get_abs_date () - p.b.get_abs_date ();

      IF timeinsec < 0
      THEN
         raise_application_error
                            (-20100,
                             'C$HERMES-009:The given time point is not valid'
                            );
      END IF;

      r := utilities.distance (m.xi, m.yi, m.xm, m.ym);
      --DBMS_OUTPUT.put_line ('R=' || TO_CHAR (r));
      totaldist :=
           (2 * 3.14 * r)
         * (  (  utilities.direction (m.xm, m.ym, m.xi, m.yi)
               - utilities.direction (m.xm, m.ym, m.xe, m.ye)
              )
            / 360
           );

      --DBMS_OUTPUT.put_line ('totaldist=' || TO_CHAR (totaldist));
      IF m.v IS NULL
      THEN                                                     -- Omali kinisi
         accel := 0.0;
         veloc := totaldist / (p.e.get_abs_date () - p.b.get_abs_date ());
      END IF;

      st := (veloc * timeinsec) + (0.5 * accel * (timeinsec * timeinsec));
      lt := 2 * r * SIN (st / (2 * r));
      angle := (3.14 / 2) + ASIN ((m.ym - m.yi) / r) - (st / (2 * r));
      --
      --
      dx := lt * COS (angle);
      dy := lt * SIN (angle);
      RETURN coords (m.xi + dx, m.yi + dy);
   END;

   MEMBER FUNCTION f_plnml_3_2 (tp tau_tll.d_timepoint_sec) RETURN coords IS
      lt          NUMBER := 0.0;
      st          NUMBER := 0.0;
      r           NUMBER := 0.0;
      angle       NUMBER := 0.0;
      dx          NUMBER := 0.0;
      dy          NUMBER := 0.0;
      totaldist   NUMBER := 0.0;
      veloc       NUMBER := 0.0;
      accel       NUMBER := 0.0;
      timeinsec   NUMBER := 0.0;
   BEGIN
      --DBMS_OUTPUT.put_line ('f_plnml_3_2');
      timeinsec := tp.get_abs_date () - p.b.get_abs_date ();

      IF timeinsec < 0
      THEN
         raise_application_error
                            (-20100,
                             'C$HERMES-009:The given time point is not valid'
                            );
      END IF;

      r := utilities.distance (m.xi, m.yi, m.xm, m.ym);
      --DBMS_OUTPUT.put_line ('R=' || TO_CHAR (r));
      totaldist :=
           (2 * 3.14 * r)
         * (  (  utilities.direction (m.xm, m.ym, m.xi, m.yi)
               - utilities.direction (m.xm, m.ym, m.xe, m.ye)
              )
            / 360
           );

      --DBMS_OUTPUT.put_line ('totaldist=' || TO_CHAR (totaldist));
      IF m.v IS NULL
      THEN                                                     -- Omali kinisi
         accel := 0.0;
         veloc := totaldist / (p.e.get_abs_date () - p.b.get_abs_date ());
      END IF;

      st := (veloc * timeinsec) + (0.5 * accel * (timeinsec * timeinsec));
      lt := 2 * r * SIN (st / (2 * r));
      angle := (3*3.14 / 2) - ASIN ((m.ym - m.yi) / r) - (st / (2 * r));
      --
      --
      dx := lt * COS (angle);
      dy := lt * SIN (angle);
      RETURN coords (m.xi + dx, m.yi + dy);
   END;

   MEMBER FUNCTION r_f_plnml_3_x (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec IS
      RESULT   tau_tll.d_timepoint_sec;
      xy       coords;
      SRID pls_integer;
   begin
      SRID:= 2100;--HARD CODED!!!

      RESULT := p.b;
      xy := f_interpolate (RESULT);

      WHILE sdo_geom.relate
                (MDSYS.SDO_GEOMETRY (2001,
                               SRID,
                               sdo_point_type (x, y, NULL),
                               NULL,
                               NULL
                              ),
                 'ANYINTERACT',
                 sdo_geom.sdo_buffer (MDSYS.SDO_GEOMETRY (2001,
                                                    SRID,
                                                    sdo_point_type (xy (1),
                                                                    xy (2),
                                                                    NULL
                                                                   ),
                                                    NULL,
                                                    NULL
                                                   ),
                                      0.9,
                                      0.01
                                     ),
                 0.5
                ) = 'TRUE'
      LOOP
         RESULT.f_incr ();
         xy := f_interpolate (RESULT);

         IF RESULT.f_equal (RESULT, p.e) = 1
         THEN
            --DBMS_OUTPUT.put_line ('@r_f_plnml_3_1 -> error');
            RETURN NULL;
         END IF;
      END LOOP;

      RETURN RESULT;
   END;

   MEMBER FUNCTION f_interpolate (tp tau_tll.d_timepoint_sec) RETURN coords IS
      RESULT   coords := coords (1e-130, 1e-130);
   BEGIN
      IF m.descr = 'PLNML_1'
      THEN
         RESULT := f_plnml_1 (tp);
      ELSIF m.descr = 'PLNML_3_1'
      THEN
         RESULT := f_plnml_3_1 (tp);
      ELSIF m.descr = 'PLNML_3_2'
      THEN
         RESULT := f_plnml_3_2 (tp);
      ELSIF m.descr = 'CONST'
      THEN
         RESULT := coords (m.xi, m.yi);
      END IF;

      RETURN RESULT;
   END;                                                        --f_interpolate

   -- To do: na ftiakso kai gia epitagxinomeni kinisi, kai gia const sinartisi
   MEMBER FUNCTION get_time_point (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec IS
      RESULT   tau_tll.d_timepoint_sec;
   BEGIN
      IF m.descr = 'PLNML_1' THEN                         --polyonimiki sinartisi
         RESULT := r_f_plnml_1 (x, y);
      ELSIF m.descr = 'PLNML_3_1' or m.descr = 'PLNML_3_2' THEN
         --DBMS_OUTPUT.put_line ('@get_time_point->PLNML_3_1');
         RESULT := r_f_plnml_3_x (x, y);
      ELSIF m.descr = 'CONST' THEN                                       --statheri
         RESULT := p.b;
      END IF;
      RETURN RESULT;
   END;                                                       --get_time_point

   -- TO DO : NA FTAXTOUN OLES OI SYNARTHSEIS....
   MEMBER FUNCTION f_contains (x NUMBER, y NUMBER)
      RETURN BOOLEAN
   IS
      contains   BOOLEAN := FALSE;
      m_xy       coords  := coords (0.0, 0.0);
      minxy coords:= coords (0.0, 0.0);
      maxxy coords:= coords (0.0, 0.0);
      SRID pls_integer;
   begin
      SRID:= 2100;--HARD CODED!!!
      --dbms_output.put_line('srid hard coded on f_contains!!!');
      if (self.m.xi<=self.m.xe) then
        minxy(1):=self.m.xi;
        maxxy(1):=self.m.xe;
      else
        minxy(1):=self.m.xe;
        maxxy(1):=self.m.xi;
      end if;
      if (self.m.yi<=self.m.ye) then
        minxy(2):=self.m.yi;
        maxxy(2):=self.m.ye;
      else
        minxy(2):=self.m.ye;
        maxxy(2):=self.m.yi;
      end if;

      /*DBMS_OUTPUT.put_line (   '@f_contains->'
                            || m.descr|| ' x,y='|| TO_CHAR (x)|| ', '|| TO_CHAR (y) );*/
      IF m.descr = 'PLNML_1'
      THEN
         contains := utilities.check_colinear(self.m.xi,self.m.yi,self.m.xe,self.m.ye,x,y)--tolerance optional
                  and utilities.is_point_between(minxy(1),minxy(2),maxxy(1),maxxy(2),x,y,0.001);--tolerance optional
      ELSIF m.descr = 'CONST'
      THEN
         contains := (m.xi = x AND m.yi = y);
      ELSE                                        -- oles oi kiklikes kiniseis
         --DBMS_OUTPUT.put_line ('@f_contains -> Kikliki kinisi');
         m_xy := get_midle_point ();
         contains :=
            sdo_geom.relate
                  (MDSYS.SDO_GEOMETRY (2002,SRID,NULL,
                                 sdo_elem_info_array (1, 2, 2),
                                 sdo_ordinate_array (m.xi,m.yi,m_xy (1), m_xy (2), m.xe, m.ye )
                                ), 'ANYINTERACT',
                   sdo_geom.sdo_buffer (MDSYS.SDO_GEOMETRY (2001, SRID, sdo_point_type (x, y, NULL), NULL,NULL),
                                        0.9, 0.01 ),
                   0.5 ) = 'TRUE';
      END IF;

      RETURN contains;
   END;                                                           --f_contains

   MEMBER FUNCTION get_speed (tp tau_tll.d_timepoint_sec) RETURN NUMBER IS
      totaldist   NUMBER := 0.0;
      timeinsec   NUMBER := 0;
   BEGIN
      IF m.v IS NULL
      THEN     -- Omali kinisi: mesi taxitita=SINOLIKI_APOST/SINOLIKOS_XRONOS
         totaldist := utilities.distance (m.xi, m.yi, m.xe, m.ye);
         RETURN totaldist / (p.e.get_abs_date () - p.b.get_abs_date ());
      ELSE                     -- Epitagxinomeni:taxitita = v0 + 1/2 * a * t^2
         timeinsec := tp.get_abs_date () - p.b.get_abs_date ();
         RETURN m.v + 0.5 * m.a * timeinsec * timeinsec;
      END IF;
   END;                                                            --get_speed

   -- ONLY FOR ARCS
   MEMBER FUNCTION get_midle_point RETURN coords IS
      tp       tau_tll.d_timepoint_sec;
      RESULT   coords                  := coords (0.0, 0.0);
   BEGIN
      IF m.descr = 'PLNML_1'
      THEN
         RESULT := coords (NULL, NULL);
      ELSIF m.descr = 'PLNML_3_1'
      THEN
         tp := p.b;
         tp.set_abs_date ((p.e.get_abs_date () + p.b.get_abs_date ()) / 2);
         RESULT := f_plnml_3_1 (tp);
      elsif m.descr='PLNML_3_2'
      THEN
         tp := p.b;
         tp.set_abs_date ((p.e.get_abs_date () + p.b.get_abs_date ()) / 2);
         RESULT := f_plnml_3_2 (tp);
      ELSIF m.descr = 'CONST'
      THEN
         RESULT := coords (m.xi, m.yi);
      END IF;

      RETURN RESULT;
   END;

END;
/


