Prompt Non-Foreign Key Constraints on Table HS1D4P50_STOP_SEMS_DIM;
ALTER TABLE HS1D4P50_STOP_SEMS_DIM ADD (
  CONSTRAINT HS1D4P50_STOPS_SEMS_PK
 PRIMARY KEY
 (STOP_SEMS_ID)
    USING INDEX 
    TABLESPACE USERS)
/
