Prompt Non-Foreign Key Constraints on Table ATTIKI_MPOINTS;
ALTER TABLE ATTIKI_MPOINTS ADD (
  CONSTRAINT ATTIKI_PK
 PRIMARY KEY
 (OBJECT_ID, TRAJ_ID)
    USING INDEX 
    TABLESPACE USERS)
/