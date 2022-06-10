Prompt Type Body INTERNAL_CLUSTER;
CREATE OR REPLACE TYPE BODY        INTERNAL_CLUSTER IS
-- -----------------------------------------------------
-- Constructor internal_cluster(cluster_id INTEGER, min_lns INTEGER, smooth_factor INTEGER)
-- -----------------------------------------------------
  CONSTRUCTOR FUNCTION internal_cluster(SELF IN OUT NOCOPY internal_cluster, cluster_id IN INTEGER, min_lns INTEGER, smooth_factor INTEGER) RETURN SELF AS RESULT
  IS
  BEGIN
    SELF.segments := line_segment_nt();
    RTR := spt_pos_nt();

    SELF.cluster_id := cluster_id;
    SELF.min_lns := min_lns;
    SELF.smooth_factor := smooth_factor;
    RETURN;
  END;

-- -----------------------------------------------------
-- Procedure post_process
-- -----------------------------------------------------
  MEMBER PROCEDURE post_process
  IS
    success INTEGER := 0;
    cnt NUMBER := 1;
  BEGIN
    WHILE success = 0
    LOOP
      representative_traj_generation();
      IF RTR.COUNT > 1 THEN
        success := 1;
      END IF;

      IF cnt >= 15 THEN
        RETURN;
      END IF;

      cnt := cnt + 1;
    END LOOP;

    IF RTR.COUNT <= 1 AND segments.COUNT = 1 THEN
      RTR := spt_pos_nt();

      RTR.EXTEND;
      RTR(RTR.LAST) := segments(segments.FIRST).s;

      RTR.EXTEND;
      RTR(RTR.LAST) := segments(segments.FIRST).e;
    END IF;
  END post_process;

-- -----------------------------------------------------
-- Procedure calculate_cardinallity
-- -----------------------------------------------------
  MEMBER PROCEDURE calculate_cardinallity
  IS
    pos1 NUMBER;
  BEGIN
    cardinal := 0;
    sort_by_traj_id();

    pos1 := segments.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF pos1 = segments.FIRST THEN
        cardinal := cardinal + 1;
      ELSE
        IF segments(pos1).traj_id <> segments(segments.PRIOR(pos1)).traj_id THEN
          cardinal := cardinal + 1;
        END IF;
      END IF;
      pos1 := segments.NEXT(pos1);
    END LOOP;
  END calculate_cardinallity;

-- -----------------------------------------------------
-- Procedure sort_by_traj_id
-- -----------------------------------------------------
  MEMBER PROCEDURE sort_by_traj_id
  IS
    tmp line_segment;
    pos1 NUMBER;
    pos2 NUMBER;
  BEGIN
    pos1 := segments.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      pos2 := pos1;
      WHILE pos2 IS NOT NULL
      LOOP
        IF segments(pos1).traj_id > segments(pos2).traj_id THEN
          tmp := segments(pos1);
          segments(pos1) := segments(pos2);
          segments(pos2) := tmp;
        END IF;

        pos2 := segments.NEXT(pos2);
      END LOOP;

      pos1 := segments.NEXT(pos1);
    END LOOP;
  END sort_by_traj_id;

