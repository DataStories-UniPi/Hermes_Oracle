Prompt Non-Foreign Key Constraints on Table IMIS_3DAYS_FACTTBL;
ALTER TABLE IMIS_3DAYS_FACTTBL ADD (
  CONSTRAINT IMIS_3DAYS_FACTTBL_IX
 PRIMARY KEY
 (TIME_ID, SPACE_ID)
    USING INDEX 
    TABLESPACE USERS)
/