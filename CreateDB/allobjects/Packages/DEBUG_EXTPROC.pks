Prompt Package DEBUG_EXTPROC;
CREATE OR REPLACE PACKAGE debug_extproc IS

  --
  -- Startup the extproc agent process in the session
  --
  --   Executing this procedure, starts up the extproc agent process
  --   in the session allowing one to be able get the PID of the
  --   executing process. This PID is needed to be able to attach
  --   to the running process using a debugger.
  --
  PROCEDURE startup_extproc_agent;

END debug_extproc;
/


