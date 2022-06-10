Prompt Procedure HOST_COMMAND2;
CREATE OR REPLACE PROCEDURE host_command2 (p_command  IN  VARCHAR2)
AS LANGUAGE JAVA
NAME 'Host2.executeCommand (java.lang.String)';
/


