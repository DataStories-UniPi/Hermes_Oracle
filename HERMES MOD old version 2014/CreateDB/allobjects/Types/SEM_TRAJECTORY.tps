Prompt Type SEM_TRAJECTORY;
CREATE OR REPLACE type sem_trajectory as object
(
  -- Attributes
  sem_trajectory_tag varchar2(50),
  srid integer,
  episodes sem_episode_tab,
  o_id integer,
  semtraj_id integer,

  -- Member functions and procedures
  --Returns the stop episodes only
  member function sem_stops return sem_episode_tab,
  --Returns the move episodes only
  member function sem_moves return sem_episode_tab,
  --Return the number of stop episodes
  member function num_of_stops return integer,
  --Return the number of move episodes
  member function num_of_moves return integer,
  member function getMBB return sem_mbb
)
 alter type sem_trajectory add member function num_of_episodes(tag varchar2, uniques varchar2) return pls_integer cascade
 alter type sem_trajectory add member function episodes_with(tag varchar2) return sem_episode_tab cascade
 alter type sem_trajectory add member function confined_in(geom sdo_geometry,period tau_tll.d_period_sec,tag varchar2) return sem_trajectory cascade
 alter type sem_trajectory add member function sim_trajectories(tr sem_trajectory,dbtable varchar2,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number cascade
 alter type sem_trajectory add member function tompoint return moving_point cascade
 alter type sem_trajectory add member function timeorderepisodes return sem_episode_tab cascade
/


