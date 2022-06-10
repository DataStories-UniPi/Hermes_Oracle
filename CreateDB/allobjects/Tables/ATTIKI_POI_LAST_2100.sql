Prompt Table ATTIKI_POI_LAST_2100;
CREATE TABLE ATTIKI_POI_LAST_2100
(
  CATEGORY    VARCHAR2(30 BYTE),
  NAME        VARCHAR2(118 BYTE),
  GEOM        MDSYS.SDO_GEOMETRY,
  ID          NUMBER,
  NN_NODE_ID  NUMBER,
  NN_NODE_X   NUMBER(30),
  NN_NODE_Y   NUMBER(30)
)
COLUMN GEOM NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


