Prompt Package TDW;
CREATE OR REPLACE package TDW is

  -- Author  : STYLIANOS
  -- Created : 7/26/2012 12:31:20 AM
  -- Purpose : To provide functions and proccedures to GUI without spoiling already existings
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  TYPE CursorType IS REF CURSOR;
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  procedure createTDW(sourceTablePrefix varchar2);
  PROCEDURE splitspace ( stepX IN number, stepY IN number, sourceTablePrefix varchar2);
  PROCEDURE splittime( secStep IN number, sourceTablePrefix varchar2);
  PROCEDURE feed_tdw_mbr_BulkFeed(sourceTablePrefix varchar2);
  procedure feed_tdw_mbr_sjbulkfeed(sourcetableprefix varchar2);
  PROCEDURE feed_tdw_tbtree_BulkFeed(sourceTablePrefix varchar2, tbtreenodes varchar2, tbtreeleafs varchar2);
  PROCEDURE CalculateAuxiliary_cl;
  PROCEDURE CalculateAuxiliary_cl(sourceTablePrefix varchar2);

end TDW;
/


