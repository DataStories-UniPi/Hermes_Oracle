Prompt Table BRINKHOFF_NODES;
CREATE TABLE BRINKHOFF_NODES
(
  ID         NUMBER,
  X          NUMBER,
  Y          NUMBER,
  LONGITUDE  NUMBER,
  LATITUDE   NUMBER,
  NODE_GEOM  MDSYS.SDO_GEOMETRY
)
COLUMN NODE_GEOM NOT SUBSTITUTABLE AT ALL LEVELS
TABLESPACE USERS
/


