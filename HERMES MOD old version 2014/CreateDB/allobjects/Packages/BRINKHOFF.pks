Prompt Package BRINKHOFF;
CREATE OR REPLACE package brinkhoff is

  -- Author  : STYLIANOS
  -- Created : 25/3/2013 16:34:57
  -- Purpose : 
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  procedure brinkhoff_proc(resolution pls_integer, minx double precision,maxy double precision,
    dx double precision, dy double precision, srid pls_integer);
  procedure brinkhoff_nodes(resolution pls_integer, minx double precision,maxy double precision,
    dx double precision, dy double precision);
  procedure nnode_ofpoi(tblnodes varchar2, tblpois varchar2);
  procedure output_propsfile(infilename varchar2,sem_trajs varchar2,poitable varchar2,nodestable varchar2);
  
  procedure brinkhoff2semtrajs(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer);
  procedure brinkhoff2semtrajs2avoidbug(brink_output varchar2,sem_trajs_out varchar2,sub_mpoints_out varchar2,srid integer);

end brinkhoff;
/


