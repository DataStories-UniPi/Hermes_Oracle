Prompt View ATTIKI_SUB_MPOINTS_VIEW;
CREATE OR REPLACE VIEW ATTIKI_SUB_MPOINTS_VIEW
AS 
select t.o_id traj_id, t.subtraj_id subtraj_id, t.sub_mpoint mpoint from attiki_sub_mpoints t where t.o_id in (1131,1192,1233,1109,1242,4313)
and t.subtraj_id=4
/


