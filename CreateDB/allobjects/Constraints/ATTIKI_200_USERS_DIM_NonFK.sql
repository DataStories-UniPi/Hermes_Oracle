Prompt Non-Foreign Key Constraints on Table ATTIKI_200_USERS_DIM;
ALTER TABLE ATTIKI_200_USERS_DIM ADD (
  CONSTRAINT ATTIKI_200_USERS_PK
 PRIMARY KEY
 (USER_PROFILE_ID)
    USING INDEX 
    TABLESPACE USERS)
/
