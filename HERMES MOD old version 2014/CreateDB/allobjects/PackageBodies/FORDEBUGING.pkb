Prompt Package Body FORDEBUGING;
CREATE OR REPLACE package body        fordebuging is
/*
  -- Private type declarations
  type <TypeName> is <Datatype>;

  -- Private constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  <VariableName> <Datatype>;

  -- Function and procedure implementations
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;*/
  
  
  
procedure tbtreestructure_export is
l_line VARCHAR2(255);
l_done NUMBER;
l_file utl_file.file_type;
type nodeStackType is varray(156) of integer;--sider DFS maybe change to queue BFS
nodeStack nodeStackType;--sider
top integer;--sider
tmpnode tbtreenode;
tmplnode tbtreeleaf;
openbranches integer :=0;
begin
  --first execute directory if dropped
--create or replace directory temp_dir as 'C:\temp';

  l_file := utl_file.fopen('TEMP_DIR', 'debug_tbtree_after.xml', 'W');
  l_line := '<tree>
 <declarations>
   <attributeDecl name="name" type="String"/>
   <attributeDecl name="traj" type="String"/>
   <attributeDecl name="entries" type="String"/>
 </declarations>';
  utl_file.put_line(l_file, l_line);
  top:=1;
  nodeStack := nodeStackType(-1);--sider -1 means close bracket
  top := top + 1;
  nodeStack.extend(1);
  nodeStack(top) := 0;--root
  while not top=0 loop
    if nodeStack(top) = -1 then
      l_line := '</branch>';
      utl_file.put_line(l_file, l_line);
      top := top -1;
    else
      select tb.node into tmpnode
        from tbtreeidx_clone_non_leaf tb where tb.r=nodeStack(top);
      top := top -1;
      l_line := '<branch>
         <attribute name="name" value="node '||tmpnode.ptrCurrentNode||'"/>';
      utl_file.put_line(l_file, l_line);
      --openbranches := openbranches + 1;
      if tmpnode.tbTreeNodeEntries(1).ptr>=10000 then--leaf
        for i in 1..tmpnode.counter loop
          select tb.node into tmplnode
            from tbtreeidx_clone_leaf tb where tb.r = tmpnode.tbTreeNodeEntries(i).ptr;
          l_line := '<leaf>
            <attribute name="name" value="leaf '||tmplnode.ptrCurrentNode||'"/>
            <attribute name="traj" value="traj '||tmplnode.MoID||'"/>
            <attribute name="entries" value="segs '||tmplnode.counter||'"/>
            </leaf>';
          utl_file.put_line(l_file, l_line);
        end loop;
      else--node
        for j in 1..tmpnode.counter loop
          if top = 1 then
            top := top + 1;
			      nodeStack(top) := -1;
            top := top + 1;
            nodeStack.extend(1);
            nodeStack(top) := tmpnode.tbtreenodeentries(j).ptr;
			    else
            top := top + 1;
            nodeStack.extend(1);
            nodeStack(top) := -1;
            top := top + 1;
            nodeStack.extend(1);
			      nodeStack(top) := tmpnode.tbtreenodeentries(j).ptr;
		      end if;
        end loop;
      end if;
     end if;
  end loop;
  l_line := '</tree>';
  utl_file.put_line(l_file, l_line);
  utl_file.fflush(l_file);
  utl_file.fclose(l_file);
end tbtreestructure_export;

procedure sem_tbtreestructure_export(non_leaves varchar2, leaves varchar2) is
l_line VARCHAR2(255);
l_done NUMBER;
l_file utl_file.file_type;
type nodeStackType is varray(156) of integer;--sider DFS maybe change to queue BFS
nodeStack nodeStackType;--sider
top integer;--sider
tmpnode sem_stbnode;
tmpleaf sem_stbleaf;
openbranches integer :=0;
begin
  --first execute directory if dropped
