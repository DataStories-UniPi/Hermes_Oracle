Prompt Table BELGSUB_STOPS_FOUND;
CREATE TABLE BELGSUB_STOPS_FOUND
(
  USERID     INTEGER,
  TRAJID     INTEGER,
  SUBTRAJID  INTEGER,
  X          NUMBER(22,6),
  Y          NUMBER(22,6),
  T          NUMBER,
  STOPID     INTEGER,
  TRAJ       VARCHAR2(20 BYTE)
)
TABLESPACE USERS
/


