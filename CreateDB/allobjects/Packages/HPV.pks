Prompt Package HPV;
CREATE OR REPLACE PACKAGE hpv
IS
  FUNCTION minof_2(x IN NUMBER, y IN NUMBER) RETURN NUMBER;
  FUNCTION maxof_2(x IN NUMBER, y IN NUMBER) RETURN NUMBER;
  FUNCTION euclidean_distance(xi IN NUMBER, yi IN NUMBER, xe IN NUMBER, ye IN NUMBER) RETURN NUMBER;
  FUNCTION factorial(x IN NUMBER) RETURN NUMBER;
  FUNCTION pi RETURN NUMBER;
  FUNCTION to_deg(rad IN NUMBER) RETURN NUMBER;
  FUNCTION angle_xx(xi IN NUMBER, yi IN NUMBER, xe IN NUMBER, ye IN NUMBER) RETURN NUMBER;
  FUNCTION angle_acute(xi1 IN NUMBER, yi1 IN NUMBER, xe1 IN NUMBER, ye1 IN NUMBER, xi2 IN NUMBER, yi2 IN NUMBER, xe2 IN NUMBER, ye2 IN NUMBER) RETURN NUMBER;
  PROCEDURE new_pos(xi IN NUMBER, yi IN NUMBER, xe IN NUMBER, ye IN NUMBER, n_length IN NUMBER, xe_n OUT NUMBER, ye_n OUT NUMBER);
  FUNCTION is_intersection(xi1 IN NUMBER, yi1 IN NUMBER, xe1 IN NUMBER, ye1 IN NUMBER, xi2 IN NUMBER, yi2 IN NUMBER, xe2 IN NUMBER, ye2 IN NUMBER) RETURN NUMBER;
  FUNCTION min_dist(xi1 IN NUMBER, yi1 IN NUMBER, xe1 IN NUMBER, ye1 IN NUMBER, xi2 IN NUMBER, yi2 IN NUMBER, xe2 IN NUMBER, ye2 IN NUMBER) RETURN NUMBER;
  FUNCTION min_dist(mp1 IN moving_point, mp2 IN moving_point) RETURN NUMBER;

  FUNCTION rotated_x(x IN NUMBER, y IN NUMBER, angle IN NUMBER) RETURN NUMBER;
    FUNCTION rotated_y(x IN NUMBER, y IN NUMBER, angle IN NUMBER) RETURN NUMBER;
    FUNCTION reverse_rotation_x(x IN NUMBER, y IN NUMBER, angle IN NUMBER) RETURN NUMBER;
    FUNCTION reverse_rotation_y(x IN NUMBER, y IN NUMBER, angle IN NUMBER) RETURN NUMBER;

    FUNCTION create_direction_vector(segments IN OUT NOCOPY unit_moving_point_nt) RETURN unit_moving_point;

    FUNCTION get_segments_containing_x(segments IN OUT NOCOPY unit_moving_point_nt, x IN NUMBER, angle IN NUMBER) RETURN unit_moving_point_nt;
    FUNCTION get_segments_cross_y(segment IN OUT NOCOPY unit_moving_point, x IN NUMBER, angle IN NUMBER) RETURN NUMBER;

  FUNCTION points_from_segments(segments IN OUT NOCOPY unit_moving_point_nt) RETURN spt_pos_nt;
  FUNCTION segments_from_trajectory(trajectory IN OUT NOCOPY moving_point) RETURN unit_moving_point_nt;
   
  FUNCTION rtg(segments IN OUT NOCOPY unit_moving_point_nt, min_lns IN NUMBER := 1, smooth_factor IN NUMBER := 0) RETURN moving_point_tab;
  FUNCTION merge(left_l IN OUT NOCOPY spt_pos_nt, right_l IN OUT NOCOPY spt_pos_nt, angle IN NUMBER) RETURN spt_pos_nt;
  FUNCTION merge_sort(a IN spt_pos_nt, angle IN NUMBER) RETURN spt_pos_nt;

    FUNCTION fake_trajectory(segments IN OUT NOCOPY unit_moving_point_nt, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER,
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
        flag1 OUT NUMBER, flag2 OUT NUMBER)
    RETURN moving_point;

  FUNCTION overlaping_windows(user_id_in IN NUMBER, sgeo IN mdsys.sdo_geometry, t_start IN tau_tll.d_timepoint_sec, t_end IN tau_tll.d_timepoint_sec) RETURN NUMBER;
    FUNCTION near_windows(user_id_in IN NUMBER, sgeo IN mdsys.sdo_geometry, t_start IN tau_tll.d_timepoint_sec, t_end IN tau_tll.d_timepoint_sec, tolerance_s IN NUMBER, tolerance_t IN NUMBER, trs IN number_nt) RETURN number_nt;
    PROCEDURE update_hist(user_id_in IN NUMBER, sgeo IN mdsys.sdo_geometry, t_start IN tau_tll.d_timepoint_sec, t_end IN tau_tll.d_timepoint_sec, trs IN number_nt);

  FUNCTION next_fake(user_id_in IN NUMBER) RETURN NUMBER;

    FUNCTION range_query(sgeo IN mdsys.sdo_geometry, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, src_tab IN VARCHAR DEFAULT 'mpoints', fakes_only IN NUMBER DEFAULT 1) RETURN mp_array;
    --range_query(spatial region, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
  --if time step is NULL then time step will be determined as the average duration of segments
  FUNCTION distance_query(xp IN NUMBER, yp IN NUMBER, d IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER) RETURN mp_array;
    --range_query(x coordinate of center, y coordinate of center, distance from center, time period, k-anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
  --if time step is NULL then time step will be determined as the average duration of segments
  FUNCTION knn_query(p IN INTEGER , n IN INTEGER, mxdist IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER) RETURN mp_array;
  --knn_query(the trajectory id that we want to find its neighbours, how many neighbours, maximum distance to be considered near, time period, k_anonymity, L, spatial tolerance, temporal tolerance, user id, min_lns, smooth_factor, time step, max step in degrees);
  --if time step is NULL then time step will be determined as the average duration of segments

  FUNCTION range_query2(sgeo IN mdsys.sdo_geometry, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, src_tab IN VARCHAR DEFAULT 'mpoints', fakes_only IN NUMBER DEFAULT 1) RETURN mp_array;
    FUNCTION distance_query2(xp IN NUMBER, yp IN NUMBER, d IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER) RETURN mp_array;
    FUNCTION knn_query2(p IN INTEGER , n IN INTEGER, mxdist IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER) RETURN mp_array;

  --The 6 following functions are essentially the same as the previous 6, but they are specially developed to be used internally by benchmarks (that's why they start with b_).
    FUNCTION b_range_query(sgeo IN mdsys.sdo_geometry, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;
    FUNCTION b_distance_query(xp IN NUMBER, yp IN NUMBER, d IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;
    FUNCTION b_knn_query(p IN INTEGER , n IN INTEGER, mxdist IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;

  FUNCTION b_range_query2(sgeo IN mdsys.sdo_geometry, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;
    FUNCTION b_distance_query2(xp IN NUMBER, yp IN NUMBER, d IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;
    FUNCTION b_knn_query2(p IN INTEGER , n IN INTEGER, mxdist IN NUMBER, wtim IN tau_tll.d_period_sec, k IN NATURALN, l IN NATURALN, tolerance_s IN NUMBER, tolerance_t IN NUMBER, user_id IN NUMBER, min_lns IN NUMBER, smooth_factor IN NUMBER, time_step IN NUMBER, max_step IN NUMBER, bid_in IN NUMBER, rid_in IN NUMBER, dur_nop OUT NUMBER, exc OUT NUMBER, exc_det OUT VARCHAR2, fret OUT NUMBER) RETURN mp_array;

  PROCEDURE bench_range(bid_t IN NUMBER, user_id_t IN NUMBER, k IN NUMBER, l IN NUMBER, min_lns_t IN NUMBER, smooth_factor_t IN NUMBER, time_step_t IN NUMBER, max_step_t IN NUMBER, volumes_t IN number_nt);
  --bench_range(benchmark id, user id, k-anonymity, L, min_lns, smooth_factor, time step, max step in degrees, a nested table that contains records of volume percentage eg 0.02, 0.04. A volume value can be repeated.)
  PROCEDURE bench_range2(bid_t IN NUMBER, user_id_t IN NUMBER, k IN NUMBER, l IN NUMBER, min_lns_t IN NUMBER, smooth_factor_t IN NUMBER, time_step_t IN NUMBER, max_step_t IN NUMBER, volumes_t IN number_nt);
  PROCEDURE bench_knn(bid_t IN NUMBER, user_id_t IN NUMBER, k IN NUMBER, l IN NUMBER, min_lns_t IN NUMBER, smooth_factor_t IN NUMBER, time_step_t IN NUMBER, max_step_t IN NUMBER, n IN NUMBER, nq IN NUMBER);
  --bench_range(benchmark id, user id, k-anonymity, L, min_lns, smooth_factor, time step, max step in degrees, the number of nearest neighbors we want, how many times it will execute knn queries)
  PROCEDURE bench_knn2(bid_t IN NUMBER, user_id_t IN NUMBER, k IN NUMBER, l IN NUMBER, min_lns_t IN NUMBER, smooth_factor_t IN NUMBER, time_step_t IN NUMBER, max_step_t IN NUMBER, n IN NUMBER, nq IN NUMBER);

  /* How to run a benchmark. In case an exception occurs before the benchmark ends normally, just re-run it and it will automatically continue from where it stoped.
  DECLARE
    volumes number_nt;
    pos1 NUMBER;
    vol_t NUMBER;
  BEGIN
    vol_t := 0.01;
    volumes := number_nt();
    FOR pos1 IN 1..1000 LOOP
      volumes.EXTEND;
      volumes(volumes.LAST) := vol_t;

      IF mod(pos1, 100) = 0 THEN
        vol_t := vol_t + 0.01;
      END IF;
    END LOOP;

    hpv.bench_range2(3003, 3003, 25, 7, 1, 5, NULL, 360, volumes);
  END;
  */
END hpv;
/


