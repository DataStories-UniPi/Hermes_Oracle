Prompt drop TABLE TEMP_ELEMENTS_Y;
DROP TABLE TEMP_ELEMENTS_Y CASCADE CONSTRAINTS PURGE
/

Prompt Table TEMP_ELEMENTS_Y;
CREATE TABLE TEMP_ELEMENTS_Y OF D_TEMP_ELEMENT_Y 
NESTED TABLE TE STORE AS TE_Y_TAB
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


