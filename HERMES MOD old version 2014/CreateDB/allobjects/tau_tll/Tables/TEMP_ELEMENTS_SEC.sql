Prompt drop TABLE TEMP_ELEMENTS_SEC;
DROP TABLE TEMP_ELEMENTS_SEC CASCADE CONSTRAINTS PURGE
/

Prompt Table TEMP_ELEMENTS_SEC;
CREATE TABLE TEMP_ELEMENTS_SEC OF D_TEMP_ELEMENT_SEC 
NESTED TABLE TE STORE AS TE_SEC_TAB
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


