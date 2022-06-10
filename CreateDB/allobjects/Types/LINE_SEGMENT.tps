Prompt Type LINE_SEGMENT;
CREATE OR REPLACE TYPE line_segment IS OBJECT(
  s spt_pos,
  e spt_pos,
  traj_id INTEGER,
  cluster_id INTEGER,
  classified INTEGER,
  noise INTEGER,
  parent_segments line_segment_small_nt,
  CONSTRUCTOR FUNCTION line_segment(SELF IN OUT NOCOPY line_segment, s IN spt_pos, e IN spt_pos) RETURN SELF AS RESULT
);
/


