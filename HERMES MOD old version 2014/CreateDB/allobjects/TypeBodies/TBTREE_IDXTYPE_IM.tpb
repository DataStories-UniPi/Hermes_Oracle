Prompt Type Body TBTREE_IDXTYPE_IM;
CREATE OR REPLACE TYPE BODY tbTree_idxtype_im
IS
/**************************************************************************************/
/*The ODCIGetInterfaces function returns the list of names of the interfaces
implemented by the type. To specify the current version of these interfaces, the
ODCIGetInterfaces routine must return'SYS.ODCIINDEX2' in the OUT
parameter.*/
/**************************************************************************************/
STATIC FUNCTION ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList)
RETURN NUMBER IS

BEGIN
ifclist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
return ODCIConst.Success;
END ODCIGetInterfaces;

/*********************************************************************************************/
/*The ODCIIndexCreate function creates the table to store index data. If the base table
containing data to be indexed is not empty, this method inserts the index data entries
for existing data.
The function takes the index information as an object parameter whose type is
SYS.ODCIINDEXINFO. The type attributes include the index name, owner name, and
so forth. The PARAMETERS string specified in the CREATE INDEX statement is also
passed in as a parameter to the function*/
/**********************************************************************************************/
STATIC FUNCTION ODCIIndexCreate (ia sys.ODCIIndexInfo, parms VARCHAR2,env sys.ODCIEnv)
RETURN NUMBER IS
i INTEGER;
p NUMBER;
v NUMBER;
--type MovingObjects IS TABLE OF tbMovingObject INDEX BY PLS_INTEGER;
stmt1 VARCHAR2(1000);
stmt2 VARCHAR2(1000);
stmt3 varchar2(1000);
stmt4 varchar2(1000);
stmt5 varchar2(1000);
cnum1 INTEGER;
cnum2 INTEGER;
cnum3 INTEGER;
junk1 NUMBER;
junk2 NUMBER;
junk3 NUMBER;

BEGIN

--dbms_output.put_line(parms);
--storing the name of the tables
stmt4:=ia.IndexSchema || '.' || ia.IndexName ||'_NON_LEAF';
stmt5:=ia.IndexSchema || '.' || ia.IndexName ||'_LEAF';
-- The SQL statement to create the table which stores internal nodes of the tree.
stmt1 := 'CREATE TABLE ' || ia.IndexSchema || '.' || ia.IndexName ||
'_Non_Leaf' || '( r integer, node TBTREENODE )';
-- Dump the SQL statement.
dbms_output.put_line('ODCIIndexCreate>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexCreate>>>>>'||stmt1);
-- Execute the statement.
cnum1 := dbms_sql.open_cursor;
dbms_sql.parse(cnum1, stmt1, dbms_sql.native);
junk1 := dbms_sql.execute(cnum1);
dbms_sql.close_cursor(cnum1);
/*
-- The SQL statement to create an index on the node id of the tbtreenode table
stmt1 := 'CREATE Unique INDEX NONLEAFIDX ON '|| ia.IndexSchema || '.' || ia.IndexName ||
'_Non_Leaf (  R ASC  )  ONLINE';
-- Dump the SQL statement.
dbms_output.put_line('ODCIIndexCreate>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexCreate>>>>>'||stmt1);
-- Execute the statement.
cnum1 := dbms_sql.open_cursor;
dbms_sql.parse(cnum1, stmt1, dbms_sql.native);
junk1 := dbms_sql.execute(cnum1);
dbms_sql.close_cursor(cnum1);*/



-- The SQL statement to create the table which stores leaf nodes of the tree.
stmt2 := 'CREATE TABLE ' || ia.IndexSchema || '.' || ia.IndexName ||
'_Leaf' || '( r integer,ROID varchar2(20), node TBTREELEAF )';
-- Dump the SQL statement.
dbms_output.put_line('ODCIIndexCreate>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexCreate>>>>>'||stmt2);
-- Execute the statement.
cnum2 := dbms_sql.open_cursor;
dbms_sql.parse(cnum2, stmt2, dbms_sql.native);
junk2 := dbms_sql.execute(cnum2);
dbms_sql.close_cursor(cnum2);

/*
-- The SQL statement to create an index on the node id of the tbtreenode table
stmt1 := 'CREATE Unique INDEX LEAFIDX ON '|| ia.IndexSchema || '.' || ia.IndexName ||
'_Leaf (  R ASC  )  ONLINE';
-- Dump the SQL statement.
dbms_output.put_line('ODCIIndexCreate>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexCreate>>>>>'||stmt1);
-- Execute the statement.
cnum1 := dbms_sql.open_cursor;
dbms_sql.parse(cnum1, stmt1, dbms_sql.native);
junk1 := dbms_sql.execute(cnum1);
dbms_sql.close_cursor(cnum1);*/



