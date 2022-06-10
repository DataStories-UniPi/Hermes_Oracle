Prompt Package STATISTICS;
CREATE OR REPLACE package Statistics is

  -- Author  : STYLIANOS
  -- Created : 12/26/2011 10:20:36 AM
  -- Purpose : Execute statistical procedures and fuctions on trajectories

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;

  procedure AttributeValuesCalculation(table_name in varchar2, selectedAttributes in number);
  procedure xydatafromattributesvalues(table_name in varchar2, xattr in number, yattr in number);
  procedure gathertimestatistics;
  function timepoint2timestamp(timepoint tau_tll.d_timepoint_sec) return timestamp;
  function timestamp2timepoint(intimepoint timestamp) return tau_tll.d_timepoint_sec;
  function to_timepoint(gpstimer timestamp) return tau_tll.d_timepoint_sec;
  function timeinterval2seconds(timediff INTERVAL DAY TO SECOND) return number;
  
  procedure createdatasetstats(sourcetable varchar2,for_sub_mpoints integer:=0);
  procedure createviewsubs2mpoints(sourcetable varchar2, viewname varchar2);
  procedure dropviewsubs2mpoints(viewname varchar2);
  function createdimensiontables(sourcetable varchar2) return varchar2;
  procedure filldimensiontables(sourcetable varchar2, outtable varchar2, headingbins number_set);
  procedure dropdatasetstats(outtable varchar2);

end Statistics;
/


