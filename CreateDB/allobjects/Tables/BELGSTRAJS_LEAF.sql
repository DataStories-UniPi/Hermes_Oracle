Prompt Table BELGSTRAJS_LEAF;
CREATE TABLE BELGSTRAJS_LEAF
(
  LID   INTEGER,
  ROID  VARCHAR2(32 BYTE),
  LEAF  SEM_STBLEAF
)
COLUMN LEAF NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


