Prompt Foreign Key Constraints on Table PLSQL_PROFILER_DATA;
ALTER TABLE PLSQL_PROFILER_DATA ADD (
  FOREIGN KEY (RUNID, UNIT_NUMBER) 
 REFERENCES PLSQL_PROFILER_UNITS (RUNID,UNIT_NUMBER))
/