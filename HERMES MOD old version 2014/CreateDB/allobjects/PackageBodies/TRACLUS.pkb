Prompt Package Body TRACLUS;
CREATE OR REPLACE PACKAGE BODY traclus
IS
 
-- -----------------------------------------------------
-- Function traclus
-- -----------------------------------------------------
  FUNCTION traclus_main
  (
    I IN OUT NOCOPY mp_array,
    e IN NUMBER,
    min_lns IN INTEGER,
    smooth_factor IN INTEGER,
    compression_method IN NUMBER DEFAULT 1, --1 -> TD_TR, 2 -> MDL
    tol IN NUMBER DEFAULT 100,
    noise_ls IN OUT NOCOPY line_segment_nt
  )
    RETURN internal_cluster_nt
  IS
    TR spt_pos_nt := spt_pos_nt();
    TR_characteristic_points spt_pos_nt;

    L line_segment;

    P_LS line_segment_small;
    P_LST line_segment_small_nt;

    mp_compr moving_point;
    ump unit_moving_point;

    D line_segment_nt := line_segment_nt();
    O internal_cluster_nt;

    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
  BEGIN
    IF compression_method = 1 THEN
      pos1 := I.FIRST;
      WHILE pos1 IS NOT NULL
      LOOP
        mp_compr := TD_TR(I(pos1), tol);

        pos2 := mp_compr.u_tab.FIRST;
        WHILE pos2 IS NOT NULL
        LOOP
          ump := mp_compr.u_tab(pos2);

          L := line_segment(spt_pos(ump.m.xi, ump.m.yi, ump.p.b), spt_pos(ump.m.xe, ump.m.ye, ump.p.e));
          L.traj_id := I(pos1).traj_id;

          D.EXTEND;
          D(D.LAST) := L;

          pos2 := mp_compr.u_tab.NEXT(pos2);
        END LOOP;

        pos1 := I.NEXT(pos1);
      END LOOP;
    ELSIF compression_method = 2 THEN
      pos1 := I.FIRST;
      WHILE pos1 IS NOT NULL
      LOOP
        TR := spt_pos_nt();

        pos2 := I(pos1).u_tab.FIRST;

        TR.EXTEND;
        TR(TR.LAST) := spt_pos(I(pos1).u_tab(pos2).m.xi, I(pos1).u_tab(pos2).m.yi, I(pos1).u_tab(pos2).p.b);

        WHILE pos2 IS NOT NULL
        LOOP
          TR.EXTEND;
          TR(TR.LAST) := spt_pos(I(pos1).u_tab(pos2).m.xe, I(pos1).u_tab(pos2).m.ye, I(pos1).u_tab(pos2).p.e);

          pos2 := I(pos1).u_tab.NEXT(pos2);
        END LOOP;

        TR_characteristic_points := approximate_traj_partitioning(TR);

        pos3 := TR.FIRST;
        pos2 := TR_characteristic_points.FIRST;
        WHILE pos2 IS NOT NULL
        LOOP
          IF pos2 <> TR_characteristic_points.LAST THEN
            L := line_segment(TR_characteristic_points(pos2), TR_characteristic_points(TR_characteristic_points.NEXT(pos2)));
            L.traj_id := I(pos1).traj_id;

            P_LST := line_segment_small_nt();
            LOOP
              P_LS := line_segment_small(TR(pos3), TR(TR.NEXT(pos3)));

              P_LST.EXTEND;
              P_LST(P_LST.LAST) := P_LS;

              IF
                TR(TR.NEXT(pos3)).x = TR_characteristic_points(TR_characteristic_points.NEXT(pos2)).x
                AND TR(TR.NEXT(pos3)).y = TR_characteristic_points(TR_characteristic_points.NEXT(pos2)).y
                AND TR(TR.NEXT(pos3)).t.f_eq(TR(TR.NEXT(pos3)).t, TR_characteristic_points(TR_characteristic_points.NEXT(pos2)).t) = 1
              THEN
                pos3 := TR.NEXT(pos3);
                EXIT;
              END IF;

              pos3 := TR.NEXT(pos3);
            END LOOP;

            L.parent_segments := P_LST;

            D.EXTEND;
            D(D.LAST) := L;
          END IF;

          pos2 := TR_characteristic_points.NEXT(pos2);
        END LOOP;

        pos1 := I.NEXT(pos1);
      END LOOP;
    END IF;

    dbms_output.put_line('D: ' || D.COUNT);

    O := line_segment_clustering(D, e, min_lns, smooth_factor, noise_ls);

    RETURN O;
  END traclus_main;

