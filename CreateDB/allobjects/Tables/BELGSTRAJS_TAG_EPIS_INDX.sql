Prompt Table BELGSTRAJS_TAG_EPIS_INDX;
CREATE TABLE BELGSTRAJS_TAG_EPIS_INDX
(
  TAG    VARCHAR2(50 BYTE),
  NODES  SEM_STBLEAFENTRYIDS
)
NESTED TABLE NODES STORE AS NODES_EPIS_NETSTED_TABLE
TABLESPACE USERS
/

