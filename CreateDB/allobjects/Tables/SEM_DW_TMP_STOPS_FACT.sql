Prompt Table SEM_DW_TMP_STOPS_FACT;
CREATE TABLE SEM_DW_TMP_STOPS_FACT
(
  USER_ID             NUMBER(9),
  SEMTRAJ_ID          NUMBER(9),
  PERIOD_ID           NUMBER(9),
  STOP_SEMS_ID        NUMBER(9),
  USER_PROFILE_ID     NUMBER(9),
  ACTIVITY            VARCHAR2(50 BYTE),
  DURATION            NUMBER,
  RADIUS_OF_GYRATION  NUMBER
)
TABLESPACE USERS
/


