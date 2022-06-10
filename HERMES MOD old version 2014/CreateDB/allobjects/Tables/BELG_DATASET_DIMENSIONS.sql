Prompt Table BELG_DATASET_DIMENSIONS;
CREATE TABLE BELG_DATASET_DIMENSIONS
(
  MINTIME       TAU_TLL.D_TIMEPOINT_SEC,
  MAXTIME       TAU_TLL.D_TIMEPOINT_SEC,
  MINLONGITUDE  NUMBER,
  MAXLONGITUDE  NUMBER,
  MINLATITUDE   NUMBER,
  MAXLATITUDE   NUMBER
)
COLUMN MINTIME NOT SUBSTITUTABLE AT ALL LEVELS
COLUMN MAXTIME NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/

