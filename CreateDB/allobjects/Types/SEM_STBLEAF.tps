Prompt Type SEM_STBLEAF;
CREATE OR REPLACE type sem_stbleaf as object
(
  -- Attributes
  id sem_traj_id,
  roid varchar2(32),
  ptrParent integer,
  ptrCurrent integer,
  ptrNext integer,
  ptrPrevious integer,
  numOfEntries integer,
  leafEntries sem_stbleaf_entries
)
/