-- -----------------------------------------------------
-- Procedure representative_traj_generation
-- -----------------------------------------------------
  MEMBER PROCEDURE representative_traj_generation
  IS
    pos1 NUMBER;
    pos2 NUMBER;
    n_t NUMBER;
    points spt_pos_nt := spt_pos_nt();
    point spt_pos;
    segments_cont_x line_segment_nt;
    ang NUMBER;
    direction_vector sp_pos_nt;
    rx NUMBER;
    ry NUMBER;
    representative_p spt_pos_nt := spt_pos_nt();
    tp tau_tll.d_timepoint_sec := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);

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
        IF rotated_x(sp_pos(left_l(left_l.FIRST).x, left_l(left_l.FIRST).y), angle) < rotated_x(sp_pos(right_l(right_l.FIRST).x, right_l(right_l.FIRST).y), angle) THEN
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

    FUNCTION merge_sort
    (
      a IN spt_pos_nt,
      angle IN NUMBER
    )
      RETURN spt_pos_nt
    IS
      n NUMBER;
      i NUMBER;
      pos NUMBER;
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
      pos := a.FIRST;
      WHILE i <= middle
      LOOP
        left_l.EXTEND;
        left_l(left_l.LAST) := a(pos);
        pos := a.NEXT(pos);
        i := i + 1;
      END LOOP;

      WHILE i <= n LOOP
        right_l.EXTEND;
        right_l(right_l.LAST) := a(pos);
        pos := a.NEXT(pos);
        i := i + 1;
      END LOOP;

      left_l := merge_sort(left_l, angle);
      right_l := merge_sort(right_l, angle);

      RETURN merge(left_l, right_l, angle);
    END merge_sort;
  BEGIN
    direction_vector := create_direction_vector();
    IF direction_vector IS NULL THEN
      RETURN;
    END IF;

    ang := angle(sp_pos(0, 0), sp_pos(1, 0), sp_pos(direction_vector(direction_vector.FIRST).x, direction_vector(direction_vector.FIRST).y), sp_pos(direction_vector(direction_vector.LAST).x, direction_vector(direction_vector.LAST).y));

    pos1 := segments.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      points.EXTEND;
      points(points.LAST) := segments(pos1).s;

      points.EXTEND;
      points(points.LAST) := segments(pos1).e;

      pos1 := segments.NEXT(pos1);
    END LOOP;

    points := merge_sort(points, ang);

    pos1 := points.FIRST;
    <<loop1>>
    WHILE pos1 IS NOT NULL
    LOOP
      segments_cont_x := segments_containing_x(rotated_x(points(pos1), ang), ang);
      IF segments_cont_x.COUNT >= min_lns THEN
        point := spt_pos(
              rotated_x(points(pos1), ang),
              0,
              NULL
        );

        pos2 := segments_cont_x.FIRST;
        <<loop2>>
        WHILE pos2 IS NOT NULL
        LOOP
          n_t := segments_cross_y(segments_cont_x(pos2), point.x, ang);
          IF n_t IS NULL THEN
            pos1 := points.NEXT(pos1);
            CONTINUE loop1;
          END IF;

          point.y := point.y + n_t;

          pos2 := segments_cont_x.NEXT(pos2);
        END LOOP;

        point.y := point.y / segments_cont_x.COUNT;

        IF representative_p.COUNT = 0 THEN
          representative_p.EXTEND;
          representative_p(representative_p.LAST) := point;
        ELSE
          IF abs(point.x - representative_p(representative_p.LAST).x) >= smooth_factor THEN
            representative_p.EXTEND;
            representative_p(representative_p.LAST) := point;
          END IF;
        END IF;
      END IF;

      pos1 := points.NEXT(pos1);
    END LOOP;

    IF representative_p.COUNT = 0 THEN
      RETURN;
    END IF;

    RTR := spt_pos_nt();

    pos1 := representative_p.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF pos1 <> representative_p.LAST THEN
        IF representative_p(pos1).x = representative_p(representative_p.NEXT(pos1)).x AND representative_p(pos1).y = representative_p(representative_p.NEXT(pos1)).y THEN
          pos1 := representative_p.NEXT(pos1);
          CONTINUE;
        END IF;
      END IF;

      point := representative_p(pos1);

      rx := point.x;
      ry := point.y;
      point.x := reverse_rotation_x(sp_pos(rx, ry), ang);
      point.y := reverse_rotation_y(sp_pos(rx, ry), ang);

      point.t := tp;
      tp.set_abs_date(tp.get_abs_date() + 1);

      RTR.EXTEND;
      RTR(RTR.LAST) := point;

      pos1 := representative_p.NEXT(pos1);
    END LOOP;
  END representative_traj_generation;

-- -----------------------------------------------------
-- Function create_direction_vector
-- -----------------------------------------------------
  MEMBER FUNCTION create_direction_vector
    RETURN sp_pos_nt
  IS
    ret sp_pos_nt := sp_pos_nt();
    pos1 NUMBER;
    n NUMBER;
    x NUMBER;
    y NUMBER;
    xb NUMBER := 0;
    yb NUMBER := 0;
  BEGIN
    n := segments.COUNT;

    IF n = 0 THEN
      RETURN NULL;
    END IF;

    pos1 := segments.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      x := segments(pos1).e.x - segments(pos1).s.x;
      y := segments(pos1).e.y - segments(pos1).s.y;

      xb := xb + x;
      yb := yb + y;

      pos1 := segments.NEXT(pos1);
    END LOOP;

    xb := xb / n;
    yb := yb / n;

    ret.EXTEND;
    ret(ret.LAST) := sp_pos(0, 0);

    ret.EXTEND;
    ret(ret.LAST) := sp_pos(xb, yb);

    RETURN ret;
  END create_direction_vector;

-- -----------------------------------------------------
-- Function segments_containing_x
-- -----------------------------------------------------
  MEMBER FUNCTION segments_containing_x
  (
    x IN NUMBER,
    angle IN NUMBER
  )
    RETURN line_segment_nt
  IS
    ret line_segment_nt := line_segment_nt();
    pos1 NUMBER;
  BEGIN
    pos1 := segments.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF segments(pos1).s.x < segments(pos1).e.x THEN
        IF rotated_x(sp_pos(segments(pos1).s.x, segments(pos1).s.y), angle) <= x AND rotated_x(sp_pos(segments(pos1).e.x, segments(pos1).e.y), angle) >= x THEN
          ret.EXTEND;
          ret(ret.LAST) := segments(pos1);
        END IF;
      ELSE
        IF rotated_x(sp_pos(segments(pos1).s.x, segments(pos1).s.y), angle) >= x AND rotated_x(sp_pos(segments(pos1).e.x, segments(pos1).e.y), angle) <= x THEN
          ret.EXTEND;
          ret(ret.LAST) := segments(pos1);
        END IF;
      END IF;

      pos1 := segments.NEXT(pos1);
    END LOOP;

    RETURN ret;
  END segments_containing_x;