-- -----------------------------------------------------
-- Function line_segment_clustering
-- -----------------------------------------------------
  FUNCTION line_segment_clustering
  (
    D IN OUT NOCOPY line_segment_nt,
    e IN NUMBER,
    min_lns IN INTEGER,
    smooth_factor IN INTEGER,
    noise_ls IN OUT NOCOPY line_segment_nt
  )
    RETURN internal_cluster_nt
  IS
    O internal_cluster_nt := internal_cluster_nt();

    cluster_id INTEGER := 1;
    Ne INTEGER_NT;

    pos1 NUMBER;
    pos2 NUMBER;
  BEGIN
    /*
    pos1 := D.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      D(pos1).classified := 0;

      pos1 := D.NEXT(pos1);
    END LOOP;
    */

    pos1 := D.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF D(pos1).classified = 0 THEN
        Ne := compute_ne(D, pos1, e);

        IF Ne.COUNT >= min_lns THEN
          D(pos1).cluster_id := cluster_id;
          D(pos1).classified := 1;
          D(pos1).noise := 0;

          pos2 := Ne.FIRST;
          WHILE pos2 IS NOT NULL
          LOOP
            D(Ne(pos2)).cluster_id := cluster_id;
            D(Ne(pos2)).classified := 1;
            D(Ne(pos2)).noise := 0;

            pos2 := Ne.NEXT(pos2);
          END LOOP;

          expand_cluster(D, Ne, cluster_id, e, min_lns);

          O.EXTEND;
          O(cluster_id) := internal_cluster(cluster_id, min_lns, smooth_factor);

          cluster_id := cluster_id + 1;
        ELSE
          D(pos1).noise := 1;
        END IF;
      END IF;

      pos1 := D.NEXT(pos1);
    END LOOP;

    dbms_output.put_line('O: ' || O.COUNT);

    --noise_ls := line_segment_nt();

    pos1 := D.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF D(pos1).noise = 0 THEN
        O(D(pos1).cluster_id).segments.EXTEND;
        O(D(pos1).cluster_id).segments(O(D(pos1).cluster_id).segments.LAST) := D(pos1);
      ELSE
        noise_ls.EXTEND;
        noise_ls(noise_ls.LAST) := D(pos1);
      END IF;

      pos1 := D.NEXT(pos1);
    END LOOP;

    pos1 := O.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF O(pos1).segments.COUNT = 0 THEN
        O.DELETE(pos1);
        pos1 := O.NEXT(pos1);
        CONTINUE;
      END IF;

      O(pos1).calculate_cardinallity();
      IF O(pos1).cardinal < min_lns THEN
        O.DELETE(pos1);
      END IF;

      pos1 := O.NEXT(pos1);
    END LOOP;

    dbms_output.put_line('O: ' || O.COUNT);

    pos1 := O.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      O(pos1).post_process();

      pos1 := O.NEXT(pos1);
    END LOOP;

    RETURN O;
  END line_segment_clustering;

-- -----------------------------------------------------
-- Procedure expand_cluster
-- -----------------------------------------------------
  PROCEDURE expand_cluster
  (
    D IN OUT NOCOPY line_segment_nt,
    Ne_Q IN OUT NOCOPY INTEGER_NT,
    cluster_id IN INTEGER,
    e IN NUMBER,
    min_lns IN INTEGER
  )
  IS
    Ne_t INTEGER_NT;
    pos1 NUMBER;
  BEGIN
    WHILE Ne_Q.COUNT > 0
    LOOP
      Ne_t := compute_ne(D, Ne_Q(Ne_Q.FIRST), e);
      IF Ne_t.COUNT >= min_lns THEN
        pos1 := Ne_t.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
          IF D(Ne_t(pos1)).classified = 0 OR D(Ne_t(pos1)).noise = 1 THEN
            D(Ne_t(pos1)).cluster_id := cluster_id;
            D(Ne_t(pos1)).noise := 0;

            IF D(Ne_t(pos1)).classified = 0 THEN
              Ne_Q.EXTEND;
              Ne_Q(Ne_Q.LAST) := Ne_t(pos1);
            END IF;
            D(Ne_t(pos1)).classified := 1;
          END IF;
          pos1 := Ne_t.NEXT(pos1);
        END LOOP;
      END IF;
      Ne_Q.DELETE(Ne_Q.FIRST);
    END LOOP;
  END expand_cluster;

