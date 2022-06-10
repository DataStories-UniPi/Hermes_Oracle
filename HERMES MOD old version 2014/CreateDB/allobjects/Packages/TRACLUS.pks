Prompt Package TRACLUS;
CREATE OR REPLACE PACKAGE traclus
IS
  w_perp NUMBER;
  w_paral NUMBER;
  w_angl NUMBER;

  PROCEDURE traclus(input_tbl varchar2, output_tbl varchar2,e IN NUMBER, min_lns IN INTEGER, smooth_factor IN INTEGER, compression_method IN NUMBER,
     tol IN NUMBER);
  FUNCTION traclus_main(I IN OUT NOCOPY mp_array, e IN NUMBER, min_lns IN INTEGER, smooth_factor IN INTEGER, compression_method IN NUMBER DEFAULT 1,
     tol IN NUMBER DEFAULT 100, noise_ls IN OUT NOCOPY line_segment_nt) RETURN internal_cluster_nt;

  FUNCTION line_segment_clustering(D IN OUT NOCOPY line_segment_nt, e IN NUMBER, min_lns IN INTEGER, smooth_factor IN INTEGER,
     noise_ls IN OUT NOCOPY line_segment_nt) RETURN internal_cluster_nt;
  PROCEDURE expand_cluster(D IN OUT NOCOPY line_segment_nt, Ne_Q IN OUT NOCOPY INTEGER_NT, cluster_id IN INTEGER, e IN NUMBER, min_lns IN INTEGER);
  FUNCTION compute_ne(D IN OUT NOCOPY line_segment_nt, pos IN NUMBER, e IN NUMBER) RETURN INTEGER_NT;
  FUNCTION dist(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER;
  FUNCTION segments_from_trajectories(trajectories IN OUT NOCOPY mp_array) RETURN unit_moving_point_nt;
  
  FUNCTION approximate_traj_partitioning(TR IN OUT NOCOPY spt_pos_nt) RETURN spt_pos_nt;
  FUNCTION compute_encoding_cost(TR IN OUT NOCOPY spt_pos_nt, start_index IN NUMBER, curr_index IN NUMBER) RETURN NUMBER;
  FUNCTION compute_model_cost(TR IN OUT NOCOPY spt_pos_nt, start_index IN NUMBER, curr_index IN NUMBER) RETURN NUMBER;
  FUNCTION MDLpar(TR IN OUT NOCOPY spt_pos_nt, start_index IN NUMBER, curr_index IN NUMBER) RETURN NUMBER;
  FUNCTION MDLnopar(TR IN OUT NOCOPY spt_pos_nt, start_index IN NUMBER, curr_index IN NUMBER) RETURN NUMBER;
  FUNCTION perpendicular_distance(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER;
  FUNCTION parallel_distance(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER;
  FUNCTION angle_distance(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER;
  FUNCTION angle_xx(s IN sp_pos, e IN sp_pos) RETURN NUMBER;
  FUNCTION angle(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER;
  FUNCTION projection_point(p IN sp_pos, l_s IN sp_pos, l_e IN sp_pos) RETURN sp_pos;
  FUNCTION euclidean_distance(s IN sp_pos, e IN sp_pos) RETURN NUMBER;
  FUNCTION minimum_value(v1 IN NUMBER, v2 IN NUMBER) RETURN NUMBER;
END traclus;
/


