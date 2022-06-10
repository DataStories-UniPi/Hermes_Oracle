Prompt Type INTERNAL_CLUSTER;
CREATE OR REPLACE TYPE internal_cluster IS OBJECT(
  cluster_id INTEGER,
  min_lns INTEGER,
  smooth_factor INTEGER,
  segments line_segment_nt,
  RTR spt_pos_nt,
  cardinal INTEGER,

  CONSTRUCTOR FUNCTION internal_cluster(SELF IN OUT NOCOPY internal_cluster, cluster_id IN INTEGER, min_lns IN INTEGER, smooth_factor IN INTEGER) RETURN SELF AS RESULT,

  MEMBER PROCEDURE post_process,
  MEMBER PROCEDURE calculate_cardinallity,
  MEMBER PROCEDURE sort_by_traj_id,

  MEMBER PROCEDURE representative_traj_generation,

  MEMBER FUNCTION create_direction_vector RETURN sp_pos_nt,
  MEMBER FUNCTION segments_containing_x(x IN NUMBER, angle IN NUMBER) RETURN line_segment_nt,
  MEMBER FUNCTION segments_cross_y(segment IN line_segment, x IN NUMBER, angle IN NUMBER) RETURN NUMBER,

  MEMBER FUNCTION angle_xx(s IN sp_pos, e IN sp_pos) RETURN NUMBER,
  MEMBER FUNCTION angle(s1 IN sp_pos, e1 IN sp_pos, s2 IN sp_pos, e2 IN sp_pos) RETURN NUMBER,
  MEMBER FUNCTION reverse_rotation_x(p IN sp_pos, angle IN NUMBER) RETURN NUMBER,
  MEMBER FUNCTION reverse_rotation_y(p IN sp_pos, angle IN NUMBER) RETURN NUMBER,
  MEMBER FUNCTION rotated_x(p IN sp_pos, angle IN NUMBER) RETURN NUMBER,
  MEMBER FUNCTION rotated_y(p IN sp_pos, angle IN NUMBER) RETURN NUMBER
);
/


