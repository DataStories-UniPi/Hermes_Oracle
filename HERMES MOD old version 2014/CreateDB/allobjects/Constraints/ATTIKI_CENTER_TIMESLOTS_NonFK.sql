Prompt Non-Foreign Key Constraints on Table ATTIKI_CENTER_TIMESLOTS;
ALTER TABLE ATTIKI_CENTER_TIMESLOTS ADD (
  CONSTRAINT ATTIKI_CENTER_TIMESLOTS_PK
 PRIMARY KEY
 (TIMEID)
    USING INDEX 
    TABLESPACE USERS)
/
