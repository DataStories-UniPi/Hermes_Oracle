Prompt Package HERMOUPOLIS;
CREATE OR REPLACE package Hermoupolis is

  -- Author  : STYLIANOS
  -- Created : 6/13/2013 02:01:59
  -- Purpose : 
  
  -- Public type declarations
  /*
  type <TypeName> is <Datatype>;
  
  -- Public constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  <VariableName> <Datatype>;

  -- Public function and procedure declarations
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  */

  --takes hermoupolis output (some columns) and produces semantic trajectories in sem_trajs_out table with their sub-trajectories at sub_mpoints_out table
  --from_id and to_id are used to run this in parallel
  procedure raw2semtrajs(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer, from_id number, to_id number);

  PROCEDURE TOMYTOPTICS( filename  VARCHAR2, mpoints mp_array)
  AS
    language java NAME 'ToMyToptics.writeFile(java.lang.String, oracle.sql.ARRAY)';

  --output semantic trajectories from semmpoints variable to file filename in hermoupolis.SemTOptics format(0 all, 1 stops, 2 moves)
  PROCEDURE TOMYTOPTICSSEM( filename  VARCHAR2, semmpoints sem_trajectory_tab)
  AS
    language java NAME 'ToMyTopticsSem.writeFile(java.lang.String, oracle.sql.ARRAY)';
    
   PROCEDURE TOMYTOPTICSSEMEPIS( filename  VARCHAR2, semepis sem_episode_type_tab)
  AS
    language java NAME 'ToMyTopticsSemEpis.writeFile(java.lang.String, oracle.sql.ARRAY)';

  PROCEDURE TOSCENARIO( filename  VARCHAR2, semmpoints sem_trajectory_tab)
  AS
    language java NAME 'ToScenario.writeFile(java.lang.String, oracle.sql.ARRAY)';

  --creates a variable with semantic trajectories from table sourceTable and pass it to TOMYTOPTICSSEM for output of them
  procedure outputSemtrajsForSemTOptics(outputFile varchar2, sourceTable varchar2);
  procedure outputSemtrajsForSemTOpticsRaw(outputFile varchar2, sourceTable varchar2);

  --
  procedure stopsOnlyToSemTOpticsPerClust(outputFile varchar2, clustersTable varchar2, sourceTable varchar2, cluster_id integer);
  
  procedure episodesToSemTOptics(outputFile varchar2, episodesClustersTable varchar2, sourceTable varchar2, cluster_id integer);
  
  procedure gatherEpisodesClusters(targetClusterTable varchar2, sourceClusterTable varchar2);

  procedure genSemTrajClusterToScenario(outputFile varchar2, clustersTable varchar2, sourceTable varchar2, cluster_id integer);
  --
  procedure generalize(epis_cluster_table varchar2, source_semtrajs_table varchar2, gst_table varchar2, sourceSemTrajClustId number, semTrajClustersTable varchar2);

  function q_measure(smd varchar2) return number;

end Hermoupolis;
/


