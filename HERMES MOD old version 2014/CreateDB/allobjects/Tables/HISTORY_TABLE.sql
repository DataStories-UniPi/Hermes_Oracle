Prompt Table HISTORY_TABLE;
CREATE TABLE HISTORY_TABLE
(
  NAME                 VARCHAR2(50 BYTE),
  QUERY_TYPE           VARCHAR2(50 BYTE)        NOT NULL,
  ALGORITHM_TYPE       VARCHAR2(50 BYTE)        NOT NULL,
  CLUSTER_COUNT        NUMBER,
  THRESHOLD_T_OPTICS   NUMBER,
  MOVING_POINTS_COUNT  NUMBER,
  ORIGINAL_TABLE       VARCHAR2(100 BYTE)
)
TABLESPACE USERS
/

