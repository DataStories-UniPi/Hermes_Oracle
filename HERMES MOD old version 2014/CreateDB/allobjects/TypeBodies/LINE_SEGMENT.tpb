Prompt Type Body LINE_SEGMENT;
CREATE OR REPLACE TYPE BODY line_segment IS
-- -----------------------------------------------------
-- Constructor line_segment(s spt_pos, e spt_pos)
-- -----------------------------------------------------
  CONSTRUCTOR FUNCTION line_segment(SELF IN OUT NOCOPY line_segment, s IN spt_pos, e IN spt_pos) RETURN SELF AS RESULT
  IS
  BEGIN
    SELF.s := s;
    SELF.e := e;
    SELF.classified := 0;
    SELF.noise := 0;
    RETURN;
  END;
END;
/


