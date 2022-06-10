Prompt Package Body HPV;
CREATE OR REPLACE PACKAGE BODY hpv
IS

-- -----------------------------------------------------
-- Function minof_2
-- -----------------------------------------------------
  FUNCTION minof_2
  (
    x IN NUMBER,
    y IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    IF x < y THEN
      RETURN x;
    END IF;
    RETURN y;
  END minof_2;

-- -----------------------------------------------------
-- Function maxof_2
-- -----------------------------------------------------
  FUNCTION maxof_2
  (
    x IN NUMBER,
    y IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    IF x > y THEN
      RETURN x;
    END IF;
    RETURN y;
  END maxof_2;

-- -----------------------------------------------------
-- Function euclidean_distance
-- -----------------------------------------------------
  FUNCTION euclidean_distance
  (
    xi IN NUMBER,
    yi IN NUMBER,
    xe IN NUMBER,
    ye IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    RETURN sqrt(power(ye - yi, 2) + power(xe - xi, 2));
  END euclidean_distance;

-- -----------------------------------------------------
-- Function factorial
-- -----------------------------------------------------
  FUNCTION factorial
  (
    x IN NUMBER
  )
    RETURN NUMBER
  IS
    i NUMBER;
    ret NUMBER := 1;
  BEGIN
    FOR i IN 1..x LOOP
      ret := ret * i;
    END LOOP;

    RETURN ret;
  END factorial;

-- -----------------------------------------------------
-- Function pi
-- -----------------------------------------------------
  FUNCTION pi
        RETURN NUMBER
    IS
  BEGIN
    RETURN acos(-1);
  END pi;

-- -----------------------------------------------------
-- Function to_deg
-- -----------------------------------------------------
  FUNCTION to_deg
    (
        rad IN NUMBER
    )
        RETURN NUMBER
    IS
    deg NUMBER;
  BEGIN
    deg := rad * (180 / pi());
    IF deg >= 0 THEN
      RETURN deg;
    ELSE
      RETURN 360 + deg;
    END IF;
  END to_deg;

-- -----------------------------------------------------
-- Function angle_xx
-- -----------------------------------------------------
  FUNCTION angle_xx
    (
        xi IN NUMBER,
    yi IN NUMBER,
    xe IN NUMBER,
    ye IN NUMBER
    )
        RETURN NUMBER
    IS
  BEGIN
    RETURN atan2(ye - yi, xe - xi);
  END angle_xx;

-- -----------------------------------------------------
-- Function angle_acute
-- -----------------------------------------------------
  FUNCTION angle_acute
    (
        xi1 IN NUMBER,
    yi1 IN NUMBER,
    xe1 IN NUMBER,
    ye1 IN NUMBER,
    xi2 IN NUMBER,
    yi2 IN NUMBER,
    xe2 IN NUMBER,
    ye2 IN NUMBER
    )
        RETURN NUMBER
    IS
  BEGIN
    RETURN abs(angle_xx(xi1, yi1, xe1, ye1) - angle_xx(xi2, yi2, xe2, ye2));
  END angle_acute;

-- -----------------------------------------------------
-- Procedure new_pos
-- -----------------------------------------------------
  PROCEDURE new_pos
    (
        xi IN NUMBER,
    yi IN NUMBER,
    xe IN NUMBER,
    ye IN NUMBER,
    n_length IN NUMBER,
    xe_n OUT NUMBER,
    ye_n OUT NUMBER
    )
    IS
    ang NUMBER;
  BEGIN
    ang := angle_xx(xi, yi, xe, ye);
    xe_n := xi + cos(ang) * n_length;
    ye_n := yi + sin(ang) * n_length;
  END new_pos;

-- -----------------------------------------------------
-- Function is_intersection
-- -----------------------------------------------------
  FUNCTION is_intersection
  (
    xi1 IN NUMBER,
    yi1 IN NUMBER,
    xe1 IN NUMBER,
    ye1 IN NUMBER,
    xi2 IN NUMBER,
    yi2 IN NUMBER,
    xe2 IN NUMBER,
    ye2 IN NUMBER
  )
    RETURN NUMBER
  IS
    A1 NUMBER;
    B1 NUMBER;
    C1 NUMBER;
    A2 NUMBER;
    B2 NUMBER;
    C2 NUMBER;
    det NUMBER;
    x NUMBER;
    y NUMBER;
  BEGIN
    A1 := ye1 - yi1;
    B1 := xi1 - xe1;
    C1 := A1 * xi1 + B1 * yi1;

    A2 := ye2 - yi2;
    B2 := xi2 - xe2;
    C2 := A2 * xi2 + B2 * yi2;

    det := A1 * B2 - A2 * B1;

    IF det = 0 THEN
      RETURN 0;
    END IF;

    x := (B2 * C1 - B1 * C2) / det;
    y := (A1 * C2 - A2 * C1) / det;

    IF
      minof_2(xi1, xe1) <= x AND x <= maxof_2(xi1, xe1) AND minof_2(yi1, ye1) <= y AND y <= maxof_2(yi1, ye1) AND
      minof_2(xi2, xe2) <= x AND x <= maxof_2(xi2, xe2) AND minof_2(yi2, ye2) <= y AND y <= maxof_2(yi2, ye2)
    THEN
      RETURN 1;
    END IF;

    RETURN 0;
  END is_intersection;

-- -----------------------------------------------------
-- Function min_dist
-- -----------------------------------------------------
  FUNCTION min_dist
  (
    xi1 IN NUMBER,
    yi1 IN NUMBER,
    xe1 IN NUMBER,
    ye1 IN NUMBER,
    xi2 IN NUMBER,
    yi2 IN NUMBER,
    xe2 IN NUMBER,
    ye2 IN NUMBER
  )
    RETURN NUMBER
  IS
    x1 NUMBER;
    y1 NUMBER;
    x2 NUMBER;
    y2 NUMBER;
  BEGIN
    x1 := (xi1 + xe1) / 2;
    y1 := (yi1 + ye1) / 2;
    x2 := (xi2 + xe2) / 2;
    y2 := (yi2 + ye2) / 2;

    RETURN euclidean_distance(x1, y1, x2, y2);
  END min_dist;

-- -----------------------------------------------------
-- Function min_dist
-- -----------------------------------------------------
  FUNCTION min_dist
  (
    mp1 IN moving_point,
    mp2 IN moving_point
  )
    RETURN NUMBER
  IS
    pos1 NUMBER;
    pos2 NUMBER;
    mind NUMBER;
    mind_t NUMBER;
    x1 NUMBER;
    y1 NUMBER;
    x2 NUMBER;
    y2 NUMBER;
  BEGIN
    IF mp1 IS NULL OR mp2 IS NULL THEN
      RETURN NULL;
    END IF;

    IF mp1.u_tab IS NULL OR mp2.u_tab IS NULL THEN
      RETURN NULL;
    END IF;

    x1 := (mp1.u_tab(mp1.u_tab.FIRST).m.xi + mp1.u_tab(mp1.u_tab.FIRST).m.xe) / 2;
    y1 := (mp1.u_tab(mp1.u_tab.FIRST).m.yi + mp1.u_tab(mp1.u_tab.FIRST).m.ye) / 2;
    x2 := (mp2.u_tab(mp2.u_tab.FIRST).m.xi + mp2.u_tab(mp2.u_tab.FIRST).m.xe) / 2;
    y2 := (mp2.u_tab(mp2.u_tab.FIRST).m.yi + mp2.u_tab(mp2.u_tab.FIRST).m.ye) / 2;
    mind := euclidean_distance(x1, y1, x2, y2);

    pos1 := mp1.u_tab.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      pos2 := mp2.u_tab.FIRST;
      WHILE pos2 IS NOT NULL LOOP
        x1 := (mp1.u_tab(pos1).m.xi + mp1.u_tab(pos1).m.xe) / 2;
        y1 := (mp1.u_tab(pos1).m.yi + mp1.u_tab(pos1).m.ye) / 2;
        x2 := (mp2.u_tab(pos2).m.xi + mp2.u_tab(pos2).m.xe) / 2;
        y2 := (mp2.u_tab(pos2).m.yi + mp2.u_tab(pos2).m.ye) / 2;
        mind_t := euclidean_distance(x1, y1, x2, y2);

        IF mind_t < mind THEN
          mind := mind_t;
        END IF;

        pos2 := mp2.u_tab.NEXT(pos2);
      END LOOP;
      pos1 := mp1.u_tab.NEXT(pos1);
    END LOOP;

    RETURN mind;
  END min_dist;

-- -----------------------------------------------------
-- Function rotated_x
-- -----------------------------------------------------
    FUNCTION rotated_x
    (
        x IN NUMBER,
        y IN NUMBER,
        angle IN NUMBER
    )
        RETURN NUMBER
    IS
    BEGIN
        RETURN cos(angle) * x + sin(angle) * y;
    END rotated_x;

-- -----------------------------------------------------
-- Function rotated_y
-- -----------------------------------------------------
    FUNCTION rotated_y
    (
        x IN NUMBER,
        y IN NUMBER,
        angle IN NUMBER
    )
        RETURN NUMBER
    IS
    BEGIN
        RETURN -sin(angle) * x + cos(angle) * y;
    END rotated_y;

-- -----------------------------------------------------
-- Function reverse_rotation_x
-- -----------------------------------------------------
    FUNCTION reverse_rotation_x
    (
        x IN NUMBER,
        y IN NUMBER,
        angle IN NUMBER
    )
        RETURN NUMBER
    IS
        det NUMBER;
        b NUMBER;
        d NUMBER;
    BEGIN
        det := power(cos(angle), 2) + power(sin(angle), 2);

        b := -1 * sin(angle) / det;
        d := cos(angle) / det;

        /* Reverse Matrix A = d   -b
         *                   -c    a
        */

        RETURN d * x + b * y;
    END reverse_rotation_x;

-- -----------------------------------------------------
-- Function reverse_rotation_y
-- -----------------------------------------------------
    FUNCTION reverse_rotation_y
    (
        x IN NUMBER,
        y IN NUMBER,
        angle IN NUMBER
    )
        RETURN NUMBER
    IS
        det NUMBER;
        a NUMBER;
        c NUMBER;
    BEGIN
        det := power(cos(angle), 2) + power(sin(angle), 2);

        a := cos(angle) / det;
        c := sin(angle) / det;

        /* Reverse Matrix A = d   -b
         *                   -c    a
        */

        RETURN c * x + a * y;
    END reverse_rotation_y;

-- -----------------------------------------------------
-- Function create_direction_vector
-- -----------------------------------------------------
    FUNCTION create_direction_vector
    (
        segments IN OUT NOCOPY unit_moving_point_nt
    )
        RETURN unit_moving_point
    IS
        pos1 NUMBER;
        n NUMBER;
        x NUMBER;
        y NUMBER;
        xb NUMBER := 0;
        yb NUMBER := 0;
        xz NUMBER;
        yz NUMBER;
    BEGIN
        n := segments.COUNT;
        IF n = 0 THEN
            RETURN NULL;
        END IF;

        pos1 := segments.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
            x := segments(pos1).m.xe - segments(pos1).m.xi;
            y := segments(pos1).m.ye - segments(pos1).m.yi;

            xb := xb + x;
            yb := yb + y;

            pos1 := segments.NEXT(pos1);
        END LOOP;

        xb := xb / n;
        yb := yb / n;

        xz := 0;
        yz := 0;

        RETURN unit_moving_point(
                    NULL,
                    unit_function(xz, yz, xb, yb, NULL, NULL, NULL, NULL, NULL, 'PLNML_1')
            );
    END create_direction_vector;

-- -----------------------------------------------------
-- Function get_segments_containing_x
-- -----------------------------------------------------
    FUNCTION get_segments_containing_x
    (
        segments IN OUT NOCOPY unit_moving_point_nt,
        x IN NUMBER,
        angle IN NUMBER
    )
        RETURN unit_moving_point_nt
    IS
        pos1 NUMBER;
        ret unit_moving_point_nt := unit_moving_point_nt();
    BEGIN
        pos1 := segments.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
            IF segments(pos1).m.xi < segments(pos1).m.xe THEN
                IF rotated_x(segments(pos1).m.xi, segments(pos1).m.yi, angle) <= x AND rotated_x(segments(pos1).m.xe, segments(pos1).m.ye, angle) >= x THEN
                    ret.EXTEND;
                    ret(ret.LAST) := segments(pos1);
                END IF;
            ELSE
                IF rotated_x(segments(pos1).m.xi, segments(pos1).m.yi, angle) >= x AND rotated_x(segments(pos1).m.xe, segments(pos1).m.ye, angle) <= x THEN
                    ret.EXTEND;
                    ret(ret.LAST) := segments(pos1);
                END IF;
            END IF;

            pos1 := segments.NEXT(pos1);
        END LOOP;

        RETURN ret;
    END get_segments_containing_x;

-- -----------------------------------------------------
-- Function get_segments_cross_y
-- -----------------------------------------------------
    FUNCTION get_segments_cross_y
    (
        segment IN OUT NOCOPY unit_moving_point,
        x IN NUMBER,
        angle IN NUMBER
    )
        RETURN NUMBER
    IS
        a_factor NUMBER;
        b_factor NUMBER;
        c_factor NUMBER;
        x0 NUMBER;
        y0 NUMBER;
        x1 NUMBER;
        y1 NUMBER;
    BEGIN
        x0 := rotated_x(segment.m.xi, segment.m.yi, angle);
        y0 := rotated_y(segment.m.xi, segment.m.yi, angle);
        x1 := rotated_x(segment.m.xe, segment.m.ye, angle);
        y1 := rotated_y(segment.m.xe, segment.m.ye, angle);

        a_factor := y0 - y1;
        b_factor := -1 * x0 + x1;
        c_factor := -1 * x1 * y0 + x0 * y1;
        IF b_factor = 0 THEN
            RETURN NULL;
        END IF;

        RETURN -1 * (a_factor / b_factor) * x - (c_factor / b_factor);
    END get_segments_cross_y;

-- -----------------------------------------------------
-- Function points_from_segments
-- -----------------------------------------------------
    FUNCTION points_from_segments
    (
        segments IN OUT NOCOPY unit_moving_point_nt
    )
        RETURN spt_pos_nt
    IS
        pos1 NUMBER;
        ret spt_pos_nt := spt_pos_nt();
    BEGIN
        pos1 := segments.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
            ret.EXTEND;
            ret(ret.LAST) := spt_pos(
                                            segments(pos1).m.xi,
                                            segments(pos1).m.yi,
                                            segments(pos1).p.b
            );

            ret.EXTEND;
            ret(ret.LAST) := spt_pos(
                                            segments(pos1).m.xe,
                                            segments(pos1).m.ye,
                                            segments(pos1).p.e
            );

            pos1 := segments.NEXT(pos1);
        END LOOP;

        RETURN ret;
    END points_from_segments;

-- -----------------------------------------------------
-- Function segments_from_trajectory
-- -----------------------------------------------------
    FUNCTION segments_from_trajectory
    (
        trajectory IN OUT NOCOPY moving_point
    )
        RETURN unit_moving_point_nt
    IS
        pos1 NUMBER;
        ret unit_moving_point_nt := unit_moving_point_nt();
    BEGIN
        pos1 := trajectory.u_tab.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
            ret.EXTEND;
            ret(ret.LAST) := trajectory.u_tab(pos1);

            pos1 := trajectory.u_tab.NEXT(pos1);
        END LOOP;

        RETURN ret;
    END segments_from_trajectory;


-- -----------------------------------------------------
-- Function merge
-- -----------------------------------------------------
  FUNCTION merge
  (
    left_l IN OUT NOCOPY spt_pos_nt,
    right_l IN OUT NOCOPY spt_pos_nt,
    angle IN NUMBER
  )
    RETURN spt_pos_nt
  IS
    ret spt_pos_nt := spt_pos_nt();
  BEGIN
    WHILE left_l.COUNT > 0 AND right_l.COUNT > 0 LOOP
      IF rotated_x(left_l(left_l.FIRST).x, left_l(left_l.FIRST).y, angle) < rotated_x(right_l(right_l.FIRST).x, right_l(right_l.FIRST).y, angle) THEN
        ret.EXTEND;
        ret(ret.LAST) := left_l(left_l.FIRST);
        left_l.DELETE(left_l.FIRST);
      ELSE
        ret.EXTEND;
        ret(ret.LAST) := right_l(right_l.FIRST);
        right_l.DELETE(right_l.FIRST);
      END IF;
    END LOOP;

    IF left_l.COUNT > 0 THEN
      WHILE left_l.COUNT > 0
      LOOP
        ret.EXTEND;
        ret(ret.LAST) := left_l(left_l.FIRST);
        left_l.DELETE(left_l.FIRST);
      END LOOP;
    ELSE
      WHILE right_l.COUNT > 0
      LOOP
        ret.EXTEND;
        ret(ret.LAST) := right_l(right_l.FIRST);
        right_l.DELETE(right_l.FIRST);
      END LOOP;
    END IF;

    RETURN ret;
  END merge;

-- -----------------------------------------------------
-- Function merge_sort
-- -----------------------------------------------------
  FUNCTION merge_sort
  (
    a IN spt_pos_nt,
    angle IN NUMBER
  )
    RETURN spt_pos_nt
  IS
    n NUMBER;
    i NUMBER;
    pos1 NUMBER;
    middle INTEGER;
    left_l spt_pos_nt := spt_pos_nt();
    right_l spt_pos_nt := spt_pos_nt();
  BEGIN
    n := a.COUNT;
    IF n <= 1 THEN
      RETURN a;
    END IF;

    middle := n / 2;

    i := 1;
    pos1 := a.FIRST;
    WHILE i <= middle
    LOOP
      left_l.EXTEND;
      left_l(left_l.LAST) := a(pos1);
      pos1 := a.NEXT(pos1);
      i := i + 1;
    END LOOP;

    WHILE i <= n LOOP
      right_l.EXTEND;
      right_l(right_l.LAST) := a(pos1);
      pos1 := a.NEXT(pos1);
      i := i + 1;
    END LOOP;

    left_l := merge_sort(left_l, angle);
    right_l := merge_sort(right_l, angle);

    RETURN merge(left_l, right_l, angle);
  END merge_sort;

  -- -----------------------------------------------------
-- Function rtg
-- -----------------------------------------------------
    FUNCTION rtg
    (
        segments IN OUT NOCOPY unit_moving_point_nt,
        min_lns IN NUMBER := 1,
        smooth_factor IN NUMBER := 0
    )
        RETURN moving_point_tab
    IS
        pos1 NUMBER;
        pos2 NUMBER;
        n_t NUMBER;
        point spt_pos;
        pre_point spt_pos;
        points spt_pos_nt;
    points_t spt_pos_nt;
        segments_containing_x unit_moving_point_nt;
        angle NUMBER;
        direction_vector unit_moving_point;
        rx NUMBER;
        ry NUMBER;
        representative spt_pos_nt := spt_pos_nt();
        ret moving_point_tab := moving_point_tab();
    tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
    te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
    BEGIN
        direction_vector := create_direction_vector(segments);
        IF direction_vector IS NULL THEN
            RETURN NULL;
        END IF;

        angle := angle_xx(direction_vector.m.xi, direction_vector.m.yi, direction_vector.m.xe, direction_vector.m.ye);

        points_t := points_from_segments(segments);

    SELECT spt_pos(p.x, p.y, p.t)
      BULK COLLECT INTO points
    FROM TABLE(points_t) p
    ORDER BY rotated_x(p.x, p.y, angle);

        --points := merge_sort(points, angle);

        pos1 := points.FIRST;
        if pos1=26 then
          null;
        end if;
        <<loop1>>
        WHILE pos1 IS NOT NULL
        LOOP
            segments_containing_x := get_segments_containing_x(segments, rotated_x(points(pos1).x, points(pos1).y, angle), angle);
            IF segments_containing_x.COUNT >= min_lns THEN
                point := spt_pos(
                            rotated_x(points(pos1).x, points(pos1).y, angle),
                            0,
                            NULL
                );

                pos2 := segments_containing_x.FIRST;
                <<loop2>>
                WHILE pos2 IS NOT NULL
                LOOP
                    n_t := get_segments_cross_y(segments_containing_x(pos2), point.x, angle);--find y coord in segment corresponding to point.x, if segment perpendicular on XX' then null
                    IF n_t IS NULL THEN
                        pos1 := points.NEXT(pos1);
                        CONTINUE loop1;
                    END IF;

                    point.y := point.y + n_t;--also a counter is needed to avoid using segments_containing_x.COUNT

                    pos2 := segments_containing_x.NEXT(pos2);
                END LOOP;

                point.y := point.y / segments_containing_x.COUNT;--not accurate if some segments are perpendicular

                IF representative.COUNT = 0 THEN
                    representative.EXTEND;
                    representative(representative.LAST) := point;--also reverse_rotation_x to save below loop if time is not needed
                ELSE
                    IF abs(point.x - representative(representative.LAST).x) >= smooth_factor THEN
                        representative.EXTEND;
                        representative(representative.LAST) := point;--also reverse_rotation_x to save below loop if time is not needed
                    END IF;
                END IF;
            END IF;

            pos1 := points.NEXT(pos1);
        END LOOP;

        IF representative.COUNT = 0 THEN
            RETURN NULL;
        END IF;

        pre_point := representative(representative.FIRST);
        rx := pre_point.x;
        ry := pre_point.y;
        pre_point.x := reverse_rotation_x(rx, ry, angle);
        pre_point.y := reverse_rotation_y(rx, ry, angle);

        pos1 := representative.NEXT(representative.FIRST);
        WHILE pos1 IS NOT NULL
        LOOP
            point := representative(pos1);

            rx := point.x;
            ry := point.y;
            point.x := reverse_rotation_x(rx, ry, angle);
            point.y := reverse_rotation_y(rx, ry, angle);

            IF pre_point.x = point.x AND pre_point.y = point.y THEN
                pos1 := representative.NEXT(pos1);
                CONTINUE;
            END IF;

      tb.set_abs_date(te.get_abs_date() + 1);
      te.set_abs_date(tb.get_abs_date() + 1);

            ret.EXTEND;
            ret(ret.LAST) := unit_moving_point(
                                tau_tll.d_period_sec(tb, te),
                                unit_function(pre_point.x, pre_point.y, point.x, point.y, null, null, null, null, null, 'PLNML_1')
            );

            pre_point := point;

            pos1 := representative.NEXT(pos1);
        END LOOP;

        IF ret.COUNT = 0 THEN
            RETURN NULL;
        END IF;

        RETURN ret;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END rtg;


-- -----------------------------------------------------
-- Function fake_trajectory
-- -----------------------------------------------------
    FUNCTION fake_trajectory
    (
        segments IN OUT NOCOPY unit_moving_point_nt,
        min_lns IN NUMBER,
    smooth_factor IN NUMBER,
        time_step IN NUMBER,
        min_tr_dur IN NUMBER,
        max_tr_dur IN NUMBER,
        t_min IN NUMBER,
        t_max IN NUMBER,
        min_tr_avg_speed IN NUMBER,
        max_tr_avg_speed IN NUMBER,
        min_seg_len IN NUMBER,
        max_seg_len IN NUMBER,
        avg_seg_len IN NUMBER,
    sgeo IN mdsys.sdo_geometry,
        wtim IN tau_tll.d_period_sec,
    c IN NUMBER,
        flag1 OUT NUMBER,
        flag2 OUT NUMBER
    )
        RETURN moving_point
    IS
    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;

        pos1 NUMBER;
    pos2 NUMBER;
        n_s NUMBER;

    t_i NUMBER;
        dur_f NUMBER;

        seg_speed NUMBER;
        seg_len NUMBER;

        min_seg_len_n NUMBER;
        max_seg_len_n NUMBER;

        ret moving_point_tab;

        tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
        te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
        xe_n NUMBER;
        ye_n NUMBER;

    cnt NUMBER;
    tdf NUMBER;
    nmb1 NUMBER;
    nmb2 NUMBER;

    idur NUMBER;
    redc INTEGER := 0;
    mpt_t moving_point_tab;
    tmp unit_moving_point;
    fl NUMBER := 0;
    BEGIN
        flag1 := 0;
        flag2 := 0;

        n_s := segments.COUNT;

        IF min_lns > n_s OR n_s = 1 THEN
            IF min_lns > n_s THEN
                flag1 := 1;
            END IF;

            IF n_s = 1 THEN
                flag2 := 1;
            END IF;

            RETURN NULL;
        END IF;

        ret := rtg(segments, min_lns, smooth_factor);
        IF ret IS NULL THEN
      RETURN NULL;
        END IF;

    t_i := dbms_random.value(wtim.b.get_abs_date(), wtim.b.get_abs_date() + abs(wtim.e.get_abs_date() - wtim.b.get_abs_date()) / 6);

        min_seg_len_n := min_seg_len;
        IF max_seg_len > avg_seg_len * 2 THEN
           max_seg_len_n := dbms_random.value(avg_seg_len, (avg_seg_len * 2));
        ELSE
            max_seg_len_n := avg_seg_len * dbms_random.value(1, (max_seg_len / avg_seg_len));
        END IF;

        pos1 := ret.FIRST;
        WHILE pos1 IS NOT NULL LOOP
      cnt := 1;

            tb.set_abs_date(t_i);
            t_i := t_i + time_step;
            te.set_abs_date(t_i);

      ret(pos1).p := tau_tll.d_period_sec(tb, te);

            seg_len := euclidean_distance(ret(pos1).m.xi, ret(pos1).m.yi, ret(pos1).m.xe, ret(pos1).m.ye);
            seg_speed := seg_len / time_step;

            IF seg_speed < min_tr_avg_speed OR seg_speed > max_tr_avg_speed THEN
                xe_n := ret(pos1).m.xe;
                ye_n := ret(pos1).m.ye;

                LOOP
                    seg_len := dbms_random.value(min_seg_len_n, max_seg_len_n);
                    seg_speed := seg_len / time_step;

          IF cnt > 20 THEN
            seg_len := dbms_random.value(min_tr_avg_speed, max_tr_avg_speed) * time_step;
            EXIT;
          END IF;

          cnt := cnt + 1;

                    EXIT WHEN seg_speed >= min_tr_avg_speed AND seg_speed <= max_tr_avg_speed;
                END LOOP;

        new_pos(ret(pos1).m.xi, ret(pos1).m.yi, ret(pos1).m.xe, ret(pos1).m.ye, seg_len, xe_n, ye_n);

                ret(pos1).m.xe := xe_n;
                ret(pos1).m.ye := ye_n;

                IF pos1 <> ret.LAST THEN
                    ret(ret.NEXT(pos1)).m.xi := xe_n;
                    ret(ret.NEXT(pos1)).m.yi := ye_n;
                END IF;
            END IF;

            pos1 := ret.NEXT(pos1);
        END LOOP;

    mp1 := moving_point(ret, -1, 2100);--hard
    --dbms_output.put_line(mp1.u_tab(mp1.u_tab.last).p.e.to_string());
    --dbms_output.put_line(mp1.u_tab(mp1.u_tab.first).p.b.to_string());
    mp2 := mp1.f_intersection2(sgeo, 0.005);

    IF mp2 IS NULL THEN
      RETURN NULL;
    ELSE
      IF mp2.u_tab IS NULL THEN
        RETURN NULL;
      ELSE
        IF mp2.u_tab.FIRST IS NULL THEN
          RETURN NULL;
        END IF;
      END IF;
    END IF;

    tdf := mp2.u_tab(mp2.u_tab.FIRST).p.b.get_abs_date() - ret(ret.FIRST).p.b.get_abs_date();
    IF tdf < 0 THEN
      RETURN NULL;
    END IF;

    pos1 := ret.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      nmb1 := ret(pos1).p.b.get_abs_date();
      nmb2 := ret(pos1).p.e.get_abs_date();
      ret(pos1).p.b.set_abs_date(nmb1 - tdf);
      ret(pos1).p.e.set_abs_date(nmb2 - tdf);

      pos1 := ret.NEXT(pos1);
    END LOOP;

        RETURN moving_point(ret, NULL, null);
/*    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;*/
    END fake_trajectory;

-- -----------------------------------------------------
-- Function overlaping_windows
-- -----------------------------------------------------
    FUNCTION overlaping_windows
    (
        user_id_in IN NUMBER,
        sgeo IN mdsys.sdo_geometry,
        t_start IN tau_tll.d_timepoint_sec,
        t_end IN tau_tll.d_timepoint_sec
    )
        RETURN NUMBER
    IS
        c NUMBER;
    BEGIN
        SELECT count(*)
            INTO c
        FROM hist p
        WHERE p.user_id = user_id_in
            AND (minof_2(t_end.get_abs_date(), p.tb.get_abs_date()) > maxof_2(t_start.get_abs_date(), p.ta.get_abs_date()))
            AND (mdsys.sdo_geom.relate(p.geom, 'ANYINTERACT', sgeo, 0.005) = 'TRUE'); --MASK=OVERLAPBDYDISJOINT+OVERLAPBDYINTERSECT

        IF c = 0 THEN
            RETURN 0;
        END IF;

        RETURN 1;
    END overlaping_windows;

-- -----------------------------------------------------
-- Function near_windows
-- -----------------------------------------------------
    FUNCTION near_windows
    (
        user_id_in IN NUMBER,
        sgeo IN mdsys.sdo_geometry,
        t_start IN tau_tll.d_timepoint_sec,
        t_end IN tau_tll.d_timepoint_sec,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
    trs IN number_nt
    )
        RETURN number_nt
    IS
        c NUMBER;
    ret number_nt;
    BEGIN
    SELECT DISTINCT ht.id
      BULK COLLECT INTO ret
    FROM hist h INNER JOIN hist_trajs ht ON (h.user_id = ht.user_id AND h.id = ht.id)
    WHERE h.user_id = user_id_in
      AND ht.traj_id IN (SELECT * FROM TABLE(trs))
      AND (minof_2(t_end.get_abs_date() + tolerance_t, h.tb.get_abs_date()) > maxof_2(t_start.get_abs_date() - tolerance_t, h.ta.get_abs_date()))
            AND (mdsys.sdo_geom.relate(h.geom, 'ANYINTERACT', sgeo, tolerance_s) = 'TRUE'); --MASK=OVERLAPBDYDISJOINT+OVERLAPBDYINTERSECT

        RETURN ret;
    END near_windows;

-- -----------------------------------------------------
-- Procedure update_hist
-- -----------------------------------------------------
    PROCEDURE update_hist
    (
        user_id_in IN NUMBER,
        sgeo IN mdsys.sdo_geometry,
        t_start IN tau_tll.d_timepoint_sec,
        t_end IN tau_tll.d_timepoint_sec,
    trs IN number_nt
    )
    IS
    mxid NUMBER;
    pos1 NUMBER;
    BEGIN
    SELECT count(*) INTO mxid FROM hist WHERE user_id = user_id_in;
    IF mxid = 0 THEN
      mxid := 1;
    ELSE
      SELECT max(id) + 1 INTO mxid FROM hist WHERE user_id = user_id_in;
    END IF;

        INSERT INTO hist(user_id, id, geom, ta, tb) VALUES (user_id_in, mxid, sgeo, t_start, t_end);

    pos1 := trs.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      INSERT INTO hist_trajs(user_id, id, traj_id) VALUES (user_id_in, mxid, trs(pos1));
      pos1 := trs.NEXT(pos1);
    END LOOP;
    END update_hist;

-- -----------------------------------------------------
-- Function next_fake
-- -----------------------------------------------------
  FUNCTION next_fake
  (
    user_id_in IN NUMBER
    )
        RETURN NUMBER
    IS
        ret NUMBER;
    c NUMBER;
    BEGIN
    SELECT count(*) INTO c FROM fakes fs WHERE fs.user_id = user_id_in;

    IF c <= 0 THEN
      SELECT max(traj_id) + 1 INTO ret FROM mpoints;
    ELSE
      SELECT max(fs.traj_id) + 1 INTO ret FROM fakes fs WHERE fs.user_id = user_id_in;
    END IF;

    RETURN ret;
  END next_fake;

-- -----------------------------------------------------
-- Function range_query
-- -----------------------------------------------------
    FUNCTION range_query
    (
        sgeo IN mdsys.sdo_geometry,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    src_tab IN VARCHAR DEFAULT 'mpoints',
    fakes_only IN NUMBER DEFAULT 1
    )
        RETURN mp_array
    IS
    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
    fl1 NUMBER;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

    rnd1 moving_point;
    rnd2 moving_point;

    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;
    u_tab_t2 moving_point_tab;
    fk mp_array := mp_array();
    nfk mp_array := mp_array();
    nfk2 mp_array := mp_array();

    nnt number_nt;
    nnt2 number_nt;

    seg_i unit_moving_point;
    seg_e unit_moving_point;

    sgeo_t mdsys.sdo_geometry;
        wtim_t tau_tll.d_period_sec;

    nmb1 NUMBER;
    nmb2 NUMBER;

    c_x NUMBER;
    c_y NUMBER;
    mn_x NUMBER;
    mx_x NUMBER;
    mn_y NUMBER;
    mx_y NUMBER;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n INTEGER;

    comb INTEGER;

    i INTEGER;
    j INTEGER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        d mp_array;
    real_tr mp_array := mp_array();
    real_tr_sliced mp_array := mp_array();
    real_spw mp_array := mp_array();
        m_ps mp_array := mp_array();

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

    f_segments unit_moving_point_nt;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
        sql_stm varchar2(1000);

    user_id_t NUMBER := user_id;
    BEGIN
      sql_stm := 'SELECT m.mpoint FROM ' || src_tab || ' m
              WHERE hpv.minof_2(:1,
              m.mpoint.f_final_timepoint().get_abs_date()) > hpv.maxof_2(:2,
              m.mpoint.f_initial_timepoint().get_abs_date())';
    EXECUTE IMMEDIATE sql_stm BULK COLLECT INTO d
    using wtim.e.get_abs_date(), wtim.b.get_abs_date();

    /*
    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());
    */

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;

    pos1 := real_tr.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
      mp1 := real_tr(pos1);

      SELECT count(*)
        INTO i
      FROM init_end ie
      WHERE ie.user_id = user_id_t AND ie.traj_id = mp1.traj_id;

      IF i > 0 THEN
        SELECT ie.init_point, ie.end_point
          INTO seg_i, seg_e
        FROM init_end ie
        WHERE ie.user_id = user_id_t AND ie.traj_id = mp1.traj_id;

        mp1.u_tab(mp1.u_tab.FIRST).m.xi := seg_i.m.xi;
        mp1.u_tab(mp1.u_tab.FIRST).m.yi := seg_i.m.yi;

        mp1.u_tab(mp1.u_tab.LAST).m.xe := seg_e.m.xe;
        mp1.u_tab(mp1.u_tab.LAST).m.ye := seg_e.m.ye;
      ELSE
        seg_i := mp1.u_tab(mp1.u_tab.FIRST);
        seg_e := mp1.u_tab(mp1.u_tab.LAST);

        r := utilities.distance(seg_i.m.xi, seg_i.m.yi, seg_i.m.xe, seg_i.m.ye) / 2;
        c_x := (seg_i.m.xi + seg_i.m.xe) / 2;
        c_y := (seg_i.m.yi + seg_i.m.ye) / 2;

        seg_i.m.xi := dbms_random.value(c_x - r, c_x + r);
        seg_i.m.yi := dbms_random.value(c_y - r, c_y + r);
        mp1.u_tab(mp1.u_tab.FIRST) := seg_i;

        r := utilities.distance(seg_e.m.xi, seg_e.m.yi, seg_e.m.xe, seg_e.m.ye) / 2;
        c_x := (seg_e.m.xi + seg_e.m.xe) / 2;
        c_y := (seg_e.m.yi + seg_e.m.ye) / 2;

        seg_e.m.xe := dbms_random.value(c_x - r, c_x + r);
        seg_e.m.ye := dbms_random.value(c_y - r, c_y + r);
        mp1.u_tab(mp1.u_tab.LAST) := seg_e;

        INSERT INTO init_end(user_id, traj_id, init_point, end_point) VALUES (user_id_t, mp1.traj_id, seg_i, seg_e);
      END IF;

      mp2 := mp1.at_period(wtim);
      IF mp2 IS NOT NULL THEN
      IF mp2.u_tab IS NOT NULL THEN
      IF mp2.u_tab.FIRST IS NOT NULL THEN
        mp3 := mp2.f_intersection2(sgeo, 0.005);
        IF mp3 IS NOT NULL THEN
        IF mp3.u_tab IS NOT NULL THEN
        IF mp3.u_tab.FIRST IS NOT NULL THEN
          real_tr_sliced.EXTEND;
          real_tr_sliced(real_tr_sliced.LAST) := mp3;
          real_tr_sliced(real_tr_sliced.LAST).traj_id := mp1.traj_id;

          pos1 := real_tr.NEXT(pos1);
          CONTINUE;
        END IF;
        END IF;
        END IF;
      END IF;
      END IF;
      END IF;

      real_tr.DELETE(pos1);
            pos1 := real_tr.NEXT(pos1);
        END LOOP;

    SELECT p.traj_id
      BULK COLLECT INTO nnt
    FROM TABLE(real_tr_sliced) p;

    --demo done
    /*
    nnt2 := near_windows(user_id, sgeo, wtim.b, wtim.e, tolerance_s, tolerance_t, nnt);
    IF nnt2.COUNT > 1 THEN
      raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
    END IF;
    */
/*
    SELECT moving_point(moving_point(m.u_tab, NULL).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m;
*/
    IF real_tr_sliced.COUNT >= k2 THEN
      update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
            RETURN real_tr_sliced;
        END IF;

        IF real_tr.COUNT < l THEN
      raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

        k2 := k2 - real_tr_sliced.COUNT;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_spw
        FROM TABLE(real_tr) m
        WHERE moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005) IS NOT NULL;

        SELECT min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_spw) t;

        segments := traclus.segments_from_trajectories(real_spw);

    IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n := real_spw.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n) / (factorial(r) * factorial(n - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_spw) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);

        IF mp1 IS NOT NULL THEN
          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            mp3 := mp2.f_intersection2(sgeo, 0.005);
            IF mp3 IS NOT NULL THEN
            IF mp3.u_tab IS NOT NULL THEN
            IF mp3.u_tab.FIRST IS NOT NULL THEN
              nfk.EXTEND;
              nfk(nfk.LAST) := mp3;

              k2 := k2 - 1;
              IF k2 = 0 THEN
                pos2 := nfk.FIRST;
                WHILE pos2 IS NOT NULL LOOP
                  nfk(pos2).traj_id := next_fake(user_id);
                  INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk(pos2).traj_id, nfk(pos2),k);

                  pos2 := nfk.NEXT(pos2);
                END LOOP;

                update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
                RETURN real_tr_sliced MULTISET UNION nfk;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
    END range_query;

