Prompt drop View BELG_SEM_TRAJS_VW;
DROP VIEW BELG_SEM_TRAJS_VW
/

Prompt View BELG_SEM_TRAJS_VW;
CREATE OR REPLACE VIEW BELG_SEM_TRAJS_VW
OF SEM_TRAJECTORY
AS 
select b.sem_trajectory_tag,b.SRID,b.EPISODES,b.O_ID,b.SEMTRAJ_ID
 from belg_sem_trajs b where b.o_id=5238 or b.o_id=9021
/


