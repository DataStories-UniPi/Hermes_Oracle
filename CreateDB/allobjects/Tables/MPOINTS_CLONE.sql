Prompt Table MPOINTS_CLONE;
CREATE TABLE MPOINTS_CLONE
(
  OBJECT_ID  INTEGER,
  TRAJ_ID    INTEGER,
  MPOINT     MOVING_POINT
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