-- -----------------------------------------------------
-- Function distance_query
-- -----------------------------------------------------
    FUNCTION distance_query
    (
        xp IN NUMBER,
        yp IN NUMBER,
        d IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER
    )
        RETURN mp_array
    IS
        SRID NUMBER;
        sgeo mdsys.sdo_geometry;
    begin
        SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

        sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,4),
                mdsys.sdo_ordinate_array(
                    xp + d * cos(atan(0)),yp + d * sin(atan(0)),
                    xp + d * cos(atan(1)),yp + d * sin(atan(1)),
                    xp + d * cos(atan(2 / 1)),yp + d * sin(atan(2 / 1))
                    )
                );
        RETURN range_query(sgeo, wtim, k, l, tolerance_s, tolerance_t, user_id, min_lns, smooth_factor, time_step, max_step);
    END distance_query;

-- -----------------------------------------------------
-- Function knn_query
-- -----------------------------------------------------
    FUNCTION knn_query
    (
        p IN INTEGER,
        n IN INTEGER,
    mxdist IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER
    )
        RETURN mp_array
    IS
    mpp moving_point;
    nnt number_nt;
    nnt2 number_nt;
    real_tr mp_array;
    real_tr_sliced mp_array;
    real_spw mp_array := mp_array();
    fk mp_array;
    nfk mp_array := mp_array();
    sgeo mdsys.sdo_geometry;
    pos1 NUMBER;
    pos2 NUMBER;
    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        min_traj_id NUMBER;

        d mp_array;
        m_ps mp_array;

        mbr mdsys.sdo_geometry;

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n2 INTEGER;

    comb INTEGER;

    i INTEGER;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    SELECT moving_point(m.mpoint.at_period(wtim).u_tab, m.traj_id, m.mpoint.srid)
            INTO mpp
        FROM mpoints m
    WHERE m.traj_id = p;

    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim) IS NOT NULL;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m
    WHERE min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp) <= mxdist
    ORDER BY min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp);

    SELECT sdo_aggr_mbr(moving_point(m.u_tab, NULL, null).route())
            INTO sgeo
        FROM TABLE(real_tr_sliced) m;

    SELECT m.traj_id
      BULK COLLECT INTO nnt
    FROM TABLE(real_tr_sliced) m;

    nnt2 := near_windows(user_id, sgeo, wtim.b, wtim.e, tolerance_s, tolerance_t, nnt);
    IF nnt2.COUNT > 0 THEN
      raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
    END IF;

    IF k2 >= n THEN
      IF real_tr_sliced.COUNT = k2 THEN
        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      ELSIF real_tr_sliced.COUNT < k2 THEN
        k2 := k2 - real_tr_sliced.COUNT;
      ELSE
        real_tr_sliced.DELETE(k2 + 1, real_tr_sliced.COUNT);

        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      END IF;
    ELSE
      IF real_tr_sliced.COUNT < k2 THEN
        k2 := k2 - real_tr_sliced.COUNT;
      ELSIF real_tr_sliced.COUNT >= k2 AND real_tr_sliced.COUNT <= n THEN
        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      ELSE
        real_tr_sliced.DELETE(n + 1, real_tr_sliced.COUNT);

        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      END IF;
    END IF;

        IF real_tr_sliced.COUNT < l THEN
      raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO d
        FROM TABLE(real_tr) m
        WHERE m.traj_id IN (SELECT p.traj_id FROM TABLE(real_tr_sliced) p);

    real_tr := d;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_spw
        FROM TABLE(real_tr) m
    WHERE moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005) IS NOT NULL;

        SELECT min(t.traj_id), min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_traj_id, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_spw) t;

        segments := traclus.segments_from_trajectories(real_spw);

        IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n2 := real_spw.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n2 LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n2) / (factorial(r) * factorial(n2 - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_spw) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);

        IF mp1 IS NOT NULL THEN
          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            mp3 := mp2.f_intersection2(sgeo, 0.005);
            IF mp3 IS NOT NULL THEN
            IF mp3.u_tab IS NOT NULL THEN
            IF mp3.u_tab.FIRST IS NOT NULL THEN
              IF min_dist(mp3, mpp) <= mxdist THEN
                nfk.EXTEND;
                nfk(nfk.LAST) := mp3;

                k2 := k2 - 1;
                IF k2 = 0 THEN
                  pos2 := nfk.FIRST;
                  WHILE pos2 IS NOT NULL LOOP
                    nfk(pos2).traj_id := next_fake(user_id);
                    INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk(pos2).traj_id, nfk(pos2),k);

                    pos2 := nfk.NEXT(pos2);
                  END LOOP;

                  update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
                  RETURN real_tr_sliced MULTISET UNION nfk;
                END IF;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
    END knn_query;

