Prompt Table MV_TBL;
CREATE TABLE MV_TBL
(
  GEOMETRY  MDSYS.SDO_GEOMETRY,
  LABEL     VARCHAR2(20 BYTE)
)
COLUMN GEOMETRY NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


