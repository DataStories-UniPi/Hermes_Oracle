Prompt Table H_BENCHMARK_RUN;
CREATE TABLE H_BENCHMARK_RUN
(
  BID          NUMBER                           NOT NULL,
  RID          NUMBER                           NOT NULL,
  VOL          NUMBER,
  N_PARAM      NUMBER,
  TID          NUMBER,
  X_MIN        NUMBER,
  Y_MIN        NUMBER,
  T_MIN        NUMBER,
  X_MAX        NUMBER,
  Y_MAX        NUMBER,
  T_MAX        NUMBER,
  EXC          NUMBER                           NOT NULL,
  EXC_DET      VARCHAR2(60 BYTE),
  FRET         NUMBER,
  NR_OF_FAKES  NUMBER                           NOT NULL,
  I_TSTAMP     TIMESTAMP(6)                     DEFAULT LOCALTIMESTAMP        NOT NULL
)
TABLESPACE USERS
/