-- -----------------------------------------------------
-- Function range_query2
-- -----------------------------------------------------
    FUNCTION range_query2
    (
        sgeo IN mdsys.sdo_geometry,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    src_tab IN VARCHAR DEFAULT 'mpoints',
    fakes_only IN NUMBER DEFAULT 1
    )
        RETURN mp_array
    IS
    fl1 NUMBER;

    user_id_t NUMBER := user_id;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;
    u_tab_t2 moving_point_tab;
    fk mp_array := mp_array();
    nfk mp_array := mp_array();
    nfk1 mp_array := mp_array();

    c_x NUMBER;
    c_y NUMBER;
    mn_x NUMBER;
    mx_x NUMBER;
    mn_y NUMBER;
    mx_y NUMBER;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n INTEGER;

    comb INTEGER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        d mp_array;
    real_tr mp_array := mp_array();
    real_tr_sliced mp_array := mp_array();
    real_spw mp_array := mp_array();
        m_ps mp_array := mp_array();

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

    f_segments unit_moving_point_nt;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;

    -------------------
    TMP mp_array := mp_array();
    RF mp_array := mp_array();
    RS mp_array := mp_array();
    FF mp_array := mp_array();
    FS mp_array := mp_array();
    RET mp_array := mp_array();

    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
    i INTEGER;
    iii INTEGER;
    seg_i unit_moving_point;
    seg_e unit_moving_point;

    SRID INTEGER;
    pois ll_pos_nt := ll_pos_nt();

    poi_geom mdsys.sdo_geometry;
    begin
    SELECT value INTO SRID FROM parameters WHERE id='SRID' and table_name='MPOINTS';

    --EXECUTE IMMEDIATE 'SELECT m.mpoint FROM ' || src_tab || ' m WHERE minof_2(:1.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(:1.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date())'
    --BULK COLLECT INTO TMP USING wtim;
    EXECUTE IMMEDIATE 'SELECT m.mpoint FROM ' || src_tab || ' m'
      BULK COLLECT INTO TMP;

    DBMS_OUTPUT.PUT_LINE('TMP.COUNT: ' || TMP.COUNT);

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO RF
        FROM TABLE(TMP) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;

    DBMS_OUTPUT.PUT_LINE('RF.COUNT: ' || RF.COUNT);

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO RS
        FROM TABLE(RF) m;

    DBMS_OUTPUT.PUT_LINE('RS.COUNT: ' || RS.COUNT);
