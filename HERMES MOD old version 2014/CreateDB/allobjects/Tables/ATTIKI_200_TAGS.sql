Prompt Table ATTIKI_200_TAGS;
CREATE TABLE ATTIKI_200_TAGS
(
  TAG    VARCHAR2(50 BYTE),
  NODES  SEM_STBLEAFENTRYIDS
)
NESTED TABLE NODES STORE AS ATTIKI_200_NODES_NTAB
TABLESPACE USERS
/


