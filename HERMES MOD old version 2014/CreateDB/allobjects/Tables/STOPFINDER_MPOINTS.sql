Prompt Table STOPFINDER_MPOINTS;
CREATE TABLE STOPFINDER_MPOINTS
(
  OBJECT_ID  INTEGER,
  TRAJ_ID    INTEGER,
  MPOINT     MOVING_POINT
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