-------------------------------------------------
    SELECT m.mpoint
            BULK COLLECT INTO TMP
        FROM fakes m
    WHERE m.user_id = user_id_t AND minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO FF
        FROM TABLE(TMP) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO FS
        FROM TABLE(FF) m;
--------------------------------------------------
    IF RF.COUNT + FF.COUNT  < l THEN
      raise_application_error(-20988,'C$HERMES-HPV-001: RF + FF < L, ' || (RF.COUNT + FF.COUNT));
    END IF;

    IF FS.COUNT < k2 THEN
            k2 := k2 - FS.COUNT;

      SELECT min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
        INTO min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
      FROM TABLE(RF) t;

      SELECT moving_point(m.u_tab, m.traj_id, m.srid)
        BULK COLLECT INTO TMP
      FROM TABLE(RF MULTISET UNION FF) m;

      segments := traclus.segments_from_trajectories(TMP);

      IF time_step IS NULL THEN
        SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
          INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
        FROM TABLE(segments) s;
      ELSE
        time_step2 := time_step;
        SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
          INTO min_seg_len, max_seg_len, avg_seg_len
        FROM TABLE(segments) s;
      END IF;

      n := RF.COUNT + FF.COUNT;

      num_buf := number_nt();
      FOR pos1 IN 2..n LOOP
        num_buf.EXTEND;
        num_buf(num_buf.LAST) := pos1;
      END LOOP;

      SELECT column_value
        BULK COLLECT INTO r_buf
      FROM TABLE(num_buf)
      ORDER BY dbms_random.value;

      tti := LOCALTIMESTAMP;
      pos1 := r_buf.FIRST;
      WHILE pos1 IS NOT NULL LOOP
        r := r_buf(pos1);
        comb := factorial(n) / (factorial(r) * factorial(n - r));
        FOR i IN 1..comb LOOP
          tt := LOCALTIMESTAMP;
          it := tt - tti;
          dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
          IF dit >= 900 THEN
            raise_application_error(-20988,'C$HERMES-HPV-001:taking too long');
          END IF;

          SELECT moving_point(p.u_tab, p.traj_id, p.srid)
            BULK COLLECT INTO TMP
          FROM
          (
            SELECT m.u_tab, m.traj_id, m.srid
            FROM TABLE(RF MULTISET UNION FF) m
            ORDER BY dbms_random.value
          ) p
          WHERE ROWNUM <= r;

          segments_t := traclus.segments_from_trajectories(TMP);

          mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);

          IF mp1 IS NOT NULL THEN
            mp2 := mp1.at_period(wtim);
            IF mp2 IS NOT NULL THEN
            IF mp2.u_tab IS NOT NULL THEN
            IF mp2.u_tab.FIRST IS NOT NULL THEN
              mp3 := mp2.f_intersection2(sgeo, 0.005);
              IF mp3 IS NOT NULL THEN
              IF mp3.u_tab IS NOT NULL THEN
              IF mp3.u_tab.FIRST IS NOT NULL THEN
                mp1.traj_id := next_fake(user_id);

                nfk.EXTEND;
                nfk(nfk.LAST) := mp3;
                nfk(nfk.LAST).traj_id := mp1.traj_id;

                nfk1.EXTEND;
                nfk1(nfk1.LAST) := mp1;
                nfk1(nfk1.LAST).traj_id := mp1.traj_id;

                k2 := k2 - 1;
                IF k2 = 0 THEN
                  pos2 := nfk1.FIRST;
                  WHILE pos2 IS NOT NULL LOOP
                    INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk1(pos2).traj_id, nfk1(pos2),k);
                    pos2 := nfk1.NEXT(pos2);
                  END LOOP;

                  pos1 := RF.FIRST;
                  WHILE pos1 IS NOT NULL
                  LOOP
                    mp1 := RF(pos1);

                    SELECT count(*)
                      INTO iii
                    FROM init_end ie
                    WHERE ie.user_id = user_id_t AND ie.traj_id = mp1.traj_id;

                    IF iii > 0 THEN
                      SELECT ie.init_point, ie.end_point
                        INTO seg_i, seg_e
                      FROM init_end ie
                      WHERE ie.user_id = user_id_t AND ie.traj_id = mp1.traj_id;

                      mp1.u_tab(mp1.u_tab.FIRST).m.xi := seg_i.m.xi;
                      mp1.u_tab(mp1.u_tab.FIRST).m.yi := seg_i.m.yi;

                      mp1.u_tab(mp1.u_tab.LAST).m.xe := seg_e.m.xe;
                      mp1.u_tab(mp1.u_tab.LAST).m.ye := seg_e.m.ye;
                    ELSE
                      seg_i := mp1.u_tab(mp1.u_tab.FIRST);
                      seg_e := mp1.u_tab(mp1.u_tab.LAST);

                      r := utilities.distance(seg_i.m.xi, seg_i.m.yi, seg_i.m.xe, seg_i.m.ye) / 2;
                      c_x := (seg_i.m.xi + seg_i.m.xe) / 2;
                      c_y := (seg_i.m.yi + seg_i.m.ye) / 2;

                      seg_i.m.xi := dbms_random.value(c_x - r, c_x + r);
                      seg_i.m.yi := dbms_random.value(c_y - r, c_y + r);
                      mp1.u_tab(mp1.u_tab.FIRST) := seg_i;

                      r := utilities.distance(seg_e.m.xi, seg_e.m.yi, seg_e.m.xe, seg_e.m.ye) / 2;
                      c_x := (seg_e.m.xi + seg_e.m.xe) / 2;
                      c_y := (seg_e.m.yi + seg_e.m.ye) / 2;

                      seg_e.m.xe := dbms_random.value(c_x - r, c_x + r);
                      seg_e.m.ye := dbms_random.value(c_y - r, c_y + r);
                      mp1.u_tab(mp1.u_tab.LAST) := seg_e;

                      INSERT INTO init_end(user_id, traj_id, init_point, end_point) VALUES (user_id_t, mp1.traj_id, seg_i, seg_e);
                    END IF;

                    mp2 := mp1.at_period(wtim);
                    IF mp2 IS NOT NULL THEN
                    IF mp2.u_tab IS NOT NULL THEN
                    IF mp2.u_tab.FIRST IS NOT NULL THEN
                      mp3 := mp2.f_intersection2(sgeo, 0.005);
                      IF mp3 IS NOT NULL THEN
                      IF mp3.u_tab IS NOT NULL THEN
                      IF mp3.u_tab.FIRST IS NOT NULL THEN
                        RS.EXTEND;
                        RS(RS.LAST) := mp3;
                        RS(RS.LAST).traj_id := mp1.traj_id;

                        pos1 := RF.NEXT(pos1);
                        CONTINUE;
                      END IF;
                      END IF;
                      END IF;
                    END IF;
                    END IF;
                    END IF;

                    RF.DELETE(pos1);
                    pos1 := RF.NEXT(pos1);
                  END LOOP;

                  IF fakes_only = 1 THEN
                    RET := RS MULTISET UNION nfk;
                  ELSE
                    RET := FS MULTISET UNION RS MULTISET UNION nfk;
                  END IF;

                  --demo poi
                  SELECT ll_pos(LON, LAT, MDSYS.SDO_CS.TRANSFORM(SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(LON, LAT, NULL), NULL, NULL), SRID).SDO_POINT.X, MDSYS.SDO_CS.TRANSFORM(SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(LON, LAT, NULL), NULL, NULL), SRID).SDO_POINT.Y)
                    BULK COLLECT INTO pois
                  FROM POI_MILANO;

                  pos1 := RET.FIRST;
                  WHILE pos1 IS NOT NULL LOOP
                    pos2 := RET(pos1).u_tab.FIRST;
                    WHILE pos2 IS NOT NULL LOOP
                      pos3 := pois.FIRST;
                      WHILE pos3 IS NOT NULL LOOP
                        poi_geom := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,4),
                                mdsys.sdo_ordinate_array(
                                  pois(pos3).X + 300 * cos(atan(0)),pois(pos3).Y + 300 * sin(atan(0)),
                                  pois(pos3).X + 300 * cos(atan(1)),pois(pos3).Y + 300 * sin(atan(1)),
                                  pois(pos3).X + 300 * cos(atan(2 / 1)),pois(pos3).Y + 300 * sin(atan(2 / 1))
                                  )
                                );

                        IF mdsys.sdo_geom.relate(moving_point(moving_point_tab(RET(pos1).u_tab(pos2)), NULL, null).route(), 'ANYINTERACT', poi_geom, 0.005) = 'TRUE' THEN
                          RET(pos1).u_tab(pos2).m.xi := dbms_random.value(pois(pos3).X - 500, pois(pos3).X + 500);
                          RET(pos1).u_tab(pos2).m.yi := dbms_random.value(pois(pos3).Y - 500, pois(pos3).Y + 500);

                          IF pos2 <> RET(pos1).u_tab.FIRST THEN
                            RET(pos1).u_tab(RET(pos1).u_tab.PRIOR(pos2)).m.xe := RET(pos1).u_tab(pos2).m.xi;
                            RET(pos1).u_tab(RET(pos1).u_tab.PRIOR(pos2)).m.ye := RET(pos1).u_tab(pos2).m.yi;
                          END IF;
                        END IF;

                        pos3 := pois.NEXT(pos3);
                      END LOOP;
                      pos2 := RET(pos1).u_tab.NEXT(pos2);
                    END LOOP;
                    pos1 := RET.NEXT(pos1);
                  END LOOP;
                END IF;
              END IF;
              END IF;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
        END LOOP;
        pos1 := r_buf.NEXT(pos1);
      END LOOP;
    ELSE
      IF fakes_only = 1 THEN
        RET := RS;
      ELSE
        RET := FS MULTISET UNION RS;
      END IF;
        END IF;

    RETURN RET;
    END range_query2;

