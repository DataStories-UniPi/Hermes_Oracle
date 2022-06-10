Prompt Non-Foreign Key Constraints on Table DOCS;
ALTER TABLE DOCS ADD (
  PRIMARY KEY
 (ID)
    USING INDEX 
    TABLESPACE USERS)
/
