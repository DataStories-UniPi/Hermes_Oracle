Prompt Package Body UTILITIES;
CREATE OR REPLACE PACKAGE BODY utilities AS
    FUNCTION check_colinear (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER, x3 NUMBER, y3 NUMBER,tolerance number:=0.01) RETURN BOOLEAN IS
    RESULT   BOOLEAN := FALSE;
    c number := 0.0;
   BEGIN
      IF x2 IS NULL OR y2 IS NULL
      THEN
         RETURN true;
      END IF;

      c :=   (x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2));
      --the area of a triangle determined by three points
      --so we can ask for a tolerance on that (sider)
      IF  c = 0 OR ( c > 0 AND c < tolerance ) OR ( c < 0 AND c > -tolerance ) THEN
         RESULT := TRUE;
      END IF;

      RETURN RESULT;
   END;

    FUNCTION check_overlap (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER, x3 NUMBER, y3 NUMBER) RETURN BOOLEAN IS
    RESULT    BOOLEAN            := FALSE;
    res_str   VARCHAR2 (10);
    geom1     MDSYS.SDO_GEOMETRY;
    geom2     MDSYS.SDO_GEOMETRY;
    SRID pls_integer;
   BEGIN
      SRID:=2100;--HARD CODED!!!

      IF check_colinear (x1, y1, x2, y2, x3, y3) = TRUE
      THEN
         geom1 :=
            MDSYS.SDO_GEOMETRY
                       (2002,           -- SDO_GTYPE: 2-Dimensional LineString
                        SRID,           -- SDO_SRID:  Spatial Reference System
                        NULL, -- SDO_POINT: X and Y coordinates of the 2-D point
                        MDSYS.sdo_elem_info_array (1, 2, 1),
                        -- SDO_ELEM_INFO: linestring
                        MDSYS.sdo_ordinate_array (x1, y1, x2, y2)
                       -- SDO_ORDINATES:
                       );
         geom2 :=
            MDSYS.SDO_GEOMETRY (2001,        -- SDO_GTYPE: 2-Dimensional point
                                SRID,   -- SDO_SRID:  Spatial Reference System
                                MDSYS.sdo_point_type (x3, y3, NULL),
                                -- SDO_POINT: X and Y coordinates of the 2-D point
                                NULL,                        -- SDO_ELEM_INFO:
                                NULL                         -- SDO_ORDINATES:
                               );
         res_str := sdo_geom.relate (geom1, 'ANYINTERACT', geom2, 0.005);

         IF res_str = 'TRUE'
         THEN
            RESULT := TRUE;
         END IF;
      END IF;

      RETURN RESULT;
   END;

    PROCEDURE print_geometry (geom MDSYS.SDO_GEOMETRY, descr VARCHAR2) IS
    i   PLS_INTEGER;
    x   VARCHAR2 (512);
    y   VARCHAR2 (512);
   BEGIN
      x := TO_CHAR (geom.sdo_point.x);
      y := TO_CHAR (geom.sdo_point.y);
      DBMS_OUTPUT.put_line ('########## ' || descr || ' ##########');
      DBMS_OUTPUT.put_line ('SDO_GTYPE = ' || TO_CHAR (geom.sdo_gtype));
      DBMS_OUTPUT.put_line ('SDO_SRID = ' || TO_CHAR (geom.sdo_srid));
      DBMS_OUTPUT.put_line ('SDO_POINT = ' || x || ', ' || y);

      IF geom.sdo_elem_info IS NOT NULL
      THEN
         i := geom.sdo_elem_info.FIRST;     -- get subscript of first element

         WHILE i IS NOT NULL
         LOOP
            DBMS_OUTPUT.put_line (   'SDO_ELEM_INFO = '
                                  || TO_CHAR (geom.sdo_elem_info (i))
                                  || ', '
                                  || TO_CHAR (geom.sdo_elem_info (i + 1))
                                  || ', '
                                  || TO_CHAR (geom.sdo_elem_info (i + 2))
                                 );
            i := geom.sdo_elem_info.NEXT (i + 2);
         -- get subscript of next element
         END LOOP;
      END IF;

      IF geom.sdo_ordinates IS NOT NULL
      THEN
         i := geom.sdo_ordinates.FIRST;     -- get subscript of first element

         WHILE i IS NOT NULL
         LOOP
            DBMS_OUTPUT.put_line (   'SDO_ORDINATES = '
                                  || TO_CHAR (geom.sdo_ordinates (i))
                                  || ', '
                                  || TO_CHAR (geom.sdo_ordinates (i + 1))
                                 );
            i := geom.sdo_ordinates.NEXT (i + 1);
         -- get subscript of next element
         END LOOP;
      END IF;
   END;

    FUNCTION add_angles (angle1 NUMBER, angle2 NUMBER) RETURN NUMBER IS
    RESULT   NUMBER := NULL;
    BEGIN
        RESULT := angle1 + angle2;

        IF RESULT > 360
      THEN
         RESULT := RESULT - 360;
      END IF;

      RETURN RESULT;
   END;

    FUNCTION is_angle_between (min_angle NUMBER, angle NUMBER, max_angle NUMBER) RETURN BOOLEAN IS
    angle_diff   NUMBER;
   BEGIN
      IF min_angle >= max_angle
      THEN
         DBMS_OUTPUT.put_line
            ('min_angle must be < than max_angle @utilities.is_angle_between');
         RETURN NULL;
      END IF;

      angle_diff := max_angle - min_angle;

      IF angle_diff > 180
      THEN
         IF angle <= min_angle OR angle >= max_angle
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         IF angle >= min_angle AND angle <= max_angle
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;
   END;

    FUNCTION direction (geom1 MDSYS.SDO_GEOMETRY, geom2 MDSYS.SDO_GEOMETRY) RETURN NUMBER IS
    RESULT   NUMBER;
    x1       NUMBER;
    y1       NUMBER;
    x2       NUMBER;
    y2       NUMBER;
   BEGIN
      IF     (geom1.sdo_gtype = 2001 OR geom1.sdo_gtype = 1)
         AND (geom2.sdo_gtype = 2001 OR geom2.sdo_gtype = 1)
      THEN
         x1 := geom1.sdo_point.x;
         y1 := geom1.sdo_point.y;
         x2 := geom2.sdo_point.x;
         y2 := geom2.sdo_point.y;

         RESULT := direction(x1, y1, x2, y2);
      ELSE
         raise_application_error(-20100, 'C$HERMES-042:Operation direction can NOT be defined in geometries other than points');
      END IF;

      RETURN RESULT;
   END;

    FUNCTION direction (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER) RETURN NUMBER IS
    RESULT   NUMBER;dx number; dy number;
   BEGIN
      dx := x2 - x1;
      dy := y2 - y1; 
      IF dx = 0 AND dy = 0
      THEN
         RESULT := 1e-130;
      ELSE
         IF dx > 0 AND dy >= 0
         THEN
            RESULT := (ATAN (dy / dx)) * (360 / (2 * acos(-1)));
         ELSIF dx = 0 AND dy > 0
         THEN
            RESULT := 90;
         ELSIF dx < 0
         THEN
            RESULT :=
                     180
                     + (ATAN (dy / dx)) * (360 / (2 * acos(-1)));
         ELSIF dx = 0 AND dy < 0
         THEN
            RESULT := 270;
         ELSIF dx > 0 AND dy < 0
         THEN
            RESULT :=
                     360
                     + (ATAN (dy/ dx)) * (360 / (2 * acos(-1)));
         END IF;
      END IF;

      RETURN RESULT;--in decimal degrees
   END;

    FUNCTION get_tan (geom1 MDSYS.SDO_GEOMETRY, geom2 MDSYS.SDO_GEOMETRY) RETURN NUMBER IS
    RESULT   NUMBER;
    x1       NUMBER;
    y1       NUMBER;
    x2       NUMBER;
    y2       NUMBER;
   BEGIN
      IF    geom1.sdo_gtype = 2001
         OR geom1.sdo_gtype = 1
         OR geom2.sdo_gtype = 2001
         OR geom2.sdo_gtype = 1
      THEN
         x1 := geom1.sdo_point.x;
         y1 := geom1.sdo_point.y;
         x2 := geom2.sdo_point.x;
         y2 := geom2.sdo_point.y;

         IF x1 = x2 AND y1 = y2
         THEN
            RESULT := 1e-130;
         ELSE
            IF x1 < x2 AND y1 <= y2
            THEN
               RESULT := (y2 - y1) / (x2 - x1);
            ELSIF x1 = x2 AND y1 < y2
            THEN
               RESULT := 89.3634;                              --(=90 moires)
            ELSIF x1 > x2
            THEN
               RESULT := 89.68 /*(=180 moires)*/ + ((y2 - y1) / (x2 - x1));
            ELSIF x1 = x2 AND y1 > y2
            THEN
               RESULT := 89.78;                              --(=270 moires);
            ELSIF x1 < x2 AND y1 > y2
            THEN
               RESULT := 89.84 /*(=360 moires)*/ + ((y2 - y1) / (x2 - x1));
            END IF;
         END IF;
      ELSE
         raise_application_error(-20100, 'C$HERMES-042:Operation direction can NOT be defined in geometries other than points');
      END IF;

      RETURN RESULT;
   END;

    FUNCTION angle (q_start MDSYS.SDO_GEOMETRY, q_end MDSYS.SDO_GEOMETRY, s_start MDSYS.SDO_GEOMETRY, s_end MDSYS.SDO_GEOMETRY) RETURN NUMBER IS
    f     NUMBER := 0.0;
    f_q   NUMBER := 0.0;
    f_s   NUMBER := 0.0;
    d     NUMBER := 0.0;
    a     NUMBER := 0.0;
   BEGIN
      f_q := direction (q_start, q_end);
      f_s := direction (s_start, s_end);

      IF 0.0 <= f_q AND f_q < 90.0
      THEN
         IF 0.0 <= f_s AND f_s < 90.0
         THEN
            f := ABS (f_q - f_s);
         ELSIF 90.0 <= f_s AND f_s < 180.0
         THEN
            f := f_s - f_q;
         ELSIF 180.0 <= f_s AND f_s < 270.0
         THEN
            f := f_s - f_q;

            IF f > 180.0
            THEN
               a := 270.0 - f_s;
               d := 90.0 - f_q - a;
               f := f - 2 * d;
            END IF;
         ELSIF 270.0 <= f_s AND f_s < 360.0
         THEN
            f_s := 360.0 - f_s;
            f := f_s + f_q;
         END IF;
      ELSIF 90.0 <= f_q AND f_q < 180.0
      THEN
         IF 0.0 <= f_s AND f_s < 90.0
         THEN
            f := f_q - f_s;
         ELSIF 90.0 <= f_s AND f_s < 180.0
         THEN
            f := ABS (f_q - f_s);
         ELSIF 180.0 <= f_s AND f_s < 270.0
         THEN
            f := f_s - f_q;
         ELSIF 270.0 <= f_s AND f_s < 360.0
         THEN
            f := f_s - f_q;

            IF f > 180.0
            THEN
               a := 360.0 - f_s;
               d := 180.0 - f_q - a;              -- 90.0 - (F_Q - 90.0) - a;
               f := f - 2 * d;
            END IF;
         END IF;
      ELSIF 180.0 <= f_q AND f_q < 270.0
      THEN
         IF 0.0 <= f_s AND f_s < 90.0
         THEN
            f := f_q - f_s;

            IF f > 180.0
            THEN
               a := 270.0 - f_q;
               d := 90.0 - f_s - a;
               f := f - 2 * d;
            END IF;
         ELSIF 90.0 <= f_s AND f_s < 180.0
         THEN
            f := f_q - f_s;
         ELSIF 180.0 <= f_s AND f_s < 270.0
         THEN
            f := ABS (f_q - f_s);
         ELSIF 270.0 <= f_s AND f_s < 360.0
         THEN
            f := f_s - f_q;
         END IF;
      ELSIF 270.0 <= f_q AND f_q < 360.0
      THEN
         IF 0.0 <= f_s AND f_s < 90.0
         THEN
            f_q := 360.0 - f_q;
            f := f_s + f_q;
         ELSIF 90.0 <= f_s AND f_s < 180.0
         THEN
            f := f_q - f_s;

            IF f > 180.0
            THEN
               a := 360.0 - f_q;
               d := 180.0 - f_s - a;              -- 90.0 - (F_S - 90.0) - a;
               f := f - 2 * d;
            END IF;
         ELSIF 180.0 <= f_s AND f_s < 270.0
         THEN
            f := f_q - f_s;
         ELSIF 270.0 <= f_s AND f_s < 360.0
         THEN
            f := ABS (f_q - f_s);
         END IF;
      END IF;

      RETURN f;
   END;

    FUNCTION angle2(Q_angle number, S_angle number) return number is
    F   number := 0.0;
    F_Q number := 0.0;
    F_S number := 0.0;
    d   number := 0.0;
    a   number := 0.0;
    begin
        F_Q := Q_angle;
        F_S := S_angle;

        IF 0.0 <= F_Q AND F_Q < 90.0 THEN
            IF 0.0 <= F_S AND F_S < 90.0 THEN
                F := ABS(F_Q - F_S);
            ELSIF 90.0 <= F_S AND F_S < 180.0 THEN
                F := F_S - F_Q;
            ELSIF 180.0 <= F_S AND F_S < 270.0 THEN
                F := F_S - F_Q;
                IF F > 180.0 THEN
                    a := 270.0 - F_S;
                    d := 90.0 - F_Q - a;
                    F := F - 2*d;
                END IF;
            ELSIF 270.0 <= F_S AND F_S < 360.0 THEN
                 F_S := 360.0 - F_S;
                 F := F_S + F_Q;
            END IF;
        ELSIF 90.0 <= F_Q AND F_Q < 180.0 THEN
            IF 0.0 <= F_S AND F_S < 90.0 THEN
                F := F_Q - F_S;
            ELSIF 90.0 <= F_S AND F_S < 180.0 THEN
                F := ABS(F_Q - F_S);
            ELSIF 180.0 <= F_S AND F_S < 270.0 THEN
                F := F_S - F_Q;
            ELSIF 270.0 <= F_S AND F_S < 360.0 THEN
                F := F_S - F_Q;
                IF F > 180.0 THEN
                    a := 360.0 - F_S;
                    d := 180.0 - F_Q - a; -- 90.0 - (F_Q - 90.0) - a;
                    F := F - 2*d;
                END IF;
            END IF;
        ELSIF 180.0 <= F_Q AND F_Q < 270.0 THEN
            IF 0.0 <= F_S  AND F_S< 90.0 THEN
                F := F_Q - F_S;
                IF F > 180.0 THEN
                    a := 270.0 - F_Q;
                    d := 90.0 - F_S - a;
                    F := F - 2*d;
                END IF;
            ELSIF 90.0 <= F_S AND F_S < 180.0 THEN
                F := F_Q - F_S;
            ELSIF 180.0 <= F_S AND F_S < 270.0 THEN
                F := ABS(F_Q - F_S);
            ELSIF 270.0 <= F_S AND F_S < 360.0 THEN
                F := F_S - F_Q;
            END IF;
        ELSIF 270.0 <= F_Q AND F_Q < 360.0 THEN
            IF 0.0 <= F_S AND F_S < 90.0 THEN
                F_Q := 360.0 - F_Q;
                F := F_S + F_Q;
            ELSIF 90.0 <= F_S AND F_S < 180.0 THEN
                F := F_Q - F_S;
                IF F > 180.0 THEN
                    a := 360.0 - F_Q;
                    d := 180.0 - F_S - a; -- 90.0 - (F_S - 90.0) - a;
                    F := F - 2*d;
                END IF;
            ELSIF 180.0 <= F_S AND F_S < 270.0 THEN
                F := F_Q - F_S;
            ELSIF 270.0 <= F_S AND F_S < 360.0 THEN
                F := ABS(F_Q - F_S);
            END IF;
        END IF;

        return F;
    end;

    FUNCTION angle3 (q_start MDSYS.SDO_GEOMETRY, q_end MDSYS.SDO_GEOMETRY, s_start MDSYS.SDO_GEOMETRY, s_end MDSYS.SDO_GEOMETRY) RETURN NUMBER IS
    f     NUMBER := 0.0;
    f_q   NUMBER := 0.0;
    f_s   NUMBER := 0.0;
    d     NUMBER := 0.0;
    a     NUMBER := 0.0;
   BEGIN
      f_q := direction (q_start, q_end);
      f_s := direction (s_start, s_end);

      f := ABS (f_q - f_s);

      RETURN f;
   END;

    FUNCTION distance (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER) RETURN NUMBER IS
      res number;
   BEGIN
      res:= SQRT (POWER (y2 - y1, 2) + POWER (x2 - x1, 2));
      if (res = 0) then
        res:=0.0001;
      end if;
      return res;
   END;

    FUNCTION f_sort (mpoint IN OUT MDSYS.SDO_GEOMETRY, line MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
    i             PLS_INTEGER;
    k             PLS_INTEGER;
    mindist       NUMBER                    := 0.0;
    min_i         PLS_INTEGER               := 1;
    curdist       NUMBER                    := 0.0;
    temp_x        NUMBER                    := 0.0;
    temp_y        NUMBER                    := 0.0;
    swap          BOOLEAN                   := FALSE;
    mpoint_info   MDSYS.sdo_elem_info_array;
    mpoint_ords   MDSYS.sdo_ordinate_array;
    SRID pls_integer;
   BEGIN
      srid:=mpoint.SDO_SRID;

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
         mindist :=
            distance (line.sdo_ordinates (1),
                      line.sdo_ordinates (2),
                      mpoint.sdo_ordinates (i),
                      mpoint.sdo_ordinates (i + 1)
                     );

         WHILE i IS NOT NULL
         LOOP
            curdist :=
               distance (line.sdo_ordinates (1),
                         line.sdo_ordinates (2),
                         mpoint.sdo_ordinates (i),
                         mpoint.sdo_ordinates (i + 1)
                        );

            IF curdist < mindist
            THEN
               mindist := curdist;
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
   END;

    FUNCTION get_odd_points (multipoint MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
    RESULT                 MDSYS.SDO_GEOMETRY;
    multipoint_ordinates   MDSYS.sdo_ordinate_array;
    i                      PLS_INTEGER;
    result_index           INT;
    SRID pls_integer;
   BEGIN
      srid:=multipoint.SDO_SRID;

      -- An i eisodos den einai multipoint...
      IF multipoint.sdo_gtype <> 2005
      THEN
         RETURN NULL;
      END IF;

      multipoint_ordinates := MDSYS.sdo_ordinate_array ();
      i := multipoint.sdo_ordinates.FIRST;
      result_index := 1;

      WHILE i IS NOT NULL
      LOOP
         multipoint_ordinates.EXTEND (2);
         multipoint_ordinates (result_index) := multipoint.sdo_ordinates (i);
         multipoint_ordinates (result_index + 1) :=
                                             multipoint.sdo_ordinates (i + 1);
         result_index := result_index + 2;
         i := multipoint.sdo_ordinates.NEXT (i + 3);
      END LOOP;

      RESULT :=
         MDSYS.SDO_GEOMETRY (2005,                                      --MULTIPOINT
                       SRID,
                       NULL,
                       sdo_elem_info_array (1,
                                            1,
                                            multipoint_ordinates.COUNT / 2
                                           ),
                       multipoint_ordinates
                      );
      RETURN RESULT;
   END;

    FUNCTION get_even_points (multipoint MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY IS
    RESULT                 MDSYS.SDO_GEOMETRY;
    multipoint_ordinates   MDSYS.sdo_ordinate_array;
    i                      PLS_INTEGER;
    result_index           INT;
    SRID pls_integer;
   BEGIN
      srid:=multipoint.SDO_SRID;

      -- An i eisodos den einai multipoint...
      IF multipoint.sdo_gtype <> 2005
      THEN
         RETURN NULL;
      END IF;

      multipoint_ordinates := MDSYS.sdo_ordinate_array ();
      i := multipoint.sdo_ordinates.FIRST;
      -- To 1o zigo shmeio arxizei apo ti thesi 3...
      i := multipoint.sdo_ordinates.NEXT (i + 1);
      result_index := 1;

      WHILE i IS NOT NULL
      LOOP
         multipoint_ordinates.EXTEND (2);
         multipoint_ordinates (result_index) := multipoint.sdo_ordinates (i);
         multipoint_ordinates (result_index + 1) :=
                                             multipoint.sdo_ordinates (i + 1);
         result_index := result_index + 2;
         i := multipoint.sdo_ordinates.NEXT (i + 3);
      END LOOP;

      RESULT :=
         MDSYS.SDO_GEOMETRY (2005,                                      --MULTIPOINT
                       SRID,
                       NULL,
                       sdo_elem_info_array (1,
                                            1,
                                            multipoint_ordinates.COUNT / 2
                                           ),
                       multipoint_ordinates
                      );
      RETURN RESULT;
   END;

    FUNCTION transfer(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY) return MDSYS.SDO_GEOMETRY is
    i pls_integer;
    j pls_integer := 1;
    dx number := 0.0;
    dy number := 0.0;
    S2 MDSYS.SDO_GEOMETRY;
    S1 MDSYS.SDO_GEOMETRY;
    SRID pls_integer;
   BEGIN
       srid:=q.SDO_SRID;

        S1 := S;
        S2 := S;

        dx := Q.SDO_ORDINATES(1) - S1.SDO_ORDINATES(1);
        dy := Q.SDO_ORDINATES(2) - S1.SDO_ORDINATES(2);
        i := S1.SDO_ORDINATES.FIRST;
        WHILE i IS NOT NULL LOOP
            S1.SDO_ORDINATES(i)   := S1.SDO_ORDINATES(i) + dx;
            S1.SDO_ORDINATES(i+1) := S1.SDO_ORDINATES(i+1) + dy;

            i := S1.SDO_ORDINATES.NEXT(i+1);
        END LOOP;

        dx := Q.SDO_ORDINATES(1) - S.SDO_ORDINATES(S2.SDO_ORDINATES.LAST-1);
        dy := Q.SDO_ORDINATES(2) - S.SDO_ORDINATES(S2.SDO_ORDINATES.LAST);
        i := S.SDO_ORDINATES.LAST;
        WHILE i >= S.SDO_ORDINATES.FIRST+1 LOOP
            S2.SDO_ORDINATES(j)   := S.SDO_ORDINATES(i-1) + dx;
            S2.SDO_ORDINATES(j+1) := S.SDO_ORDINATES(i) + dy;

            i := i-2;
            j := j+2;
        END LOOP;

        IF SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_INTERSECTION(SDO_GEOM.SDO_MBR(Q), SDO_GEOM.SDO_MBR(S1), 0.00005), 0.00005) >=
           SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_INTERSECTION(SDO_GEOM.SDO_MBR(Q), SDO_GEOM.SDO_MBR(S2), 0.00005), 0.00005) THEN
                S := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S1.SDO_ELEM_INFO, S1.SDO_ORDINATES);
        ELSE
                S := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S2.SDO_ELEM_INFO, S2.SDO_ORDINATES);
        END IF;

        return S;
    end;

    FUNCTION transfer2(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY) return MDSYS.SDO_GEOMETRY is
    i pls_integer;
    dx number;
    dy number;
    begin
        dx := Q.SDO_ORDINATES(1) - S.SDO_ORDINATES(1);
        dy := Q.SDO_ORDINATES(2) - S.SDO_ORDINATES(2);

        i := S.SDO_ORDINATES.FIRST;
        WHILE i IS NOT NULL LOOP
            S.SDO_ORDINATES(i)   := S.SDO_ORDINATES(i) + dx;
            S.SDO_ORDINATES(i+1) := S.SDO_ORDINATES(i+1) + dy;

            i := S.SDO_ORDINATES.NEXT(i+1);
        END LOOP;

        return S;
    end;

    FUNCTION transfer_cost(Q MDSYS.SDO_GEOMETRY, S MDSYS.SDO_GEOMETRY, dir number) return number is
    result number;
    lQ number;
    lS number;
    dist number;
    begin
        dist := distance(Q.SDO_ORDINATES(1), Q.SDO_ORDINATES(2), S.SDO_ORDINATES(1), S.SDO_ORDINATES(2));
        lQ := distance(Q.SDO_ORDINATES(1), Q.SDO_ORDINATES(2), Q.SDO_ORDINATES(3), Q.SDO_ORDINATES(4));
        lS := distance(S.SDO_ORDINATES(1), S.SDO_ORDINATES(2), S.SDO_ORDINATES(3), S.SDO_ORDINATES(4));

        result := lQ*lS*dir;
        IF dir = 1 THEN
            result := result + dist*1;
        ELSE
            IF lQ*dist > lS*dist THEN
                result := result + lQ*dist;
            ELSE
                result := result + lS*dist;
            END IF;
        END IF;

        return result;
    end;

    FUNCTION f_segment(xi number, yi number, xe number, ye number) return MDSYS.SDO_GEOMETRY is
    seg_info    MDSYS.SDO_ELEM_INFO_ARRAY;
    seg_ords    MDSYS.SDO_ORDINATE_ARRAY;
    SRID pls_integer:=2100;
    begin

        seg_info := MDSYS.SDO_ELEM_INFO_ARRAY();
        seg_info.EXTEND(3);
        seg_info(1) := 1;
        seg_info(2) := 2;
        seg_info(3) := 1;
        seg_ords := MDSYS.SDO_ORDINATE_ARRAY();
        seg_ords.EXTEND(4);
        seg_ords(1) := xi;
        seg_ords(2) := yi;
        seg_ords(3) := xe;
        seg_ords(4) := ye;
        return MDSYS.SDO_GEOMETRY(2002, SRID, NULL, seg_info, seg_ords);
    end;

    FUNCTION position(line MDSYS.SDO_GEOMETRY, x number, y number, old_pos pls_integer) return pls_integer is
    i           pls_integer;
    pos         pls_integer;
    point       MDSYS.SDO_GEOMETRY;
    seg         MDSYS.SDO_GEOMETRY;
    ORD_COUNT   pls_integer;
    SRID pls_integer;
    begin
      srid:=line.SDO_SRID;

        point := MDSYS.SDO_GEOMETRY(2001, SRID, SDO_POINT_TYPE(x, y, NULL), NULL, NULL);
        pos := old_pos;
        i := 2*old_pos + 1;
        ORD_COUNT := line.SDO_ORDINATES.COUNT;
        WHILE i <=  ORD_COUNT - 3 LOOP
            seg := f_segment(line.SDO_ORDINATES(i), line.SDO_ORDINATES(i+1), line.SDO_ORDINATES(i+2), line.SDO_ORDINATES(i+3));
            pos := pos + 1;
            IF SDO_GEOM.RELATE(seg,'ANYINTERACT', point, 0.00005) = 'TRUE' THEN
                return pos;
            END IF;
            i := line.SDO_ORDINATES.NEXT(i+1);
        END LOOP;

        --dbms_output.put_line('POSITION NOT FOUND!!!');
        return old_pos;
    end;

    FUNCTION BadSegment(Q_line MDSYS.SDO_GEOMETRY, S_line MDSYS.SDO_GEOMETRY, PQx number, PQy number, PSx number, PSy number) return boolean is
    seg_1       MDSYS.SDO_GEOMETRY;
    P           MDSYS.SDO_GEOMETRY;
    begin
        seg_1  := f_segment(PSx, PSy, PQx, PQy);
        IF SDO_GEOM.RELATE(seg_1, 'ANYINTERACT', S_line, 0.00005) = 'TRUE' OR SDO_GEOM.RELATE(seg_1, 'ANYINTERACT', Q_line, 0.00005) = 'TRUE' THEN
            return true;
        END IF;

        return false;
    end;

    PROCEDURE SmoothLine(L IN OUT MDSYS.SDO_GEOMETRY) is
    i           pls_integer := 1;
    j           pls_integer := 1;
    pre_x       number := -1234.121;
    pre_y       number := -4321.131;
    prepre_x    number := -5678.141;
    prepre_y    number := -8765.151;
    NewL_ords   MDSYS.SDO_ORDINATE_ARRAY;
    ORD_COUNT   pls_integer;
    SRID pls_integer;
    begin
      srid:=l.SDO_SRID;

        NewL_ords := MDSYS.SDO_ORDINATE_ARRAY();
        ORD_COUNT := L.SDO_ORDINATES.COUNT;
        WHILE i <= ORD_COUNT - 1 LOOP
            IF L.SDO_ORDINATES(i) = pre_x AND L.SDO_ORDINATES(i+1) = pre_y THEN
                NULL;
            ELSIF UTILITIES.check_colinear(prepre_x, prepre_y, pre_x, pre_y, L.SDO_ORDINATES(i), L.SDO_ORDINATES(i+1)) = TRUE THEN
                NULL;
            ELSE
                NewL_ords.EXTEND(2);
                NewL_ords(j)   := L.SDO_ORDINATES(i);
                NewL_ords(j+1) := L.SDO_ORDINATES(i+1);
                prepre_x := pre_x;
                prepre_y := pre_y;
                pre_x := NewL_ords(j);
                pre_y := NewL_ords(j+1);
                j := j + 2;
            END IF;
            i := i + 2;
        END LOOP;

        L := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, L.SDO_ELEM_INFO, NewL_ords);
    end;

    FUNCTION LIP(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, Q_LEN number, S_LEN  number) return number is
    i           pls_integer;
    j           pls_integer := 1;
    k           pls_integer;
    m           pls_integer;
    pos         pls_integer;
    old_pos     pls_integer := 0;
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
    IP          pls_integer := 1;
    first_time_trace_null boolean := TRUE;
    point1      MDSYS.SDO_GEOMETRY;
    point2      MDSYS.SDO_GEOMETRY;
    zerodist    boolean := FALSE;
    S_ORD_LAST  pls_integer;
    Q_ORD_COUNT pls_integer;
    SRID pls_integer;
    begin
      srid:=q.SDO_SRID;

        i := Q.SDO_ORDINATES.FIRST;
        start_x := Q.SDO_ORDINATES(i);
        start_y := Q.SDO_ORDINATES(i+1);

        S_ORD_LAST := S.SDO_ORDINATES.LAST;
        --UTILITIES.print_geometry(Q, 'Q'); UTILITIES.print_geometry(S, 'S');
        IF trans THEN
            S := UTILITIES.transfer2(Q,S);
        ELSE
            IF SDO_GEOM.RELATE(Q,'ANYINTERACT', S, 0.00005) = 'FALSE' THEN
                -- Construct poly between the two trajectories
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();
                j := 1;
                WHILE j <= S_ORD_LAST LOOP
                    poly_ords.EXTEND(1);poly_ords(j) := S.SDO_ORDINATES(j);
                    j := j + 1;
                END LOOP;

                i := Q.SDO_ORDINATES.LAST;
                WHILE i >= 1 LOOP
                    poly_ords.EXTEND(2);poly_ords(j) := Q.SDO_ORDINATES(i-1);poly_ords(j+1) := Q.SDO_ORDINATES(i);j:=j+2;
                    i := Q.SDO_ORDINATES.PRIOR(i-1);
                END LOOP;
                poly_ords.EXTEND(2);poly_ords(j) := poly_ords(1);poly_ords(j+1) := poly_ords(2);j:=j+2;
                poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
                all_area := SDO_GEOM.SDO_AREA(poly, 0.00005);

                IF Q_LEN+S_LEN <> 0 THEN return all_area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN)); ELSE return all_area; END IF;
            END IF;
        END IF;

        SmoothLine(S);

        Q_ORD_COUNT := Q.SDO_ORDINATES.COUNT;
        WHILE i <= Q_ORD_COUNT - 3 LOOP
            seg  := f_segment(Q.SDO_ORDINATES(i), Q.SDO_ORDINATES(i+1), Q.SDO_ORDINATES(i+2), Q.SDO_ORDINATES(i+3));
            point1 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q.SDO_ORDINATES(i), Q.SDO_ORDINATES(i+1), NULL), NULL, NULL);
            point2 := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q.SDO_ORDINATES(i+2), Q.SDO_ORDINATES(i+3), NULL), NULL, NULL);
            IF (SDO_GEOM.RELATE(S, 'ANYINTERACT', point1, 0.00005) = 'TRUE' AND SDO_GEOM.RELATE(S, 'ANYINTERACT', point2, 0.00005) = 'TRUE') OR
               (Q.SDO_ORDINATES(i)=Q.SDO_ORDINATES(i+2) AND Q.SDO_ORDINATES(i+1)=Q.SDO_ORDINATES(i+3))
            THEN zerodist := TRUE; GOTO PROBLEM; END IF;

            IF flag THEN
                poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                dist := 0.0; sim := 0.0;
                flag := FALSE;
            END IF;

            --UTILITIES.print_geometry(seg, 'seg');UTILITIES.print_geometry(S, 'S');
            trace := SDO_GEOM.SDO_INTERSECTION(S, seg, 0.000005);   --UTILITIES.print_geometry(trace, 'trace');
            IF trace IS NOT NULL THEN
                trace := f_sort(trace, seg);
                IF add_last THEN
                    poly_ords.EXTEND(2);poly_ords(j) := Q.SDO_ORDINATES(i);poly_ords(j+1) := Q.SDO_ORDINATES(i+1);j:=j+2;
                    dist := dist + distance(Q.SDO_ORDINATES(i-2), Q.SDO_ORDINATES(i-1), Q.SDO_ORDINATES(i), Q.SDO_ORDINATES(i+1));
                    add_last := FALSE;
                END IF;

                k := trace.SDO_ORDINATES.FIRST;
                WHILE k IS NOT NULL LOOP
                    IF flag THEN
                        poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
                        poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);
                        poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
                        dist := 0.0; sim := 0.0;
                        flag := FALSE;
                    END IF;
                    dist := dist + distance(poly_ords(j-2), poly_ords(j-1), trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1));
                    poly_ords.EXTEND(2);poly_ords(j) := trace.SDO_ORDINATES(k);poly_ords(j+1) := trace.SDO_ORDINATES(k+1);j:=j+2;

                    pos := position(S, trace.SDO_ORDINATES(k), trace.SDO_ORDINATES(k+1), old_pos);
                    m := pos;
                    WHILE old_pos < m LOOP
                        poly_ords.EXTEND(2);poly_ords(j) := S.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S.SDO_ORDINATES(2*m);j:=j+2;

                        m := S.SDO_ORDINATES.PRIOR(m);
                    END LOOP;
                    old_pos := pos;
                    poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

                    flag := TRUE;
                    first_time_trace_null := TRUE;
                    poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
                    area := SDO_GEOM.SDO_AREA(poly, 0.00005);                           --dbms_output.put_line('area'||TO_CHAR(area));
                    all_area := all_area + area;
                    all_dist := all_dist + dist;
                    IP := IP + 1;
                    start_x := trace.SDO_ORDINATES(k);
                    start_y := trace.SDO_ORDINATES(k+1);
                    j := 1;
                    IF Q_LEN+S_LEN <> 0 THEN sim  := area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN)); ELSE sim  := area; END IF;

                    sum_sim := sum_sim + sim;

                    k := trace.SDO_ORDINATES.NEXT(k+1);
                END LOOP;
            ELSE
                IF first_time_trace_null THEN
                    prev_x := start_x; prev_y := start_y; first_time_trace_null := FALSE;
                ELSE
                    prev_x := Q.SDO_ORDINATES(i-2); prev_y := Q.SDO_ORDINATES(i-1);
                END IF;
                IF NOT firstseg THEN poly_ords.EXTEND(2);poly_ords(j) := Q.SDO_ORDINATES(i);poly_ords(j+1) := Q.SDO_ORDINATES(i+1);j:=j+2; ELSE firstseg := FALSE; END IF;
                dist := dist + distance(prev_x, prev_y, Q.SDO_ORDINATES(i), Q.SDO_ORDINATES(i+1));
            END IF;

            add_last := TRUE;firstseg := FALSE;
            <<PROBLEM>>
            i := Q.SDO_ORDINATES.NEXT(i+1);
            IF zerodist = TRUE AND i > Q_ORD_COUNT - 3 THEN GOTO BYPASSPROBLEM; END IF;
            zerodist := FALSE;
        END LOOP;

        -- Form the polygon after the last interesection point
        IF flag THEN
            poly_info := MDSYS.SDO_ELEM_INFO_ARRAY();poly_info.EXTEND(3);poly_info(1) := 1;poly_info(2) := 1003;poly_info(3) := 1;
            poly_ords := MDSYS.SDO_ORDINATE_ARRAY();poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;
            dist := 0.0; sim := 0.0;
        END IF;
        dist := dist + distance(poly_ords(j-2), poly_ords(j-1), Q.SDO_ORDINATES(Q_ORD_COUNT-1), Q.SDO_ORDINATES(Q_ORD_COUNT));
        poly_ords.EXTEND(2);poly_ords(j) := Q.SDO_ORDINATES(Q_ORD_COUNT-1);poly_ords(j+1) := Q.SDO_ORDINATES(Q_ORD_COUNT);j:=j+2;

        poly_ords.EXTEND(2);poly_ords(j) := S.SDO_ORDINATES(S_ORD_LAST-1);poly_ords(j+1) := S.SDO_ORDINATES(S_ORD_LAST);j:=j+2;
        pos := position(S, S.SDO_ORDINATES(S_ORD_LAST-1), S.SDO_ORDINATES(S_ORD_LAST), old_pos);
        m := pos;
        WHILE old_pos < m LOOP
            poly_ords.EXTEND(2);poly_ords(j) := S.SDO_ORDINATES(2*m-1);poly_ords(j+1) := S.SDO_ORDINATES(2*m);j:=j+2;

            m := S.SDO_ORDINATES.PRIOR(m);
        END LOOP;
        poly_ords.EXTEND(2);poly_ords(j) := start_x;poly_ords(j+1) := start_y;j:=j+2;

        poly := MDSYS.SDO_GEOMETRY(2003, SRID, NULL, poly_info, poly_ords); --UTILITIES.print_geometry(poly, 'poly');
        area := SDO_GEOM.SDO_AREA(poly, 0.00005);
        all_area := all_area + area;
        all_dist := all_dist + dist;
        IF Q_LEN+S_LEN <> 0 THEN sim  := area * (SDO_GEOM.SDO_LENGTH(poly, 0.00005)/(Q_LEN+S_LEN)); ELSE sim  := area; END IF;

        <<BYPASSPROBLEM>>
        sum_sim := sum_sim + sim;
        return sum_sim;
    end;

    FUNCTION FindBadSegments(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, policy pls_integer, Q_LEN number, S_LEN   number) return number is
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
    sim         number := 0.0;
    sum_sim     number := 0.0;
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
    SRID pls_integer;
    begin
      srid:=q.SDO_SRID;
        q_counter := Q.SDO_ORDINATES.FIRST;
        s_counter := S.SDO_ORDINATES.FIRST;
        IF trans THEN
            S := UTILITIES.transfer2(Q,S); --UTILITIES.print_geometry(Q, 'Q'); UTILITIES.print_geometry(S, 'S');
        END IF;

        Q_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();Q_line_info.EXTEND(3);Q_line_info(1) := 1;Q_line_info(2) := 2;Q_line_info(3) := 1;Q_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
        S_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();S_line_info.EXTEND(3);S_line_info(1) := 1;S_line_info(2) := 2;S_line_info(3) := 1;S_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);
        WHILE q_counter <= Q.SDO_ORDINATES.COUNT - 3 AND s_counter <= S.SDO_ORDINATES.COUNT - 3 LOOP
            Q_seg  := f_segment(Q.SDO_ORDINATES(q_counter), Q.SDO_ORDINATES(q_counter+1), Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3));
            S_seg  := f_segment(S.SDO_ORDINATES(s_counter), S.SDO_ORDINATES(s_counter+1), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3));
            IF SDO_GEOM.RELATE(Q_seg,'ANYINTERACT', S_seg, 0.00005) = 'TRUE' THEN
                last_good_Q := (q_counter + 1) / 2;
                last_good_S := (s_counter + 1) / 2;
                Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;
                S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;
            ELSE
                Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
                S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                IF BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
                    bad_Q := (q_counter + 1) / 2;
                    bad_S := (s_counter + 1) / 2;
                    k := 1;
                    WHILE k <= policy LOOP
                        IF q_counter <= Q.SDO_ORDINATES.COUNT - 5 AND s_counter <= S.SDO_ORDINATES.COUNT - 5 THEN
                            q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
                            Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
                            Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);

                            s_counter := S.SDO_ORDINATES.NEXT(s_counter+1);
                            S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
                            S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                            IF BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
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
        sim := LIP(Q_line, S_line, false, Q_LEN, S_LEN);
        sum_sim := sum_sim + sim;

        IF q_counter <= Q.SDO_ORDINATES.COUNT - 3 AND s_counter <= S.SDO_ORDINATES.COUNT - 3 THEN
            NewQ_ords := MDSYS.SDO_ORDINATE_ARRAY();
            FOR c IN q_counter .. Q.SDO_ORDINATES.COUNT LOOP
                NewQ_ords.EXTEND(1); NewQ_ords(cc) := Q.SDO_ORDINATES(c); cc := cc + 1;
            END LOOP;
            Q := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q.SDO_ELEM_INFO, NewQ_ords);

            cc := 1;
            NewS_ords := MDSYS.SDO_ORDINATE_ARRAY();
            FOR c IN s_counter .. S.SDO_ORDINATES.COUNT LOOP
                NewS_ords.EXTEND(1); NewS_ords(cc) := S.SDO_ORDINATES(c); cc := cc + 1;
            END LOOP;
            S := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S.SDO_ELEM_INFO, NewS_ords);

            sum_sim := sum_sim + FindBadSegments(Q, S, false, policy, Q_LEN, S_LEN);
        END IF;

        return sum_sim;
    end;

    FUNCTION GenLIP(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, policy pls_integer, Q_LEN number, S_LEN    number) return number is --, avg_sim    IN OUT number, NoLIPgrams IN OUT pls_integer
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
    sim         number := 0.0;
    sum_sim     number := 0.0;
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
    a           number := 10.0;
    avg_len     number := 0.0;
    Q_start     MDSYS.SDO_GEOMETRY;
    Q_end       MDSYS.SDO_GEOMETRY;
    S_start     MDSYS.SDO_GEOMETRY;
    S_end       MDSYS.SDO_GEOMETRY;
    fi          number := 0.0;
    dir         number := 0.0;
    cost        number := 0.0;
    Q_ORD_COUNT pls_integer;
    S_ORD_COUNT pls_integer;
    SRID pls_integer;
    begin
      srid:=q.SDO_SRID;

        q_counter := Q.SDO_ORDINATES.FIRST;
        s_counter := S.SDO_ORDINATES.FIRST;
        IF trans THEN
            S := UTILITIES.transfer2(Q,S); --UTILITIES.print_geometry(Q, 'Q'); UTILITIES.print_geometry(S, 'S');
        END IF;

        Q_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();Q_line_info.EXTEND(3);Q_line_info(1) := 1;Q_line_info(2) := 2;Q_line_info(3) := 1;Q_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
        Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
        S_line_info := MDSYS.SDO_ELEM_INFO_ARRAY();S_line_info.EXTEND(3);S_line_info(1) := 1;S_line_info(2) := 2;S_line_info(3) := 1;S_line_ords := MDSYS.SDO_ORDINATE_ARRAY();
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+1);Sj:=Sj+2;
        S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);

        --avg_len := distance(Q.SDO_ORDINATES(1),Q.SDO_ORDINATES(2), Q.SDO_ORDINATES(3),Q.SDO_ORDINATES(4));
        --avg_len := avg_len + distance(S.SDO_ORDINATES(1),S.SDO_ORDINATES(2), S.SDO_ORDINATES(3),S.SDO_ORDINATES(4));
        Q_ORD_COUNT := Q.SDO_ORDINATES.COUNT; S_ORD_COUNT := S.SDO_ORDINATES.COUNT;
        WHILE q_counter <= Q_ORD_COUNT - 3 AND s_counter <= S_ORD_COUNT - 3 LOOP
            Q_seg  := f_segment(Q.SDO_ORDINATES(q_counter), Q.SDO_ORDINATES(q_counter+1), Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3));
            S_seg  := f_segment(S.SDO_ORDINATES(s_counter), S.SDO_ORDINATES(s_counter+1), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3));

            Q_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_seg.SDO_ORDINATES(1), Q_seg.SDO_ORDINATES(2), NULL), NULL, NULL);
            Q_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q_seg.SDO_ORDINATES(3), Q_seg.SDO_ORDINATES(4), NULL), NULL, NULL);
            S_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(1), S_seg.SDO_ORDINATES(2), NULL), NULL, NULL);
            S_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(3), S_seg.SDO_ORDINATES(4), NULL), NULL, NULL);
            fi := angle3(Q_start, Q_end, S_start, S_end);

            IF fi > 90 THEN
                dir := 1 - ((cos(fi) + 1) / 2);
                cost := transfer_cost(Q_seg, S_seg, dir);
                sum_sim := sum_sim + cost;
                q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
                s_counter := Q.SDO_ORDINATES.NEXT(s_counter+1);
                GOTO RECALL;
            END IF;
            --S_seg := UTILITIES.transfer2(Q_seg, S_seg);

        --  IF SDO_GEOM.SDO_LENGTH(Q_seg, 0.00005) > a*avg_len OR SDO_GEOM.SDO_LENGTH(S_seg, 0.00005) > a*avg_len THEN GOTO RECALL; END IF;
            IF SDO_GEOM.RELATE(Q_seg,'ANYINTERACT', S_seg, 0.00005) = 'TRUE' THEN
                last_good_Q := (q_counter + 1) / 2;
                last_good_S := (s_counter + 1) / 2;
                Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter+2);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+3);Qj:=Qj+2;
                S_line_ords.EXTEND(2);S_line_ords(Sj) := S.SDO_ORDINATES(s_counter+2);S_line_ords(Sj+1) := S.SDO_ORDINATES(s_counter+3);Sj:=Sj+2;
            ELSE
                Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);
                S_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, S_line_info, S_line_ords);
                IF BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
                    bad_Q := (q_counter + 1) / 2;
                    bad_S := (s_counter + 1) / 2;
                    k := 1;
                    WHILE k <= policy LOOP
                        IF q_counter <= Q_ORD_COUNT - 5 AND s_counter <= S_ORD_COUNT - 5 THEN
                            q_counter := Q.SDO_ORDINATES.NEXT(q_counter+1);
                            Q_line_ords.EXTEND(2);Q_line_ords(Qj) := Q.SDO_ORDINATES(q_counter);Q_line_ords(Qj+1) := Q.SDO_ORDINATES(q_counter+1);Qj:=Qj+2;
                            Q_line := MDSYS.SDO_GEOMETRY(2002, SRID, NULL, Q_line_info, Q_line_ords);

                            IF BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
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
                            IF BadSegment(Q_line, S_line, Q.SDO_ORDINATES(q_counter+2), Q.SDO_ORDINATES(q_counter+3), S.SDO_ORDINATES(s_counter+2), S.SDO_ORDINATES(s_counter+3)) = TRUE THEN
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
        sim := LIP(Q_line, S_line, false, Q_LEN, S_LEN);

