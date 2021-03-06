Prompt Table IMIS_3DAYS_PERTRAJ;
CREATE TABLE IMIS_3DAYS_PERTRAJ
(
  OBJECT_ID         INTEGER,
  TRAJ_ID           INTEGER,
  STARTLOCX         NUMBER,
  STARTLOCY         NUMBER,
  ENDLOCX           NUMBER,
  ENDLOCY           NUMBER,
  MBB               SEM_MBB,
  DURATION          NUMBER,
  LENGTH            NUMBER,
  AVGSPEED          NUMBER,
  NUMOFPOINTS       INTEGER,
  RADIUSOFGYRATION  NUMBER
)
COLUMN MBB NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


