Prompt Non-Foreign Key Constraints on Table INIT_END;
ALTER TABLE INIT_END ADD (
  CONSTRAINT INIT_END_PK
 PRIMARY KEY
 (USER_ID, TRAJ_ID)
    USING INDEX 
    TABLESPACE USERS)
/