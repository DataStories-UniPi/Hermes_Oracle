Prompt Table POI_MILANO;
CREATE TABLE POI_MILANO
(
  CATEGORY     VARCHAR2(250 BYTE)               NOT NULL,
  LON          NUMBER                           NOT NULL,
  LAT          NUMBER                           NOT NULL,
  DESCRIPTION  VARCHAR2(250 BYTE)               NOT NULL,
  X            NUMBER                           DEFAULT 0                     NOT NULL,
  Y            NUMBER                           DEFAULT 0                     NOT NULL,
  MISC         VARCHAR2(250 BYTE)
)
TABLESPACE USERS
/