-- -----------------------------------------------------
-- Function distance_query2
-- -----------------------------------------------------
    FUNCTION distance_query2
    (
        xp IN NUMBER,
        yp IN NUMBER,
        d IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER
    )
        RETURN mp_array
    IS
        SRID NUMBER;
        sgeo mdsys.sdo_geometry;
    begin
        SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

        sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,4),
                mdsys.sdo_ordinate_array(
                    xp + d * cos(atan(0)),yp + d * sin(atan(0)),
                    xp + d * cos(atan(1)),yp + d * sin(atan(1)),
                    xp + d * cos(atan(2 / 1)),yp + d * sin(atan(2 / 1))
                    )
                );

        RETURN range_query2(sgeo, wtim, k, l, tolerance_s, tolerance_t, user_id, min_lns, smooth_factor, time_step, max_step);
    END distance_query2;

-- -----------------------------------------------------
-- Function knn_query2
-- -----------------------------------------------------
    FUNCTION knn_query2
    (
        p IN INTEGER,
        n IN INTEGER,
    mxdist IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER
    )
        RETURN mp_array
    IS
    mpp moving_point;
    nnt number_nt;
    nnt2 number_nt;
    real_tr mp_array;
    real_tr_sliced mp_array;
    real_spw mp_array := mp_array();
    fk mp_array;
    nfk mp_array := mp_array();
    nfk1 mp_array := mp_array();
    sgeo mdsys.sdo_geometry;
    pos1 NUMBER;
    pos2 NUMBER;
    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;

    user_id_t NUMBER := user_id;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        min_traj_id NUMBER;

        d mp_array;
        m_ps mp_array;

        mbr mdsys.sdo_geometry;

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n2 INTEGER;

    comb INTEGER;

    i INTEGER;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    SELECT moving_point(m.mpoint.at_period(wtim).u_tab, m.traj_id, m.mpoint.srid)
            INTO mpp
        FROM mpoints m
    WHERE m.traj_id = p;

    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim) IS NOT NULL;

    /*
    here
    */
    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m
    WHERE min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp) <= mxdist;

    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM fakes m
    WHERE m.user_id = user_id_t AND minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO fk
        FROM TABLE(d) m
    WHERE moving_point(m.u_tab, NULL, null).at_period(wtim) IS NOT NULL AND min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp) <= mxdist;

    IF k2 >= n THEN
      IF real_tr_sliced.COUNT + fk.COUNT = k2 THEN
        RETURN real_tr_sliced MULTISET UNION fk;
      ELSIF real_tr_sliced.COUNT + fk.COUNT < k2 THEN
        k2 := k2 - (real_tr_sliced.COUNT + fk.COUNT);
      ELSE
        SELECT moving_point(m.u_tab, m.traj_id, m.srid)
          BULK COLLECT INTO d
        FROM TABLE(real_tr_sliced MULTISET UNION fk) m
        ORDER BY min_dist(moving_point(m.u_tab, NULL, null), mpp);

        d.DELETE(k2 + 1, d.COUNT);

        RETURN d;
      END IF;
    ELSE
      IF real_tr_sliced.COUNT + fk.COUNT < k2 THEN
        k2 := k2 - (real_tr_sliced.COUNT + fk.COUNT);
      ELSIF real_tr_sliced.COUNT + fk.COUNT >= k2 AND real_tr_sliced.COUNT + fk.COUNT <= n THEN
        RETURN real_tr_sliced MULTISET UNION fk;
      ELSE
        SELECT moving_point(m.u_tab, m.traj_id, m.srid)
          BULK COLLECT INTO d
        FROM TABLE(real_tr_sliced MULTISET UNION fk) m
        ORDER BY min_dist(moving_point(m.u_tab, NULL, null), mpp);

        d.DELETE(n + 1, d.COUNT);

        RETURN d;
      END IF;
    END IF;

        IF real_tr_sliced.COUNT < l THEN
      raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO d
        FROM TABLE(real_tr) m
        WHERE m.traj_id IN (SELECT p.traj_id FROM TABLE(real_tr_sliced) p);

    real_tr := d;

    SELECT sdo_aggr_mbr(moving_point(m.u_tab, NULL, null).route())
            INTO sgeo
        FROM TABLE(real_tr) m;

        SELECT min(t.traj_id), min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_traj_id, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_tr) t;

        segments := traclus.segments_from_trajectories(real_tr);

        IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n2 := real_tr.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n2 LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n2) / (factorial(r) * factorial(n2 - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_tr) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);

        IF mp1 IS NOT NULL THEN
          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            IF min_dist(mp2, mpp) <= mxdist THEN
              mp1.traj_id := next_fake(user_id);

              nfk.EXTEND;
              nfk(nfk.LAST) := mp2;
              nfk(nfk.LAST).traj_id := mp1.traj_id;

              nfk1.EXTEND;
              nfk1(nfk1.LAST) := mp1;
              nfk1(nfk1.LAST).traj_id := mp1.traj_id;

              k2 := k2 - 1;
              IF k2 = 0 THEN
                pos2 := nfk1.FIRST;
                WHILE pos2 IS NOT NULL LOOP
                  INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk1(pos2).traj_id, nfk1(pos2),k);
                  pos2 := nfk1.NEXT(pos2);
                END LOOP;

                RETURN real_tr_sliced MULTISET UNION fk MULTISET UNION nfk;
              END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    raise_application_error(-20988,'C$HERMES-HPV-001:privacy threat');
    END knn_query2;

-- -----------------------------------------------------
-- Function b_range_query
-- -----------------------------------------------------
    FUNCTION b_range_query
    (
        sgeo IN mdsys.sdo_geometry,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
    fl1 NUMBER;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

    rnd1 moving_point;
    rnd2 moving_point;

    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;
    u_tab_t2 moving_point_tab;
    fk mp_array := mp_array();
    nfk mp_array := mp_array();
    nfk2 mp_array := mp_array();

    nnt number_nt;
    nnt2 number_nt;

    seg_i unit_moving_point;
    seg_e unit_moving_point;

    sgeo_t mdsys.sdo_geometry;
        wtim_t tau_tll.d_period_sec;

    nmb1 NUMBER;
    nmb2 NUMBER;

    c_x NUMBER;
    c_y NUMBER;
    mn_x NUMBER;
    mx_x NUMBER;
    mn_y NUMBER;
    mx_y NUMBER;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n INTEGER;

    comb INTEGER;

    i INTEGER;
    j INTEGER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        d mp_array;
    real_tr mp_array := mp_array();
    real_tr_sliced mp_array := mp_array();
    real_spw mp_array := mp_array();
        m_ps mp_array := mp_array();

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

    f_segments unit_moving_point_nt;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    dur_nop := NULL;
    exc := 0;
    exc_det := NULL;
    fret := 0;

    t1 := LOCALTIMESTAMP;
    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;
    t2 := LOCALTIMESTAMP;

    interv := t2 - t1;
    dur_nop := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);

    SELECT p.traj_id
      BULK COLLECT INTO nnt
    FROM TABLE(real_tr) p;

    nnt2 := near_windows(user_id, sgeo, wtim.b, wtim.e, tolerance_s, tolerance_t, nnt);
    IF nnt2.COUNT > 0 THEN
      exc := 1;
      exc_det := 'NEAR';
      RETURN NULL;
    END IF;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m;

    IF real_tr_sliced.COUNT >= k2 THEN
      update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
            RETURN real_tr_sliced;
        END IF;

        IF real_tr_sliced.COUNT < l THEN
      exc := 1;
      exc_det := 'L';
      RETURN NULL;
        END IF;

        k2 := k2 - real_tr_sliced.COUNT;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_spw
        FROM TABLE(real_tr) m
        WHERE moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005) IS NOT NULL;

        SELECT min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_spw) t;

        segments := traclus.segments_from_trajectories(real_spw);

    IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n := real_spw.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n) / (factorial(r) * factorial(n - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          exc := 1;
          exc_det := 'LPT';
          RETURN NULL;
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_spw) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        t1 := LOCALTIMESTAMP;
        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);
        t2 := LOCALTIMESTAMP;

        IF mp1 IS NOT NULL THEN
          interv := t2 - t1;
          dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
          INSERT INTO h_fake_dur(bid, rid, dur) VALUES (bid_in, rid_in, dur_t);

          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            mp3 := mp2.f_intersection2(sgeo, 0.005);
            IF mp3 IS NOT NULL THEN
            IF mp3.u_tab IS NOT NULL THEN
            IF mp3.u_tab.FIRST IS NOT NULL THEN
              nfk.EXTEND;
              nfk(nfk.LAST) := mp3;

              k2 := k2 - 1;
              IF k2 = 0 THEN
                pos2 := nfk.FIRST;
                WHILE pos2 IS NOT NULL LOOP
                  nfk(pos2).traj_id := next_fake(user_id);
                  INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk(pos2).traj_id, nfk(pos2),k);

                  pos2 := nfk.NEXT(pos2);
                END LOOP;

                update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
                RETURN real_tr_sliced MULTISET UNION nfk;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    exc := 1;
    exc_det := 'LPC';
    RETURN NULL;

    EXCEPTION
      WHEN OTHERS THEN
        exc := 1;
        exc_det := 'UFO';
        RETURN NULL;
    END b_range_query;

-- -----------------------------------------------------
-- Function b_distance_query
-- -----------------------------------------------------
    FUNCTION b_distance_query
    (
        xp IN NUMBER,
        yp IN NUMBER,
        d IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
        SRID NUMBER;
        sgeo mdsys.sdo_geometry;
    begin
        SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

        sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,4),
                mdsys.sdo_ordinate_array(
                    xp + d * cos(atan(0)),yp + d * sin(atan(0)),
                    xp + d * cos(atan(1)),yp + d * sin(atan(1)),
                    xp + d * cos(atan(2 / 1)),yp + d * sin(atan(2 / 1))
                    )
                );
        RETURN b_range_query(sgeo, wtim, k, l, tolerance_s, tolerance_t, user_id, min_lns, smooth_factor, time_step, max_step, bid_in, rid_in, dur_nop, exc, exc_det, fret);
    END b_distance_query;

-- -----------------------------------------------------
-- Function b_knn_query
-- -----------------------------------------------------
    FUNCTION b_knn_query
    (
        p IN INTEGER,
        n IN INTEGER,
    mxdist IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
    mpp moving_point;
    nnt number_nt;
    nnt2 number_nt;
    real_tr mp_array;
    real_tr_sliced mp_array;
    real_spw mp_array := mp_array();
    fk mp_array;
    nfk mp_array := mp_array();
    sgeo mdsys.sdo_geometry;
    pos1 NUMBER;
    pos2 NUMBER;
    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        min_traj_id NUMBER;

        d mp_array;
        m_ps mp_array;

        mbr mdsys.sdo_geometry;

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n2 INTEGER;

    comb INTEGER;

    i INTEGER;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    dur_nop := NULL;
    exc := 0;
    exc_det := NULL;
    fret := 0;

    SELECT moving_point(m.mpoint.at_period(wtim).u_tab, m.traj_id, m.mpoint.srid)
            INTO mpp
        FROM mpoints m
    WHERE m.traj_id = p;

    t1 := LOCALTIMESTAMP;
    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim) IS NOT NULL;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m
    WHERE min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp) <= mxdist
    ORDER BY min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp);
    t2 := LOCALTIMESTAMP;

    interv := t2 - t1;
    dur_nop := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);

    SELECT sdo_aggr_mbr(moving_point(m.u_tab, NULL, null).route())
            INTO sgeo
        FROM TABLE(real_tr_sliced) m;

    SELECT m.traj_id
      BULK COLLECT INTO nnt
    FROM TABLE(real_tr_sliced) m;

    nnt2 := near_windows(user_id, sgeo, wtim.b, wtim.e, tolerance_s, tolerance_t, nnt);
    IF nnt2.COUNT > 0 THEN
      exc := 1;
      exc_det := 'NEAR';
      RETURN NULL;
    END IF;

    IF k2 >= n THEN
      IF real_tr_sliced.COUNT = k2 THEN
        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      ELSIF real_tr_sliced.COUNT < k2 THEN
        k2 := k2 - real_tr_sliced.COUNT;
      ELSE
        real_tr_sliced.DELETE(k2 + 1, real_tr_sliced.COUNT);

        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      END IF;
    ELSE
      IF real_tr_sliced.COUNT < k2 THEN
        k2 := k2 - real_tr_sliced.COUNT;
      ELSIF real_tr_sliced.COUNT >= k2 AND real_tr_sliced.COUNT <= n THEN
        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      ELSE
        real_tr_sliced.DELETE(n + 1, real_tr_sliced.COUNT);

        update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
        RETURN real_tr_sliced;
      END IF;
    END IF;

        IF real_tr_sliced.COUNT < l THEN
      exc := 1;
      exc_det := 'L';
      RETURN NULL;
        END IF;

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO d
        FROM TABLE(real_tr) m
        WHERE m.traj_id IN (SELECT p.traj_id FROM TABLE(real_tr_sliced) p);

    real_tr := d;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_spw
        FROM TABLE(real_tr) m
    WHERE moving_point(m.u_tab, NULL, null).f_intersection2(sgeo, 0.005) IS NOT NULL;

        SELECT min(t.traj_id), min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_traj_id, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_spw) t;

        segments := traclus.segments_from_trajectories(real_spw);

        IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n2 := real_spw.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n2 LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n2) / (factorial(r) * factorial(n2 - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          exc := 1;
          exc_det := 'LPT';
          RETURN NULL;
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_spw) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        t1 := LOCALTIMESTAMP;
        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);
        t2 := LOCALTIMESTAMP;

        IF mp1 IS NOT NULL THEN
          interv := t2 - t1;
          dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
          INSERT INTO h_fake_dur(bid, rid, dur) VALUES (bid_in, rid_in, dur_t);

          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            mp3 := mp2.f_intersection2(sgeo, 0.005);
            IF mp3 IS NOT NULL THEN
            IF mp3.u_tab IS NOT NULL THEN
            IF mp3.u_tab.FIRST IS NOT NULL THEN
              IF min_dist(mp3, mpp) <= mxdist THEN
                nfk.EXTEND;
                nfk(nfk.LAST) := mp3;

                k2 := k2 - 1;
                IF k2 = 0 THEN
                  pos2 := nfk.FIRST;
                  WHILE pos2 IS NOT NULL LOOP
                    nfk(pos2).traj_id := next_fake(user_id);
                    INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk(pos2).traj_id, nfk(pos2),k);

                    pos2 := nfk.NEXT(pos2);
                  END LOOP;

                  update_hist(user_id, sgeo, wtim.b, wtim.e, nnt);
                  RETURN real_tr_sliced MULTISET UNION nfk;
                END IF;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    exc := 1;
    exc_det := 'LPC';
    RETURN NULL;

    EXCEPTION
      WHEN OTHERS THEN
        exc := 1;
        exc_det := 'UFO';
        RETURN NULL;
    END b_knn_query;

