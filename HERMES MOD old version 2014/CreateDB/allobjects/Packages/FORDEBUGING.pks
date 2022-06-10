Prompt Package FORDEBUGING;
CREATE OR REPLACE package        fordebuging is
/*
  -- Author  : STYLIANOS
  -- Created : 3/8/2012 4:01:10 PM
  -- Purpose : Procedures or function helping debug others

  -- Public type declarations
  type <TypeName> is <Datatype>;

  -- Public constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  <VariableName> <Datatype>;

  -- Public function and procedure declarations
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  */


  
  procedure tbtreestructure_export;
  procedure sem_tbtreestructure_export(non_leaves varchar2, leaves varchar2);
  function findMBBforSomeTrajsSeries(fromTraj integer, toTraj integer) return tbMBB;
  procedure tbtreesimulation;
  
  PROCEDURE to_tsampling_centra( filename  VARCHAR2, mpoints mp_array)
  AS
    language java NAME 'ToTSampling.writeFile(java.lang.String, oracle.sql.ARRAY)';
    
  PROCEDURE to_traclus( filename  VARCHAR2, mpoints mp_array)
  AS
    language java NAME 'ToTraclus.writeFile(java.lang.String, oracle.sql.ARRAY)';
    
  PROCEDURE to_tpatterns( filename  VARCHAR2, mpoints mp_array)
  AS
    language java NAME 'ToTPatterns.writeFile(java.lang.String, oracle.sql.ARRAY)';
    
  PROCEDURE TOMYTOPTICS( filename  VARCHAR2, mpoints mp_array)
  AS
    language java NAME 'ToMyToptics.writeFile(java.lang.String, oracle.sql.ARRAY)';
    
  PROCEDURE TOMYTOPTICSSEM( filename  VARCHAR2, semmpoints sem_trajectory_tab)
  AS
    language java NAME 'ToMyTopticsSem.writeFile(java.lang.String, oracle.sql.ARRAY)';

end fordebuging;
/


