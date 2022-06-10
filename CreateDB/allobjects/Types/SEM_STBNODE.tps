Prompt Type SEM_STBNODE;
CREATE OR REPLACE type sem_stbnode as object
(
  -- Attributes
  ptrParent integer,
  ptrCurrent integer,
  numOfEntries integer,
  nodeEntries sem_stbnode_entries
)
/


