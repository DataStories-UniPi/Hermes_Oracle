Prompt Foreign Key Constraints on Table H_FAKE_DUR;
ALTER TABLE H_FAKE_DUR ADD (
  CONSTRAINT H_FAKE_DUR_FK 
 FOREIGN KEY (BID, RID) 
 REFERENCES H_BENCHMARK_RUN (BID,RID))
/
