Prompt Table IMIS_3DAYS_TBTREE_LEAF;
CREATE TABLE IMIS_3DAYS_TBTREE_LEAF
(
  R     INTEGER,
  ROID  VARCHAR2(20 BYTE),
  NODE  TBTREELEAF
)
COLUMN NODE NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


