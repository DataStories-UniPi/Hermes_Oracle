Prompt Table IMIS_3DAYS_MPOINTS;
CREATE TABLE IMIS_3DAYS_MPOINTS
(
  OBJECT_ID  INTEGER,
  TRAJ_ID    INTEGER,
  MPOINT     MOVING_POINT
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


