Prompt Table TOPOLOGICAL_TABLE;
CREATE TABLE TOPOLOGICAL_TABLE
(
  OBJECT_ID  NUMBER,
  TRAJ_ID    NUMBER,
  MPOINT     MOVING_POINT
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


