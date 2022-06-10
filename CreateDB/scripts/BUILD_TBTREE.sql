drop table "HERMES"."TBTREEIDX_LEAF" PURGE;
drop table "HERMES"."TBTREEIDX_NON_LEAF" PURGE;
/

drop indextype tbtree force;
/

drop index tbtreeidx force;
/

--DELETE FROM mpoints;
--/

CREATE INDEXTYPE TBTREE
FOR 
contains_timepoint(moving_point, tau_tll.d_timepoint_sec),
tb_intersects(moving_point,MDSYS.SDO_GEOMETRY) ,
contains_timeperiod(moving_point,tau_tll.D_Period_Sec),
contains_temporal_element(moving_point,tau_tll.D_Temp_Element_Sec),
mp_in_SpatioTemp_Win(moving_point, MDSYS.SDO_GEOMETRY,tau_tll.d_period_sec)
USING tbTree_idxtype_im;
/

create index tbtreeidx on mpoints(mpoint)  indextype is TBTREE Parameters('traj_id');
/

/*
INSERT INTO mpoints(object_id, traj_id, mpoint)
	SELECT object_id, traj_id, mpoint FROM milano_cl_mpoints;
/
*/
