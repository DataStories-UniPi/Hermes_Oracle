Prompt Package Body MODEL_TRACLUS;
CREATE OR REPLACE PACKAGE BODY MODEL_TRACLUS
IS

-- -----------------------------------------------------
-- Procedure run_traclus
-- -----------------------------------------------------
	PROCEDURE run_traclus
	(
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

		O := traclus.traclus(I, e, min_lns, smooth_factor, compression_method, tol, noise_ls);

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
	END run_traclus;

END MODEL_TRACLUS;
/


