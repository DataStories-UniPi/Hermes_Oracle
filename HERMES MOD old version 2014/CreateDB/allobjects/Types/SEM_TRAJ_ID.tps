Prompt Type SEM_TRAJ_ID;
CREATE OR REPLACE type sem_traj_id as object
(
  -- Attributes
  o_id integer,
  semtraj_id integer
)
 alter type sem_traj_id add order member function match(other sem_traj_id) return integer cascade
 alter type sem_traj_id not final cascade
/