-- -----------------------------------------------------
-- Function segments_cross_y
-- -----------------------------------------------------
  MEMBER FUNCTION segments_cross_y
  (
    segment IN line_segment,
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
    x0 := rotated_x(sp_pos(segment.s.x, segment.s.y), angle);
    y0 := rotated_y(sp_pos(segment.s.x, segment.s.y), angle);
    x1 := rotated_x(sp_pos(segment.e.x, segment.e.y), angle);
    y1 := rotated_y(sp_pos(segment.e.x, segment.e.y), angle);

    IF b_factor = 0 THEN
      RETURN NULL;
    END IF;

    a_factor := y0 - y1;
    b_factor := -1 * x0 + x1;
    c_factor := -1 * x1 * y0 + x0 * y1;
    if b_factor=0 then
      b_factor:=0.00001;
    end if;

    RETURN -1 * (a_factor / b_factor) * x - (c_factor / b_factor);
  END segments_cross_y;

-- -----------------------------------------------------
-- Function angle_xx
-- -----------------------------------------------------
  MEMBER FUNCTION angle_xx
    (
        s IN sp_pos,
    e IN sp_pos
    )
        RETURN NUMBER
    IS
  BEGIN
    RETURN atan2(e.y - s.y, e.x - s.x);
  END angle_xx;

-- -----------------------------------------------------
-- Function angle
-- -----------------------------------------------------
  MEMBER FUNCTION angle
    (
        s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
    )
        RETURN NUMBER
    IS
  BEGIN
    RETURN abs(angle_xx(s1, e1) - angle_xx(s2, e2));
  END angle;

/*
-- -----------------------------------------------------
-- Function angle
-- -----------------------------------------------------
  MEMBER FUNCTION angle
  (
    s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
  )
    RETURN NUMBER
  IS
    sloap_a NUMBER;
    sloap_b NUMBER;
    tangent NUMBER;
  BEGIN
    IF e1.x - s1.x = 0 THEN
      IF e2.x - s2.x = 0 THEN
        tangent := 0;
      ELSE
        sloap_b := (e2.y - s2.y) / (e2.x - s2.x);
        tangent := abs(1 / sloap_b);
      END IF;
    ELSIF e2.x - s2.x = 0 THEN
      sloap_a := (e1.y - s1.y) / (e1.x - s1.x);
      tangent := abs(1 / sloap_a);
    ELSIF e1.x - s1.x <> 0 AND e2.x - s2.x <> 0 THEN
      sloap_a := (e1.y - s1.y) / (e1.x - s1.x);
      sloap_b := (e2.y - s2.y) / (e2.x - s2.x);

      IF sloap_a = sloap_b THEN
        tangent := 0; --parallel segments
      ELSE
        tangent := abs((sloap_a - sloap_b) / (1 + sloap_a * sloap_b));
      END IF;
    END IF;

    RETURN atan(tangent);
  END angle;
*/

-- -----------------------------------------------------
-- Function reverse_rotation_x
-- -----------------------------------------------------
  MEMBER FUNCTION reverse_rotation_x
  (
    p IN sp_pos,
    angle IN NUMBER
  )
    RETURN NUMBER
  IS
    det NUMBER;
    a NUMBER;
    b NUMBER;
    c NUMBER;
    d NUMBER;
  BEGIN
    det := power(cos(angle), 2) + power(sin(angle), 2);
    a := cos(angle) / det;
    b := -1 * sin(angle) / det;
    c := sin(angle) / det;
    d := cos(angle) / det;

    /* Reverse Matrix A = d   -b
     *                   -c    a
    */

    RETURN d * p.x + b * p.y;
  END reverse_rotation_x;

-- -----------------------------------------------------
-- Function reverse_rotation_y
-- -----------------------------------------------------
  MEMBER FUNCTION reverse_rotation_y
  (
    p IN sp_pos,
    angle IN NUMBER
  )
    RETURN NUMBER
  IS
    det NUMBER;
    a NUMBER;
    b NUMBER;
    c NUMBER;
    d NUMBER;
  BEGIN
    det := power(cos(angle), 2) + power(sin(angle), 2);

    a := cos(angle) / det;
    b := -1 * sin(angle) / det;
    c := sin(angle) / det;
    d := cos(angle) / det;

    RETURN c * p.x + a * p.y;
  END reverse_rotation_y;

-- -----------------------------------------------------
-- Function rotated_x
-- -----------------------------------------------------
  MEMBER FUNCTION rotated_x
  (
    p IN sp_pos,
    angle IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    RETURN cos(angle) * p.x + sin(angle) * p.y;
  END rotated_x;

-- -----------------------------------------------------
-- Function rotated_y
-- -----------------------------------------------------
  MEMBER FUNCTION rotated_y
  (
    p IN sp_pos,
    angle IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    RETURN -sin(angle) * p.x + cos(angle) * p.y;
  END rotated_y;
END;
/