--create or replace directory temp_dir as 'C:\temp';

  l_file := utl_file.fopen('TEMP_DIR', 'debug_sem_tbtree_atiiki.xml', 'W');
  l_line := '<tree>
 <declarations>
   <attributeDecl name="name" type="String"/>
   <attributeDecl name="traj" type="String"/>
   <attributeDecl name="entries" type="String"/>
 </declarations>';
  utl_file.put_line(l_file, l_line);
  top:=1;
  nodeStack := nodeStackType(-1);--sider -1 means close bracket
  top := top + 1;
  nodeStack.extend(1);
  nodeStack(top) := 0;--root
  while not top=0 loop
    if nodeStack(top) = -1 then
      l_line := '</branch>';
      utl_file.put_line(l_file, l_line);
      top := top -1;
    else
      execute immediate 'begin select tb.node into :tmpnode
        from '||non_leaves||' tb where tb.nid=:top;end;'
        using out tmpnode, in nodeStack(top);
      top := top -1;
      l_line := '<branch>
         <attribute name="name" value="node '||tmpnode.ptrCurrent||'"/>';
      utl_file.put_line(l_file, l_line);
      --openbranches := openbranches + 1;
      if tmpnode.nodeEntries(1).ptrTo>=10000 then--leaf
        for i in 1..tmpnode.numOfEntries loop
          execute immediate 'begin select tb.leaf into :tmpleaf
            from '||leaves||' tb where tb.lid = :ptrTo;end;'
            using out tmpleaf, in tmpnode.nodeEntries(i).ptrTo;            
            
          l_line := '<leaf>
            <attribute name="name" value="leaf '||tmpleaf.ptrCurrent||'"/>
            <attribute name="traj" value="traj '||tmpleaf.id.o_id||','||tmpleaf.id.semtraj_id||'"/>
            <attribute name="entries" value="episodes '||tmpleaf.numOfEntries||'"/>
            </leaf>';
          utl_file.put_line(l_file, l_line);
        end loop;
      else--node
        for j in 1..tmpnode.numOfEntries loop
          if top = 1 then
            top := top + 1;
                  nodeStack(top) := -1;
            top := top + 1;
            nodeStack.extend(1);
            nodeStack(top) := tmpnode.nodeentries(j).ptrTo;
                else
            top := top + 1;
            nodeStack.extend(1);
            nodeStack(top) := -1;
            top := top + 1;
            nodeStack.extend(1);
                  nodeStack(top) := tmpnode.nodeentries(j).ptrTo;
              end if;
        end loop;
      end if;
     end if;
  end loop;
  l_line := '</tree>';
  utl_file.put_line(l_file, l_line);
  utl_file.fflush(l_file);
  utl_file.fclose(l_file);
end sem_tbtreestructure_export;


function findMBBforSomeTrajsSeries(fromTraj integer, toTraj integer) return tbMBB
  is
  trajs mp_array;
  miny number := 1000000000000000000;
  maxy number := 0;
  minx number := 1000000000000000000;
  maxx number := 0;
  mint number := 1000000000000000000;
  maxt number := 0;
  tmpMBB tbMBB;
  pos1 number;
  i number;
  trajid number;
  begin
    execute immediate 'select m.mpoint from mpoints m where m.traj_id between '||fromTraj||
            ' and '||toTraj bulk collect into trajs;
    pos1 := trajs.first;
    while pos1 is not null loop
      trajid := trajs(pos1).traj_id;--first mpoint
      i := trajs(pos1).u_tab.first;--first segment
      while i is not null loop
        minx := tbfunctions.tbmin(minx, trajs(pos1).u_tab(i).m.xe);
        minx := tbfunctions.tbmin(minx, trajs(pos1).u_tab(i).m.xi);
        miny := tbfunctions.tbmin(miny, trajs(pos1).u_tab(i).m.ye);
        miny := tbfunctions.tbmin(miny, trajs(pos1).u_tab(i).m.yi);
        mint := tbfunctions.tbmin(mint, tau_tll.D_timepoint_Sec_package.get_abs_date(trajs(pos1).u_tab(i).p.b.m_y,
          trajs(pos1).u_tab(i).p.b.m_m, trajs(pos1).u_tab(i).p.b.m_d, trajs(pos1).u_tab(i).p.b.m_h,
          trajs(pos1).u_tab(i).p.b.m_min, trajs(pos1).u_tab(i).p.b.m_sec));
        maxx := tbfunctions.tbmax(maxx, trajs(pos1).u_tab(i).m.xe);
        maxx := tbfunctions.tbmax(maxx, trajs(pos1).u_tab(i).m.xi);
        maxy := tbfunctions.tbmax(maxy, trajs(pos1).u_tab(i).m.ye);
        maxy := tbfunctions.tbmax(maxy, trajs(pos1).u_tab(i).m.yi);
        maxt := tbfunctions.tbmax(maxt, tau_tll.D_timepoint_Sec_package.get_abs_date(trajs(pos1).u_tab(i).p.e.m_y,
          trajs(pos1).u_tab(i).p.e.m_m, trajs(pos1).u_tab(i).p.e.m_d, trajs(pos1).u_tab(i).p.e.m_h,
          trajs(pos1).u_tab(i).p.e.m_min, trajs(pos1).u_tab(i).p.e.m_sec));
        i :=  trajs(pos1).u_tab.next(i);--next segment
      end loop;
      pos1 := trajs.next(pos1);--next mpoint
    end loop;
    tmpMBB := tbMBB(tbPoint(tbx(minx, miny, mint)), tbPoint(tbx(maxx, maxy, maxt)) );
    return tmpMBB;
  end findMBBforSomeTrajsSeries;

  procedure tbtreesimulation is
