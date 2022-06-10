Prompt Type LINE_SEGMENT_SMALL;
CREATE OR REPLACE TYPE line_segment_small IS OBJECT(
  s spt_pos,
  e spt_pos,
  CONSTRUCTOR FUNCTION line_segment_small(SELF IN OUT NOCOPY line_segment_small, s IN spt_pos, e IN spt_pos) RETURN SELF AS RESULT
);
/


