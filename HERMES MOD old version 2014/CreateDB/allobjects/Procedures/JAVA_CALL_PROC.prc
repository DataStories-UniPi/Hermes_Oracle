Prompt drop Procedure JAVA_CALL_PROC;
DROP PROCEDURE JAVA_CALL_PROC
/

Prompt Procedure JAVA_CALL_PROC;
CREATE OR REPLACE procedure java_call_proc(dir varchar2,conf varchar2)
as language java
NAME 'stopfinder.Application.main(java.lang.String[])';
/

SHOW ERRORS;


