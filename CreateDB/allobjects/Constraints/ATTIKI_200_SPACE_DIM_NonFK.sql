Prompt Non-Foreign Key Constraints on Table ATTIKI_200_SPACE_DIM;
ALTER TABLE ATTIKI_200_SPACE_DIM ADD (
  CONSTRAINT ATTIKI_200_SPACE_DIM_PK
 PRIMARY KEY
 (POI_ID)
    USING INDEX 
    TABLESPACE USERS)
/
