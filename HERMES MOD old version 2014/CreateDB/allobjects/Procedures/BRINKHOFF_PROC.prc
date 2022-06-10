Prompt drop Procedure BRINKHOFF_PROC;
DROP PROCEDURE BRINKHOFF_PROC
/

Prompt Procedure BRINKHOFF_PROC;
CREATE OR REPLACE PROCEDURE brinkhoff_proc
IS
	fst INTEGER := 1;

	prev_id INTEGER;
	prev_tm NUMBER;
	prev_x NUMBER;
	prev_y NUMBER;

	cur_id INTEGER;
	cur_tm NUMBER;
	cur_x NUMBER;
	cur_y NUMBER;

	mpt moving_point_tab := moving_point_tab();

	tb tau_tll.d_timepoint_sec;
	te tau_tll.d_timepoint_sec;
BEGIN
	tb := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);
	te := tau_tll.d_timepoint_sec(1, 1, 1, 0, 0, 0);

	FOR rec IN (SELECT id, tm, x, y FROM brinkhoff_temp ORDER BY id ASC, tm ASC) LOOP
		cur_id := rec.id;
		cur_tm := rec.tm;
		cur_x := rec.x;
		cur_y := rec.y;

		IF fst = 1 THEN
			fst := 0;
		ELSE
			IF prev_id = cur_id THEN
				tb.set_abs_date(210866803200 + prev_tm * 30);
				te.set_abs_date(210866803200 + cur_tm * 30);

				mpt.EXTEND;
				mpt(mpt.LAST) := unit_moving_point(
									tau_tll.d_period_sec(tb, te),
									unit_function(prev_x, prev_y, cur_x, cur_y, null, null, null, null, null, 'PLNML_1')
				);
			ELSE
				INSERT INTO brinkhoff_result(TRAJ_ID, MPOINT) VALUES (prev_id, MOVING_POINT(mpt, prev_id, null));

				mpt := moving_point_tab();
			END IF;
		END IF;

		prev_id := cur_id;
		prev_tm := cur_tm;
		prev_x := cur_x;
		prev_y := cur_y;
	END LOOP;

	INSERT INTO brinkhoff_result(TRAJ_ID, MPOINT) VALUES (prev_id, MOVING_POINT(mpt, prev_id, null));
END brinkhoff_proc;
/

SHOW ERRORS;


