Prompt Non-Foreign Key Constraints on Table SEM_DW_TIME_DIM;
ALTER TABLE SEM_DW_TIME_DIM ADD (
  CONSTRAINT TIME_DIM_PK
 PRIMARY KEY
 (TIME_ID)
    USING INDEX 
    TABLESPACE USERS)
/