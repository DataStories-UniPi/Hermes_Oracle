Prompt Non-Foreign Key Constraints on Table ATTIKI_200_MOVE_SEMS_DIM;
ALTER TABLE ATTIKI_200_MOVE_SEMS_DIM ADD (
  CONSTRAINT ATTIKI_200_MOVE_SEMS_PK
 PRIMARY KEY
 (MOVE_SEMS_ID)
    USING INDEX 
    TABLESPACE USERS)
/