--      IF sim < a*avg_sim THEN
--          NoLIPgrams := NoLIPgrams + 1;
            sum_sim := sum_sim + sim;
--          avg_sim := sum_sim / NoLIPgrams;
--      END IF;

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

            sum_sim := sum_sim + GenLIP(Q, S, false, policy, Q_LEN, S_LEN); --, avg_sim, NoLIPgrams
        END IF;

        return sum_sim;
    end;

    FUNCTION DDIST(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, policy pls_integer) return number is
    i           pls_integer;
    j           pls_integer;
    m           pls_integer := 1;
    NumOfAngles pls_integer := 0;
    Q_pos       pls_integer := 1;
    S_pos       pls_integer := 1;
    Q_start     MDSYS.SDO_GEOMETRY;
    Q_end       MDSYS.SDO_GEOMETRY;
    S_start     MDSYS.SDO_GEOMETRY;
    S_end       MDSYS.SDO_GEOMETRY;
    Q_seg       MDSYS.SDO_GEOMETRY;
    S_seg       MDSYS.SDO_GEOMETRY;
    New_ords    MDSYS.SDO_ORDINATE_ARRAY;
    F_Q         number := 0.0;
    F_S         number := 0.0;
    avrg_F_Q    number := 0.0;
    avrg_F_S    number := 0.0;
    F           number := 0.0;
    fi          number := 0.0;
    x           number := 0.0;
    start_x     number := 0.0;
    start_y     number := 0.0;
    Q_next_x    number := 0.0;
    S_next_x    number := 0.0;
    Q_seg_len   number := 0.0;
    S_seg_len   number := 0.0;
    clos_next   varchar2(1);
    Qdist       number := 0.0;
    Sdist       number := 0.0;
    all_dist    number := 0.0;
    dd          number := 0.0;
    sum_dd      number := 0.0;
    proj_Q_to_S_x number := 0.0;
    proj_Q_to_S_y number := 0.0;
    proj_S_to_Q_x number := 0.0;
    proj_S_to_Q_y number := 0.0;
    clip_Q      boolean := false;
    clipQ       number := 0.0;
    clip_S      boolean := false;
    clipS       number := 0.0;
    Q_LEN       number := 0.0;
    S_LEN       number := 0.0;
    dx          number := 0.0;
    dy          number := 0.0;
    penalty     number := 0.0;
    Q_ORD_COUNT pls_integer;
    S_ORD_COUNT pls_integer;
    SRID pls_integer;
    begin
      
      if(Q.sdo_srid<>S.sdo_srid) then
        raise_application_error(-20100, 'The given geometries have different srids');
      end if;
      srid:=Q.sdo_srid;

        Q_LEN := SDO_GEOM.SDO_LENGTH(Q, 0.00005);
        S_LEN := SDO_GEOM.SDO_LENGTH(S, 0.00005);
        all_dist := Q_LEN+S_LEN;

        IF Q_LEN > S_LEN AND Q_LEN <> 0 THEN penalty := Q_LEN / S_LEN;
        ELSE penalty := S_LEN / Q_LEN; END IF;

        j := S.SDO_ORDINATES.FIRST;
        i := Q.SDO_ORDINATES.FIRST;
        start_x := Q.SDO_ORDINATES(i);
        start_y := Q.SDO_ORDINATES(i+1);
        Q_ORD_COUNT := Q.SDO_ORDINATES.COUNT; S_ORD_COUNT := S.SDO_ORDINATES.COUNT;
        WHILE i <= Q_ORD_COUNT - 3 AND j <= S_ORD_COUNT - 3 LOOP
            Q_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(start_x, start_y, NULL), NULL, NULL);
            Q_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(Q.SDO_ORDINATES(2*Q_pos + 1), Q.SDO_ORDINATES(2*Q_pos + 2), NULL), NULL, NULL);
            S_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S.SDO_ORDINATES(2*S_pos - 1), S.SDO_ORDINATES(2*S_pos), NULL), NULL, NULL);
            S_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S.SDO_ORDINATES(2*S_pos + 1), S.SDO_ORDINATES(2*S_pos + 2), NULL), NULL, NULL);
            Q_seg  := f_segment(start_x, start_y, Q.SDO_ORDINATES(2*Q_pos + 1), Q.SDO_ORDINATES(2*Q_pos + 2));
            S_seg  := f_segment(S.SDO_ORDINATES(2*S_pos - 1), S.SDO_ORDINATES(2*S_pos), S.SDO_ORDINATES(2*S_pos + 1), S.SDO_ORDINATES(2*S_pos + 2));

            -- Now clip
            IF clip_Q = true THEN
                clip_Q := false; --clipQ := 0.0; i := Q.SDO_ORDINATES.NEXT(i+1); Q_pos := Q_pos + 1;
                IF i > Q_ORD_COUNT - 3 THEN exit; END IF;
                Q_seg  := f_segment(proj_S_to_Q_x, proj_S_to_Q_y, Q.SDO_ORDINATES(2*Q_pos + 1), Q.SDO_ORDINATES(2*Q_pos + 2));
            END IF;
            IF clip_S = true THEN
                clip_S := false; --clipS := 0.0; j := S.SDO_ORDINATES.NEXT(j+1); S_pos := S_pos + 1;
                IF j > S_ORD_COUNT - 3 THEN exit; END IF;
                S_seg  := f_segment(proj_Q_to_S_x, proj_Q_to_S_y, S.SDO_ORDINATES(2*S_pos + 1), S.SDO_ORDINATES(2*S_pos + 2));
            END IF;

            S_seg := UTILITIES.transfer2(Q_seg, S_seg);
            S_start := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(1), S_seg.SDO_ORDINATES(2), NULL), NULL, NULL);
            S_end := MDSYS.SDO_GEOMETRY(2001, SRID, MDSYS.SDO_POINT_TYPE(S_seg.SDO_ORDINATES(3), S_seg.SDO_ORDINATES(4), NULL), NULL, NULL);

            F_Q := direction(Q_start, Q_end);
            avrg_F_Q := avrg_F_Q + F_Q;
            F_S := direction(S_start, S_end);
            avrg_F_S := avrg_F_S + F_S;
            fi := angle3(Q_start, Q_end, S_start, S_end);

            Q_seg_len := SDO_GEOM.SDO_LENGTH(Q_seg, 0.00005);
            S_seg_len := SDO_GEOM.SDO_LENGTH(S_seg, 0.00005);
            IF Q_seg_len <= S_seg_len THEN
                clos_next := 'Q';
            ELSE
                clos_next := 'S';
            END IF;

            Qdist := 0.0;
            Sdist := 0.0;
            IF clos_next = 'Q' THEN
                Qdist := distance(start_x, start_y, Q_end.SDO_POINT.X, Q_end.SDO_POINT.Y);
                Sdist := Qdist;
                if (S_seg_len = 0) then
                  S_seg_len := 0.0001;
                end if;
                proj_Q_to_S_x := S_start.SDO_POINT.X + (S_end.SDO_POINT.X - S_start.SDO_POINT.X) * (Sdist / S_seg_len);
                proj_Q_to_S_y := S_start.SDO_POINT.Y + (S_end.SDO_POINT.Y - S_start.SDO_POINT.Y) * (Sdist / S_seg_len);

                --clipS := clipS + Sdist;
                i := Q.SDO_ORDINATES.NEXT(i+1);
                start_x := Q_end.SDO_POINT.X; start_y := Q_end.SDO_POINT.Y;
                Q_pos := Q_pos + 1;
                clip_S := true; clipQ := 0.0; clip_Q := false;
            ELSIF clos_next = 'S' THEN
                Sdist := distance(start_x, start_y, S_end.SDO_POINT.X, S_end.SDO_POINT.Y);
                Qdist := Sdist;
                if (Q_seg_len = 0) then
                  Q_seg_len := 0.0001;
                end if;
                proj_S_to_Q_x := Q_start.SDO_POINT.X + (Q_end.SDO_POINT.X - Q_start.SDO_POINT.X) * (Qdist / Q_seg_len);
                proj_S_to_Q_y := Q_start.SDO_POINT.Y + (Q_end.SDO_POINT.Y - Q_start.SDO_POINT.Y) * (Qdist / Q_seg_len);

                --clipQ := clipQ + Qdist;
                j := S.SDO_ORDINATES.NEXT(j+1);
                start_x := proj_S_to_Q_x; start_y := proj_S_to_Q_y;
                S_pos := S_pos + 1;
                clip_Q := true; clipS := 0.0; clip_S := false;
            END IF;

            dd := (1 - ((cos(fi) + 1) / 2)) * ((Qdist+Sdist) / all_dist);
            --dbms_output.put_line('dd=' || to_char(dd) || 'Qdist=' || to_char(Qdist) || 'fi=' || to_char(fi));

            sum_dd := sum_dd + dd;
            NumOfAngles := NumOfAngles + 1;
        END LOOP;
        --dbms_output.put_line('NumOfAngles=' || to_char(NumOfAngles));
        return sum_dd * penalty;
    end;

    FUNCTION compute_MDI (startQ_tp TAU_TLL.D_Timepoint_Sec, endQ_tp TAU_TLL.D_Timepoint_Sec, startS_tp TAU_TLL.D_Timepoint_Sec, endS_tp TAU_TLL.D_Timepoint_Sec, delta TAU_TLL.D_Interval) return number is
    Q_per       TAU_TLL.D_Period_Sec;
    S_per       TAU_TLL.D_Period_Sec;
    S_per_plus  TAU_TLL.D_Period_Sec;
    S_per_minus TAU_TLL.D_Period_Sec;
    S_per_stretch  TAU_TLL.D_Period_Sec;
    intersection_per TAU_TLL.D_Period_Sec;
    intersection_Sec number;
    stretch_b  TAU_TLL.D_Timepoint_Sec;
    stretch_e  TAU_TLL.D_Timepoint_Sec;
    mdi number := 0;
    BEGIN
        Q_per := TAU_TLL.D_Period_sec(startQ_tp, endQ_tp);--dbms_output.put_line('Q_per START=' || Q_per.b.to_string());dbms_output.put_line('Q_per END=' || Q_per.e.to_string());
        S_per := TAU_TLL.D_Period_sec(startS_tp, endS_tp);--dbms_output.put_line('S_per START=' || S_per.b.to_string());dbms_output.put_line('S_per END=' || S_per.e.to_string());

        S_per_plus := S_per;
        S_per_minus := S_per;
        stretch_b := S_per.b;
        stretch_e := S_per.e;

        IF Q_per.f_overlaps(Q_per, S_per) = 1 THEN
            intersection_per := Q_per.intersects(Q_per, S_per);--dbms_output.put_line('intersection_per START=' || intersection_per.b.to_string());dbms_output.put_line('intersection_per END=' || intersection_per.e.to_string());
            intersection_Sec := intersection_per.duration().m_Value;
            mdi := intersection_Sec;
        END IF;

        S_per_plus.f_add_interval(delta);--dbms_output.put_line('S_per_plus START=' || S_per_plus.b.to_string());dbms_output.put_line('S_per_plus END=' || S_per_plus.e.to_string());
        IF Q_per.f_overlaps(Q_per, S_per_plus) = 1 THEN
            intersection_per := Q_per.intersects(Q_per, S_per_plus);--dbms_output.put_line('PLUS intersection_per START=' || intersection_per.b.to_string());dbms_output.put_line('PLUS intersection_per END=' || intersection_per.e.to_string());
            intersection_Sec := intersection_per.duration().m_Value;
            IF intersection_Sec > mdi THEN mdi := intersection_Sec; END IF;
        END IF;

        S_per_minus.f_sub_interval(delta);--dbms_output.put_line('S_per_minus START=' || S_per_minus.b.to_string());dbms_output.put_line('S_per_minus END=' || S_per_minus.e.to_string());
        IF Q_per.f_overlaps(Q_per, S_per_minus) = 1 THEN
            intersection_per := Q_per.intersects(Q_per, S_per_minus);--dbms_output.put_line('MINUS intersection_per START=' || intersection_per.b.to_string());dbms_output.put_line('MINUS intersection_per END=' || intersection_per.e.to_string());
            intersection_Sec := intersection_per.duration().m_Value;
            IF intersection_Sec > mdi THEN mdi := intersection_Sec; END IF;
        END IF;

        stretch_b.f_sub_interval(delta);
        stretch_e.f_add_interval(delta);
        S_per_stretch := TAU_TLL.D_Period_sec(stretch_b, stretch_e);--dbms_output.put_line('S_per_stretch START=' || S_per_stretch.b.to_string());dbms_output.put_line('S_per_stretch END=' || S_per_stretch.e.to_string());
        IF Q_per.f_overlaps(Q_per, S_per_stretch) = 1 THEN
            intersection_per := Q_per.intersects(Q_per, S_per_stretch);--dbms_output.put_line('STRETCH intersection_per START=' || intersection_per.b.to_string());dbms_output.put_line('STRETCH intersection_per END=' || intersection_per.e.to_string());
            intersection_Sec := intersection_per.duration().m_Value;
            IF intersection_Sec > mdi THEN mdi := intersection_Sec; END IF;
        END IF;

        return mdi;
    END;
    
    function azimuth(xi number,yi number,xe number,ye number) return number is
    /*
    This function returns the azimuth of a segment, that is the clockwise angle (in radians) 
    between the north and the segment or direction etc. Segment coordinates in meters.
    */
      az number;--in radians
      dx number;dy number;
    begin
      dx:=xe - xi;
      dy:=ye - yi;
      --check if is the same point
      if dy=0 and dx=0 then
        az:=null;
      --else if on the xx axis
      elsif dy=0 then
        --if on 0x semiaxis
        if dx > 0 then
          az:=acos(-1)/2;
        --else on x'0 semiaxis
        else
          az:=3*acos(-1)/2;
        end if;
      --else if on the yy axis
      elsif dx=0 then
        --if on 0y semiaxis
        if dy > 0 then
          az:=0;
        --else on y'0 semiaxis
        else
          az:=acos(-1);
        end if;
      --else in between axes
      else
      /*
      ATAN returns the arc tangent of n. The argument n can be in an unbounded 
      range and returns a value in the range of -pi/2 to pi/2, expressed in radians.
      */
        /*
        If at 1st quadrant then tangent of the angle with the xx axis is positive 
        so it is subtracted from pi/2 to form azimuth.
        The same if is on 2th quadrant as the tangent of the angle with the xx axis is negative
        so again it must be "subtracted" from pi/2 to form azimuth
        */
        if (dy>0 and dx>0) or (dy<0 and dx>0) then
          az:=(acos(-1)/2)-atan(dy/dx);
        /*
        If at 3nd quadrant then tangent of the angle with the xx axis is negative 
        so it is "subtracted" from 3pi/2 to form azimuth.
        The same if is on 4rd quadrant as the tangent of the angle with the xx axis is positive
        so again it must be subtracted from 3pi/2 to form azimuth
        */
        elsif (dy<0 and dx<0) or (dy>0 and dx<0) then
          az:=(3*acos(-1)/2)-atan(dy/dx);
        end if;
      end if;
  
      if az = 2.0 * acos(-1) then
        az := 0.0;
      end if;
      return az;
    end azimuth;
    
    function azimuth(geom1 sdo_geometry, geom2 sdo_geometry) return number is
    /*
    This function calls the azimuth function for two point geometries.
    */
      geom1x number;
      geom1y number;
      geom2x number;
      geom2y number;
    begin
      if ((geom1 is null) or(geom2 is null)) then
        return -1;
      end if;
      if (geom1.SDO_POINT is null) then
        geom1x:=geom1.SDO_ORDINATES(1);
        geom1y:=geom1.SDO_ORDINATES(2);
      else
        geom1x:=geom1.SDO_POINT.X;
        geom1y:=geom1.SDO_POINT.Y;
      end if;
      if (geom2.SDO_POINT is null) then
        geom2x:=geom2.SDO_ORDINATES(1);
        geom2y:=geom2.SDO_ORDINATES(2);
      else
        geom2x:=geom2.SDO_POINT.X;
        geom2y:=geom2.SDO_POINT.Y;
      end if;
    
    
      return utilities.azimuth(geom1x,geom1y,geom2x,geom2y);
    end azimuth;
    
    function is_point_between(minx number, miny number, maxx number, maxy number, x number, y number,tolerance number:=0.001) return boolean is
      result boolean:=false;
    begin
      if (minx-tolerance<=x and x<=maxx+tolerance) and (miny-tolerance<=y and x<=maxy+tolerance) then
        result:=true;
      end if;
      return result;
    end;
    

END;
/