--CURSOR c IS SELECT ROWIDTOCHAR(ROWID) R,traj_id,mpoint
/*'TrajID:=item.traj_id; '||
'ROID:=item.R; '||
'MV:=item.mpoint;*/
/**********************************************************************************/
/*After having created the tables we populate the table*/
/*********************************************************************************/--stmt3:=
execute immediate 'DECLARE  '||
'TrajID INTEGER; metrates integer_nt;'||
'I integer; '||
'MV moving_point; '||
'UMV unit_moving_point; '||
'UF unit_function; '||
'ROID varchar2(20); '||
't tau_tll.d_period_sec; '||
'tbPoint1 tbPoint; '||
'tbPoint2 tbPoint; '||
'x tbX; '||
'BEGIN '||
' select '||parms||' bulk collect into metrates FROM '|| ia.IndexCols(1).TableSchema || '.' ||
ia.IndexCols(1).TableName||';'||
'FOR k IN metrates.first..metrates.last '||
'LOOP select ROWIDTOCHAR(ROWID) R,'||parms||','||ia.IndexCols(1).ColName||' into ROID,TrajID,MV from '|| ia.IndexCols(1).TableSchema || '.' ||
ia.IndexCols(1).TableName||' where '||parms||'=metrates(k);'||
' if MV.u_tab.count>0 then '||
'for i in mv.u_tab.first..mv.u_tab.last '||
'loop '||
'umv:=mv.u_tab(i);'||
'uf:=umv.m;'||
't:=umv.p;'||
'tbpoint1:=tbPoint(tbX(uf.xi,uf.yi,tau_tll.D_timepoint_Sec_package.get_abs_date(t.b.m_y,t.b.m_m,t.b.m_d,t.b.m_h,t.b.m_min,t.b.m_sec)));'||
'tbPoint2:=tbPoint(tbX(uf.xe,uf.ye,tau_tll.D_timepoint_Sec_package.get_abs_date(t.e.m_y,t.e.m_m,t.e.m_d,t.e.m_h,t.e.m_min,t.e.m_sec)));'||
'tbfunctions.tbinsert(tbpoint1,tbPoint2,TrajID,ROID,'''||stmt5||''','''||stmt4||''');'||
'end loop;commit;end if;'||
'END LOOP;'||
'END;';

-- Execute the statement.
/*cnum3 := dbms_sql.open_cursor;
dbms_sql.parse(cnum3, stmt3, dbms_sql.native);
junk3 := dbms_sql.execute(cnum3);
dbms_sql.close_cursor(cnum3);*/

RETURN ODCICONST.SUCCESS;
END ODCIIndexCreate;

/*****************************************************************************************/
/*The ODCIIndexDrop function drops the table that stores the index data. This method
is called when a DROP INDEX statement is issued.*/
/*****************************************************************************************/
STATIC FUNCTION ODCIIndexDrop(ia sys.ODCIIndexInfo, env sys.ODCIEnv)
RETURN NUMBER IS
stmt1 VARCHAR2(1000);
stmt2 VARCHAR2(1000);
cnum1 INTEGER;
cnum2 INTEGER;
junk1 INTEGER;
junk2 INTEGER;
BEGIN
-- Construct the SQL statement to drop the table which holds non leaf nodes.
stmt1 := 'drop table ' || ia.indexschema || '.' || ia.indexname||'_NON_LEAF';
dbms_output.put_line('ODCIIndexDrop>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexDrop>>>>>'||stmt1);
-- Execute the statement.
cnum1 := dbms_sql.open_cursor;
dbms_sql.parse(cnum1, stmt1, dbms_sql.native);
junk1 := dbms_sql.execute(cnum1);
dbms_sql.close_cursor(cnum1);
-- Construct the SQL statement to drop the table which holds leaf nodes.
stmt2 := 'drop table ' || ia.IndexSchema || '.' || ia.IndexName||'_Leaf';
dbms_output.put_line('ODCIIndexDrop>>>>>');
sys.ODCIIndexInfoDump(ia);
dbms_output.put_line('ODCIIndexDrop>>>>>'||stmt2);
-- Execute the statement.
cnum2 := dbms_sql.open_cursor;
dbms_sql.parse(cnum2, stmt2, dbms_sql.native);
junk2 := dbms_sql.execute(cnum2);
dbms_sql.close_cursor(cnum2);
/*
DO NOT USED HARD CODED TABLES TO BE ABLE TO BUILD MULTIPLE
TBTREEs IN THE SAME SCHEMA--STYLIANOS 27/2/2013
execute immediate 'delete from movingobjects';COMMIT WORK;
--to ypsos tou dentrou apo8hkeyetai me kwdiko -1 ston moving objects
insert into movingobjects values(-1,1);
insert into movingobjects values(-2,0);
insert into movingobjects values(-3,0);
--insert into movingobjects values(-1,1);
*/
RETURN ODCICONST.SUCCESS;
END ODCIIndexDrop;



STATIC FUNCTION ODCIIndexInsert(ia sys.ODCIIndexInfo,rid varchar2,newval moving_point,env sys.ODCIEnv)RETURN NUMBER is
--cid INTEGER;
i BINARY_INTEGER;
--nrows INTEGER;
stmt4 VARCHAR2(300);
stmt5 VARCHAR2(300);
TRAJ_ID INTEGER;
ROID varchar(20);
BEGIN
sys.ODCIIndexInfoDump(ia);
--storing the name of the tables
stmt4:=ia.IndexSchema || '.' || ia.IndexName ||'_NON_LEAF';
stmt5:=ia.IndexSchema || '.' || ia.IndexName ||'_LEAF';
ROID:=rid;
Execute Immediate 'DECLARE '||
'I integer; counter integer;'||
'MV moving_point; '||
'UMV unit_moving_point; '||
'UF unit_function; '||
't tau_tll.d_period_sec; '||
'tbPoint1 tbPoint; '||
'tbPoint2 tbPoint; '||
'x tbX; '||
'BEGIN '||
'MV:=:newvalmpoint; counter:= mv.u_tab.count; if counter>0 then '||
'for i in 1..counter '||
'loop '||
'umv:=mv.u_tab(i);'||
'uf:=umv.m;'||
't:=umv.p;'||
'tbpoint1:=tbPoint(tbX(uf.xi,uf.yi,tau_tll.D_timepoint_Sec_package.get_abs_date(t.b.m_y,t.b.m_m,t.b.m_d,t.b.m_h,t.b.m_min,t.b.m_sec)));'||
'tbPoint2:=tbPoint(tbX(uf.xe,uf.ye,tau_tll.D_timepoint_Sec_package.get_abs_date(t.e.m_y,t.e.m_m,t.e.m_d,t.e.m_h,t.e.m_min,t.e.m_sec)));'||
'tbfunctions.tbinsert(tbpoint1,tbPoint2,:traj_id,:ROID,'''||stmt5||''','''||stmt4||''');'||
'end loop;end if;'||
'END;'using in newval,newval.traj_id,ROID;

RETURN ODCICONST.SUCCESS;
END ODCIIndexInsert;

--updates are permitted in an append-only fashion
STATIC FUNCTION ODCIIndexUpdate(ia sys.ODCIIndexInfo, rid VARCHAR2,
oldval moving_point, newval moving_point, env sys.ODCIEnv)
RETURN NUMBER AS
oldval_size integer;--the old size of the u_tab
newval_size integer;--the new size of the u_tab
ptr integer;--a pointer refering to the starting point of the appended unit_moving_points
stmt4 VARCHAR2(300);
stmt5 VARCHAR2(300);
ROID varchar(20);
BEGIN
ROID:=rid;
--storing the name of the tables
stmt4:=ia.IndexSchema || '.' || ia.IndexName ||'_NON_LEAF';
stmt5:=ia.IndexSchema || '.' || ia.IndexName ||'_LEAF';
oldval_size:=oldval.u_tab.count;
newval_size:=newval.u_tab.count;
ptr:=newval_size-oldval_size;
--if the newval's size is greater
if ptr>0 then
Execute Immediate 'DECLARE '||
'I integer; '||
'MV moving_point; OMV moving_point;'||
'UMV unit_moving_point; '||
'UF unit_function; '||
't tau_tll.d_period_sec; '||
'tbPoint1 tbPoint; '||
'tbPoint2 tbPoint; '||
'x tbX; '||
'BEGIN '||
'MV:=:newvalmpoint; OMV:=:oldvalmpoint;'||
'for i in omv.u_tab.count..mv.u_tab.count '||
'loop '||
'umv:=mv.u_tab(i);'||
'uf:=umv.m;'||
't:=umv.p;'||
'tbpoint1:=tbPoint(tbX(uf.xi,uf.yi,tau_tll.D_timepoint_Sec_package.get_abs_date(t.b.m_y,t.b.m_m,t.b.m_d,t.b.m_h,t.b.m_min,t.b.m_sec)));'||
'tbPoint2:=tbPoint(tbX(uf.xe,uf.ye,tau_tll.D_timepoint_Sec_package.get_abs_date(t.e.m_y,t.e.m_m,t.e.m_d,t.e.m_h,t.e.m_min,t.e.m_sec)));'||
'tbfunctions.tbinsert(tbpoint1,tbPoint2,:traj_id,:roid,'''||stmt5||''','''||stmt4||''');'||
'end loop;'||
'END;'using in newval,oldval,newval.traj_id,ROID;
else dbms_output.put_line('No unit_moving_point appended');
end if;
RETURN ODCICONST.SUCCESS;
END ODCIIndexUpdate;

STATIC FUNCTION ODCIIndexGetMetadata(ia sys.ODCIIndexInfo, expversion
VARCHAR2, newblock OUT PLS_INTEGER, env sys.ODCIEnv)
RETURN VARCHAR2 IS
BEGIN
-- Let getversion do all the work since it has to maintain state across calls.
RETURN tbTreeMetadata_pkg.getversion (ia.IndexSchema, ia.IndexName, newblock);
EXCEPTION
WHEN OTHERS THEN
RAISE;
END ODCIIndexGetMetaData;

STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,
ia sys.ODCIIndexInfo, op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER, tp tau_tll.d_timepoint_sec, env sys.ODCIEnv)
RETURN NUMBER IS
cnum INTEGER;
rid ROWID;
nrows INTEGER;
stmt VARCHAR2(1000);
leaf tbtreeleaf;
node tbtreenode;
nodeid integer;
--types for descending tbtree
type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
nodestack nodestacktype := nodestacktype(0);--0==>root
top integer:=1;--initial value pointing to element 1 on stack (root)
result integer;
t number;
leafptr integer_nt;
BEGIN
sys.ODCIIndexInfoDump(ia);
sys.ODCIPredInfoDump(op);
t:=tp.get_abs_date;
--nested tables initialization
leafptr:=integer_nt(0);

while not top=0 loop
  stmt:= 'begin select node into :node from '||ia.IndexName||'_non_leaf where r=:r;end;';
  execute immediate stmt
  using out node,in nodestack(top);
  top := top-1;--we took node top from stack
    for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
      if (node.tbtreenodeentries(i).mbb.minpoint.x(3)<=t) and (t<=node.tbtreenodeentries(i).mbb.maxpoint.x(3)) then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr(leafptr.last)<>0 then 
            leafptr.extend(1); 
          end if;
          leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
        else
          --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;
    end loop;
end loop;

--if strt=1 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' where r in (select column_value from table(:leafptr))';
--els
if strt=0 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' minus '||stmt;
elsif (strt<>0) AND (strt<>1) then
raise_application_error(-20101, 'Incorrect predicate for operator');
end if;
dbms_output.put_line('ODCIIndexStart>>>>>' || stmt);
cnum := dbms_sql.open_cursor;
dbms_sql.parse(cnum, stmt, dbms_sql.native);
dbms_sql.bind_variable(cnum,':leafptr',leafptr);
dbms_sql.define_column_rowid(cnum, 1, rid);
nrows := dbms_sql.execute(cnum);
dbms_output.put_line('tbtreeidx used....');
-- Set context as the cursor number.
sctx := tbtree_idxtype_im(cnum);
-- Return success.
RETURN ODCICONST.SUCCESS;
END ODCIIndexStart;

STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,ia sys.ODCIIndexInfo,op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER, geom MDSYS.SDO_geometry, env sys.ODCIEnv) RETURN NUMBER IS
cnum INTEGER;
rid ROWID;
nrows INTEGER;
stmt VARCHAR2(1000);
leaf tbtreeleaf;
node tbtreenode;
nodeid integer;
--types for descending tbtree
type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
nodestack nodestacktype := nodestacktype(0);--0==>root
top integer:=1;--initial value pointing to element 1 on stack (root)
result integer;
t number;
rectangle sdo_geometry;
leafptr integer_nt;
tolerance NUMBER:= 0.1;
BEGIN
--nested tables initialization
leafptr:=integer_nt(0);

while not top=0 loop
  stmt:= 'begin select node into :node from '||ia.IndexName||'_non_leaf where r=:r;end;';
  execute immediate stmt
  using out node,in nodestack(top);
  top := top-1;--we took node top from stack
    for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
      rectangle:=sdo_geometry(2003,
                              geom.sdo_srid,
                              NULL,
                              SDO_ELEM_INFO_ARRAY(1,1003,3),
                              SDO_ORDINATE_ARRAY(node.tbtreenodeentries(i).MBB.MinPoint.x(1),
                              node.tbtreenodeentries(i).MBB.MinPoint.x(2),
                              node.tbtreenodeentries(i).MBB.MaxPoint.x(1),
                              node.tbtreenodeentries(i).MBB.MaxPoint.x(2))
                              );
      if mdsys.sdo_geom.sdo_intersection (geom, rectangle, tolerance) is not null then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr(leafptr.last)<>0 then 
            leafptr.extend(1); 
          end if;
          leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
        else
         --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;
    end loop;
end loop;

--if strt=1 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' where r in (select column_value from table(:leafptr))';
if strt=0 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' minus '||stmt;
elsif (strt<>0) AND (strt<>1) then
raise_application_error(-20101, 'Incorrect predicate for operator');
end if;
dbms_output.put_line('ODCIIndexStart>>>>>' || stmt);
cnum := dbms_sql.open_cursor;
dbms_sql.parse(cnum, stmt, dbms_sql.native);
dbms_sql.bind_variable(cnum,':leafptr',leafptr);
dbms_sql.define_column_rowid(cnum, 1, rid);
nrows := dbms_sql.execute(cnum);
-- Set context as the cursor number.
sctx := tbtree_idxtype_im(cnum);

-- Return success.
RETURN ODCICONST.SUCCESS;
END ODCIIndexStart;

STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,ia sys.ODCIIndexInfo,op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,tp tau_tll.D_Period_Sec, env sys.ODCIEnv)
RETURN NUMBER is
cnum INTEGER;
rid ROWID;
nrows INTEGER;
stmt VARCHAR2(1000);
leaf tbtreeleaf;
node tbtreenode;
nodeid integer;
--types for descending tbtree
type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
nodestack nodestacktype := nodestacktype(0);--0==>root
top integer:=1;--initial value pointing to element 1 on stack (root)
result integer;
tb number;
te number;
leafptr_b integer_nt;  --pointers to leaf nodes containing the beginning of the timeperiod
leafptr_e integer_nt;  --pointers to leaf nodes containing the end of the timeperiod
moids_b integer_nt;    --actual moids (not pointers) of the moving objects containing the beggining of the given timeperiod
moids_e integer_nt;    --actual moids (not pointers) of the moving objects containing the end of the given timeperiod
rids integer_nt;       --r values used to extract appropriate rowids
ptrs integer_nt;
BEGIN
sys.ODCIIndexInfoDump(ia);
sys.ODCIPredInfoDump(op);
tb:=tp.b.get_abs_date;
te:=tp.e.get_abs_Date;
--nested tables initialization
leafptr_b:=integer_nt(0);
leafptr_e:=integer_nt(0);
moids_b:=integer_nt(0);
moids_e:=integer_nt(0);
rids:=integer_nt(0);

while not top=0 loop
  stmt:= 'begin select node into :node from '||ia.IndexName||'_non_leaf where r=:r;end;';
  execute immediate stmt
  using out node,in nodestack(top);
  top := top-1;--we took node top from stack
    for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
      if ((node.tbtreenodeentries(i).mbb.minpoint.x(3)<=tb) and (tb<=node.tbtreenodeentries(i).mbb.maxpoint.x(3))) then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr_b(leafptr_b.last)<>0 then 
            leafptr_b.extend(1); 
          end if;
          leafptr_b(leafptr_b.last):= node.tbtreenodeentries(i).ptr;
        else
          --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;

      if (node.tbtreenodeentries(i).mbb.minpoint.x(3)<=te) and (te<=node.tbtreenodeentries(i).mbb.maxpoint.x(3)) then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr_e(leafptr_e.last)<>0 then
            leafptr_e.extend(1); 
          end if;
          leafptr_e(leafptr_e.last):= node.tbtreenodeentries(i).ptr;
          --An sto MBB periexetai kai h arxh kai to telos ths periodou o pointer pros ton child node prepei na mpainei mia fora
          --ara elegxw an periexetai kai h arxh ektos apo to telos prokeimenou na mhn ksanabalw ton idio deikth 2 fores kai kanw
          --perittes anakthseis.
        elsif not ((node.tbtreenodeentries(i).mbb.minpoint.x(3)<=tb) and (tb<=node.tbtreenodeentries(i).mbb.maxpoint.x(3))) then
          --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
            top:=top+1;--overwrite root with its child
            nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
            top:=top+1;
            nodeStack.extend(1);
            nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;
    end loop;
end loop;
dbms_output.put_line('tbtree used');

if leafptr_b(leafptr_b.first)<>0 then
--epelekse to Moid twn kombwn pou periexoun thn arxh ths xronikhs periodou
for w in leafptr_b.first..leafptr_b.last loop
    if moids_b.count <>1 then moids_b.extend(1); end if;
    EXECUTE IMMEDIATE 'begin select m.node.MoID into :n from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
                ' m  where r=:rr;end;' using out moids_b(w), in leafptr_b(w);
end loop;
end if;

if leafptr_e(leafptr_e.first)<>0 then
--epelekse to Moid twn kombwn pou periexoun to telos ths xronikhs periodou
for x in leafptr_e.first..leafptr_e.last loop
    if moids_e.count <>1 then moids_e.extend(1); end if;
    EXECUTE IMMEDIATE 'begin select m.node.MoID into :n from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
                ' m  where r=:rr;end;' using out moids_e(x), in leafptr_e(x);
end loop;
end if;

--search the previously formed arrays to find the moids that are included in both categories (those that include the beginning as well as the
--end of the timeperiod). If that condition holds then the moid contains the timeperiod so choose corresponding rowids

for d in leafptr_b.first..leafptr_b.last loop
    for e in leafptr_e.first..leafptr_e.last loop
        if moids_b(d)=moids_e(e) then
            if rids.count<>1 then rids.extend(1); end if;
            rids(rids.last):=leafptr_b(d);
            exit;
        end if;
    end loop;
end loop;

--if strt=1 then
stmt := 'select distinct roid from '||ia.indexschema||'.'||ia.indexname||'_LEAF'||
        ' where r in (select column_value from table(:lp))';
if strt=0 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' minus '||stmt;
elsif (strt<>0) AND (strt<>1) then
raise_application_error(-20101, 'Incorrect predicate for operator');
end if;
dbms_output.put_line('ODCIIndexStart>>>>>' || stmt);
cnum := dbms_sql.open_cursor;
dbms_sql.parse(cnum, stmt, dbms_sql.native);
dbms_sql.bind_variable(cnum,':lp', rids);
dbms_sql.define_column_rowid(cnum, 1, rid);
nrows := dbms_sql.execute(cnum);
-- Set context as the cursor number.
sctx := tbtree_idxtype_im(cnum);
-- Return success.
RETURN ODCICONST.SUCCESS;
END ODCIIndexStart;

STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,ia sys.ODCIIndexInfo,op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,tp tau_tll.D_Temp_Element_Sec, env sys.ODCIEnv)
RETURN NUMBER is
cnum INTEGER;
rid ROWID;
nrows INTEGER;
stmt VARCHAR2(1000);
leaf tbtreeleaf;
node tbtreenode;
nodeid integer;
--types for descending tbtree
type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
nodestack nodestacktype := nodestacktype(0);--0==>root
top integer:=1;--initial value pointing to element 1 on stack (root)
result integer;
tb number;
te number;
Type aptr is table of integer index by pls_integer;
leafptr_b integer_nt;  --pointers to leaf nodes containing the beginning of the timeperiod
leafptr_e integer_nt;  --pointers to leaf nodes containing the end of the timeperiod
moids_b integer_nt;    --actual moids (not pointers) of the moving objects containing the beggining of the given timeperiod
moids_e integer_nt;    --actual moids (not pointers) of the moving objects containing the end of the given timeperiod
moids_b_count aptr;
moids_e_count aptr;
rids integer_nt;       --r values used to extract appropriate rowids
BEGIN
sys.ODCIIndexInfoDump(ia);
sys.ODCIPredInfoDump(op);

--nested tables initialization
leafptr_b:=integer_nt(0);
leafptr_e:=integer_nt(0);
moids_b:=integer_nt(0);
moids_e:=integer_nt(0);
rids:=integer_nt(0);

while not top=0 loop
  stmt:= 'begin select node into :node from '||ia.IndexName||'_non_leaf where r=:r;end;';
  execute immediate stmt
  using out node,in nodestack(top);
  top := top-1;--we took node top from stack
  --Gia ola ta entries tou kombou pou molis anekthses psakse an periexontai arxes kai telh twn periodwn
  --kai topo8ethse tous deiktes analoga
  for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
    for k in tp.te.first..tp.te.last loop
      tb:=tp.te(k).b.get_abs_date;
      te:=tp.te(k).e.get_abs_Date;
      if ((node.tbtreenodeentries(i).mbb.minpoint.x(3)<=tb) and (tb<=node.tbtreenodeentries(i).mbb.maxpoint.x(3))) then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr_b(leafptr_b.last)<>0 then 
            leafptr_b.extend(1); 
          end if;
          leafptr_b(leafptr_b.last):= node.tbtreenodeentries(i).ptr;
        else
          --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;

      if (node.tbtreenodeentries(i).mbb.minpoint.x(3)<=te) and (te<=node.tbtreenodeentries(i).mbb.maxpoint.x(3)) then
        if (node.tbtreenodeentries(i).ptr>=10000) then
          if leafptr_e(leafptr_e.last)<>0 then 
            leafptr_e.extend(1); 
          end if;
          leafptr_e(leafptr_e.last):= node.tbtreenodeentries(i).ptr;
          --An sto MBB periexetai kai h arxh kai to telos ths periodou o pointer pros ton child node prepei na mpainei mia fora
          --ara elegxw an periexetai kai h arxh ektos apo to telos prokeimenou na mhn ksanabalw ton idio deikth 2 fores kai kanw
          --perittes anakthseis.
        elsif Not ((node.tbtreenodeentries(i).MBB.MinPoint.x(3)<=tb) AND (tb<=node.tbtreenodeentries(i).MBB.Maxpoint.x(3))) then
          --otherwise place the pointer to the internal node's list
          if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
          else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodestack(top):=node.tbtreenodeentries(i).ptr;
          end if;
        end if;
      end if;
    end loop;
  end loop;
end loop;


--epelekse to Moid twn kombwn pou periexoun thn arxh ths xronikhs periodou
--kai metra ton ari8mo twn emfanisewn ka8e moid
if leafptr_b(leafptr_b.first)<>0 then
for w in leafptr_b.first..leafptr_b.last loop
    if moids_b.count <>1 then moids_b.extend(1); end if;
    EXECUTE IMMEDIATE 'begin select m.node.MoID into :n from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
                ' m  where r=:rr;end;' using out moids_b(w), in leafptr_b(w);
    --bale zeygh moids counts sthn akolou8h domh
    if not moids_b_count.exists(moids_b(w))  then
            moids_b_count(moids_b(w)):=1;
    else moids_b_count(moids_b(w)):=moids_b_count(moids_b(w))+1;
    end if;
end loop;
end if;



--epelekse to Moid twn kombwn pou periexoun to telos ths xronikhs periodou
if leafptr_e(leafptr_e.first)<>0 then
for x in leafptr_e.first..leafptr_e.last loop
    if moids_e.count <>1 then moids_e.extend(1); end if;
    EXECUTE IMMEDIATE 'begin select m.node.MoID into :n from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
                ' m  where r=:rr;end;' using out moids_e(x), in leafptr_e(x);
    --bale zeygh moids counts sthn akolou8h domh
    if not moids_e_count.exists(moids_b(x)) then
            moids_e_count(moids_b(x)):=1;
    else moids_e_count(moids_b(x)):=moids_e_count(moids_b(x))+1;
    end if;

end loop;
end if;

                dbms_output.put_line('la9os1');
--ws edw exw anakthsei ta moids pou periexoun kapoies apo tis arxes twn xronikwn periodwn tou D_Temp_Element_Sec
--kai ta moids pou periexoun kapoia apo ta telh twn xronikwn periodwn tou D_Temp_Element_sec
--Ekeino pou prepei twra na ginei einai na krathsw mono ekeina ta moids pou periexoun oles tis arxes kai ola ta telh twn
--xronikwn periodwn ths D_Temp_Element_Sec. Ara arkei na krathsw ta moids pou stis listes moids_b kai moids_e exoun
--count emfanisewn iso me ton ari8mo twn xronikwn periodwn sto D_temp_Element sec

--krata mono ta pointers se fylla twn opoiwn to moid exei count emfanisewn iso me ton ari8mo
--twn xronikwn periodwn sth D_Temp_Element_Sec parametro
if leafptr_b(leafptr_b.first)<>0 AND leafptr_e(leafptr_e.first)<>0 then
for d in leafptr_b.first..leafptr_b.last loop
    for e in leafptr_e.first..leafptr_e.last loop
        if moids_b(d)=moids_e(e) and moids_b_count(moids_b(d))= tp.te.count and  moids_e_count(moids_b(e))= tp.te.count then
            if rids.count<>1 then rids.extend(1); end if;
                rids(rids.last):=leafptr_b(d);
            exit;
        end if;
    end loop;
end loop;
end if;
                dbms_output.put_line('la9os2');

--if strt=1 then
stmt := 'select distinct roid from '||ia.indexschema||'.'||ia.indexname||'_LEAF'||
        ' where r in (select column_value from table(:lp))';
if strt=0 then
stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' minus '||stmt;
elsif (strt<>0) AND (strt<>1) then
raise_application_error(-20101, 'Incorrect predicate for operator');
end if;
dbms_output.put_line('ODCIIndexStart>>>>>' || stmt);
cnum := dbms_sql.open_cursor;
dbms_sql.parse(cnum, stmt, dbms_sql.native);
dbms_sql.bind_variable(cnum,':lp',rids);
dbms_sql.define_column_rowid(cnum, 1, rid);
nrows := dbms_sql.execute(cnum);
-- Set context as the cursor number.
sctx := tbtree_idxtype_im(cnum);
-- Return success.
RETURN ODCICONST.SUCCESS;
END ODCIIndexStart;



STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,ia sys.ODCIIndexInfo,op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,strt NUMBER, stop NUMBER,
geom MDSYS.SDO_geometry,tp tau_tll.D_period_sec, env sys.ODCIEnv)
RETURN NUMBER is
   node tbtreenode;

  --types for descending tbtree
   type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
   nodestack nodestacktype := nodestacktype(0);--0==>root
   top integer:=1;--initial value pointing to element 1 on stack (root)

   cnum INTEGER;
   stmt VARCHAR2(32767);--this is a limit for our query string
   leafptr integer_nt;
   rectangle MDSYS.SDO_GEOMETRY;
   tolerance number:= 0.01;
   intersection MDSYS.SDO_GEOMETRY;
   tb number;
   te number;
   srid integer;
   templeafid integer;
   nrows INTEGER;
   rid ROWID;
BEGIN

dbms_output.put_line('tbtree used');
    tb:=tp.b.get_abs_date;
    te:=tp.e.get_abs_date;
    leafptr:=integer_nt(0);
    stmt:='begin select p.value into :SRID from parameters p where p.id like ''SRID'' and upper(table_name)=:tab_name;end;';
    execute immediate stmt
      using out srid, in ia.indexcols(1).tablename;
    
    while not top=0 loop
      stmt:= 'begin select node into :node from '||ia.IndexName||'_non_leaf where r=:r;end;';
      execute immediate stmt
      using out node,in nodestack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node
      for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
        --tranform mBB to rectangular geometry so as to use the sdo_intersection function
        rectangle:=sdo_geometry(2003,
                                srid,
                                NULL,
                                SDO_ELEM_INFO_ARRAY(1,1003,3),
        SDO_ORDINATE_ARRAY(node.tbtreenodeentries(i).MBB.MinPoint.x(1),node.tbtreenodeentries(i).MBB.MinPoint.x(2), node.tbtreenodeentries(i).MBB.MaxPoint.x(1),node.tbtreenodeentries(i).MBB.MaxPoint.x(2))
                                );
        --find the intersection of the MBB of the current entry with the given geometry
        intersection:= mdsys.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
        --get the pointers of those MBBs that intersect the geomentry and concurrently contain a part of the time period
        if (NOT (intersection is NULL)) AND
                        (((node.tbtreenodeentries(i).mbb.minpoint.x(3)<=tb)and(node.tbtreenodeentries(i).mbb.maxpoint.x(3)>tb))
                        or((node.tbtreenodeentries(i).MBB.Minpoint.x(3)>tb)and(node.tbtreenodeentries(i).MBB.minpoint.x(3)<te)))  then
          --if the entry's pointer to the child node is >10000 then it points to a leaf so place the pointer in the leafpointers' list
          if (node.tbtreenodeentries(i).ptr>=10000) then
            --sort leaf pointers as you add them
            if leafptr(leafptr.last)=0 then
              leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
              --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));--sider
            else
              if leafptr(leafptr.last)<node.tbtreenodeentries(i).ptr then
                  leafptr.extend(1);
                  leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                  --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));--sider
              elsif  leafptr(leafptr.last)>node.tbtreenodeentries(i).ptr then
                  templeafid:=leafptr(leafptr.last);
                  leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
                  --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));--sider
                  leafptr.extend(1);
                  leafptr(leafptr.last):=templeafid;
              end if;
            end if;
          else
            --otherwise place the pointer to the internal node's list
            if top=0 then--means stack had one element ==> root
                top:=top+1;--overwrite root with its child
                nodeStack(top):=node.tbtreenodeentries(i).ptr;
            else--add child to stack
                top:=top+1;
                nodeStack.extend(1);
                nodestack(top):=node.tbtreenodeentries(i).ptr;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    --if strt=1 then
    stmt := 'select distinct roid from '||ia.indexschema||'.'||ia.indexname||'_LEAF'||
        ' where r in (select column_value from table(:leafptr))';
    if strt=0 then
    stmt := 'select distinct roid from '||ia.IndexSchema||'.'||ia.IndexName||'_LEAF'||
        ' minus '||stmt;
    elsif (strt<>0) AND (strt<>1) then
    raise_application_error(-20101, 'Incorrect predicate for operator');
    end if;
    --dbms_output.put_line('ODCIIndexStart>>>>>' || stmt);
    --dbms_output.put_line('flptr>>>>>' || flptr.count);
    cnum := dbms_sql.open_cursor;
    dbms_sql.parse(cnum, stmt, dbms_sql.native);
    dbms_sql.define_column_rowid(cnum, 1, rid);
    dbms_sql.bind_variable(cnum, ':leafptr', leafptr);
    dbms_output.put_line('stmt_size>>>>>' || length(stmt));
    nrows := dbms_sql.execute(cnum);
    -- Set context as the cursor number.
    sctx := tbtree_idxtype_im(cnum);
    -- Return success.
    RETURN ODCICONST.SUCCESS;
END ODCIIndexStart;

MEMBER FUNCTION ODCIIndexFetch(nrows NUMBER, rids OUT sys.ODCIRidList,
env sys.ODCIEnv)
RETURN NUMBER IS
cnum INTEGER;
idx INTEGER := 1;
rlist sys.ODCIRidList := sys.ODCIRidList();
done boolean := false;
BEGIN
dbms_output.put_line('ODCIIndexFetch>>>>>');
cnum := self.curnum;
WHILE not done LOOP
if idx > nrows then
done := TRUE;
else
rlist.extEND;
if dbms_sql.fetch_rows(cnum) > 0 then
dbms_sql.column_value_rowid(cnum, 1, rlist(idx));
    --dbms_output.put_line('rowid>>>>>'||rlist(idx));
idx := idx + 1;
else
rlist(idx) := null;
done := TRUE;
END if;
END if;
END LOOP;

rids := rlist;
--dbms_output.put_line('rids: '||rids(rids.count));
RETURN ODCICONST.SUCCESS;
END ODCIIndexFetch;

MEMBER FUNCTION ODCIIndexClose (env sys.ODCIEnv) RETURN NUMBER IS
cnum INTEGER;
BEGIN
dbms_output.put_line('ODCIIndexClose>>>>>');
cnum := self.curnum;
dbms_sql.close_cursor(cnum);
RETURN ODCICONST.SUCCESS;
END ODCIIndexClose;

END;
/


