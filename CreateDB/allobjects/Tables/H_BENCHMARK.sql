Prompt Table H_BENCHMARK;
CREATE TABLE H_BENCHMARK
(
  BID            NUMBER                         NOT NULL,
  QTYP           VARCHAR2(20 BYTE)              NOT NULL,
  K_PARAM        NUMBER                         NOT NULL,
  L_PARAM        NUMBER                         NOT NULL,
  MIN_LNS        NUMBER                         NOT NULL,
  SMOOTH_FACTOR  NUMBER                         NOT NULL,
  MAX_STEP       NUMBER                         NOT NULL,
  USER_ID        NUMBER                         NOT NULL,
  I_TSTAMP       TIMESTAMP(6)                   DEFAULT LOCALTIMESTAMP        NOT NULL
)
TABLESPACE USERS
/


