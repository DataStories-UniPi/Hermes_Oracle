Prompt Table TRACLUS_RESULT_PSEG;
CREATE TABLE TRACLUS_RESULT_PSEG
(
  CLUST_ID  NUMBER                              NOT NULL,
  TRAJ_ID   INTEGER,
  MPOINT    MOVING_POINT,
  NOISE     NUMBER
)
COLUMN MPOINT NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/

