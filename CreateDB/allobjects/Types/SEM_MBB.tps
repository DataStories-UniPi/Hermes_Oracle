Prompt Type SEM_MBB;
CREATE OR REPLACE type sem_mbb as object
(
  -- Attributes
  minPoint sem_st_point,
  maxPoint sem_st_point,

  -- Member functions and procedures
  --Returns the spatial area of this MBB
  member function area return number,
  --Returns the temporal area of this MBB
  member function duration return tau_tll.d_interval
)
 alter type sem_mbb add member function getrectangle return mdsys.sdo_geometry cascade
 alter type sem_mbb add member function area(srid integer) return number cascade
 alter type sem_mbb add member function getrectangle(srid integer) return mdsys.sdo_geometry cascade
 alter type sem_mbb add member function intersectsperdim(inmbb sem_mbb) return integer_nt cascade
 alter type sem_mbb add member function intersects(inmbb sem_mbb) return boolean cascade
 alter type sem_mbb add constructor function sem_mbb(geom sdo_geometry,period tau_tll.d_period_sec) return self as result cascade
 alter type sem_mbb add member function intersects01(inmbb sem_mbb) return pls_integer cascade
 alter type sem_mbb add member function ispoint return number cascade
 alter type sem_mbb drop constructor function sem_mbb(geom sdo_geometry,period tau_tll.d_period_sec) return self as result cascade
 alter type sem_mbb add member function to_sem_mbb(geom sdo_geometry,period tau_tll.d_period_sec) return sem_mbb cascade
/


