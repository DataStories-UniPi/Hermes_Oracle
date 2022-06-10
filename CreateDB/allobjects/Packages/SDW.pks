Prompt Package SDW;
CREATE OR REPLACE package        SDW is

  -- Author  : STYLIANOS
  -- Created : 9/17/2012 8:41:37 AM
  -- Purpose : 
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  starting_time  TIMESTAMP WITH TIME ZONE;
  ending_time    TIMESTAMP WITH TIME ZONE;
  
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  procedure createSDW(sdwtableprefix varchar2, poitable varchar2, dataset_dims varchar2,
    userstable varchar2, intervalsecs number, srcTable varchar2);
  procedure deleteSDW(sdwTablePrefix varchar2);
  procedure dropsdw(sdwtableprefix varchar2);
  procedure loaddimensions(sdwtableprefix varchar2, poitable varchar2, dataset_dims varchar2,
    userstable varchar2, intervalsecs number, srcTable varchar2);
  procedure updatedistrict(stepx number, stepy number, poitable varchar2);
  procedure loadstopsemsdim(sdwTablePrefix varchar2, poitable varchar2);
  procedure loadtimedim(sdwTablePrefix varchar2, dataset_dims varchar2,
    intervalperiod number);
  procedure loadperiodsdim(sdwTablePrefix varchar2, dataset_dims varchar2,
    intervalperiod number);
  procedure loaduserprofilesdim(sdwtableprefix varchar2, userstable varchar2);
  procedure loadmovesemsdim(sdwTablePrefix varchar2, srcTable varchar2);
  procedure cellstopsload(sdwTablePrefix varchar2,stbtreeprefix varchar2);
  procedure cellstopsload3d(sdwTablePrefix varchar2,treeprefix varchar2);
  procedure cellstopsload_parallel(sdwTablePrefix varchar2,stbtreeprefix varchar2, fstop_sem_id number, tstop_sem_id number);
  procedure cellmovesload(sdwTablePrefix varchar2,stbtreeprefix varchar2);
  procedure cellmovesload3d(sdwTablePrefix varchar2,stbtreeprefix varchar2);
  procedure semtrajstopsload(sdwTablePrefix varchar2,semtrajs varchar2);
  procedure semtrajmovesload(sdwTablePrefix varchar2, semtrajs varchar2);
  procedure textstopsload(sdwTablePrefix varchar2,stbtreeprefix varchar2);
  procedure textstopsload3d(sdwTablePrefix varchar2,treeprefix varchar2);
  procedure textmovesload(sdwTablePrefix varchar2,stbtreeprefix varchar2);
  procedure textmovesload3d(sdwTablePrefix varchar2,stbtreeprefix varchar2);

  procedure updateauxiliarystops(sdwTablePrefix varchar2);
  procedure updateauxiliarymoves(sdwTablePrefix varchar2);
  --aggregations
  function aggrstopscrosst(sdwTablePrefix varchar2,listofpois integer_nt,fromtimeid pls_integer,
    totimeid pls_integer,listofusers integer_nt) return number;
  function aggrstopsnumofsemtrajs(sdwTablePrefix varchar2,listofpois integer_nt,fromtimeid pls_integer,
    totimeid pls_integer,listofusers integer_nt) return number;

end SDW;
/