-- -----------------------------------------------------
-- Function b_range_query2
-- -----------------------------------------------------
    FUNCTION b_range_query2
    (
        sgeo IN mdsys.sdo_geometry,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
    pos1 NUMBER;
    pos2 NUMBER;
    fl1 NUMBER;

    user_id_t NUMBER := user_id;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;
    u_tab_t2 moving_point_tab;
    fk mp_array := mp_array();
    nfk mp_array := mp_array();
    nfk1 mp_array := mp_array();

    seg_i unit_moving_point;
    seg_e unit_moving_point;

    c_x NUMBER;
    c_y NUMBER;
    mn_x NUMBER;
    mx_x NUMBER;
    mn_y NUMBER;
    mx_y NUMBER;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n INTEGER;

    comb INTEGER;

    i INTEGER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        d mp_array;
    real_tr mp_array := mp_array();
    real_tr_sliced mp_array := mp_array();
    real_spw mp_array := mp_array();
        m_ps mp_array := mp_array();

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

    f_segments unit_moving_point_nt;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    dur_nop := NULL;
    exc := 0;
    exc_det := NULL;
    fret := 0;

    t1 := LOCALTIMESTAMP;
    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;
    t2 := LOCALTIMESTAMP;

    interv := t2 - t1;
    dur_nop := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m;

    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM fakes m
    WHERE m.user_id = user_id_t AND minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005).u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO fk
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim).f_intersection2(sgeo, 0.005) IS NOT NULL;

    IF real_tr.COUNT + fk.COUNT >= k2 THEN
            RETURN real_tr_sliced MULTISET UNION fk;
        END IF;

        IF real_tr.COUNT < l THEN
      exc := 1;
      exc_det := 'L';
      RETURN NULL;
        END IF;

        k2 := k2 - (real_tr.COUNT + fk.COUNT);

        SELECT min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_tr) t;

        segments := traclus.segments_from_trajectories(real_tr);

    IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n := real_tr.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n) / (factorial(r) * factorial(n - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          exc := 1;
          exc_det := 'LPT';
          RETURN NULL;
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_tr) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        t1 := LOCALTIMESTAMP;
        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);
        t2 := LOCALTIMESTAMP;

        IF mp1 IS NOT NULL THEN
          interv := t2 - t1;
          dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
          INSERT INTO h_fake_dur(bid, rid, dur) VALUES (bid_in, rid_in, dur_t);

          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            mp3 := mp2.f_intersection2(sgeo, 0.005);
            IF mp3 IS NOT NULL THEN
            IF mp3.u_tab IS NOT NULL THEN
            IF mp3.u_tab.FIRST IS NOT NULL THEN
              mp1.traj_id := next_fake(user_id);

              nfk.EXTEND;
              nfk(nfk.LAST) := mp3;
              nfk(nfk.LAST).traj_id := mp1.traj_id;

              nfk1.EXTEND;
              nfk1(nfk1.LAST) := mp1;
              nfk1(nfk1.LAST).traj_id := mp1.traj_id;

              k2 := k2 - 1;
              IF k2 = 0 THEN
                pos2 := nfk1.FIRST;
                WHILE pos2 IS NOT NULL LOOP
                  INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk1(pos2).traj_id, nfk1(pos2),k);
                  pos2 := nfk1.NEXT(pos2);
                END LOOP;

                RETURN real_tr_sliced MULTISET UNION fk MULTISET UNION nfk;
              END IF;
            END IF;
            END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    exc := 1;
    exc_det := 'LPC';
    RETURN NULL;

    EXCEPTION
      WHEN OTHERS THEN
        exc := 1;
        exc_det := 'UFO';
        RETURN NULL;
    END b_range_query2;

-- -----------------------------------------------------
-- Function b_distance_query2
-- -----------------------------------------------------
    FUNCTION b_distance_query2
    (
        xp IN NUMBER,
        yp IN NUMBER,
        d IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
        SRID NUMBER;
        sgeo mdsys.sdo_geometry;
    begin
        SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

        sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,4),
                mdsys.sdo_ordinate_array(
                    xp + d * cos(atan(0)),yp + d * sin(atan(0)),
                    xp + d * cos(atan(1)),yp + d * sin(atan(1)),
                    xp + d * cos(atan(2 / 1)),yp + d * sin(atan(2 / 1))
                    )
                );

        RETURN b_range_query2(sgeo, wtim, k, l, tolerance_s, tolerance_t, user_id, min_lns, smooth_factor, time_step, max_step, bid_in, rid_in, dur_nop, exc, exc_det, fret);
    END b_distance_query2;

-- -----------------------------------------------------
-- Function b_knn_query2
-- -----------------------------------------------------
    FUNCTION b_knn_query2
    (
        p IN INTEGER,
        n IN INTEGER,
    mxdist IN NUMBER,
        wtim IN tau_tll.d_period_sec,
        k IN NATURALN,
    l IN NATURALN,
        tolerance_s IN NUMBER,
    tolerance_t IN NUMBER,
        user_id IN NUMBER,
    min_lns IN NUMBER,
    smooth_factor IN NUMBER,
    time_step IN NUMBER,
    max_step IN NUMBER,
    bid_in IN NUMBER,
    rid_in IN NUMBER,
    dur_nop OUT NUMBER,
    exc OUT NUMBER,
    exc_det OUT VARCHAR2,
    fret OUT NUMBER
    )
        RETURN mp_array
    IS
    mpp moving_point;
    nnt number_nt;
    nnt2 number_nt;
    real_tr mp_array;
    real_tr_sliced mp_array;
    real_spw mp_array := mp_array();
    fk mp_array;
    nfk mp_array := mp_array();
    nfk1 mp_array := mp_array();
    sgeo mdsys.sdo_geometry;
    pos1 NUMBER;
    pos2 NUMBER;
    mp1 moving_point;
    mp2 moving_point;
    mp3 moving_point;

    user_id_t NUMBER := user_id;

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    tt TIMESTAMP;
    tti TIMESTAMP;
    it INTERVAL DAY TO SECOND;
    dit NUMBER;

        k2 NATURALN := k;
        step NUMBER;
    step_min NUMBER;

        min_traj_id NUMBER;

        d mp_array;
        m_ps mp_array;

        mbr mdsys.sdo_geometry;

        min_t NUMBER;
        max_t NUMBER;

        ft NUMBER;
    fl NUMBER := 0;
    lpc NUMBER := 0;

    num_buf number_nt;
    r_buf number_nt;
    r INTEGER;
    n2 INTEGER;

    comb INTEGER;

    i INTEGER;

        segments unit_moving_point_nt;
        segments_t unit_moving_point_nt;
        u_tab_t moving_point_tab;

        time_step2 NUMBER;

        flag1 NUMBER;
        flag2 NUMBER;

        min_tr_dur NUMBER;
        max_tr_dur NUMBER;
        t_min NUMBER;
        t_max NUMBER;
        min_tr_avg_speed NUMBER;
        max_tr_avg_speed NUMBER;
        min_seg_len NUMBER;
        max_seg_len NUMBER;
        avg_seg_len NUMBER;
    BEGIN
    dur_nop := NULL;
    exc := 0;
    exc_det := NULL;
    fret := 0;

    SELECT moving_point(m.mpoint.at_period(wtim).u_tab, m.traj_id, m.mpoint.srid)
            INTO mpp
        FROM mpoints m
    WHERE m.traj_id = p;

    t1 := LOCALTIMESTAMP;
    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM mpoints m
    WHERE minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO real_tr
        FROM TABLE(d) m
        WHERE moving_point(m.u_tab, NULL, null).at_period(wtim) IS NOT NULL;

    SELECT moving_point(moving_point(m.u_tab, NULL, null).at_period(wtim).u_tab, m.traj_id,m.srid)
            BULK COLLECT INTO real_tr_sliced
        FROM TABLE(real_tr) m
    WHERE min_dist(moving_point(m.u_tab, NULL, null).at_period(wtim), mpp) <= mxdist;
    t2 := LOCALTIMESTAMP;

    interv := t2 - t1;
    dur_nop := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);

    SELECT m.mpoint
            BULK COLLECT INTO d
        FROM fakes m
    WHERE m.user_id = user_id_t AND minof_2(wtim.e.get_abs_date(), m.mpoint.f_final_timepoint().get_abs_date()) > maxof_2(wtim.b.get_abs_date(), m.mpoint.f_initial_timepoint().get_abs_date());

    SELECT moving_point(moving_point(m.u_tab, NULL,null).at_period(wtim).u_tab, m.traj_id,m.srid)
            BULK COLLECT INTO fk
        FROM TABLE(d) m
    WHERE moving_point(m.u_tab, NULL,null).at_period(wtim) IS NOT NULL AND min_dist(moving_point(m.u_tab, NULL,null).at_period(wtim), mpp) <= mxdist;

    IF k2 >= n THEN
      IF real_tr_sliced.COUNT + fk.COUNT = k2 THEN
        RETURN real_tr_sliced MULTISET UNION fk;
      ELSIF real_tr_sliced.COUNT + fk.COUNT < k2 THEN
        k2 := k2 - (real_tr_sliced.COUNT + fk.COUNT);
      ELSE
        SELECT moving_point(m.u_tab, m.traj_id, m.srid)
          BULK COLLECT INTO d
        FROM TABLE(real_tr_sliced MULTISET UNION fk) m
        ORDER BY min_dist(moving_point(m.u_tab, NULL, null), mpp);

        d.DELETE(k2 + 1, d.COUNT);

        RETURN d;
      END IF;
    ELSE
      IF real_tr_sliced.COUNT + fk.COUNT < k2 THEN
        k2 := k2 - (real_tr_sliced.COUNT + fk.COUNT);
      ELSIF real_tr_sliced.COUNT + fk.COUNT >= k2 AND real_tr_sliced.COUNT + fk.COUNT <= n THEN
        RETURN real_tr_sliced MULTISET UNION fk;
      ELSE
        SELECT moving_point(m.u_tab, m.traj_id, m.srid)
          BULK COLLECT INTO d
        FROM TABLE(real_tr_sliced MULTISET UNION fk) m
        ORDER BY min_dist(moving_point(m.u_tab, NULL, null), mpp);

        d.DELETE(n + 1, d.COUNT);

        RETURN d;
      END IF;
    END IF;

        IF real_tr_sliced.COUNT < l THEN
      exc := 1;
      exc_det := 'L';
      RETURN NULL;
        END IF;

    SELECT moving_point(m.u_tab, m.traj_id, m.srid)
            BULK COLLECT INTO d
        FROM TABLE(real_tr) m
        WHERE m.traj_id IN (SELECT p.traj_id FROM TABLE(real_tr_sliced) p);

    real_tr := d;

    SELECT sdo_aggr_mbr(moving_point(m.u_tab, NULL, null).route())
            INTO sgeo
        FROM TABLE(real_tr) m;

        SELECT min(t.traj_id), min(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date() - t.f_initial_timepoint().get_abs_date()), min(t.f_initial_timepoint().get_abs_date()), max(t.f_final_timepoint().get_abs_date()), min(t.f_avg_speed()), max(t.f_avg_speed())
            INTO min_traj_id, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed
        FROM TABLE(real_tr) t;

        segments := traclus.segments_from_trajectories(real_tr);

        IF time_step IS NULL THEN
      SELECT avg(s.p.duration().m_Value), min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO time_step2, min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    ELSE
      time_step2 := time_step;
      SELECT min(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), max(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye)), avg(euclidean_distance(s.m.xi, s.m.yi, s.m.xe, s.m.ye))
        INTO min_seg_len, max_seg_len, avg_seg_len
      FROM TABLE(segments) s;
    END IF;

    n2 := real_tr.COUNT;

    num_buf := number_nt();
    FOR pos1 IN 2..n2 LOOP
      num_buf.EXTEND;
      num_buf(num_buf.LAST) := pos1;
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO r_buf
    FROM TABLE(num_buf)
    ORDER BY dbms_random.value;

    tti := LOCALTIMESTAMP;
    pos1 := r_buf.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      r := r_buf(pos1);
      comb := factorial(n2) / (factorial(r) * factorial(n2 - r));
      FOR i IN 1..comb LOOP
        tt := LOCALTIMESTAMP;
        it := tt - tti;
        dit := ABS(EXTRACT(SECOND FROM it) + EXTRACT(MINUTE FROM it) * 60 + EXTRACT(HOUR FROM it) * 60 * 60 + EXTRACT(DAY FROM it) * 24 * 60 * 60);
        IF dit >= 900 THEN
          exc := 1;
          exc_det := 'LPT';
          RETURN NULL;
        END IF;

        SELECT moving_point(p.u_tab, p.traj_id, p.srid)
          BULK COLLECT INTO d
        FROM
        (
          SELECT m.u_tab, m.traj_id, m.srid
          FROM TABLE(real_tr) m
          ORDER BY dbms_random.value
        ) p
        WHERE ROWNUM <= r;

        segments_t := traclus.segments_from_trajectories(d);

        t1 := LOCALTIMESTAMP;
        mp1 := fake_trajectory(segments_t, min_lns, smooth_factor, time_step2, min_tr_dur, max_tr_dur, t_min, t_max, min_tr_avg_speed, max_tr_avg_speed, min_seg_len, max_seg_len, avg_seg_len, sgeo, wtim, 1, flag1, flag2);
        t2 := LOCALTIMESTAMP;

        IF mp1 IS NOT NULL THEN
          interv := t2 - t1;
          dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
          INSERT INTO h_fake_dur(bid, rid, dur) VALUES (bid_in, rid_in, dur_t);

          mp2 := mp1.at_period(wtim);
          IF mp2 IS NOT NULL THEN
          IF mp2.u_tab IS NOT NULL THEN
          IF mp2.u_tab.FIRST IS NOT NULL THEN
            IF min_dist(mp2, mpp) <= mxdist THEN
              mp1.traj_id := next_fake(user_id);

              nfk.EXTEND;
              nfk(nfk.LAST) := mp2;
              nfk(nfk.LAST).traj_id := mp1.traj_id;

              nfk1.EXTEND;
              nfk1(nfk1.LAST) := mp1;
              nfk1(nfk1.LAST).traj_id := mp1.traj_id;

              k2 := k2 - 1;
              IF k2 = 0 THEN
                pos2 := nfk1.FIRST;
                WHILE pos2 IS NOT NULL LOOP
                  INSERT INTO fakes(user_id, traj_id, mpoint,k_param) VALUES (user_id, nfk1(pos2).traj_id, nfk1(pos2),k);
                  pos2 := nfk1.NEXT(pos2);
                END LOOP;

                RETURN real_tr_sliced MULTISET UNION fk MULTISET UNION nfk;
              END IF;
            END IF;
          END IF;
          END IF;
          END IF;
        END IF;
      END LOOP;
      pos1 := r_buf.NEXT(pos1);
    END LOOP;

    exc := 1;
    exc_det := 'LPC';
    RETURN NULL;

    EXCEPTION
      WHEN OTHERS THEN
        exc := 1;
        exc_det := 'UFO';
        RETURN NULL;
    END b_knn_query2;