-- -----------------------------------------------------
-- Function compute_ne
-- -----------------------------------------------------
  FUNCTION compute_ne
  (
    D IN OUT NOCOPY line_segment_nt,
    pos IN NUMBER,
    e IN NUMBER
  )
    RETURN INTEGER_NT
    IS
    Ne INTEGER_NT := INTEGER_NT();
    distance NUMBER := 0;
    L_T line_segment;
    pos1 NUMBER;
  BEGIN
    pos1 := D.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      IF pos1 <> pos THEN
        L_T := D(pos1);
        distance := dist(D(pos).s, D(pos).e, L_T.s, L_T.e);

        INSERT INTO traclus_result_dist(dist) VALUES (distance);

        IF distance <= e THEN
          Ne.EXTEND;
          Ne(Ne.LAST) := pos1;
        END IF;
      END IF;

      pos1 := D.NEXT(pos1);
    END LOOP;

    RETURN Ne;
    END compute_ne;

-- -----------------------------------------------------
-- Function dist
-- -----------------------------------------------------
  FUNCTION dist
  (
    s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
  )
    RETURN NUMBER
  IS
  BEGIN
    RETURN w_perp * perpendicular_distance(s1, e1, s2, e2) + w_paral * parallel_distance(s1, e1, s2, e2) + w_angl * angle_distance(s1, e1, s2, e2);
  END dist;

-- -----------------------------------------------------
-- Function approximate_traj_partitioning
-- -----------------------------------------------------
  FUNCTION approximate_traj_partitioning
  (
    TR IN OUT NOCOPY spt_pos_nt
  )
    RETURN spt_pos_nt
  IS
    CP spt_pos_nt := spt_pos_nt();
    start_index NUMBER := 1;
    lngth NUMBER := 1;
    curr_index NUMBER;
    cost_par NUMBER;
    cost_nopar NUMBER;
  BEGIN
    CP.EXTEND;
    CP(CP.LAST) := TR(TR.FIRST);

    WHILE start_index + lngth <= TR.COUNT
    LOOP
      curr_index := start_index + lngth;

      --cost_par := compute_model_cost(TR, start_index, curr_index) + compute_encoding_cost(TR, start_index, curr_index);
      --cost_nopar := compute_model_cost(TR, curr_index - 1, curr_index);

      cost_par := MDLpar(TR, start_index, curr_index);
      cost_nopar := MDLnopar(TR, start_index, curr_index);

      IF cost_par > cost_nopar THEN
        CP.EXTEND;
        CP(CP.LAST) := TR(TR.PRIOR(curr_index));

        start_index := curr_index - 1;
        lngth := 1;
      ELSE
        lngth := lngth + 1;
      END IF;
    END LOOP;

    CP.EXTEND;
    CP(CP.LAST) := TR(TR.LAST);

    RETURN CP;
  END approximate_traj_partitioning;

-- -----------------------------------------------------
-- Function compute_encoding_cost
-- -----------------------------------------------------
  FUNCTION compute_encoding_cost
  (
    TR IN OUT NOCOPY spt_pos_nt,
    start_index IN NUMBER,
    curr_index IN NUMBER
  )
    RETURN NUMBER
  IS
    perpendicular_dist NUMBER := 0;
    angle_dist NUMBER := 0;
    pos1 NUMBER;
  BEGIN
    pos1 := start_index;
    WHILE pos1 < curr_index
    LOOP
      perpendicular_dist := perpendicular_dist + perpendicular_distance(TR(start_index), TR(curr_index), TR(pos1), TR(TR.NEXT(pos1)));
      angle_dist := angle_dist + angle_distance(TR(start_index), TR(curr_index), TR(pos1), TR(TR.NEXT(pos1)));

      pos1 := TR.NEXT(pos1);
    END LOOP;

    IF perpendicular_dist = 0 THEN
      perpendicular_dist := 1;
    END IF;

    IF angle_dist = 0 THEN
      angle_dist := 1;
    END IF;

    RETURN log(2, perpendicular_dist) + log(2, angle_dist);
  END compute_encoding_cost;