min_x number := 1506003.15939003;--1503924.26966666;
min_y number := 5040368.80894550;--5024061.12590634;
max_x number := 1506114.2597310;--1521949.4735669;
max_y number := 5040499.57777103;--5045215.97055078;
min_t timestamp(0):=to_timestamp('2008-4-6 09:37:00','yyyy-mm-dd hh24:mi:ss');--sysdate;
max_t timestamp(0):=to_timestamp('2008-4-6 14:54:59','yyyy-mm-dd hh24:mi:ss');--sysdate;
tmp_timestampb timestamp(0);
tmp_timestampe timestamp(0);
tmp_utab moving_point_tab;
i number;
begin
  delete dataforstatisticgraphs;
  for c_mpoint in(
    select m.mpoint, m.traj_id
    from mpoints m)
    loop
        select mi.mpoint.u_tab into tmp_utab
        from mpoints mi
        where mi.traj_id = c_mpoint.mpoint.traj_id;
        for utabrow in tmp_utab.first..tmp_utab.last
          loop
            tmp_timestampb := to_timestamp(tmp_utab(utabrow).p.b.m_y||'-'||tmp_utab(utabrow).p.b.m_m||'-'||
               tmp_utab(utabrow).p.b.m_d||' '||tmp_utab(utabrow).p.b.m_h||':'||tmp_utab(utabrow).p.b.m_min||':'||
               tmp_utab(utabrow).p.b.m_sec,'yyyy-mm-dd hh24:mi:ss');
            tmp_timestampe := to_timestamp(tmp_utab(utabrow).p.e.m_y||'-'||tmp_utab(utabrow).p.e.m_m||'-'||
               tmp_utab(utabrow).p.e.m_d||' '||tmp_utab(utabrow).p.e.m_h||':'||tmp_utab(utabrow).p.e.m_min||':'||
               tmp_utab(utabrow).p.e.m_sec,'yyyy-mm-dd hh24:mi:ss');

            if max_t >= tmp_timestampb  then
              if max_t >= tmp_timestampe then
                if min_t <= tmp_timestampb then
                  if min_t <= tmp_timestampe then--time
                    if min_x <= tmp_utab(utabrow).m.xi then
                      if min_x <= tmp_utab(utabrow).m.xe then
                        if min_y <= tmp_utab(utabrow).m.yi then
                          if min_y <= tmp_utab(utabrow).m.ye then
                            if max_x >= tmp_utab(utabrow).m.xi then
                              if max_x >= tmp_utab(utabrow).m.xe then
                                if max_y >= tmp_utab(utabrow).m.yi then
                                  if max_y >= tmp_utab(utabrow).m.ye then--space
                                    --dbms_output.put_line('segment:'||utabrow||' of traj_id:'||c_mpoint.traj_id);
                                    insert into dataforstatisticgraphs values(0,utabrow,c_mpoint.traj_id,
                                           0,0,0,tmp_timestampb,0);
                                  end if;end if;end if;end if;end if;end if;
                                  end if;end if;end if;end if;end if;end if;
          end loop;
    end loop;
    commit;
    --dbms_output.put_line(max_tb);
    --dbms_output.put_line(max_te);-
end tbtreesimulation;



begin
  -- Initialization
  null;
end fordebuging;
/


