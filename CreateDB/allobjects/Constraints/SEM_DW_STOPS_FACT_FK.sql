Prompt Foreign Key Constraints on Table SEM_DW_STOPS_FACT;
ALTER TABLE SEM_DW_STOPS_FACT ADD (
  CONSTRAINT STOPS_FACT_USER_FK 
 FOREIGN KEY (USER_PROFILE_ID) 
 REFERENCES SEM_DW_USER_PROFILE_DIM (USER_PROFILE_ID),
  CONSTRAINT STOPS_FACT_PERIOD_FK 
 FOREIGN KEY (PERIOD_ID) 
 REFERENCES SEM_DW_PERIOD_DIM (PERIOD_ID),
  CONSTRAINT STOPS_FACT_STOP_SEMS_FK 
 FOREIGN KEY (STOP_SEMS_ID) 
 REFERENCES SEM_DW_STOP_SEMS_DIM (STOP_SEMS_ID))
/
