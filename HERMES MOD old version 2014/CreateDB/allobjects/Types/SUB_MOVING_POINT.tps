Prompt Type SUB_MOVING_POINT;
CREATE OR REPLACE type sub_moving_point as object
(
  -- Attributes
  o_id integer,
  traj_id integer,
  subtraj_id integer,
  sub_mpoint moving_point
)
 alter type sub_moving_point add member function getsemmbb return sem_mbb cascade
 alter type sub_moving_point not final cascade
/


