Prompt Non-Foreign Key Constraints on Table A_ATTIKI_MOVE_SEMS_DIM;
ALTER TABLE A_ATTIKI_MOVE_SEMS_DIM ADD (
  CONSTRAINT MOVE_SEMS_PK
 PRIMARY KEY
 (MOVE_SEMS_ID)
    USING INDEX 
    TABLESPACE USERS)
/
