Prompt Foreign Key Constraints on Table ATTIKI_200_MOVES_FACT;
ALTER TABLE ATTIKI_200_MOVES_FACT ADD (
  CONSTRAINT ATTIKI_200_MOVES_MOVE_SEMS_FK 
 FOREIGN KEY (MOVE_SEMS_ID) 
 REFERENCES ATTIKI_200_MOVE_SEMS_DIM (MOVE_SEMS_ID),
  CONSTRAINT ATTIKI_200_MOVES_PERIOD_FK 
 FOREIGN KEY (PERIOD_ID) 
 REFERENCES ATTIKI_200_PERIOD_DIM (PERIOD_ID),
  CONSTRAINT ATTIKI_200_MOVES_USER_FK 
 FOREIGN KEY (USER_PROFILE_ID) 
 REFERENCES ATTIKI_200_USERS_DIM (USER_PROFILE_ID),
  CONSTRAINT ATTIKI_200_MOVES_FROM_STOPS_FK 
 FOREIGN KEY (FROM_STOP_SEMS_ID) 
 REFERENCES ATTIKI_200_STOP_SEMS_DIM (STOP_SEMS_ID),
  CONSTRAINT ATTIKI_200_MOVES_TO_STOPS_FK 
 FOREIGN KEY (TO_STOP_SEMS_ID) 
 REFERENCES ATTIKI_200_STOP_SEMS_DIM (STOP_SEMS_ID))
/