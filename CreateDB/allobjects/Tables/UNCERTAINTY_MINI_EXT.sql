Prompt Table UNCERTAINTY_MINI_EXT;
CREATE TABLE UNCERTAINTY_MINI_EXT
(
  CLUST_ID  NUMBER,
  TRAJ_ID   NUMBER,
  MPOINT    MOVING_POINT
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