-- -----------------------------------------------------
-- Procedure bench_range
-- -----------------------------------------------------
  PROCEDURE bench_range
  (
    bid_t IN NUMBER,
    user_id_t IN NUMBER,
    k IN NUMBER,
    l IN NUMBER,
    min_lns_t IN NUMBER,
    smooth_factor_t IN NUMBER,
    time_step_t IN NUMBER,
    max_step_t IN NUMBER,
    volumes_t IN number_nt
  )
    IS
    SRID NUMBER;
    mbr mdsys.sdo_geometry;
    xmin NUMBER;
    ymin NUMBER;
    tmin NUMBER;
    xmax NUMBER;
    ymax NUMBER;
    tmax NUMBER;
    dx NUMBER;
    dy NUMBER;
    dt NUMBER;
    s_vol NUMBER;

    qtyp_t VARCHAR2(20);

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    nrfk NUMBER;

    sgeo mdsys.sdo_geometry;
    per tau_tll.d_period_sec;

    tolerance_s NUMBER;
    tolerance_t NUMBER;

    dur_nop NUMBER;
    exc_check NUMBER;
    exc_details VARCHAR2(60);
    fret_t NUMBER;

    i NUMBER;
    j NUMBER;
    mxrid NUMBER;
    nnv number_nt;
    nnt number_nt;
    volumes number_nt;

    pos1 NUMBER;
    pos2 NUMBER;

    vol_t NUMBER;
    s_edge NUMBER;
    t_edge NUMBER;

    x1_t NUMBER;
    y1_t NUMBER;
    t1_t NUMBER;
    x2_t NUMBER;
    y2_t NUMBER;
    t2_t NUMBER;

    ret mp_array;
    tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
    te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
  begin
    SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

    qtyp_t := 'RANGE';

    SELECT count(*)
      INTO mxrid
    FROM h_benchmark_run
    WHERE bid = bid_t;

    SELECT DISTINCT column_value
      BULK COLLECT INTO nnv
    FROM TABLE(volumes_t);

    nnt := number_nt();
    pos1 := nnv.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      vol_t := nnv(pos1);

      SELECT count(*)
        INTO i
      FROM TABLE(volumes_t)
      WHERE column_value = vol_t;

      SELECT i - count(*)
        INTO j
      FROM h_benchmark_run
      WHERE bid = bid_t AND vol = vol_t;

      FOR pos2 IN 1..j LOOP
        nnt.EXTEND;
        nnt(nnt.LAST) := vol_t;
      END LOOP;

      pos1 := nnv.NEXT(pos1);
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO volumes
    FROM TABLE(nnt)
    ORDER BY dbms_random.value; --ORDER BY column_value;

    SELECT mdsys.sdo_aggr_mbr(m.mpoint.route()) INTO mbr FROM mpoints m;
    xmin := sdo_geom.sdo_min_mbr_ordinate(mbr, 1);
    ymin := sdo_geom.sdo_min_mbr_ordinate(mbr, 2);
    xmax := sdo_geom.sdo_max_mbr_ordinate(mbr, 1);
    ymax := sdo_geom.sdo_max_mbr_ordinate(mbr, 2);
    dx := xmax - xmin;
    dy := ymax - ymin;
    s_vol := dx * dy;

    IF dx <= dy THEN
      tolerance_s := 0.001 * dx;
    ELSE
      tolerance_s := 0.001 * dy;
    END IF;
/*
    dbms_output.put_line('xmin: ' || xmin);
    dbms_output.put_line('ymin: ' || ymin);
    dbms_output.put_line('xmax: ' || xmax);
    dbms_output.put_line('ymax: ' || ymax);
    dbms_output.put_line('dx: ' || dx);
    dbms_output.put_line('dy: ' || dy);
    dbms_output.put_line('tolerance_s: ' || tolerance_s);
*/
    SELECT min(m.mpoint.f_initial_timepoint().get_abs_date()), max(m.mpoint.f_final_timepoint().get_abs_date()) INTO tmin, tmax FROM mpoints m;
    dt := tmax - tmin;
    tolerance_t := 0.001 * dt;