-- -----------------------------------------------------
-- Function compute_model_cost
-- -----------------------------------------------------
  FUNCTION compute_model_cost
  (
    TR IN OUT NOCOPY spt_pos_nt,
    start_index IN NUMBER,
    curr_index IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    RETURN log(2, euclidean_distance(TR(start_index), TR(curr_index)));
  END compute_model_cost;

-- -----------------------------------------------------
-- Function MDLpar
-- -----------------------------------------------------
  FUNCTION MDLpar
  (
    TR IN OUT NOCOPY spt_pos_nt,
    start_index IN NUMBER,
    curr_index IN NUMBER
  )
    RETURN NUMBER
  IS
    LH NUMBER;
    LDH NUMBER;
    perpendicular_dist NUMBER := 0;
    angle_dist NUMBER := 0;
    pos1 NUMBER;
  BEGIN
    LH := log(2, euclidean_distance(TR(start_index), TR(curr_index)));

    pos1 := start_index;
    WHILE pos1 < curr_index
    LOOP
      perpendicular_dist := perpendicular_dist + perpendicular_distance(TR(start_index), TR(curr_index), TR(pos1), TR(TR.NEXT(pos1)));
      angle_dist := angle_dist + angle_distance(TR(start_index), TR(curr_index), TR(pos1), TR(TR.NEXT(pos1)));

      pos1 := TR.NEXT(pos1);
    END LOOP;

    IF perpendicular_dist = 0 THEN
      perpendicular_dist := 1;
    END IF;

    IF angle_dist = 0 THEN
      angle_dist := 1;
    END IF;

    LDH := log(2, perpendicular_dist) + log(2, angle_dist);

    RETURN LH + LDH;
  END MDLpar;

-- -----------------------------------------------------
-- Function MDLnopar
-- -----------------------------------------------------
  FUNCTION MDLnopar
  (
    TR IN OUT NOCOPY spt_pos_nt,
    start_index IN NUMBER,
    curr_index IN NUMBER
  )
    RETURN NUMBER
  IS
    ret NUMBER;
    pos1 NUMBER;
  BEGIN
    pos1 := start_index;
    WHILE pos1 < curr_index
    LOOP
      ret := ret + euclidean_distance(TR(pos1), TR(TR.NEXT(pos1)));

      pos1 := TR.NEXT(pos1);
    END LOOP;

    RETURN log(2, ret);
  END MDLnopar;

-- -----------------------------------------------------
-- Function perpendicular_distance
-- -----------------------------------------------------
  FUNCTION perpendicular_distance
  (
    s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
  )
    RETURN NUMBER
  IS
    L1 NUMBER;
    L2 NUMBER;
    proj_point sp_pos;
  BEGIN
    proj_point := projection_point(s2, s1, e1);
    L1 := euclidean_distance(proj_point, s2);

    proj_point := projection_point(e2, s1, e1);
    L2 := euclidean_distance(proj_point, e2);

    IF L1 + L2 = 0 THEN
      RETURN 0;
    END IF;

    RETURN (power(L1, 2) + power(L2, 2)) / (L1 + L2);
  END perpendicular_distance;

-- -----------------------------------------------------
-- Function parallel_distance
-- -----------------------------------------------------
  FUNCTION parallel_distance
  (
    s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
  )
    RETURN NUMBER
  IS
    L1 NUMBER;
    L2 NUMBER;
    proj_point sp_pos;
  BEGIN
    proj_point := projection_point(s2, s1, e1);
    L1 := minimum_value(euclidean_distance(proj_point, s1), euclidean_distance(proj_point, e1));

    proj_point := projection_point(e2, s1, e1);
    L2 := minimum_value(euclidean_distance(proj_point, s1), euclidean_distance(proj_point, e1));

    RETURN minimum_value(L1, L2);
  END parallel_distance;

-- -----------------------------------------------------
-- Function angle_distance
-- -----------------------------------------------------
  FUNCTION angle_distance
  (
    s1 IN sp_pos,
    e1 IN sp_pos,
    s2 IN sp_pos,
    e2 IN sp_pos
  )
    RETURN NUMBER
  IS
    ang NUMBER;
    angdeg NUMBER;
  BEGIN
    ang := angle(s1, e1, s2, e2);
    angdeg := ang * (180.0 / acos(-1.0));

    IF angdeg >= 0 AND angdeg < 90 THEN
      RETURN euclidean_distance(s2, e2) * sin(ang);
    ELSE
      RETURN euclidean_distance(s2, e2);
    END IF;
  END angle_distance;

-- -----------------------------------------------------
-- Function angle_xx
-- -----------------------------------------------------
  FUNCTION angle_xx
    (
        s IN sp_pos,
    e IN sp_pos
    )
        RETURN NUMBER
    IS
  BEGIN
    if (e.y = s.y) and (e.x = s.x) then
      return 0;
    else
      RETURN atan2(e.y - s.y, e.x - s.x);
    end if;
  END angle_xx;

-- -----------------------------------------------------
-- Function angle
-- -----------------------------------------------------
  FUNCTION angle
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
    FUNCTION angle
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
-- Function projection_point --> returns the point of perpendicular projection of p onto line (l)
-- -----------------------------------------------------
  FUNCTION projection_point
  (
    p IN sp_pos,
    l_s IN sp_pos, --first line point
    l_e IN sp_pos --second line point
  )
    RETURN sp_pos
  IS
    u NUMBER;
    x NUMBER;
    y NUMBER;
    dist number:=0;
  BEGIN
    dist:=power(l_e.x - l_s.x, 2) + power(l_e.y - l_s.y, 2);
    if dist=0 then
      dist:=0.0001;
    end if;
    u := ((l_s.y - p.y) * (l_s.y - l_e.y) - (l_s.x - p.x) * (l_e.x - l_s.x)) / power(sqrt(dist), 2);

    x := l_s.x + u * (l_e.x - l_s.x);
    y := l_s.y + u * (l_e.y - l_s.y);

    RETURN sp_pos(x, y);
  END projection_point;
  
  
-- -----------------------------------------------------
-- Function segments_from_trajectories
-- -----------------------------------------------------
    FUNCTION segments_from_trajectories
    (
        trajectories IN OUT NOCOPY mp_array
    )
        RETURN unit_moving_point_nt
    IS
        pos1 NUMBER;
        pos2 NUMBER;
        ret unit_moving_point_nt := unit_moving_point_nt();
    BEGIN
        pos1 := trajectories.FIRST;
        WHILE pos1 IS NOT NULL
        LOOP
            pos2 := trajectories(pos1).u_tab.FIRST;
            WHILE pos2 IS NOT NULL
            LOOP
                ret.EXTEND;
                ret(ret.LAST) := trajectories(pos1).u_tab(pos2);

                pos2 := trajectories(pos1).u_tab.NEXT(pos2);
            END LOOP;
            pos1 := trajectories.NEXT(pos1);
        END LOOP;

        RETURN ret;
    END segments_from_trajectories;

-- -----------------------------------------------------
-- Function euclidean_distance
-- -----------------------------------------------------
  FUNCTION euclidean_distance
  (
    s IN sp_pos,
    e IN sp_pos
  )
    RETURN NUMBER
  IS
  dist number:=0.0;
  BEGIN
    dist:=power(e.x - s.x, 2) + power(e.y - s.y, 2);
    if dist=0 then
      return 0.00001;
    else
      return sqrt(dist);
    end if;
    END euclidean_distance;

-- -----------------------------------------------------
-- Function minimum_value
-- -----------------------------------------------------
  FUNCTION minimum_value
  (
    v1 IN NUMBER,
    v2 IN NUMBER
  )
    RETURN NUMBER
  IS
  BEGIN
    IF v1 <= v2 THEN
      RETURN v1;
    ELSE
      RETURN v2;
    END IF;
  END minimum_value;
  
  PROCEDURE traclus
  (
    input_tbl varchar2,
    output_tbl varchar2,
    e IN NUMBER,
    min_lns IN INTEGER,
    smooth_factor IN INTEGER,
    compression_method NUMBER,
    tol NUMBER
  )
  IS
    I mp_array;
    noise_ls line_segment_nt := line_segment_nt();
    O internal_cluster_nt;
    pos1 NUMBER;
    pos2 NUMBER;
    pos3 NUMBER;
    segments line_segment_nt;
    segments_small line_segment_small_nt;
    RTR spt_pos_nt;
    LS moving_point_tab;
    traj_id NUMBER := 1;
    srid integer;
  BEGIN

    DELETE FROM traclus_result;
    DELETE FROM traclus_result_ext;
    DELETE FROM traclus_result_dist;
    
    --just get srid, assume all mpoits have the same
    select m.mpoint.srid
    into srid
    from hpv_result m
    where rownum<=1;

    SELECT m.mpoint BULK COLLECT INTO I
          FROM hpv_result m;

    O := traclus_main(I, e, min_lns, smooth_factor, compression_method, tol, noise_ls);


    pos1 := O.FIRST;
    WHILE pos1 IS NOT NULL
    LOOP
      segments := O(pos1).segments;
      pos2 := segments.FIRST;
      WHILE pos2 IS NOT NULL
      LOOP
        LS := moving_point_tab();
        LS.EXTEND;
        LS(LS.LAST) := unit_moving_point(
                  tau_tll.d_period_sec(segments(pos2).s.t, segments(pos2).e.t),
                  unit_function(segments(pos2).s.x, segments(pos2).s.y, segments(pos2).e.x, segments(pos2).e.y, NULL, NULL, NULL, NULL, NULL, 'PLNML_1')
                );

        INSERT INTO traclus_result_ext(clust_id, traj_id, mpoint, noise) 
        VALUES (O(pos1).cluster_id, segments(pos2).traj_id, 
        moving_point(LS, segments(pos2).traj_id, srid), segments(pos2).noise);

        pos2 := segments.NEXT(pos2);
      END LOOP;

      RTR := O(pos1).RTR;
      IF RTR.COUNT <= 1 THEN
        pos1 := O.NEXT(pos1);
        CONTINUE;
      END IF;

      LS := moving_point_tab();
      pos2 := RTR.FIRST;
      WHILE pos2 IS NOT NULL
      LOOP
        IF pos2 <> RTR.LAST THEN
          LS.EXTEND;
          LS(LS.LAST) := unit_moving_point(
                    tau_tll.d_period_sec(RTR(pos2).t, RTR(RTR.NEXT(pos2)).t),
                    unit_function(RTR(pos2).x, RTR(pos2).y, RTR(RTR.NEXT(pos2)).x, RTR(RTR.NEXT(pos2)).y, NULL, NULL, NULL, NULL, NULL, 'PLNML_1')
                  );
        END IF;

        pos2 := RTR.NEXT(pos2);
      END LOOP;

      INSERT INTO traclus_result(clust_id, mpoint) 
      VALUES (O(pos1).cluster_id, moving_point(LS, traj_id, srid));
      traj_id := traj_id + 1;

      pos1 := O.NEXT(pos1);
    END LOOP;

    pos2 := noise_ls.FIRST;
    WHILE pos2 IS NOT NULL
    LOOP
      segments_small := noise_ls(pos2).parent_segments;
      if segments_small is not null then
        pos3 := segments_small.FIRST;
      end if;
      WHILE pos3 IS NOT NULL
      LOOP
        LS := moving_point_tab();
        LS.EXTEND;
        LS(LS.LAST) := unit_moving_point(
                  tau_tll.d_period_sec(segments_small(pos3).s.t, segments_small(pos3).e.t),
                  unit_function(segments_small(pos3).s.x, segments_small(pos3).s.y, segments_small(pos3).e.x, segments_small(pos3).e.y, NULL, NULL, NULL, NULL, NULL, 'PLNML_1')
                );

        INSERT INTO traclus_result_ext(clust_id, traj_id, mpoint, noise) 
        VALUES (-1, noise_ls(pos2).traj_id, moving_point(LS, noise_ls(pos2).traj_id, srid), 
        noise_ls(pos2).noise);

        pos3 := segments_small.NEXT(pos3);
      END LOOP;

      pos2 := noise_ls.NEXT(pos2);
    END LOOP;

	COMMIT;
	END traclus;

BEGIN
  w_perp := 1;
  w_paral := 1;
  w_angl := 1;
END traclus;
/


