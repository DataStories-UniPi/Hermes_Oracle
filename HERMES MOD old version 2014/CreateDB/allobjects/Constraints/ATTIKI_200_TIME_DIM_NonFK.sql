Prompt Non-Foreign Key Constraints on Table ATTIKI_200_TIME_DIM;
ALTER TABLE ATTIKI_200_TIME_DIM ADD (
  CONSTRAINT ATTIKI_200_TIME_DIM_PK
 PRIMARY KEY
 (TIME_ID)
    USING INDEX 
    TABLESPACE USERS)
/