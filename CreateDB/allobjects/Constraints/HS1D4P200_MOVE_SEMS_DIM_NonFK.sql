Prompt Non-Foreign Key Constraints on Table HS1D4P200_MOVE_SEMS_DIM;
ALTER TABLE HS1D4P200_MOVE_SEMS_DIM ADD (
  CONSTRAINT HS1D4P200_MOVE_SEMS_PK
 PRIMARY KEY
 (MOVE_SEMS_ID)
    USING INDEX 
    TABLESPACE USERS)
/
