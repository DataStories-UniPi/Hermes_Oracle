Prompt Non-Foreign Key Constraints on Table HS1D4P100_EPIS3DGEOM;
ALTER TABLE HS1D4P100_EPIS3DGEOM ADD (
  CONSTRAINT HS1D4P100_3DGEOM_PK
 PRIMARY KEY
 (O_ID, T_ID, E_ID)
    USING INDEX 
    TABLESPACE USERS)
/