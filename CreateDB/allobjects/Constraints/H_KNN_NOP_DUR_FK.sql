Prompt Foreign Key Constraints on Table H_KNN_NOP_DUR;
ALTER TABLE H_KNN_NOP_DUR ADD (
  CONSTRAINT H_KNN_NOP_DUR_FK 
 FOREIGN KEY (BID, RID) 
 REFERENCES H_BENCHMARK_RUN (BID,RID))
/