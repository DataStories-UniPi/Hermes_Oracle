Prompt Type SEM_ST_POINT;
CREATE OR REPLACE type sem_st_point as object
(
  -- Attributes
  x number,
  y number,
  t tau_tll.d_timepoint_sec
)
 alter type sem_st_point add member function isspatialequalto(aPoint sem_st_point ) return number cascade
/


