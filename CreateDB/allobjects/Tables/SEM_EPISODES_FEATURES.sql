Prompt Table SEM_EPISODES_FEATURES;
CREATE TABLE SEM_EPISODES_FEATURES
(
  O_ID              INTEGER,
  TRAJ_ID           INTEGER,
  SUBTRAJ_ID        INTEGER,
  DISTANCE_COVERED  NUMBER,
  DURATION_SEC      NUMBER,
  TOP_SPEED         NUMBER,
  AVG_SPEED         NUMBER,
  SPEED_VAR         NUMBER,
  ROAD_TYPE         VARCHAR2(50 BYTE),
  STARTPOITYPE      VARCHAR2(50 BYTE),
  ENDPOITYPE        VARCHAR2(50 BYTE),
  TRANSMODE         VARCHAR2(50 BYTE),
  STOPACTIVITY      VARCHAR2(50 BYTE),
  STARTTIME         TAU_TLL.D_TIMEPOINT_SEC,
  ENDTIME           TAU_TLL.D_TIMEPOINT_SEC,
  AREA              NUMBER
)
COLUMN STARTTIME NOT SUBSTITUTABLE AT ALL LEVELS
COLUMN ENDTIME NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/

