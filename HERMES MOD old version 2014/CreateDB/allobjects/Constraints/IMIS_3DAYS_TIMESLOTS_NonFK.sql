Prompt Non-Foreign Key Constraints on Table IMIS_3DAYS_TIMESLOTS;
ALTER TABLE IMIS_3DAYS_TIMESLOTS ADD (
  CONSTRAINT IMIS_3DAYS_TIMESLOTS_PK
 PRIMARY KEY
 (TIMEID)
    USING INDEX 
    TABLESPACE USERS)
/