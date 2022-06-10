Prompt Foreign Key Constraints on Table HS1D4P150_STOPS_FACT;
ALTER TABLE HS1D4P150_STOPS_FACT ADD (
  CONSTRAINT HS1D4P150_STOPS_STOP_SEMS_FK 
 FOREIGN KEY (STOP_SEMS_ID) 
 REFERENCES HS1D4P150_STOP_SEMS_DIM (STOP_SEMS_ID),
  CONSTRAINT HS1D4P150_STOPS_PERIOD_FK 
 FOREIGN KEY (PERIOD_ID) 
 REFERENCES HS1D4P150_PERIOD_DIM (PERIOD_ID),
  CONSTRAINT HS1D4P150_STOPS_USER_FK 
 FOREIGN KEY (USER_PROFILE_ID) 
 REFERENCES HS1D4P150_USERS_DIM (USER_PROFILE_ID))
/