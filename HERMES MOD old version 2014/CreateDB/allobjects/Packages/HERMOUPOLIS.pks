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
  
  procedure raw2semtrajs(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer);
  procedure raw2semtrajs2avoidbug(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer);

end Hermoupolis;
/


