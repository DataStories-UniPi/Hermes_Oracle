Prompt Non-Foreign Key Constraints on Table A_ATTIKI_TIME_DIM;
ALTER TABLE A_ATTIKI_TIME_DIM ADD (
  CONSTRAINT TIME_DIM_PK
 PRIMARY KEY
 (TIME_ID)
    USING INDEX 
    TABLESPACE USERS)
/