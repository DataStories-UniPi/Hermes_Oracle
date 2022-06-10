Prompt Type Body LINE_SEGMENT_SMALL;
CREATE OR REPLACE TYPE BODY line_segment_small IS
-- -----------------------------------------------------
-- Constructor line_segment_small(s spt_pos, e spt_pos)
-- -----------------------------------------------------
  CONSTRUCTOR FUNCTION line_segment_small(SELF IN OUT NOCOPY line_segment_small, s IN spt_pos, e IN spt_pos) RETURN SELF AS RESULT
  IS
  BEGIN
    SELF.s := s;
    SELF.e := e;
    RETURN;
  END;
END;
/


