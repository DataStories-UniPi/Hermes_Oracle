Prompt Non-Foreign Key Constraints on Table HS1D4P50_MOVES_FACT;
ALTER TABLE HS1D4P50_MOVES_FACT ADD (
  CONSTRAINT HS1D4P50_MOVES_FACT_PK
 PRIMARY KEY
 (PERIOD_ID, FROM_STOP_SEMS_ID, TO_STOP_SEMS_ID, USER_PROFILE_ID, MOVE_SEMS_ID)
    USING INDEX 
    TABLESPACE USERS)
/