Prompt Table IMIS_3DAYS_TIMESLOTS;
CREATE TABLE IMIS_3DAYS_TIMESLOTS
(
  TIMEID   NUMBER(9)                            NOT NULL,
  DATEDES  TIMESTAMP(7),
  YEAR     NUMBER(4),
  MONTH    NUMBER(2),
  DAY      NUMBER(2),
  MINUTE   NUMBER(2),
  SECOND   NUMBER(2),
  HOUR     NUMBER(2)
)
TABLESPACE USERS
/


