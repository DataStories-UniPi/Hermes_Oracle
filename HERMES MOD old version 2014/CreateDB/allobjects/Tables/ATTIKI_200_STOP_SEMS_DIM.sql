Prompt Table ATTIKI_200_STOP_SEMS_DIM;
CREATE TABLE ATTIKI_200_STOP_SEMS_DIM
(
  STOP_SEMS_ID   NUMBER(9),
  STOP_NAME      VARCHAR2(50 BYTE),
  STOP_TYPE      VARCHAR2(50 BYTE),
  STOP_ACTIVITY  VARCHAR2(50 BYTE),
  POI_ID         NUMBER(9)
)
TABLESPACE USERS
/

