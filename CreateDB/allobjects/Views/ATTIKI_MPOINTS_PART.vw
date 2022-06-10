Prompt View ATTIKI_MPOINTS_PART;
CREATE OR REPLACE VIEW ATTIKI_MPOINTS_PART
AS 
select t.object_id,t.traj_id,t.mpoint from attiki_mpoints t
where t.object_id between 3500 and 3800
/*t.object_id,t.traj_id,t.mpoint from ATTIKI_SAMPLING t
where t.object_id in (select a.id from attiki_reporter a where a.objclass in (1))
--t.traj_id object_id,t.traj_id,t.mpoint from ATTIKI_CLUSTER_EXT t where t.clust_id in (1)
/*d.object_id,d.traj_id,d.mpoint from attiki_sampling_tdtr d
where d.traj_id in (select r.id from attiki_reporter_table r where r.objclass in (0,1,4))
--o_id OBJECT_ID, traj_id TRAJ_ID, sub_mpoint MPOINT from attiki_sub_mpoints m
--p.object_id,p.traj_id,p.mpoint from attiki_mpoints p
/*where mod(m.subtraj_id,2)=0 and
traj_id between 450 and 550

or (t.traj_id between 500 and 800)
or (t.traj_id between 2500 and 2700)
--or (m.traj_id between 3500 and 3900)
--or (m.traj_id between 3000 and 3045)
or (t.traj_id between 4350 and 4550)
*/
/


