Prompt Type SEM_EPISODE;
CREATE OR REPLACE type sem_episode as object
(
  -- Attributes
  defining_tag varchar2(4),
  episode_tag varchar2(50),
  activity_tag varchar2(50),
  MBB sem_mbb,
  tlink ref sub_moving_point,

  -- Member functions and procedures
  --Returns the duration of the episode (based on its MBB)
  member function duration return tau_tll.d_interval
)
 alter type sem_episode add member function sim_episodes(e sem_episode,lamda number:=0.5,
  weight number_nt:=number_nt(0.333,0.333,0.333),dbtable varchar2, indxprefix varchar2) return number cascade
 alter type sem_episode drop member function sim_episodes(e sem_episode,lamda number:=0.5,
  weight number_nt:=number_nt(0.333,0.333,0.333),dbtable varchar2, indxprefix varchar2) return number cascade
 alter type sem_episode add member function sim_episodes(e sem_episode,dbtable varchar2,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number cascade
 alter type sem_episode drop member function sim_episodes(e sem_episode,dbtable varchar2,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number cascade
 alter type sem_episode add member function sim_episodes(e sem_episode,dbtable varchar2:=null,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number cascade
/


