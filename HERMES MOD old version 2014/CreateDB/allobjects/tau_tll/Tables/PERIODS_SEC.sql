Prompt drop TABLE PERIODS_SEC;
DROP TABLE PERIODS_SEC CASCADE CONSTRAINTS PURGE
/

Prompt Table PERIODS_SEC;
CREATE TABLE PERIODS_SEC OF D_PERIOD_SEC 
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


