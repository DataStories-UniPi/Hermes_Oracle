Prompt Foreign Key Constraints on Table PLSQL_PROFILER_UNITS;
ALTER TABLE PLSQL_PROFILER_UNITS ADD (
  FOREIGN KEY (RUNID) 
 REFERENCES PLSQL_PROFILER_RUNS (RUNID))
/
