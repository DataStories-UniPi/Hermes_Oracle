Prompt Non-Foreign Key Constraints on Table BELG_USERS;
ALTER TABLE BELG_USERS ADD (
  CONSTRAINT BELG_USERS_PK
 PRIMARY KEY
 (ID)
    USING INDEX 
    TABLESPACE USERS)
/
