Prompt Package Body DEBUG_EXTPROC;
CREATE OR REPLACE PACKAGE BODY debug_extproc IS

  extproc_lib_error EXCEPTION;
  PRAGMA EXCEPTION_INIT (extproc_lib_error, -6520);

  extproc_func_error EXCEPTION;
  PRAGMA EXCEPTION_INIT (extproc_func_error, -6521);

  PROCEDURE local_startup_extproc_agent IS EXTERNAL
    LIBRARY debug_extproc_library;

  PROCEDURE startup_extproc_agent is
  BEGIN

    -- call a dummy procedure and trap all errors.
    local_startup_extproc_agent;

  EXCEPTION
    -- Ignore any errors if the function or library is not found.
    WHEN extproc_func_error then NULL;
    WHEN extproc_lib_error then NULL;
  END startup_extproc_agent;

END debug_extproc;
/


