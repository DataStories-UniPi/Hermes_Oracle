Prompt Table TBTREEIDX_CLONE_LEAF;
CREATE TABLE TBTREEIDX_CLONE_LEAF
(
  R     INTEGER,
  ROID  VARCHAR2(20 BYTE),
  NODE  TBTREELEAF
)
COLUMN NODE NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/

