Prompt Table DEBUG_MPOINTS_INDX_LEAF;
CREATE TABLE DEBUG_MPOINTS_INDX_LEAF
(
  R     INTEGER,
  ROID  VARCHAR2(20 BYTE),
  NODE  TBTREELEAF
)
COLUMN NODE NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


