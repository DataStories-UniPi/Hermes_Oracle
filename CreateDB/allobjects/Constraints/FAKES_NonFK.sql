Prompt Non-Foreign Key Constraints on Table FAKES;
ALTER TABLE FAKES ADD (
  CONSTRAINT FAKES_PK
 PRIMARY KEY
 (USER_ID, TRAJ_ID)
    USING INDEX 
    TABLESPACE USERS)
/