/*
    dbms_output.put_line('tmin: ' || tmin);
    dbms_output.put_line('tmax: ' || tmax);
    dbms_output.put_line('dt: ' || dt);
    dbms_output.put_line('tolerance_t: ' || tolerance_t);
*/
    IF mxrid = 0 THEN
      INSERT INTO h_benchmark(bid, qtyp, k_param, l_param, min_lns, smooth_factor, max_step, user_id) VALUES (bid_t, qtyp_t, k, l, min_lns_t, smooth_factor_t, max_step_t, user_id_t);
    END IF;

    pos1 := volumes.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      vol_t := volumes(pos1);

      s_edge := sqrt(s_vol * vol_t);
      t_edge := dt * vol_t;

      x1_t := dbms_random.value(xmin, xmax - s_edge);
      y1_t := dbms_random.value(ymin, ymax - s_edge);
      t1_t := dbms_random.value(tmin, tmax - t_edge);
      x2_t := x1_t + s_edge;
      y2_t := y1_t + s_edge;
      t2_t := t1_t + t_edge;

      INSERT INTO h_benchmark_run(bid, rid, vol, x_min, y_min, t_min, x_max, y_max, t_max, exc, exc_det, nr_of_fakes) VALUES (bid_t, pos1 + mxrid, vol_t, x1_t, y1_t, t1_t, x2_t, y2_t, t2_t, 0, NULL, 0);

      sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,3), mdsys.sdo_ordinate_array(x1_t,y1_t, x2_t,y2_t));
      tb.set_abs_date(t1_t);
      te.set_abs_date(t2_t);
      per := tau_tll.d_period_sec(tb, te);

      t1 := LOCALTIMESTAMP;
      ret := b_range_query(sgeo, per, k, l, tolerance_s, tolerance_t, user_id_t, min_lns_t, smooth_factor_t, time_step_t, max_step_t, bid_t, pos1 + mxrid, dur_nop, exc_check, exc_details, fret_t);
      --b_range_query(spatial region, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
      --if time step is NULL then time step will be determined as the average duration of segments
      t2 := LOCALTIMESTAMP;

      IF exc_check = 0 THEN
        interv := t2 - t1;
        dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
        INSERT INTO h_range_dur(bid, rid, dur) VALUES (bid_t, pos1 + mxrid, dur_t);

        INSERT INTO h_range_nop_dur(bid, rid, dur) VALUES (bid_t, pos1 + mxrid, dur_nop);
      END IF;

      SELECT count(*) INTO nrfk FROM fakes fs WHERE fs.user_id = user_id_t;
      UPDATE h_benchmark_run
      SET nr_of_fakes = nrfk, exc = exc_check, exc_det = exc_details
      WHERE bid = bid_t AND rid = pos1 + mxrid;

      COMMIT;

      pos1 := volumes.NEXT(pos1);
    END LOOP;
  END bench_range;

-- -----------------------------------------------------
-- Procedure bench_range2
-- -----------------------------------------------------
  PROCEDURE bench_range2
  (
    bid_t IN NUMBER,
    user_id_t IN NUMBER,
    k IN NUMBER,
    l IN NUMBER,
    min_lns_t IN NUMBER,
    smooth_factor_t IN NUMBER,
    time_step_t IN NUMBER,
    max_step_t IN NUMBER,
    volumes_t IN number_nt
  )
    IS
    SRID NUMBER;
    mbr mdsys.sdo_geometry;
    xmin NUMBER;
    ymin NUMBER;
    tmin NUMBER;
    xmax NUMBER;
    ymax NUMBER;
    tmax NUMBER;
    dx NUMBER;
    dy NUMBER;
    dt NUMBER;
    s_vol NUMBER;

    qtyp_t VARCHAR2(20);

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    nrfk NUMBER;

    sgeo mdsys.sdo_geometry;
    per tau_tll.d_period_sec;

    tolerance_s NUMBER;
    tolerance_t NUMBER;

    dur_nop NUMBER;
    exc_check NUMBER;
    exc_details VARCHAR2(60);
    fret_t NUMBER;

    i NUMBER;
    j NUMBER;
    mxrid NUMBER;
    nnv number_nt;
    nnt number_nt;
    volumes number_nt;

    pos1 NUMBER;
    pos2 NUMBER;

    vol_t NUMBER;
    s_edge NUMBER;
    t_edge NUMBER;

    x1_t NUMBER;
    y1_t NUMBER;
    t1_t NUMBER;
    x2_t NUMBER;
    y2_t NUMBER;
    t2_t NUMBER;

    ret mp_array;
    tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
    te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
  begin
    SELECT value INTO SRID FROM parameters WHERE id = 'SRID' and table_name='MPOINTS';

    qtyp_t := 'RANGE2';

    SELECT count(*)
      INTO mxrid
    FROM h_benchmark_run
    WHERE bid = bid_t;

    SELECT DISTINCT column_value
      BULK COLLECT INTO nnv
    FROM TABLE(volumes_t);

    nnt := number_nt();
    pos1 := nnv.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      vol_t := nnv(pos1);

      SELECT count(*)
        INTO i
      FROM TABLE(volumes_t)
      WHERE column_value = vol_t;

      SELECT i - count(*)
        INTO j
      FROM h_benchmark_run
      WHERE bid = bid_t AND vol = vol_t;

      FOR pos2 IN 1..j LOOP
        nnt.EXTEND;
        nnt(nnt.LAST) := vol_t;
      END LOOP;

      pos1 := nnv.NEXT(pos1);
    END LOOP;

    SELECT column_value
      BULK COLLECT INTO volumes
    FROM TABLE(nnt)
    ORDER BY dbms_random.value;

    SELECT mdsys.sdo_aggr_mbr(m.mpoint.route()) INTO mbr FROM mpoints m;
    xmin := sdo_geom.sdo_min_mbr_ordinate(mbr, 1);
    ymin := sdo_geom.sdo_min_mbr_ordinate(mbr, 2);
    xmax := sdo_geom.sdo_max_mbr_ordinate(mbr, 1);
    ymax := sdo_geom.sdo_max_mbr_ordinate(mbr, 2);
    dx := xmax - xmin;
    dy := ymax - ymin;
    s_vol := dx * dy;

    IF dx <= dy THEN
      tolerance_s := 0.001 * dx;
    ELSE
      tolerance_s := 0.001 * dy;
    END IF;

    SELECT min(m.mpoint.f_initial_timepoint().get_abs_date()), max(m.mpoint.f_final_timepoint().get_abs_date()) INTO tmin, tmax FROM mpoints m;
    dt := tmax - tmin;
    tolerance_t := 0.001 * dt;

    IF mxrid = 0 THEN
      INSERT INTO h_benchmark(bid, qtyp, k_param, l_param, min_lns, smooth_factor, max_step, user_id) VALUES (bid_t, qtyp_t, k, l, min_lns_t, smooth_factor_t, max_step_t, user_id_t);
    END IF;

    pos1 := volumes.FIRST;
    WHILE pos1 IS NOT NULL LOOP
      vol_t := volumes(pos1);

      s_edge := sqrt(s_vol * vol_t);
      t_edge := dt * vol_t;

      x1_t := dbms_random.value(xmin, xmax - s_edge);
      y1_t := dbms_random.value(ymin, ymax - s_edge);
      t1_t := dbms_random.value(tmin, tmax - t_edge);
      x2_t := x1_t + s_edge;
      y2_t := y1_t + s_edge;
      t2_t := t1_t + t_edge;

      INSERT INTO h_benchmark_run(bid, rid, vol, x_min, y_min, t_min, x_max, y_max, t_max, exc, exc_det, nr_of_fakes) VALUES (bid_t, pos1 + mxrid, vol_t, x1_t, y1_t, t1_t, x2_t, y2_t, t2_t, 0, NULL, 0);

      sgeo := mdsys.sdo_geometry(2003, SRID, NULL, mdsys.sdo_elem_info_array(1,1003,3), mdsys.sdo_ordinate_array(x1_t,y1_t, x2_t,y2_t));
      tb.set_abs_date(t1_t);
      te.set_abs_date(t2_t);
      per := tau_tll.d_period_sec(tb, te);

      t1 := LOCALTIMESTAMP;
      ret := b_range_query2(sgeo, per, k, l, tolerance_s, tolerance_t, user_id_t, min_lns_t, smooth_factor_t, time_step_t, max_step_t, bid_t, pos1 + mxrid, dur_nop, exc_check, exc_details, fret_t);
      --b_range_query2(spatial region, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
      --if time step is NULL then time step will be determined as the average duration of segments
      t2 := LOCALTIMESTAMP;

      IF exc_check = 0 THEN
        interv := t2 - t1;
        dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
        INSERT INTO h_range_dur(bid, rid, dur) VALUES (bid_t, pos1 + mxrid, dur_t);

        INSERT INTO h_range_nop_dur(bid, rid, dur) VALUES (bid_t, pos1 + mxrid, dur_nop);
      END IF;

      SELECT count(*) INTO nrfk FROM fakes fs WHERE fs.user_id = user_id_t;
      UPDATE h_benchmark_run
      SET nr_of_fakes = nrfk, exc = exc_check, exc_det = exc_details
      WHERE bid = bid_t AND rid = pos1 + mxrid;

      COMMIT;

      pos1 := volumes.NEXT(pos1);
    END LOOP;
  END bench_range2;

-- -----------------------------------------------------
-- Procedure bench_knn
-- -----------------------------------------------------
  PROCEDURE bench_knn
  (
    bid_t IN NUMBER,
    user_id_t IN NUMBER,
    k IN NUMBER,
    l IN NUMBER,
    min_lns_t IN NUMBER,
    smooth_factor_t IN NUMBER,
    time_step_t IN NUMBER,
    max_step_t IN NUMBER,
    n IN NUMBER,
    nq IN NUMBER
  )
  IS
    mbr mdsys.sdo_geometry;
    xmin NUMBER;
    ymin NUMBER;
    tmin NUMBER;
    xmax NUMBER;
    ymax NUMBER;
    tmax NUMBER;
    dx NUMBER;
    dy NUMBER;
    dt NUMBER;

    qtyp_t VARCHAR2(20);

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    nrfk NUMBER;

    p moving_point;

    mxdist_t NUMBER;
    per tau_tll.d_period_sec;

    tolerance_s NUMBER;
    tolerance_t NUMBER;

    dur_nop NUMBER;
    exc_check NUMBER;
    exc_details VARCHAR2(60);
    fret_t NUMBER;

    nrtrid NUMBER;

    mxrid NUMBER;

    pos1 NUMBER;

    t1_t NUMBER;
    t2_t NUMBER;

    ret mp_array;
    tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
    te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
  BEGIN
    qtyp_t := 'KNN';

    SELECT count(*)
      INTO mxrid
    FROM h_benchmark_run
    WHERE bid = bid_t;

    SELECT COUNT(DISTINCT traj_id) INTO nrtrid FROM mpoints;

    SELECT mdsys.sdo_aggr_mbr(m.mpoint.route()) INTO mbr FROM mpoints m;
    xmin := sdo_geom.sdo_min_mbr_ordinate(mbr, 1);
    ymin := sdo_geom.sdo_min_mbr_ordinate(mbr, 2);
    xmax := sdo_geom.sdo_max_mbr_ordinate(mbr, 1);
    ymax := sdo_geom.sdo_max_mbr_ordinate(mbr, 2);
    dx := xmax - xmin;
    dy := ymax - ymin;

    IF dx <= dy THEN
      tolerance_s := 0.001 * dx;
      mxdist_t := 0.1 * dy;
    ELSE
      tolerance_s := 0.001 * dy;
      mxdist_t := 0.1 * dx;
    END IF;

    SELECT min(m.mpoint.f_initial_timepoint().get_abs_date()), max(m.mpoint.f_final_timepoint().get_abs_date()) INTO tmin, tmax FROM mpoints m;
    dt := tmax - tmin;
    tolerance_t := 0.001 * dt;

    IF mxrid = 0 THEN
      INSERT INTO h_benchmark(bid, qtyp, k_param, l_param, min_lns, smooth_factor, max_step, user_id) VALUES (bid_t, qtyp_t, k, l, min_lns_t, smooth_factor_t, max_step_t, user_id_t);
    END IF;

    FOR pos1 IN mxrid + 1..nq LOOP
      SELECT m.mpoint
        INTO p
      FROM
      (
        SELECT mpoint FROM mpoints ORDER BY dbms_random.value
      ) m
      WHERE ROWNUM = 1;

      --n := dbms_random.value(1, k * 2);

      tmin := p.f_initial_timepoint().get_abs_date();
      tmax := p.f_final_timepoint().get_abs_date();

      t1_t := dbms_random.value(tmin, tmax - (tmax - tmin) * 0.1);
      t2_t := t1_t + (tmax - tmin) * 0.1;

      INSERT INTO h_benchmark_run(bid, rid, tid, n_param, t_min, t_max, exc, exc_det, nr_of_fakes) VALUES (bid_t, pos1, p.traj_id, n, t1_t, t2_t, 0, NULL, 0);

      tb.set_abs_date(t1_t);
      te.set_abs_date(t2_t);
      per := tau_tll.d_period_sec(tb, te);

      t1 := LOCALTIMESTAMP;
      ret := b_knn_query(p.traj_id, n, mxdist_t, per, k, l, tolerance_s, tolerance_t, user_id_t, min_lns_t, smooth_factor_t, time_step_t, max_step_t, bid_t, pos1, dur_nop, exc_check, exc_details, fret_t);
      --b_knn_query(trajectory id, number of neighbours, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
      --if time step is NULL then time step will be determined as the average duration of segments
      t2 := LOCALTIMESTAMP;

      IF exc_check = 0 THEN
        interv := t2 - t1;
        dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
        INSERT INTO h_knn_dur(bid, rid, dur) VALUES (bid_t, pos1, dur_t);

        INSERT INTO h_knn_nop_dur(bid, rid, dur) VALUES (bid_t, pos1, dur_nop);
      END IF;

      SELECT count(*) INTO nrfk FROM fakes fs WHERE fs.user_id = user_id_t;
      UPDATE h_benchmark_run
      SET nr_of_fakes = nrfk, exc = exc_check, exc_det = exc_details
      WHERE bid = bid_t AND rid = pos1;

      COMMIT;
    END LOOP;
  END bench_knn;

-- -----------------------------------------------------
-- Procedure bench_knn2
-- -----------------------------------------------------
  PROCEDURE bench_knn2
  (
    bid_t IN NUMBER,
    user_id_t IN NUMBER,
    k IN NUMBER,
    l IN NUMBER,
    min_lns_t IN NUMBER,
    smooth_factor_t IN NUMBER,
    time_step_t IN NUMBER,
    max_step_t IN NUMBER,
    n IN NUMBER,
    nq IN NUMBER
  )
  IS
    mbr mdsys.sdo_geometry;
    xmin NUMBER;
    ymin NUMBER;
    tmin NUMBER;
    xmax NUMBER;
    ymax NUMBER;
    tmax NUMBER;
    dx NUMBER;
    dy NUMBER;
    dt NUMBER;

    qtyp_t VARCHAR2(20);

    t1 TIMESTAMP;
    t2 TIMESTAMP;
    interv INTERVAL DAY TO SECOND;
    dur_t NUMBER;

    nrfk NUMBER;

    p moving_point;

    mxdist_t NUMBER;
    per tau_tll.d_period_sec;

    tolerance_s NUMBER;
    tolerance_t NUMBER;

    dur_nop NUMBER;
    exc_check NUMBER;
    exc_details VARCHAR2(60);
    fret_t NUMBER;

    nrtrid NUMBER;

    mxrid NUMBER;

    pos1 NUMBER;

    t1_t NUMBER;
    t2_t NUMBER;

    ret mp_array;
    tb tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
    te tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1,1,1,0,0,0);
  BEGIN
    qtyp_t := 'KNN2';

    SELECT count(*)
      INTO mxrid
    FROM h_benchmark_run
    WHERE bid = bid_t;

    SELECT COUNT(DISTINCT traj_id) INTO nrtrid FROM mpoints;

    SELECT mdsys.sdo_aggr_mbr(m.mpoint.route()) INTO mbr FROM mpoints m;
    xmin := sdo_geom.sdo_min_mbr_ordinate(mbr, 1);
    ymin := sdo_geom.sdo_min_mbr_ordinate(mbr, 2);
    xmax := sdo_geom.sdo_max_mbr_ordinate(mbr, 1);
    ymax := sdo_geom.sdo_max_mbr_ordinate(mbr, 2);
    dx := xmax - xmin;
    dy := ymax - ymin;

    IF dx <= dy THEN
      tolerance_s := 0.001 * dx;
      mxdist_t := 0.1 * dy;
    ELSE
      tolerance_s := 0.001 * dy;
      mxdist_t := 0.1 * dx;
    END IF;

    SELECT min(m.mpoint.f_initial_timepoint().get_abs_date()), max(m.mpoint.f_final_timepoint().get_abs_date()) INTO tmin, tmax FROM mpoints m;
    dt := tmax - tmin;
    tolerance_t := 0.001 * dt;

    IF mxrid = 0 THEN
      INSERT INTO h_benchmark(bid, qtyp, k_param, l_param, min_lns, smooth_factor, max_step, user_id) VALUES (bid_t, qtyp_t, k, l, min_lns_t, smooth_factor_t, max_step_t, user_id_t);
    END IF;

    FOR pos1 IN mxrid + 1..nq LOOP
      SELECT m.mpoint
        INTO p
      FROM
      (
        SELECT mpoint FROM mpoints ORDER BY dbms_random.value
      ) m
      WHERE ROWNUM = 1;

      --n := dbms_random.value(1, k * 2);

      tmin := p.f_initial_timepoint().get_abs_date();
      tmax := p.f_final_timepoint().get_abs_date();

      t1_t := dbms_random.value(tmin, tmax - (tmax - tmin) * 0.1);
      t2_t := t1_t + (tmax - tmin) * 0.1;

      INSERT INTO h_benchmark_run(bid, rid, tid, n_param, t_min, t_max, exc, exc_det, nr_of_fakes) VALUES (bid_t, pos1, p.traj_id, n, t1_t, t2_t, 0, NULL, 0);

      tb.set_abs_date(t1_t);
      te.set_abs_date(t2_t);
      per := tau_tll.d_period_sec(tb, te);

      t1 := LOCALTIMESTAMP;
      ret := b_knn_query2(p.traj_id, n, mxdist_t, per, k, l, tolerance_s, tolerance_t, user_id_t, min_lns_t, smooth_factor_t, time_step_t, max_step_t, bid_t, pos1, dur_nop, exc_check, exc_details, fret_t);
      --b_knn_query2(trajectory id, number of neighbours, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
      --if time step is NULL then time step will be determined as the average duration of segments
      t2 := LOCALTIMESTAMP;

      IF exc_check = 0 THEN
        interv := t2 - t1;
        dur_t := ABS(EXTRACT(SECOND FROM interv) + EXTRACT(MINUTE FROM interv) * 60 + EXTRACT(HOUR FROM interv) * 60 * 60 + EXTRACT(DAY FROM interv) * 24 * 60 * 60);
        INSERT INTO h_knn_dur(bid, rid, dur) VALUES (bid_t, pos1, dur_t);

        INSERT INTO h_knn_nop_dur(bid, rid, dur) VALUES (bid_t, pos1, dur_nop);
      END IF;

      SELECT count(*) INTO nrfk FROM fakes fs WHERE fs.user_id = user_id_t;
      UPDATE h_benchmark_run
      SET nr_of_fakes = nrfk, exc = exc_check, exc_det = exc_details
      WHERE bid = bid_t AND rid = pos1;

      COMMIT;
    END LOOP;
  END bench_knn2;
END hpv;
/


