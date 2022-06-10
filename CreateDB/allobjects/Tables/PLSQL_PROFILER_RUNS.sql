Prompt drop TABLE PLSQL_PROFILER_RUNS;
ALTER TABLE PLSQL_PROFILER_RUNS
 DROP PRIMARY KEY CASCADE
/

DROP TABLE PLSQL_PROFILER_RUNS CASCADE CONSTRAINTS PURGE
/

Prompt Table PLSQL_PROFILER_RUNS;
CREATE TABLE PLSQL_PROFILER_RUNS
(
  RUNID            NUMBER,
  RELATED_RUN      NUMBER,
  RUN_OWNER        VARCHAR2(32 BYTE),
  RUN_DATE         DATE,
  RUN_COMMENT      VARCHAR2(2047 BYTE),
  RUN_TOTAL_TIME   NUMBER,
  RUN_SYSTEM_INFO  VARCHAR2(2047 BYTE),
  RUN_COMMENT1     VARCHAR2(2047 BYTE),
  SPARE1           VARCHAR2(256 BYTE)
)
TABLESPACE USERS
/

COMMENT ON TABLE PLSQL_PROFILER_RUNS IS 'Run-specific information for the PL/SQL profiler'
/


