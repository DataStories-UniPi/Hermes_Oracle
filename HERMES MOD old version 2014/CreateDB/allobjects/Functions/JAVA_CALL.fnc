Prompt drop Function JAVA_CALL;
DROP FUNCTION JAVA_CALL
/

Prompt Function JAVA_CALL;
CREATE OR REPLACE FUNCTION java_call RETURN number
as language java
NAME 'Test.x() return java.lang.Double';
/

SHOW ERRORS;


