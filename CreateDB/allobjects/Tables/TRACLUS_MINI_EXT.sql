Prompt Table TRACLUS_MINI_EXT;
CREATE TABLE TRACLUS_MINI_EXT
(
  CLUST_ID  NUMBER,
  TRAJ_ID   NUMBER,
  MPOINT    MOVING_POINT,
  NOISE     NUMBER
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


