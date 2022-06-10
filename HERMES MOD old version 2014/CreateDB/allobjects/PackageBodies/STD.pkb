Prompt Package Body STD;
CREATE OR REPLACE package body        STD is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  procedure create_sem_tbtree(idxname varchar2, source_table varchar2) is

  begin
    create_stbtree_structure(idxname);
    fill_stbtree_structure(idxname, source_table);
    create_stbtree_textindx(idxname);
    fill_stbtree_textindx(idxname);
  end create_sem_tbtree;
  
  procedure create_stbtree_textindx(idxname varchar2) is
    stmt varchar2(5000);
  begin
    stmt:='create table '||idxname||'_tags (tag varchar2(50), nodes sem_stbleafentryids)
 nested table nodes store as '||idxname||'_nodes_ntab';
    execute immediate stmt;
    stmt:='create index '||idxname||'_tag_indx on '||idxname||'_tags (tag)';
    execute immediate stmt;
    /*
    stmt:='create table '||idxname||'_tag_activ_indx (tag varchar2(50), nodes sem_stbleafentryids)
 nested table nodes store as nodes_activ_netsted_table';
    execute immediate stmt;
    stmt:='create index activ_tag_indx on '||idxname||'_tag_activ_indx (tag)';
    execute immediate stmt;
    */
  end create_stbtree_textindx;
  
  procedure fill_stbtree_textindx(idxname varchar2) is
    stmt varchar2(4000);
    leafcur sys_refcursor;
    lid pls_integer;
    exist pls_integer;
    leaf sem_stbleaf;
    dtag varchar2(50);
    etag varchar2(50);
    atag varchar2(50);
  begin
    --for now no def_tag in index are entered
    --get each leaf from stbtree
    stmt := 'select s.lid, s.leaf
            from '||idxname||'_leaf s
            order by s.lid';--just in case
    open leafcur for stmt;
    loop
      fetch leafcur into lid, leaf;
      exit when leafcur%notfound;
      --loop leaf entries=>episodes
      for i in leaf.leafentries.first..leaf.leafentries.last loop
        dtag:=upper(leaf.leafentries(i).def_tag);
        if dtag is null then
          dtag:=upper('nulltag');
        end if;
        etag:=upper(leaf.leafentries(i).epis_tag);
        if etag is null then
          etag:=upper('nulltag');
        end if;
        atag:=upper(leaf.leafEntries(i).activ_tag);
        if atag is null then
          atag:=upper('nulltag');
        end if;
        --check if dtag exist on index
        stmt:='begin select count(*)
               into :exist
               from '||idxname||'_tags t
               where upper(t.tag)=upper(:dtag);end;';
        execute immediate stmt using out exist,in dtag;       
        if exist > 0 then
          --add leafentryid to its nodes
          stmt:='insert into table(
                 select t.nodes
                 from '||idxname||'_tags t
                 where upper(t.tag)=upper(:dtag))
                 values (sem_stbleafentryid(:lid,:entryid))';
          execute immediate stmt using in dtag,lid,i;
          commit;
        else
          --add tag and leafentryid to index
          stmt:='insert into '||idxname||'_tags t
                 values (upper(:dtag),sem_stbleafentryids(
                 sem_stbleafentryid(:lid,:entryid)))';
          execute immediate stmt using in dtag,lid,i;
          commit;
        end if;
        --check if etag exist on index
        stmt:='begin select count(*)
               into :exist
               from '||idxname||'_tags t
               where upper(t.tag)=upper(:etag);end;';
        execute immediate stmt using out exist,in etag;       
        if exist > 0 then
          --add leafentryid to its nodes
          stmt:='insert into table(
                 select t.nodes
                 from '||idxname||'_tags t
                 where upper(t.tag)=upper(:etag))
                 values (sem_stbleafentryid(:lid,:entryid))';
          execute immediate stmt using in etag,lid,i;
          commit;
        else
          --add tag and leafentryid to index
          stmt:='insert into '||idxname||'_tags t
                 values (upper(:etag),sem_stbleafentryids(
                 sem_stbleafentryid(:lid,:entryid)))';
          execute immediate stmt using in etag,lid,i;
          commit;
        end if;    
        --check if atag exist on index
        stmt:='begin select count(*)
               into :exist
               --from '||idxname||'_tag_activ_indx t
               from '||idxname||'_tags t
               where upper(t.tag)=upper(:atag);end;';
        execute immediate stmt using out exist,in atag; 
        if exist > 0 then
          --add leafentryid to its nodes
          stmt:='insert into table(
                 select t.nodes
                 --from '||idxname||'_tag_activ_indx t
                 from '||idxname||'_tags t
                 where upper(t.tag)=upper(:atag))
                 values (sem_stbleafentryid(:lid,:entryid))';
          execute immediate stmt using in atag,lid,i;
          commit;
        else
          --add tag and leafentryid to index
          stmt:='insert into '||idxname||'_tags t
                 --insert into '||idxname||'_tag_activ_indx t
                 values (upper(:atag),sem_stbleafentryids(
                 sem_stbleafentryid(:lid,:entryid)))';
          execute immediate stmt using in atag,lid,i;
          commit;
        end if;
      end loop;
    end loop;
    close leafcur;
  end fill_stbtree_textindx; 


  procedure fill_stbtree_structure(idxname varchar2, source_table varchar2) is
    type strajcurtyp is ref cursor;
    cur_straj strajcurtyp;
    tmpstraj sem_trajectory;
    roid varchar2(32);
    stmt varchar2(4000);
  begin
    --source table is an object table
    stmt := 'select s.rowid, value(s)
            from '||source_table||' s
            where s.rowid not in (select fl.roid from '||idxname||'_leaf fl)
            ';
    open cur_straj for stmt ;
    loop
      fetch cur_straj into roid, tmpstraj;
      exit when cur_straj%notfound;
      if tmpstraj.episodes.count > 0 then
        --episodes are not ordered by oracle as in nested table. Mind that and pass them in order
        for c_epis in (select sem_episode(t.defining_tag,t.episode_tag,t.activity_tag,t.mbb,t.tlink) epis
          from table(tmpstraj.episodes) t order by t.mbb.minpoint.t.m_y,t.mbb.minpoint.t.m_m,t.mbb.minpoint.t.m_d,t.mbb.minpoint.t.m_h,t.mbb.minpoint.t.m_min,t.mbb.minpoint.t.m_sec) loop
        --for i in tmpstraj.episodes.first..tmpstraj.episodes.last loop
          stbinsert(c_epis.epis,sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
          --stbinsert(tmpstraj.episodes(i),sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
                    roid, idxname||'_non_leaf', idxname||'_leaf', 155, 155);
        end loop;
        commit;--per trajectory
      end if;
    end loop;
    close cur_straj;
  end fill_stbtree_structure;

  procedure fill_stbtree_structure_par(idxname varchar2, source_table varchar2, from_id number, to_id number) is
    type strajcurtyp is ref cursor;
    cur_straj strajcurtyp;
    tmpstraj sem_trajectory;
    roid varchar2(32);
    stmt varchar2(4000);
  begin
    --source table is an object table
    stmt := 'select /*+parallel+*/ s.rowid, value(s)
            from '||source_table||' s
            where s.o_id between '||from_id||' and '||to_id||'
            --and s.rowid not in (select fl.roid from '||idxname||'_leaf fl)
            ';
    open cur_straj for stmt ;
    loop
      fetch cur_straj into roid, tmpstraj;
      exit when cur_straj%notfound;
      if tmpstraj.episodes.count > 0 then
        --episodes are not ordered by oracle as in nested table. Mind that and pass them in order
        for c_epis in (select sem_episode(t.defining_tag,t.episode_tag,t.activity_tag,t.mbb,t.tlink) epis
          from table(tmpstraj.episodes) t order by t.mbb.minpoint.t.m_y,t.mbb.minpoint.t.m_m,t.mbb.minpoint.t.m_d,t.mbb.minpoint.t.m_h,t.mbb.minpoint.t.m_min,t.mbb.minpoint.t.m_sec) loop
        --for i in tmpstraj.episodes.first..tmpstraj.episodes.last loop
          stbinsert(c_epis.epis,sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
          --stbinsert(tmpstraj.episodes(i),sem_traj_id(tmpstraj.o_id, tmpstraj.semtraj_id),
                    roid, idxname||'_non_leaf', idxname||'_leaf', 155, 155);
        end loop;
        commit;--per trajectory
      end if;
    end loop;
    close cur_straj;
  end fill_stbtree_structure_par;
  
  procedure stbinsert(episode sem_episode, sem_trajid sem_traj_id, roid varchar2,
    nodetab varchar2, leaftab varchar2,maxleafentries integer:=155, maxnodeentries integer:=155) is
    newleafentry sem_stbleaf_entry;
    stmt varchar2(4000);
    numofnodes integer;
    numofleaves integer;
    newleaf sem_stbleaf := sem_stbleaf(null,null,-1,-1,-1,-1,-1,null);
    newnodeentry sem_stbnode_entry := sem_stbnode_entry(-1, null);
    newernodeentry sem_stbnode_entry := sem_stbnode_entry(-1, null);
    newnode sem_stbnode:=sem_stbnode(-1,-1,-1,null);
    newrootnode sem_stbnode:=sem_stbnode(-1,-1,-1,null);
    oldrootnode sem_stbnode:=sem_stbnode(-1,-1,-1,null);
    --maxleafentries integer;
    newerleaf sem_stbleaf := sem_stbleaf(null,null,-1,-1,-1,-1,-1,null);
  begin
    --maxleafentries := 155;
    --create a new leaf entry for incoming episode
    newleafentry := sem_stbleaf_entry(episode.MBB, episode.defining_tag, episode.episode_tag,
                 episode.activity_tag, episode.tlink);
    --get the number of inner nodes
    stmt := 'begin select count(nid) into :numofnodes from '||nodetab||'; end;';
    execute immediate stmt using out numofnodes;
    if numofnodes = 0 then
      --no root, no tree
      newleaf:= sem_stbleaf(sem_trajid,roid,0,10000,10000,10000,1,sem_stbleaf_entries(newleafentry));
      newnodeentry:= sem_stbnode_entry(10000, newleafentry.mbb);
      newnode:=sem_stbnode(0,0,1,sem_stbnode_entries(newnodeentry));
      saveleaf(newleaf, leaftab, false);
      savenode(newnode, nodetab, false, 0);
      --commit;
      return;
    end if;
    --here means a tree exists so find leaf with sem_trajid
    newleaf:=findleaf(sem_trajid, leaftab);
    if newleaf is not null and newleaf.numOfEntries < maxleafentries then
      newleaf.leafEntries.extend();
      newleaf.numOfEntries := newleaf.numOfEntries + 1;
      newleaf.leafEntries(newleaf.numOfEntries) := newleafentry;
      --newnode:=adjusttree(newleaf, null, nodetab, leaftab);
      newnode:=adjusttree(newleaf, null, nodetab, leaftab, maxnodeentries);
      saveleaf(newleaf, leaftab, true);
    else--newleaf is null or does not have room
      newerleaf:=sem_stbleaf(sem_trajid, roid, -1,-1,-1,-1,1, sem_stbleaf_entries(newleafentry));
      stmt := 'begin select max(lid) into :numofleaves from '||leaftab||'; end;';
      execute immediate stmt using out numofleaves;
      numofleaves:=numofleaves+1;
      newerleaf.ptrCurrent:=numofleaves;
      newerleaf.ptrNext:=newerleaf.ptrCurrent;
      if (newleaf is not null) then--no room
        newerleaf.ptrPrevious:=newleaf.ptrCurrent;
        newleaf.ptrNext:=newerleaf.ptrCurrent;
        saveleaf(newleaf, leaftab, true);
      else --newleaf is null (not found)
        newerleaf.ptrPrevious:=newerleaf.ptrCurrent;
      end if;
      --get the rigth-most leaf of tree (last leaf of tree)
      newleaf:= chooselastleaf(nodetab, leaftab);
      --newnode:=adjusttree(newleaf, newerleaf, nodetab, leaftab);
      newnode:=adjusttree(newleaf, newerleaf, nodetab, leaftab, maxnodeentries);
      if (newnode.ptrCurrent!=-1) then--root is splitted
        stmt := 'begin select count(nid) into :numofnodes from '||nodetab||'; end;';
        execute immediate stmt using out numofnodes;
        numofnodes:=numofnodes+2;--
        newrootnode.ptrCurrent:=0;
        newrootnode.ptrParent:=0;
        execute immediate 'begin select node into :oldrootnode
                from '||nodetab||' where nid=0;end;'
                using out oldrootnode;
        oldrootnode.ptrParent:=0;
        oldrootnode.ptrCurrent:=numofnodes;
        execute immediate 'begin update '||nodetab||'
                l set l.node.ptrparent= :oldroot
                where l.node.ptrparent=0;end;'
                using in oldrootnode.ptrCurrent;
        savenode(oldrootnode, nodetab, true, 0);
        newnodeentry.ptrTo:=oldrootnode.ptrCurrent;
        newnodeentry.mbb:=ncoveringmbb(oldrootnode);
        newernodeentry.ptrTo:=newnode.ptrCurrent;
        newernodeentry.mbb:=ncoveringmbb(newnode);
        newnode.ptrParent:=0;
        savenode(newnode, nodetab, false,0);
        newrootnode:=sem_stbnode(0,0,1,sem_stbnode_entries(newnodeentry));
        newrootnode.nodeEntries.extend(1);
        newrootnode.numOfEntries:=newrootnode.numOfEntries+1;
        newrootnode.nodeEntries(newrootnode.numOfEntries):=newernodeentry;
        savenode(newrootnode, nodetab, false, 0);
        execute immediate 'begin update '||leaftab||'
                l set l.leaf.ptrparent= :oldroot
                where l.leaf.ptrparent=0;end;'
                using in oldrootnode.ptrCurrent;
      end if;
    end if;
    exception
      when others then
        dbms_output.put_line('stbinsert');
  end stbinsert;

  function adjusttree(l sem_stbleaf,ll sem_stbleaf,nodetab varchar2,leaftab varchar2,maxentries integer:=155) return sem_stbnode is
    --ascend from a leaf node l to the root, adjusting covering _
    --rectangles and propagating node splits as necessary. if l was _
    --previously split, ll is the resulted second node
    --maxentries integer;
    cnum integer;
    it integer;
    numofnodes integer;
    n hybrid_node;
    nn hybrid_node;
    p sem_stbnode;
    pp sem_stbnode;
    templeaf sem_stbleaf;
    tempnode sem_stbnode;
    enn sem_stbnode_entry;
    previousmbb sem_mbb;
    stmt varchar2(4000);
    splited boolean :=false;
    added boolean := false;

  begin
    cnum:=0;
    it:=1;

    --maxentries:=155;
    --1st step of the adjusttree algorithm
    --set n=l
    n.isleaf:=1;
    n.id:=l.id;
    n.roid:=l.roid;
    n.ptrparent:=l.ptrparent;
    n.ptrcurrent:=l.ptrcurrent;
    n.ptrnext:=l.ptrnext;
    n.ptrprevious:=l.ptrprevious;
    n.numofentries:=l.numOfEntries;
    n.leafentries:=l.leafEntries;

    stmt := 'begin select count(nid) into :numofnodes from '||nodetab||'; end;';
    execute immediate stmt using out numofnodes;
    if not (ll is null) then
      nn.isleaf:=1;
      nn.id:=ll.id;
      nn.roid:=ll.roid;
      nn.ptrparent:=ll.ptrparent;
      nn.ptrcurrent:=ll.ptrcurrent;
      nn.ptrnext:=ll.ptrnext;
      nn.ptrprevious:=ll.ptrprevious;
      nn.numofentries:=ll.numOfEntries;
      nn.leafentries:=ll.leafEntries;
    else
      nn.isleaf:=-1;
    end if;
    --2nd step of the adjusttree algorithm
    --if n is the root of the tree then stop
    <<overall_loop>>
    loop
      -- let p be the parent node of n
      execute immediate 'begin select node into :p from '||nodetab||' e
              where e.node.ptrcurrent=:nptrparent;end;'
              using out p,in n.ptrparent;
      exit overall_loop when ((n.ptrparent=0)and(n.ptrcurrent=0));
      cnum:=cnum+1;
      /*3rd step of the adjusttree algorithm
      adjust the covering rectangle in the parent entry*/
      for i in 1..p.numOfEntries loop
        if (p.nodeEntries(i).ptrto=n.ptrcurrent) then
            exit;
        end if;
        it:=it+1;
      end loop;
      --store p's covering rectangle in order to compare _
      --it with the covering rectangle resulting after the _
      --following modifications
      previousmbb := ncoveringmbb(p);
      --adjust parent entry for leaf so that tightly encloses all entry rectangles in n
      if n.isleaf=1 then
        templeaf:=sem_stbleaf(n.id,n.roid,n.ptrparent,n.ptrcurrent,n.ptrnext,n.ptrprevious,
                    n.numofentries,n.leafentries);
        p.nodeEntries(it).mbb := lcoveringmbb(templeaf);
      elsif n.isleaf=0 then
        tempnode:=sem_stbnode(n.ptrparent,n.ptrcurrent,n.numofentries,n.nodeentries);
        p.nodeentries(it).mbb := ncoveringmbb(tempnode);
      end if;
      --4th step of the adjusttree algorithm
      --if n has a partner nn from an earlier split
      if (nn.isleaf!=-1)  then
        --adjust covering rectangle so as to cover _
        --the nn 's covering rectangle
        if nn.isleaf=1 then
            templeaf:=sem_stbleaf(nn.id,nn.roid,nn.ptrparent,nn.ptrcurrent,nn.ptrnext,
                       nn.ptrprevious,nn.numofentries,nn.leafentries);
            enn:= sem_stbnode_entry(nn.ptrcurrent,lcoveringmbb(templeaf));
        elsif(nn.isleaf=0) then
          tempnode.ptrparent:=nn.ptrparent;
          tempnode.ptrcurrent:=nn.ptrcurrent;
          tempnode.numOfEntries:=nn.numofentries;
          tempnode.nodeEntries:=nn.nodeentries;
          enn:=sem_stbnode_entry(nn.ptrcurrent,ncoveringmbb(tempnode));
        end if;
        --the pointer of enn points to the node nn (resulted from a split)
        --if there is room in p for another entry
        if (p.numofentries < maxentries) then
          --add the new entry to p
          p.nodeentries.extend(1);
          p.numofentries:=p.numofentries+1;
          p.nodeentries(p.numofentries) := enn;
          nn.ptrparent := p.ptrcurrent;
          added:=true;
        else
          --otherwise create node pp containing enn
          numofnodes:=numofnodes+1;
          pp:=sem_stbnode(-1,numofnodes,1,sem_stbnode_entries(enn));
          --splited is a variable indicating whether a split has occured or not.
          splited := true;
          nn.ptrparent:=pp.ptrcurrent;
        end if;
        --savenode nn
        if nn.isleaf=1 then
          templeaf:=sem_stbleaf(nn.id,nn.roid,nn.ptrparent,nn.ptrcurrent,nn.ptrnext,
                    nn.ptrprevious,nn.numofentries,nn.leafentries);
          saveleaf(templeaf,leaftab,false);
        elsif nn.isleaf=0 then
          tempnode:=sem_stbnode(nn.ptrparent,nn.ptrcurrent,nn.numofentries,nn.nodeentries);
          savenode(tempnode,nodetab,false,0);
        end if;
      end if;
      savenode(p,nodetab,true,p.ptrcurrent);
      --n=p
      n.isleaf:=0;
      n.ptrparent:=p.ptrparent;
      n.ptrcurrent:=p.ptrcurrent;
      n.numofentries:=p.numofentries;
      n.nodeentries:=p.nodeentries;
      --set nn=pp if a split occured
      if splited=true then
        nn.isleaf :=0;
        nn.ptrparent:=pp.ptrparent;
        nn.ptrcurrent:=pp.ptrcurrent;
        nn.numofentries:=pp.numofentries;
        nn.nodeentries:=pp.nodeentries;
      else
        nn.isleaf:=-1;
      end if;
      --if no split occured and the node's bounding rectangle _
      --was not modified, there is no reason to ascend to higher nodes
      if splited = false and includes(previousmbb, p.nodeentries(it).mbb)
        and ((added = true and includes(previousmbb, p.nodeentries(p.numOfEntries).mbb))
            or added = false) then
         exit overall_loop ;
      end if;

      splited := false;
      added := false;
      it:=1;
    end loop;
    if nn.isleaf=-1 then
      tempnode:=sem_stbnode(-1,-1,-1,null);
    else
      tempnode:=sem_stbnode(nn.ptrparent,nn.ptrcurrent,nn.numofentries,nn.nodeentries);
    end if;
    return tempnode;
    exception
      when others then
        dbms_output.put_line('adjusttree');
  end adjusttree;

  function includes(sourcembr sem_mbb, insertedmbr sem_mbb) return boolean is
  begin
    if not
    (sourcembr.minpoint.x <= insertedmbr.minpoint.x and
     sourcembr.maxpoint.x >= insertedmbr.maxpoint.x) then
        return false;
    end if;
    if not
    (sourcembr.minpoint.y <= insertedmbr.minpoint.y and
     sourcembr.maxpoint.y >= insertedmbr.maxpoint.y) then
        return false;
    end if;
    if not
    (sourcembr.minpoint.t.get_abs_date() <= insertedmbr.minpoint.t.get_abs_date() and
     sourcembr.maxpoint.t.get_abs_date() >= insertedmbr.maxpoint.t.get_abs_date()) then
        return false;
    end if;
    return true;
  end includes;

  function ncoveringmbb(node sem_stbnode) return sem_mbb is
    tmpmbb sem_mbb;
  begin
    tmpmbb:=node.nodeEntries(1).mbb;
    for i in 2..node.numOfEntries loop
      if (node.nodeEntries(i).mbb.minpoint.x < tmpmbb.minpoint.x) then
        tmpmbb.minpoint.x := node.nodeEntries(i).mbb.minpoint.x;
      end if;
      if (node.nodeEntries(i).mbb.minpoint.y < tmpmbb.minpoint.y) then
        tmpmbb.minpoint.y := node.nodeEntries(i).mbb.minpoint.y;
      end if;
      if (node.nodeEntries(i).mbb.minpoint.t.get_Abs_Date() < tmpmbb.minpoint.t.get_Abs_Date()) then
        tmpmbb.minpoint.t := node.nodeEntries(i).mbb.minpoint.t;
      end if;
      if (node.nodeEntries(i).mbb.maxpoint.x > tmpmbb.maxpoint.x) then
        tmpmbb.maxpoint.x := node.nodeEntries(i).mbb.maxpoint.x;
      end if;
      if (node.nodeEntries(i).mbb.maxpoint.y > tmpmbb.maxpoint.y) then
        tmpmbb.maxpoint.y := node.nodeEntries(i).mbb.maxpoint.y;
      end if;
      if (node.nodeEntries(i).mbb.maxpoint.t.get_Abs_Date() > tmpmbb.maxpoint.t.get_Abs_Date()) then
        tmpmbb.maxpoint.t := node.nodeEntries(i).mbb.maxpoint.t;
      end if;
    end loop;
    return tmpmbb;
  end ncoveringmbb;

  function lcoveringmbb(leaf sem_stbleaf) return sem_mbb is
    tmpmbb sem_mbb;
  begin
    tmpmbb:=leaf.leafEntries(1).mbb;
    for i in 2..leaf.numOfEntries loop
      if (leaf.leafEntries(i).mbb.minpoint.x < tmpmbb.minpoint.x) then
        tmpmbb.minpoint.x := leaf.leafEntries(i).mbb.minpoint.x;
      end if;
      if (leaf.leafEntries(i).mbb.minpoint.y < tmpmbb.minpoint.y) then
        tmpmbb.minpoint.y := leaf.leafEntries(i).mbb.minpoint.y;
      end if;
      if (leaf.leafEntries(i).mbb.minpoint.t.get_Abs_Date() < tmpmbb.minpoint.t.get_Abs_Date()) then
        tmpmbb.minpoint.t := leaf.leafEntries(i).mbb.minpoint.t;
      end if;
      if (leaf.leafEntries(i).mbb.maxpoint.x > tmpmbb.maxpoint.x) then
        tmpmbb.maxpoint.x := leaf.leafEntries(i).mbb.maxpoint.x;
      end if;
      if (leaf.leafEntries(i).mbb.maxpoint.y > tmpmbb.maxpoint.y) then
        tmpmbb.maxpoint.y := leaf.leafEntries(i).mbb.maxpoint.y;
      end if;
      if (leaf.leafEntries(i).mbb.maxpoint.t.get_Abs_Date() > tmpmbb.maxpoint.t.get_Abs_Date()) then
        tmpmbb.maxpoint.t := leaf.leafEntries(i).mbb.maxpoint.t;
      end if;
    end loop;
    return tmpmbb;
  end lcoveringmbb;

  function chooselastleaf(nodetab varchar2, leaftab varchar2) return sem_stbleaf is
    tmpnode sem_stbnode;
    tmpleaf sem_stbleaf;
  begin
    execute immediate 'begin select node into :tmpnode from '||nodetab||' where nid=0;end;'
            using out tmpnode;
      while (tmpnode.nodeEntries(tmpnode.numOfEntries).ptrto<10000) loop

      execute immediate 'begin select node into :tmpnode from '||nodetab||' where nid=:entry;end;'
              using out tmpnode,in tmpnode.nodeEntries(tmpnode.numOfEntries).ptrto;
      end loop;
    execute immediate 'begin select leaf into :tmpleaf from '||leaftab||' where lid=:lid;end;'
            using out tmpleaf,in tmpnode.nodeEntries(tmpnode.numOfEntries).ptrto;
    return tmpleaf;
    exception
      when others then
        dbms_output.put_line('chooselastleaf');
  end chooselastleaf;

  procedure saveleaf(leaf sem_stbleaf, leaftab varchar2, existence boolean) is
    begin
    if existence = false then
      EXECUTE IMMEDIATE 'begin insert into '||leaftab||'(lid, roid, leaf) values (:lid, :roid, :leaf);end;'
              using in leaf.ptrCurrent, in leaf.roid, in leaf;
    else
      EXECUTE IMMEDIATE 'begin update '||leaftab||' set leaf=:leaf where lid=:lid;end;'
              using  in leaf, leaf.ptrCurrent;
    end if;
  end saveleaf;

  procedure savenode(node sem_stbnode, nodetab varchar2, existence boolean, nid integer) is
  begin
    if existence=false then
      EXECUTE IMMEDIATE 'begin insert into '||nodetab||'(nid, node) values (:nid, :node);end;'
        using in node.ptrCurrent, node;
    else
      EXECUTE IMMEDIATE 'begin update '||nodetab||' set nid=:current, node=:node where nid=:nid;end;'
        using  in node.ptrCurrent, node, nid;
    end if;
  end savenode;

  function findleaf(sem_trajid sem_traj_id, leaftab varchar2) return sem_stbleaf is
    leaf sem_stbleaf;
    stmt varchar2(4000);
    lastleaf integer;
  begin
    stmt:='begin select max(l.lid) into :lastleaf from '||leaftab||' l where l.leaf.id.o_id=:o_id
           and l.leaf.id.semtraj_id=:semtraj_id;end;';
    execute immediate stmt
            using out lastleaf, in sem_trajid.o_id, in sem_trajid.semtraj_id;
    stmt:='begin select l.leaf into :leaf from '||leaftab||' l where l.lid=:lastleaf;end;';
    execute immediate stmt
            using out leaf, in lastleaf;
    return leaf;
    exception
      when no_data_found then
        leaf:=null;
        return leaf;
      when others then
        dbms_output.put_line('findleaf for '|| sem_trajid.o_id ||', '|| sem_trajid.semtraj_id || ', found '||lastleaf);
        return null;
  end findleaf;

  procedure create_stbtree_structure(idxname varchar2) is
    stmt varchar2(5000);
  begin
    stmt:='create table '||idxname||'_non_leaf (nid integer, node sem_stbnode)';---=index on nid
    execute immediate stmt;
    stmt:='create table '||idxname||'_leaf (lid integer, roid varchar2(32), leaf sem_stbleaf)';---+index on lid
    execute immediate stmt;
  end create_stbtree_structure;

  procedure drop_sem_tbtree(idxname varchar2) is
    stmt varchar2(5000);
  begin
    stmt:='drop table '||idxname||'_non_leaf ';
    execute immediate stmt;
    stmt:='drop table '||idxname||'_leaf ';
    execute immediate stmt;
    drop_stbtree_textindx(idxname);
  end drop_sem_tbtree;
  
  procedure drop_stbtree_textindx(idxname varchar2) is
    stmt varchar2(5000);
  begin
    stmt:='drop table '||idxname||'_tags';
    execute immediate stmt;
    /*
    stmt:='drop table '||idxname||'_tag_activ_indx';
    execute immediate stmt;
    */
  end drop_stbtree_textindx;

  function stb_range_episodes(geomfrom mdsys.sdo_geometry,
    geomto mdsys.sdo_geometry,tp tau_tll.d_period_sec,
    stbtreeprefix varchar2) return sem_episode_tab is
    --you might consider pipelined function....
    /*
    returns WHOLE episodes of type move that live in tp
    caller should refine results
    (clip corresponding sub_mpoint to tp interval)
    */
    result_episodes sem_episode_tab:=sem_episode_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of integer;
    nodeStack nodeStackType:= nodeStackType(0);--0==>root
    top integer:=1;--initial value pointing to element 1 on stack (root)
    
    node sem_stbnode;
    leaf sem_stbleaf;
    prevleaf sem_stbleaf;
    afterleaf sem_stbleaf;
    intersection sdo_geometry;
    entrygeom sdo_geometry;
    tolerance number:=0.01;
    stbtree_srid integer;
  begin
    execute immediate 'begin select deref(le.tlink).sub_mpoint.srid into :stbtree_srid
                        from '||stbtreeprefix||'_leaf t,table(t.leaf.leafentries) le where t.lid=10000 and rownum=1;end;'--all must have the same srid
              using out stbtree_srid;
    while not top=0 loop
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numOfEntries loop
        if ((node.nodeEntries(i).mbb.minpoint.t.get_abs_date < tp.e.get_abs_date)
              and (node.nodeEntries(i).mbb.maxpoint.t.get_abs_date > tp.b.get_abs_date)) then
          --episode lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            for j in 1..leaf.numOfEntries loop
              if (upper(leaf.leafEntries(j).def_tag)='MOVE')
                and ((leaf.leafEntries(j).mbb.minpoint.t.get_abs_date < tp.e.get_abs_date)
                      and (leaf.leafEntries(j).mbb.maxpoint.t.get_abs_date > tp.b.get_abs_date)) then
                if (j=1) then--MOVE is the first entry of leaf
                  --previous STOP is in the previous leaf , last entry
                  if (leaf.ptrPrevious<>-1) then--just in case
                    execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                      using out prevleaf, in leaf.ptrPrevious;
                    entrygeom:=sdo_geometry(2003,--sdo_gtype
                      stbtree_srid,--sdo_srid
                      null,--sdo_point
                      sdo_elem_info_array(1,1003,3),
                      sdo_ordinate_array(
                      prevleaf.leafEntries(prevleaf.leafEntries.last).mbb.minpoint.x,
                        prevleaf.leafEntries(prevleaf.leafEntries.last).mbb.minpoint.y,
                      prevleaf.leafEntries(prevleaf.leafEntries.last).mbb.maxpoint.x,
                        prevleaf.leafEntries(prevleaf.leafEntries.last).mbb.maxpoint.y)
                      );
                    --find the intersection of the MBR(no time) of the previous STOP with the geomfrom geometry
                    intersection:= MDSYS.sdo_geom.sdo_intersection (geomfrom, entrygeom, tolerance);
                    if (prevleaf.leafEntries(prevleaf.leafEntries.last).def_tag='STOP')
                      and (intersection is not null) then--check after episode
                      if (leaf.numOfEntries>1) then--just in case
                        --leaf expected to hold 155 episodes
                        entrygeom:=sdo_geometry(2003,--sdo_gtype
                          stbtree_srid,--sdo_srid
                          null,--sdo_point
                          sdo_elem_info_array(1,1003,3),
                          sdo_ordinate_array(
                          leaf.leafEntries(j+1).mbb.minpoint.x,
                            leaf.leafEntries(j+1).mbb.minpoint.y,
                          leaf.leafEntries(j+1).mbb.maxpoint.x,
                            leaf.leafEntries(j+1).mbb.maxpoint.y)
                          );
                        --find the intersection of the MBR(no time) of the after STOP with the geomto geometry
                        intersection:= MDSYS.sdo_geom.sdo_intersection (geomto, entrygeom, tolerance);
                        if (upper(leaf.leafEntries(j+1).def_tag)='STOP')
                          and (intersection is not null) then
                          --ok
                          --add this episode_type episode to solution
                          result_episodes.extend(1);
                          result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                                leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                                leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                        end if;
                      end if;
                    end if;
                  end if;
                elsif(j=leaf.numOfEntries) then--MOVE is the last entry of leaf
                  entrygeom:=sdo_geometry(2003,--sdo_gtype
                          stbtree_srid,--sdo_srid
                          null,--sdo_point
                          sdo_elem_info_array(1,1003,3),
                          sdo_ordinate_array(
                          leaf.leafEntries(j-1).mbb.minpoint.x,
                            leaf.leafEntries(j-1).mbb.minpoint.y,
                          leaf.leafEntries(j-1).mbb.maxpoint.x,
                            leaf.leafEntries(j-1).mbb.maxpoint.y)
                          );
                  --find the intersection of the MBR(no time) of the previus STOP with the geomfrom geometry
                  intersection:= MDSYS.sdo_geom.sdo_intersection (geomfrom, entrygeom, tolerance);
                  if (upper(leaf.leafEntries(j-1).def_tag)='STOP')
                    and (intersection is not null) then--check after episode
                    --after STOP is in the next leaf , first entry
                    if (leaf.ptrNext<>-1) then--just in case
                      execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                        using out afterleaf, in leaf.ptrNext;
                      entrygeom:=sdo_geometry(2003,--sdo_gtype
                        stbtree_srid,--sdo_srid
                        null,--sdo_point
                        sdo_elem_info_array(1,1003,3),
                        sdo_ordinate_array(
                        afterleaf.leafEntries(afterleaf.leafEntries.first).mbb.minpoint.x,
                          afterleaf.leafEntries(afterleaf.leafEntries.first).mbb.minpoint.y,
                        afterleaf.leafEntries(afterleaf.leafEntries.first).mbb.maxpoint.x,
                          afterleaf.leafEntries(afterleaf.leafEntries.first).mbb.maxpoint.y)
                        );
                      --find the intersection of the MBR(no time) of the after STOP with the geomto geometry
                      intersection:= MDSYS.sdo_geom.sdo_intersection (geomto, entrygeom, tolerance);
                      if (upper(afterleaf.leafEntries(afterleaf.leafEntries.first).def_tag)='STOP')
                        and (intersection is not null) then
                        --ok
                        --add this episode_type episode to solution
                        result_episodes.extend(1);
                        result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                              leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                              leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                      end if;
                    end if;
                  end if;
                else--simple case of( epis1-MOVE-epis3 )
                  entrygeom:=sdo_geometry(2003,--sdo_gtype
                          stbtree_srid,--sdo_srid
                          null,--sdo_point
                          sdo_elem_info_array(1,1003,3),
                          sdo_ordinate_array(
                          leaf.leafEntries(j-1).mbb.minpoint.x,
                            leaf.leafEntries(j-1).mbb.minpoint.y,
                          leaf.leafEntries(j-1).mbb.maxpoint.x,
                            leaf.leafEntries(j-1).mbb.maxpoint.y)
                          );
                  --find the intersection of the MBR(no time) of the previus STOP with the geomfrom geometry
                  intersection:= MDSYS.sdo_geom.sdo_intersection (geomfrom, entrygeom, tolerance);
                  if (upper(leaf.leafEntries(j-1).def_tag)='STOP')
                    and (intersection is not null) then--check after episode
                    entrygeom:=sdo_geometry(2003,--sdo_gtype
                          stbtree_srid,--sdo_srid
                          null,--sdo_point
                          sdo_elem_info_array(1,1003,3),
                          sdo_ordinate_array(
                          leaf.leafEntries(j+1).mbb.minpoint.x,
                            leaf.leafEntries(j+1).mbb.minpoint.y,
                          leaf.leafEntries(j+1).mbb.maxpoint.x,
                            leaf.leafEntries(j+1).mbb.maxpoint.y)
                          );
                    --find the intersection of the MBR(no time) of the after STOP with the geomto geometry
                    intersection:= MDSYS.sdo_geom.sdo_intersection (geomto, entrygeom, tolerance);
                    if (upper(leaf.leafEntries(j+1).def_tag)='STOP')
                      and (intersection is not null) then
                      --ok
                      --add this episode_type episode to solution
                      result_episodes.extend(1);
                      result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                            leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                            leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                    end if;
                  end if;
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  function stb_range_leafentries(inputepisode sem_episode, stbtreeprefix varchar2) return sem_stbleafentrymid_tab is
       
    result_entries sem_stbleafentrymid_tab:=sem_stbleafentrymid_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of pls_integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top pls_integer:=1;--initial value pointing to element 1 on stack (root)
    intersecting boolean;
    node sem_stbnode;
    leaf sem_stbleaf;
  begin
    while not top=0 loop
      --dbms_session.free_unused_user_memory();
      --starting_time:=systimestamp;
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      --dbms_output.put_line('bring node :'||to_char(nodeStack(top))||'=>'||to_char(systimestamp-starting_time));
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numOfEntries loop
        --find the intersection of the MBB of the current entry with the given geometry
        --starting_time:=systimestamp;
        intersecting:=inputepisode.mbb.intersects(node.nodeEntries(i).mbb);
        --dbms_output.put_line('check intersection of node entry:'||to_char(i)||'=>'||to_char(systimestamp-starting_time));
        if (intersecting) then
          --episode intersect POI and lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            --starting_time:=systimestamp;
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            --dbms_output.put_line('bring leaf :'||to_char(node.nodeEntries(i).ptrto)||'=>'||to_char(systimestamp-starting_time));
            for j in 1..leaf.numOfEntries loop
              if ((inputepisode.defining_tag is null) or (upper(leaf.leafentries(j).def_tag)=upper(inputepisode.defining_tag)))
                    and ((inputepisode.episode_tag is null) or (upper(leaf.leafentries(j).epis_tag)=upper(inputepisode.episode_tag)))
                    and ((inputepisode.activity_tag is null) or (upper(leaf.leafentries(j).activ_tag)=upper(inputepisode.activity_tag))) then
                --find the intersection of the MBB of the current entry with the given geometry
                --starting_time:=systimestamp;
                intersecting:=inputepisode.mbb.intersects(leaf.leafEntries(j).mbb);
                --dbms_output.put_line('check intersection of leaf entry:'||to_char(j)||'=>'||to_char(systimestamp-starting_time));
                if (intersecting) then
                  --add this entry to solution
                  result_entries.extend(1);
                  result_entries(result_entries.last):=sem_stbleafentrymid(leaf.id.o_id,leaf.id.semtraj_id,
                    node.nodeEntries(i).ptrto,j,leaf.numOfEntries);               
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
        --commit;
      end loop;
    end loop;
    return result_entries;
  end stb_range_leafentries;

  function stb_range_episodes(inputepisode sem_episode, 
    stbtreeprefix varchar2) return sem_episode_tab is
    /*
    returns WHOLE episodes of type episode_type that intersects with
    geom and live in tp
    caller should refine results
    (clip corresponding sub_mpoint to tp interval,
    check intersection of true geometries)
    added parameter solutions_tags for prunning results space
    */
    result_episodes sem_episode_tab:=sem_episode_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of pls_integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top pls_integer:=1;--initial value pointing to element 1 on stack (root)
    
    node sem_stbnode;
    leaf sem_stbleaf;
  begin
    --geom parameter is expected to be point or polygon
    while not top=0 loop
      --starting_time := systimestamp;
      --dbms_session.free_unused_user_memory();
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numofentries loop
        --find if intersection of the MBB of the current entry with the given geometry
        if (inputepisode.mbb.intersects(node.nodeEntries(i).mbb)) then
          --episode intersect POI and lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            for j in 1..leaf.numOfEntries loop
              if ((inputepisode.defining_tag is null) or (upper(leaf.leafentries(j).def_tag)=upper(inputepisode.defining_tag)))
                    and ((inputepisode.episode_tag is null) or (upper(leaf.leafentries(j).epis_tag)=upper(inputepisode.episode_tag)))
                    and ((inputepisode.activity_tag is null) or (upper(leaf.leafentries(j).activ_tag)=upper(inputepisode.activity_tag))) then
                --find if intersection of the MBB of the current entry with the given geometry
                if (inputepisode.mbb.intersects(leaf.leafEntries(j).mbb)) then
                  --add this episode_type episode to solution
                  result_episodes.extend(1);
                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                end if;
              end if;
            end loop;            
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
      --dbms_output.put_line('for node:'||nodeStack(top)||'->'||to_char(systimestamp - starting_time));
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  function stb_range_episodes(inputepisode sem_episode,
       nodes stbtree_nodes_tab_typ, leaves stbtree_leaves_tab_typ) return sem_episode_tab is
    result_episodes sem_episode_tab:=sem_episode_tab();
    type nodeStackType is table of pls_integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top pls_integer:=1;--initial value pointing to element 1 on stack (root)
    
    node sem_stbnode;
    leaf sem_stbleaf;
  begin
    --geom parameter is expected to be point or polygon
    while not top=0 loop
      --dbms_session.free_unused_user_memory();
      --execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
      --   using out node, in nodeStack(top);
      --test if the following is faster
      select n.node into node
        from table(nodes) n
        where n.nid = nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numofentries loop
        --find if intersection of the MBB of the current entry with the given geometry
        if (inputepisode.mbb.intersects(node.nodeEntries(i).mbb)) then
          --episode intersect POI and lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            --execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
            --        using out leaf, in node.nodeEntries(i).ptrto;
            select l.leaf into leaf
              from table(leaves) l
              where l.lid=node.nodeEntries(i).ptrto;
            for j in 1..leaf.numOfEntries loop
              if ((inputepisode.defining_tag is null) or (upper(leaf.leafentries(j).def_tag)=upper(inputepisode.defining_tag)))
                    and ((inputepisode.episode_tag is null) or (upper(leaf.leafentries(j).epis_tag)=upper(inputepisode.episode_tag)))
                    and ((inputepisode.activity_tag is null) or (upper(leaf.leafentries(j).activ_tag)=upper(inputepisode.activity_tag))) then
                --find if intersection of the MBB of the current entry with the given geometry
                if (inputepisode.mbb.intersects(leaf.leafEntries(j).mbb)) then
                  --add this episode_type episode to solution
                  result_episodes.extend(1);
                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
        --commit;
      end loop;
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  function stb_range_episodes(episode_type varchar2, geom mdsys.sdo_geometry,
       stbtreeprefix varchar2) return sem_episode_tab is
    /*
    returns WHOLE episodes of type episode_type that intersects with
    geom
    caller should refine results although mbbs check is done here and thus may be late->check
    (check intersection of true geometries)
    */
    result_episodes sem_episode_tab:=sem_episode_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top integer:=1;--initial value pointing to element 1 on stack (root)
    
    node sem_stbnode;
    leaf sem_stbleaf;
    intersection sdo_geometry;
    entrygeom sdo_geometry;
    tolerance number:=0.01;
    stbtree_srid integer;
  begin
    execute immediate 'begin select deref(le.tlink).sub_mpoint.srid into :stbtree_srid
                        from '||stbtreeprefix||'_leaf t,table(t.leaf.leafentries) le where t.lid=10000 and rownum=1;end;'--all must have the same srid
              using out stbtree_srid;
    while not top=0 loop
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numOfEntries loop
        
        entrygeom:=sdo_geometry(2003,--sdo_gtype
                      stbtree_srid,--sdo_srid
                      null,--sdo_point
                      sdo_elem_info_array(1,1003,3),
                      sdo_ordinate_array(
                      node.nodeEntries(i).mbb.minpoint.x,node.nodeEntries(i).mbb.minpoint.y,
                      node.nodeEntries(i).mbb.maxpoint.x,node.nodeEntries(i).mbb.maxpoint.y)
                      );
        
        --find the intersection of the MBB of the current entry with the given geometry
        intersection:= MDSYS.sdo_geom.sdo_intersection (geom, entrygeom, tolerance);
        if (intersection is not null) then
          --episode intersect POI
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            for j in 1..leaf.numOfEntries loop
              if (upper(leaf.leafEntries(j).def_tag)=upper(episode_type)) then
                entrygeom:=sdo_geometry(2003,--sdo_gtype
                              stbtree_srid,--sdo_srid
                              null,--sdo_point
                              sdo_elem_info_array(1,1003,3),
                              sdo_ordinate_array(
                              leaf.leafEntries(j).mbb.minpoint.x,leaf.leafEntries(j).mbb.minpoint.y,
                              leaf.leafEntries(j).mbb.maxpoint.x,leaf.leafEntries(j).mbb.maxpoint.y)
                              );
        
                --find the intersection of the MBB of the current entry with the given geometry
                intersection:= MDSYS.sdo_geom.sdo_intersection (geom, entrygeom, tolerance);
                if (intersection is not null)  then
                  --add this episode_type episode to solution
                  result_episodes.extend(1);
                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  function stb_range_episodes(episode_type varchar2, tp tau_tll.d_period_sec,
       stbtreeprefix varchar2) return sem_episode_tab is
    /*
    returns WHOLE episodes of type episode_type that
    live in tp
    caller should refine results
    (clip corresponding sub_mpoint to tp interval)
    */
    result_episodes sem_episode_tab:=sem_episode_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top integer:=1;--initial value pointing to element 1 on stack (root)
    
    node sem_stbnode;
    leaf sem_stbleaf;
  begin
  
    while not top=0 loop
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numOfEntries loop
        if ((node.nodeEntries(i).mbb.minpoint.t.get_abs_date < tp.e.get_abs_date)
              and (node.nodeEntries(i).mbb.maxpoint.t.get_abs_date > tp.b.get_abs_date)) then
          --episode lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            for j in 1..leaf.numOfEntries loop
              if (upper(leaf.leafEntries(j).def_tag)=upper(episode_type)) then
                if ((leaf.leafEntries(j).mbb.minpoint.t.get_abs_date < tp.e.get_abs_date)
                      and (leaf.leafEntries(j).mbb.maxpoint.t.get_abs_date > tp.b.get_abs_date)) then
                  --add this episode_type episode to solution
                  result_episodes.extend(1);
                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  function stb_from_to_via(from_stop sem_episode, to_stop sem_episode, via_move sem_episode,
       stbtreeprefix varchar2) return sem_episode_tab is
  /*
  This method returns MOVE episodes. It takes as input arguments three episodes. A fromStop episode, a toStop episode and a viaMove episode.
  Returned move episodes obey to the input parameters episodes, that is, they began from fromStop episode, ended to toStop episode and
  have similar attirbutes as viaMove episode. Input episodes can be null, meaning no corresponding constraint is applied. For example,
  if fromStop episode is null then this method would return all move episodes from the dataset that ended to toStop episode parameter after
  having moved according to viaMove episode parameter. Moreover each input episode can have its text or spatio-temporal attributes
  set to null, meaning again that no corresponding constraint is to be applied. For example the fromStop episode parameter can have its
  spatiotemporal attribute (sem_mbb) set to null and the toStop episode can have all or some of its text attributes (defining_tag,
  episode_tag or activity_tag) set to null while parameter viaMove is null. In such a case the method sould return MOVE episodes
  that began from fromStop episode where only text constraints are applied (eg Home, eating) went to toStop episode where only spatiotemporal
  and some text constraints are applied (eg areaX, Work ) using in between any MOVE episode exists in the dataset.
  */
  result_episodes sem_episode_tab:=sem_episode_tab();
  --types for descending tbtree
  --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
  type nodeStackType is table of integer;
  nodeStack nodeStackType := nodeStackType(0);--0==>root
  top integer:=1;--initial value pointing to element 1 on stack (root)
  
  node sem_stbnode;
  leaf sem_stbleaf;
  prevleaf sem_stbleaf;
  afterleaf sem_stbleaf;
  begin
    while not top=0 loop
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
        using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numOfEntries loop
        --find the intersection of the MBB of the current entry with the given episode mbb
        if (via_move is null) or (via_Move.mbb is null) or (via_Move.mbb.intersects(node.nodeEntries(i).mbb)) then
          --episode intersects entry
          if (node.nodeEntries(i).ptrto >= 10000) then
            --if child is leaf, processed it
            execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                    using out leaf, in node.nodeEntries(i).ptrto;
            for j in 1..leaf.numofentries loop
              --only MOVE episodes//comment it for interesting results
              if upper(leaf.leafEntries(j).def_tag)=upper('MOVE') then
                --textual constraints
                if (via_move is null) 
                or (
                  ((via_move.defining_tag is null)--null is taken as every tag
                    or (upper(leaf.leafEntries(j).def_tag)=upper(via_move.defining_tag)))
                  and ((via_move.episode_tag is null)
                    or (upper(leaf.leafEntries(j).epis_tag)=upper(via_move.episode_tag)))
                  and ((via_move.activity_tag is null)
                    or (upper(leaf.leafEntries(j).activ_tag)=upper(via_move.activity_tag)))
                  ) then
                  --spatiotemporal constraints
                  if (via_move is null) or (via_Move.mbb is null) or (via_Move.mbb.intersects(leaf.leafEntries(j).mbb)) then
                    if (j=1) then--MOVE is the first entry of leaf
                      if (leaf.ptrPrevious<>-1) and (leaf.ptrprevious<>leaf.ptrcurrent) then--just in case (only the second holds trully)
                        --PREVIOUS STOP is in the PREVIOUS leaf , last entry
                        execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                          using out prevleaf, in leaf.ptrPrevious;
                        --check intersection of the MBB of the previous STOP with the from_stop episode
                        --textual constraints
                        if (from_stop is null)
                        or(
                          ((from_stop.defining_tag is null)
                            or (upper(prevleaf.leafEntries(prevleaf.leafEntries.last).def_tag)=upper(from_stop.defining_tag)))
                          and ((from_stop.episode_tag is null)
                            or (upper(prevleaf.leafEntries(prevleaf.leafEntries.last).epis_tag)=upper(from_stop.episode_tag)))
                          and ((from_stop.activity_tag is null)
                            or (upper(prevleaf.leafEntries(prevleaf.leafEntries.last).activ_tag)=upper(from_stop.activity_tag)))
                        ) then
                          --spatiotemporal constraints
                          if (from_stop is null) or (from_stop.mbb is null) 
                          or (from_stop.mbb.intersects(prevleaf.leafEntries(prevleaf.leafEntries.last).mbb)) then
                            --check intersection of the MBB of the next STOP with the to_stop episode
                            if (leaf.numOfEntries>1) then--just in case
                              --textual constraints
                              if (to_stop is null)
                              or(
                                ((to_stop.defining_tag is null)
                                  or(upper(leaf.leafEntries(j+1).def_tag)=upper(to_stop.defining_tag)))
                                and ((to_stop.episode_tag is null)
                                  or(upper(leaf.leafEntries(j+1).epis_tag)=upper(to_stop.episode_tag)))
                                and ((to_stop.activity_tag is null)
                                  or(upper(leaf.leafEntries(j+1).activ_tag)=upper(to_stop.activity_tag)))
                              ) then
                                --spatiotemporal constraints
                                if (to_stop is null) or (to_stop.mbb is null) or (to_stop.mbb.intersects(leaf.leafEntries(j+1).mbb)) then
                                  --ok
                                  --add this episode_type episode to solution
                                  result_episodes.extend(1);
                                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                                end if;
                              end if;
                            end if;
                          end if;
                        end if;
                      end if;      
                    elsif(j=leaf.numOfEntries) then--MOVE is the last entry of leaf
                      if (j>1) then--just in case
                        --check intersection of the MBB of the previous STOP with the from_stop episode
                        if (from_stop is null)
                        or (
                          ((from_stop.defining_tag is null)
                            or(upper(leaf.leafEntries(j-1).def_tag)=upper(from_stop.defining_tag)))
                          and ((from_stop.episode_tag is null)
                            or(upper(leaf.leafEntries(j-1).epis_tag)=upper(from_stop.episode_tag)))
                          and ((from_stop.activity_tag is null)
                            or(upper(leaf.leafEntries(j-1).activ_tag)=upper(from_stop.activity_tag)))
                        ) then
                          --spatiotemporal constraints
                          if (from_stop is null) or (from_stop.mbb is null) or (from_stop.mbb.intersects(leaf.leafEntries(j-1).mbb)) then
                            --check intersection of the MBB of the next STOP with the to_stop episode
                            if (leaf.ptrNext<>-1)  and (leaf.ptrnext<>leaf.ptrcurrent) then--just in case (only the second holds trully)
                              execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                                using out afterleaf, in leaf.ptrNext;
                              --check intersection of the MBB of the next STOP with the to_stop episode
                              --after STOP is in the next leaf , first entry
                              --textual constraints
                              if (to_stop is null)
                              or(
                                ((to_stop.defining_tag is null)
                                  or(upper(afterleaf.leafEntries(afterleaf.leafEntries.first).def_tag)=upper(to_stop.defining_tag)))
                                and ((to_stop.episode_tag is null)
                                  or(upper(afterleaf.leafEntries(afterleaf.leafEntries.first).epis_tag)=upper(to_stop.episode_tag)))
                                and ((to_stop.activity_tag is null)
                                  or(upper(afterleaf.leafEntries(afterleaf.leafEntries.first).activ_tag)=upper(to_stop.activity_tag)))
                              )then
                                --spatiotemporal constraints
                                if (to_stop is null) or(to_stop.mbb is null)
                                or(to_stop.mbb.intersects(afterleaf.leafEntries(afterleaf.leafEntries.first).mbb)) then
                                  --ok
                                  --add this episode_type episode to solution
                                  result_episodes.extend(1);
                                  result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                                        leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                                        leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                                end if;
                              end if;
                            end if;
                          end if;
                        end if;
                      end if;
                    else--simple case of( epis1-MOVE-epis3 ) in the same leaf
                      --check intersection of the MBB of the previous STOP with the from_stop episode
                      --textual constraints
                      if (from_stop is null)
                      or(
                        ((from_stop.defining_tag is null)
                          or(upper(leaf.leafEntries(j-1).def_tag)=upper(from_stop.defining_tag)))
                        and ((from_stop.episode_tag is null)
                          or(upper(leaf.leafEntries(j-1).epis_tag)=upper(from_stop.episode_tag)))
                        and ((from_stop.activity_tag is null)
                          or(upper(leaf.leafEntries(j-1).activ_tag)=upper(from_stop.activity_tag)))
                      ) then
                        --spatiotemporal constraints
                        if (from_stop is null) or (from_stop.mbb is null)
                        or(from_stop.mbb.intersects(leaf.leafEntries(j-1).mbb)) then
                          --check intersection of the MBB of the next STOP with the to_stop episode
                          --textual constraints
                          if (to_stop is null)
                          or(
                            ((to_stop.defining_tag is null)
                              or(upper(leaf.leafEntries(j+1).def_tag)=upper(to_stop.defining_tag)))
                            and ((to_stop.episode_tag is null)
                              or(upper(leaf.leafEntries(j+1).epis_tag)=upper(to_stop.episode_tag)))
                            and ((to_stop.activity_tag is null)
                              or(upper(leaf.leafEntries(j+1).activ_tag)=upper(to_stop.activity_tag)))
                          ) then
                            --spatiotemporal constraints
                            if (to_stop is null) or (to_stop.mbb is null)
                            or(to_stop.mbb.intersects(leaf.leafEntries(j+1).mbb)) then
                              --ok
                              --add this episode_type episode to solution
                              result_episodes.extend(1);
                              result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                                    leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                                    leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                            end if;
                          end if;
                        end if;
                      end if;   
                    end if;
                  end if;  
                end if;
              end if;
            end loop;
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    return result_episodes;
  end stb_from_to_via;    
  function stb_range_episodes(inputepisode sem_episode, validleafentries varchar2, stbtreeprefix varchar2) return sem_episode_tab is
  /*
    returns WHOLE episodes 
    */
    result_episodes sem_episode_tab:=sem_episode_tab();
    --types for descending tbtree
    --type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
    type nodeStackType is table of pls_integer;
    nodeStack nodeStackType := nodeStackType(0);--0==>root
    top pls_integer:=1;--initial value pointing to element 1 on stack (root)    
    found integer;
    node sem_stbnode;
    leaf sem_stbleaf;
    
    leafentriesfound integer_nt;--sem_stbleafentrymid_tab;
  begin
    --geom parameter is expected to be point or polygon
    while not top=0 loop
      --starting_time := systimestamp;
      --dbms_session.free_unused_user_memory();
      execute immediate 'begin select node into :node from '||stbtreeprefix||'_non_leaf where nid=:nid;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.numofentries loop
        --find if intersection of the MBB of the current entry with the given geometry
        if (inputepisode.mbb.intersects(node.nodeEntries(i).mbb)) then
          --episode intersect POI and lives in interval given
          if (node.nodeEntries(i).ptrto >= 10000) then
            --check if the leaf worth proccesing
            execute immediate 'begin select /*value(l)*/ l.stbnodeid bulk collect into :leafentriesfound from '||validleafentries||' l where l.stbnodeid = :ptrto;end;'
              using out leafentriesfound, in node.nodeEntries(i).ptrto;
            if (leafentriesfound.count > 0) then
              execute immediate 'begin select leaf into :leaf from '||stbtreeprefix||'_leaf where lid=:lid;end;'
                      using out leaf, in node.nodeEntries(i).ptrto;
              for j in 1..leaf.numOfEntries loop
                --check if the entry worth proccesing
                --select count(*) into found from table(leafentriesfound) l where l.entryid=j;
                --if (found > 0) then
                if ((inputepisode.defining_tag is null) or (upper(leaf.leafentries(j).def_tag)=upper(inputepisode.defining_tag)))
                    and ((inputepisode.episode_tag is null) or (upper(leaf.leafentries(j).epis_tag)=upper(inputepisode.episode_tag)))
                    and ((inputepisode.activity_tag is null) or (upper(leaf.leafentries(j).activ_tag)=upper(inputepisode.activity_tag))) then
                  --if entry worth it, processed it
                  if (inputepisode.mbb.intersects(leaf.leafEntries(j).mbb)) then
                    --add this episode_type episode to solution
                    result_episodes.extend(1);
                    result_episodes(result_episodes.last):=sem_episode(leaf.leafEntries(j).def_tag,
                          leaf.leafEntries(j).epis_tag, leaf.leafEntries(j).activ_tag,
                          leaf.leafEntries(j).mbb,leaf.leafEntries(j).tlink);
                  end if;
                end if;
              end loop; 
            end if;
          else--is an inner node
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.nodeEntries(i).ptrto;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.nodeEntries(i).ptrto;
            end if;
          end if;
        end if;
      end loop;
      --dbms_output.put_line('for node:'||nodeStack(top)||'->'||to_char(systimestamp - starting_time));
    end loop;
    return result_episodes;
  end stb_range_episodes;
  
  procedure calcallfeatures(outputtblfeatures varchar2, intblsemtrajs varchar2) is
    query varchar2(4000);
    cur_straj sys_refcursor;
    in_semtrajs sem_trajectory_tab;
    cur_episodes sys_refcursor; 
    in_episodes sem_episode_tab;
  begin
    query := 'select value(t)--distinct t.o_id,t.semtraj_id 
      from '||intblsemtrajs||' t
      --where t.o_id =139744-- and t.o_id<208168--partition like
      order by t.o_id';
    open cur_straj for query;
    loop
      fetch cur_straj bulk collect into in_semtrajs limit 10;--f..ing memory
      exit when in_semtrajs.count=0;
      for i in in_semtrajs.first..in_semtrajs.last loop
        query := 'select value(e) from table( 
           select b.episodes 
           from '||intblsemtrajs||' b
           where b.o_id=:o_id
           and b.semtraj_id=:semtraj_id) e';
        open cur_episodes for query using in in_semtrajs(i).o_id, in in_semtrajs(i).semtraj_id;
        loop
          fetch cur_episodes bulk collect into in_episodes;
          exit when in_episodes.count = 0;
          for j in in_episodes.first..in_episodes.last loop
            calcfeatures(outputtblfeatures,in_episodes(j).tlink,in_episodes(j).defining_tag);
          end loop;
        end loop;
        close cur_episodes;
      end loop;
    end loop;
    close cur_straj; 
  end calcallfeatures;
  
  procedure calcfeatures(outputtblfeatures varchar2, refer ref sub_moving_point,
    episode_type varchar2) is
    distance_covered number:=-1;
    duration_sec number:=-1;transmode varchar2(50);starttime tau_tll.d_timepoint_sec;
    top_speed number:=-1;frompoitype varchar2(50);endtime tau_tll.d_timepoint_sec;
    avg_speed number:=-1;topoitype varchar2(50);stopactivity varchar2(50);
    road_type varchar2(50);foundfrom boolean:=false;speed_var number:=-1;area number:=-1;
    sub_traj sub_moving_point;oldfrompoitype varchar2(50);geom mdsys.sdo_geometry;
  begin
    select deref(refer) into sub_traj from dual;
    duration_sec:=sub_traj.sub_mpoint.f_duration();--seconds
    --length depends on srid so ask mdsys
    geom:=sub_traj.sub_mpoint.route();
    distance_covered:=mdsys.sdo_geom.sdo_length(geom,0.0005);--meters
    avg_speed:=distance_covered/duration_sec;--m/s
    speed_var:=sub_traj.sub_mpoint.f_speed_var();
    top_speed:=sub_traj.sub_mpoint.f_max_speed;
    area:=sdo_geom.sdo_area(sdo_geom.sdo_mbr(geom),0.005);
    starttime:=sub_traj.sub_mpoint.f_initial_timepoint();
    endtime:=sub_traj.sub_mpoint.f_final_timepoint();
    if (episode_type='MOVE') then
      road_type:=null;--for now
      stopactivity:=null;
      for cur in (select * from table(
                  select bs.episodes
                  from belg_sem_trajs bs--this means to be run after sem trajs found
                  --from sem_trajs
                  where bs.o_id=sub_traj.o_id
                  and bs.semtraj_id=sub_traj.traj_id)) loop
        if (cur.defining_tag='STOP') then
          if (foundfrom) then
            topoitype:=cur.episode_tag;
            foundfrom:=false;
          else
            oldfrompoitype:=cur.episode_tag;
          end if;
        elsif (cur.defining_tag='MOVE') then
          if (cur.tlink=refer) then
            frompoitype:=oldfrompoitype;
            foundfrom:=true;
            transmode:=cur.activity_tag;
          else
            null;--next episode
          end if;
        end if;
      end loop;
    elsif (episode_type='STOP') then
      road_type:=null;
      frompoitype:=null;
      transmode:=null;
      for cur in (select * from table(
                  select bs.episodes
                  from belg_sem_trajs bs--this means to be run after sem trajs found
                  --from sem_trajs
                  where bs.o_id=sub_traj.o_id
                  and bs.semtraj_id=sub_traj.traj_id)) loop
        if (cur.defining_tag='STOP') then
          if (cur.tlink=refer) then
            stopactivity:=cur.activity_tag;
            topoitype:=cur.episode_tag;
          else
            null;--next stop
          end if;
        end if;
      end loop;
    else
      null;--error
    end if;
    execute immediate 'delete '||outputtblfeatures||'
           where o_id='||sub_traj.o_id||'
           and traj_id='||sub_traj.traj_id||'
           and subtraj_id='||sub_traj.subtraj_id;
    commit;
    execute immediate 'insert into '||outputtblfeatures||'
       (o_id,traj_id,subtraj_id,distance_covered,
            duration_sec,top_speed,avg_speed,speed_var,road_type,
            startpoitype,endpoitype,transmode,starttime,endtime,stopactivity,area)
       values(:o_id,:traj_id,:subtraj_id,:distance_covered,:duration_sec,
            :top_speed,:avg_speed,:speed_var,:road_type,
            :startpoitype,:endpoitype,:transmode,:starttime,:endtime,:stopactivity,:area)'
      using in sub_traj.o_id,sub_traj.traj_id,sub_traj.subtraj_id,distance_covered,
           duration_sec,top_speed,avg_speed,speed_var,road_type,frompoitype,topoitype,
           transmode,starttime,endtime,stopactivity,area;
    commit;
  end calcfeatures;
  
function stb_patterns_tags(inputquery varchar2, stbtree varchar2)--this is old version now
  return integer_nt is
  inputtag varchar2(1000);
  stmt     varchar2(5000);
  toolong exception;
  cur_sor sys_refcursor;
  emptytag exception;errortag exception;
  firsttag  integer := 0;
  starplace pls_integer;
  subsequentplace pls_integer;
  newtag    varchar2(150);
  trajids   integer_nt;
  ntab1     sem_stbleafentrymid_tab;
  solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  ntab2     sem_stbleafentrymid_tab;
  n         integer;
  star varchar2(1) := '*';
  subsequent varchar2(1) := '>';
  condition pls_integer:=0;--0 for any, 1 for subsequent
  
  procedure solve_any is  
  begin
    select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
      bulk collect into solutions
      from (select distinct t2.o_id, t2.traj_id, t2.stbnodeid, t2.entryid, t2.numOfEntries
              from table(ntab2) t2, table(ntab1) t1
             where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id
               and ((t2.stbnodeid = t1.stbnodeid and t2.entryid > t1.entryid)
                or (t2.stbnodeid > t1.stbnodeid))) k; --assuming leafs ordering asc
    if solutions.count>0 then
      --dbms_output.put_line('solutions='||solutions.count); 
      --for j in solutions.first..solutions.last loop
        --dbms_output.put_line('solutions='||solutions(j).traj_id||','||solutions(j).stbnodeid||','||solutions(j).entryid);
      --end loop;
      n:=solutions.count;
    end if;
  end solve_any;
  
  procedure solve_subseq is  
  begin
    select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
      bulk collect into solutions
      from (select distinct t2.o_id, t2.traj_id, t2.stbnodeid, t2.entryid, t2.numOfEntries
              from table(ntab2) t2, table(ntab1) t1
             where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id
               and ((t2.stbnodeid = t1.stbnodeid and t2.entryid = t1.entryid+1)
                or (t2.stbnodeid > t1.stbnodeid and t2.entryid=1 and t1.entryid=t1.numOfEntries))) k; --assuming leafs ordering asc
    if solutions.count>0 then
      --dbms_output.put_line('solutions='||solutions.count); 
      --for j in solutions.first..solutions.last loop
        --dbms_output.put_line('solutions='||solutions(j).traj_id||','||solutions(j).stbnodeid||','||solutions(j).entryid);
      --end loop;
      n:=solutions.count;
    end if;
  end solve_subseq;

  procedure pattern(tag varchar2, cond pls_integer) is  
  begin
    --get moid,lid,eid from tagindx,leafs
    stmt := 'select sem_stbleafentrymid(l.leaf.id.o_id, l.leaf.id.semtraj_id, l.lid, n.entryid, l.leaf.numOfEntries)
      from ' || stbtree || '_tags t, table(t.nodes) n,' ||
            stbtree || '_leaf l
      where l.lid=n.stbnodeid and upper(t.tag) = upper(:tag)';
    --if nodes contained semtraj_id then i gain the join with leaf table
    open cur_sor for stmt
      using in tag;
    if firsttag = 0 then
      fetch cur_sor bulk collect
        into ntab1;
      dbms_output.put_line('ntab1='||ntab1.count||' for tag '||tag);
      n:=ntab1.count;
      firsttag := 1;
      --initially
      solutions:=ntab1;
    else
      fetch cur_sor bulk collect
        into ntab2;
      dbms_output.put_line('ntab2='||ntab2.count||' for tag '||tag);
      n:=ntab2.count;
      if cond = 0 then
        solve_any(); --update solutions
      elsif cond = 1 then
        solve_subseq(); --update solutions
      end if;
      --prun for next step
      dbms_output.put_line('solutions='||solutions.count||' for now');
      ntab1 := solutions;
    end if;
  end pattern;

begin
  --split input string
  if length(inputquery) > 1000 then
    raise toolong;
  end if;
  if length(inputquery) = 0 then
    raise emptytag;
  end if;
  inputtag := inputquery;
  loop
    starplace := instr(inputtag, star);
    subsequentplace := instr(inputtag, subsequent);
    if starplace = 0 and subsequentplace = 0 then
      --only one tag
      newtag := substr(inputtag, 1);
      if length(newtag) > 0 then
        --dbms_output.put_line(newtag);
        pattern(newtag, condition);
      end if;
      exit;
    elsif starplace > 0 and subsequentplace = 0 then
      --* exists in input , > does not
      newtag := substr(inputtag, 1, starplace - 1);
      if length(newtag) > 0 then
        --dbms_output.put_line(newtag);
        pattern(newtag, condition);
      end if;
      inputtag := substr(inputtag, starplace + 1);
      condition := 0;
    elsif starplace = 0 and subsequentplace > 0 then
      --> exists in input , * does not
      newtag := substr(inputtag, 1, subsequentplace - 1);
      if length(newtag) > 0 then
        --dbms_output.put_line(newtag);
        pattern(newtag, condition);
      end if;
      inputtag := substr(inputtag, subsequentplace + 1);
      condition := 1;
    elsif starplace > 0 and subsequentplace > 0 then
      --> exists in input , * does too
      if starplace < subsequentplace then
        newtag := substr(inputtag, 1, starplace - 1);
        if length(newtag) > 0 then
          --dbms_output.put_line(newtag);
          pattern(newtag, condition);
        end if;
        inputtag := substr(inputtag, starplace + 1);
        condition := 0;
      elsif subsequentplace < starplace then
        newtag := substr(inputtag, 1, subsequentplace - 1);
        if length(newtag) > 0 then
          --dbms_output.put_line(newtag);
          pattern(newtag, condition);
        end if;
        inputtag := substr(inputtag, subsequentplace + 1);
        condition := 1;
      else
        raise errortag;-- > and * hold the same place in input string!!!
      end if;
    end if;
  end loop;
  --output solutions-- distinct traj_ids if you like
  select distinct s.traj_id bulk collect
    into trajids
    from table(solutions) s;

  return trajids;

exception
  when toolong then
    dbms_output.put_line('Input tag is too long');
    --return null;
  when emptytag then
    dbms_output.put_line('Input tag is empty');
  when errortag then
    dbms_output.put_line('Tag is wrong!!!');
    --return null;
  /*when others then
  dbms_output.put_line('ERROR');*/
end stb_patterns_tags;
  
function stb_patterns(inputepisodes sem_episode_tab,inputchars varchar_ntab,stbtree varchar2, method integer:=1)
  return integer_nt
  /*
  Returns the trajectory ids that follow the whole pattern given.
  This function takes an array of episodes and an array of wildchars plus the stbtree index. Wildchars exist in between two episodes, so
  the first wildchar should be null. Wildchar '>' means that the current episode is comming immediate after the previous (no other
  episode is in between them) while wildchar '*' means that other episodes could exist in between current and previous in the array episode.
  For every episode in the input array it finds the stbtree leaf entries (which are episodes) of the same tags (null tag is acceptable).
  These episodes are the current solutions based on tags. The same happens based on mbb of the current episode only for episodes that are in
  solution set found from tags. 
  In the followings loops these current solutions are combined with the solutions found previously to get intersection of the two solutions sets.
  */
is  
  inputerror exception;  
  solutions_from_tags sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  previous_episode_solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  trajids   integer_nt; 
  --semtrajids sem_traj_ids;
  --method 1 is not to descend the tree, method 2 is to descend the tree
begin
  if (inputepisodes.count = 0) or (inputepisodes.count <> (inputchars.count) or (inputchars(inputchars.first) <> null)) then
    raise inputerror;
  end if;
  for i in inputepisodes.first..inputepisodes.last loop    
    solutions_from_tags:=pattern_tags(inputepisodes(i), inputchars(i), previous_episode_solutions, stbtree);
    --prune for next step 
    dbms_output.put_line('solutions_from_tags='||solutions_from_tags.count||' for now from tags');
    if (solutions_from_tags.count = 0) then--no solutions_from_tags found 
      --update soluiotns
      previous_episode_solutions := solutions_from_tags;
      --and exit loop
      exit;
    end if;
    
    previous_episode_solutions:=pattern_mbbs(inputepisodes(i),  inputchars(i), method, previous_episode_solutions, solutions_from_tags, stbtree);
    --prune for next step 
    dbms_output.put_line('previous_episode_solutions='||previous_episode_solutions.count||' for now from mbbs');
  end loop;
  dbms_output.put_line('solutions='||previous_episode_solutions.count);
  --output solutions-- distinct traj_ids if you like
  select distinct d.traj_id bulk collect
    into trajids
    from table(previous_episode_solutions) d;
  --dbms_output.put_line('trajids='||trajids.count);
  return trajids;
  
  exception
  when inputerror then
    dbms_output.put_line('Input error on stb_patterns');
    --return null;
end stb_patterns;

function stb_patterns_semtrajids(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return sem_traj_ids
 /*
  Returns the semantic trajectory ids that follow the whole pattern given.
  This function takes an array of episodes and an array of wildchars plus the stbtree index. Wildchars exist in between two episodes, so
  the first wildchar should be null. Wildchar '>' means that the current episode is comming immediate after the previous (no other
  episode is in between them) while wildchar '*' means that other episodes could exist in between current and previous in the array episode.
  For every episode in the input array it finds the stbtree leaf entries (which are episodes) of the same tags (null tag is acceptable).
  These episodes are the current solutions based on tags. The same happens based on mbb of the current episode only for episodes that are in
  solution set found from tags. 
  In the followings loops these current solutions are combined with the solutions found previously to get intersection of the two solutions sets.
  */
is  
  inputerror exception;  
  solutions_from_tags sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  previous_episode_solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  semtrajids sem_traj_ids;
  --method 1 is not to descend the tree, method 2 is to descend the tree
begin
  if (inputepisodes.count = 0) or (inputepisodes.count <> (inputchars.count) or (inputchars(inputchars.first) <> null)) then
    raise inputerror;
  end if;
  for i in inputepisodes.first..inputepisodes.last loop    
    solutions_from_tags:=pattern_tags(inputepisodes(i), inputchars(i), previous_episode_solutions, stbtree);
    --prune for next step 
    dbms_output.put_line('solutions_from_tags='||solutions_from_tags.count||' for now from tags');
    if (solutions_from_tags.count = 0) then--no solutions_from_tags found 
      --update soluiotns
      previous_episode_solutions := solutions_from_tags;
      --and exit loop
      exit;
    end if;
    
    previous_episode_solutions:=pattern_mbbs(inputepisodes(i),  inputchars(i), method, previous_episode_solutions, solutions_from_tags, stbtree);
    --prune for next step 
    dbms_output.put_line('previous_episode_solutions='||previous_episode_solutions.count||' for now from mbbs');
  end loop;
  --dbms_output.put_line('done');
  --output solutions-- distinct traj_ids if you like
  select sem_traj_id(t.o_id,t.traj_id) bulk collect--althouth an order member function exists
    into semtrajids
    from (select distinct d.o_id,d.traj_id
    from table(previous_episode_solutions) d) t;
  --dbms_output.put_line('semtrajids='||semtrajids.count);
  return semtrajids;
  
  exception
  when inputerror then
    dbms_output.put_line('Input error on stb_patterns');
    --return null;
end stb_patterns_semtrajids;


function stb_patterns_leafids(inputepisodes sem_episode_tab,inputchars varchar_ntab,stbtree varchar2, method integer:=1)
  return sem_stbleafentrymid_tab
  /*
  Returns the ending leaf entries that follow the whole pattern given.
  This function takes an array of episodes and an array of wildchars plus the stbtree index. Wildchars exist in between two episodes, so
  the first wildchar should be null. Wildchar '>' means that the current episode is comming immediate after the previous (no other
  episode is in between them) while wildchar '*' means that other episodes could exist in between current and previous in the array episode.
  For every episode in the input array it finds the stbtree leaf entries (which are episodes) of the same tags (null tag is acceptable).
  These episodes are the current solutions based on tags. The same happens based on mbb of the current episode only for episodes that are in
  solution set found from tags. 
  In the followings loops these current solutions are combined with the solutions found previously to get intersection of the two solutions sets.
  */
is  
  inputerror exception;  
  solutions_from_tags sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  previous_episode_solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  --method 1 is not to descend the tree, method 2 is to descend the tree
  --semtrajids sem_traj_ids;
begin
  if (inputepisodes.count = 0) or (inputepisodes.count <> (inputchars.count) or (inputchars(inputchars.first) <> null)) then
    raise inputerror;
  end if;
  for i in inputepisodes.first..inputepisodes.last loop  
    solutions_from_tags:=pattern_tags(inputepisodes(i), inputchars(i), previous_episode_solutions, stbtree);
    --prune for next step 
    dbms_output.put_line('solutions_from_tags='||solutions_from_tags.count||' for now from tags');
    if (solutions_from_tags.count = 0) then--no solutions_from_tags found 
      --update soluiotns
      previous_episode_solutions := solutions_from_tags;
      --and exit loop
      exit;
    end if;
    
    previous_episode_solutions:=pattern_mbbs(inputepisodes(i),  inputchars(i), method, previous_episode_solutions, solutions_from_tags, stbtree);
    --prune for next step 
    dbms_output.put_line('previous_episode_solutions='||previous_episode_solutions.count||' for now from mbbs');
  end loop;
  --dbms_output.put_line('done');
  --output solutions-- distinct traj_ids if you like
  --dbms_output.put_line('leafids='||solutions_mbbs.count);
  return previous_episode_solutions;
  
  exception
  when inputerror then
    dbms_output.put_line('Input error on stb_patterns');
    --return null;
end stb_patterns_leafids;

function stb_patterns_episodes(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return sem_episode_tab
 /*
  Returns the ending episodes that follow the whole pattern given.
  This function takes an array of episodes and an array of wildchars plus the stbtree index. Wildchars exist in between two episodes, so
  the first wildchar should be null. Wildchar '>' means that the current episode is comming immediate after the previous (no other
  episode is in between them) while wildchar '*' means that other episodes could exist in between current and previous in the array episode.
  For every episode in the input array it finds the stbtree leaf entries (which are episodes) of the same tags (null tag is acceptable).
  These episodes are the current solutions based on tags. The same happens based on mbb of the current episode only for episodes that are in
  solution set found from tags. 
  In the followings loops these current solutions are combined with the solutions found previously to get intersection of the two solutions sets.
  */
is  
  inputerror exception;  
  solutions_from_tags sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  previous_episode_solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  tmp_episode sem_episode;
  episodes   sem_episode_tab:=sem_episode_tab(); 
  --method 1 is not to descend the tree, method 2 is to descend the tree
  --semtrajids sem_traj_ids;
begin
  if (inputepisodes.count = 0) or (inputepisodes.count <> (inputchars.count) or (inputchars(inputchars.first) <> null)) then
    raise inputerror;
  end if;
  for i in inputepisodes.first..inputepisodes.last loop  
    solutions_from_tags:=pattern_tags(inputepisodes(i), inputchars(i), previous_episode_solutions, stbtree);
    --prune for next step 
    dbms_output.put_line('solutions_from_tags='||solutions_from_tags.count||' for now from tags');
    if (solutions_from_tags.count = 0) then--no solutions_from_tags found 
      --update soluiotns
      previous_episode_solutions := solutions_from_tags;
      --and exit loop
      exit;
    end if;
    
    previous_episode_solutions:=pattern_mbbs(inputepisodes(i),  inputchars(i), method, previous_episode_solutions, solutions_from_tags, stbtree);
    --prune for next step 
    dbms_output.put_line('previous_episode_solutions='||previous_episode_solutions.count||' for now from mbbs');
  end loop;
  --dbms_output.put_line('done');
  --output solutions-- distinct traj_ids if you like
  for e in previous_episode_solutions.first..previous_episode_solutions.last loop  
    execute immediate 'begin select sem_episode(def_tag,epis_tag,activ_tag,mbb,tlink) into :tmp_episode
                    from (select rownum aa, t.* from table(      
                    select l.leaf.leafentries from '||stbtree||'_leaf l where lid=:lid) t)
                    where aa =:entryid;end;'
      using out tmp_episode, in previous_episode_solutions(e).stbnodeid, in previous_episode_solutions(e).entryid;
    episodes.extend();
    episodes(episodes.last):=tmp_episode;
  end loop;   
  --dbms_output.put_line('episodes='||episodes.count);
  return episodes;
  
  exception
  when inputerror then
    dbms_output.put_line('Input error on stb_patterns');
    --return null;
end stb_patterns_episodes;

function combine(previous_tab sem_stbleafentrymid_tab, after_tab sem_stbleafentrymid_tab, wildchar varchar2,stbtree varchar2) return sem_stbleafentrymid_tab is  
  /*
  This function combine solution sets based on the wildchar in between them and return stbtree leaf entries found.
  */
  solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  charerror exception;
  stmt     varchar2(5000);
  cur_sor sys_refcursor;  
begin
  if wildchar = '>' then
    stmt := 'select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
      from (select distinct t2.o_id, t2.traj_id, t2.stbnodeid, t2.entryid, t2.numOfEntries
              from table(:after_tab) t2, table(:previous_tab) t1, ' || stbtree || '_leaf l
             where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id and l.lid = t1.stbnodeid
               and ((t2.stbnodeid = t1.stbnodeid and t2.entryid = t1.entryid+1)
                or (t2.stbnodeid > t1.stbnodeid and t2.entryid=1 and t1.entryid=t1.numOfEntries and l.leaf.ptrNext = t2.stbnodeid)
                  )) k'; --assuming leafs ordering asc
    open cur_sor for stmt using in after_tab, in previous_tab;
    fetch cur_sor bulk collect into solutions;    
  elsif wildchar = '*' then
    select sem_stbleafentrymid(k.o_id, k.traj_id, k.stbnodeid, k.entryid, k.numOfEntries)
    bulk collect into solutions
    from (select distinct t2.o_id, t2.traj_id, t2.stbnodeid, t2.entryid, t2.numOfEntries
            from table(after_tab) t2, table(previous_tab) t1
           where t2.o_id = t1.o_id and t2.traj_id = t1.traj_id
             and ((t2.stbnodeid = t1.stbnodeid and t2.entryid > t1.entryid)
              or (t2.stbnodeid > t1.stbnodeid))) k; --assuming leafs ordering asc
  else
    raise charerror;
  end if;
  return solutions;
  
  exception
  when charerror then
    dbms_output.put_line('Input char must be null or ">" or "*"');
end combine;

function pattern_tags(epis sem_episode, wildchar varchar2, previous_episode_solutions sem_stbleafentrymid_tab,stbtree varchar2) return sem_stbleafentrymid_tab is
  /*
  This function finds the stbtree leaf entries for input episode based on its tags. If previous solutions have been found
  (input wildchar is not null and so is not input ntab1_tags) then combine function is used to find the solutions.
  */
  valid_tabs integer:=0;--0 none,1 only def,2 only epis,3 def+epis,4 only activ,5 activ+def,6 activ+epis, 7 all
  new_solutions     sem_stbleafentrymid_tab;
  solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
  stmt     varchar2(5000);
  cur_sor sys_refcursor;
  deftag_tab sem_stbleafentrymid_tab;
  epistag_tab sem_stbleafentrymid_tab;
  activtag_tab sem_stbleafentrymid_tab;
begin
  stmt := 'select sem_stbleafentrymid(l.leaf.id.o_id,l.leaf.id.semtraj_id,l.lid,n.entryid,l.leaf.numofentries)
    from ' || stbtree || '_tags t,table(t.nodes) n, ' || stbtree || '_leaf l
    where l.lid = n.stbnodeid ';
  if epis.defining_tag is not null then
    open cur_sor for stmt||' and upper(t.tag)=upper(:def_tag)'
      using in epis.defining_tag;
    fetch cur_sor bulk collect into deftag_tab;
    --dbms_output.put_line('deftag_tab='||deftag_tab.count||' for tag '||epis.defining_tag);
    valid_tabs:=valid_tabs+1;
  end if;
  if epis.episode_tag is not null then
    open cur_sor for stmt||' and upper(t.tag)=upper(:epis_tag)'
      using in epis.episode_tag;
    fetch cur_sor bulk collect into epistag_tab;
    --dbms_output.put_line('epistag_tab='||epistag_tab.count||' for tag '||epis.episode_tag);
    valid_tabs:=valid_tabs+2;
  end if;
  if epis.activity_tag is not null then
    open cur_sor for stmt||' and upper(t.tag)=upper(:activ_tag)'
      using in epis.activity_tag;
    fetch cur_sor bulk collect into activtag_tab;
    --dbms_output.put_line('activtag_tab='||activtag_tab.count||' for tag '||epis.activity_tag);
    valid_tabs:=valid_tabs+4;
  end if;
  
  stmt :='begin select sem_stbleafentrymid(l.o_id,l.traj_id,l.stbnodeid,l.entryid,l.numofentries)
    bulk collect into :ntab
    from(';
  if valid_tabs = 0 then --all tags are null
    stmt := 'begin select sem_stbleafentrymid(e.o_id,e.semtraj_id,e.lid,e.entryid,e.numofentries)
      bulk collect into :ntab
      from (select distinct l.leaf.id.o_id o_id,l.leaf.id.semtraj_id semtraj_id,l.lid,n.entryid,l.leaf.numofentries numofentries
      from ' || stbtree || '_tags t,table(t.nodes) n, ' || stbtree || '_leaf l
      where l.lid = n.stbnodeid) e;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions;
    else--next input episode
      execute immediate stmt using out new_solutions;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:= combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 1 then --epis,activ are null
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:deftag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in deftag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in deftag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 2 then --def,activ are null  
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:epistag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in epistag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in epistag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 3 then --activ is null 
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:deftag_tab) d
      intersect
      select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:epistag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in deftag_tab, in epistag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in deftag_tab, in epistag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 4 then --def,epis are null 
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:activtag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in activtag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in activtag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 5 then --epis is null 
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:deftag_tab) d
      intersect
      select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:activtag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in deftag_tab, in activtag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in deftag_tab, in activtag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 6 then --def is null 
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:epistag_tab) d
      intersect
      select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:activtag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in epistag_tab, in activtag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in epistag_tab, in activtag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  elsif valid_tabs = 7 then --none is null 
    stmt:=stmt||'select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:deftag_tab) d
      intersect
      select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:epistag_tab) d
      intersect
      select d.o_id,d.traj_id,d.stbnodeid,d.entryid,d.numofentries
      from table(:activtag_tab) d) l;end;';
    if wildchar is null then--first input episode
      execute immediate stmt using out solutions, in deftag_tab, in epistag_tab, in activtag_tab ;
    else--next input episode
      execute immediate stmt using out new_solutions, in deftag_tab, in epistag_tab, in activtag_tab ;
      --dbms_output.put_line('ntab2_tags='||ntab2_tags.count);
      solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
    end if;
  end if; 
   --dbms_output.put_line('solutions from pattern_tags='||solutions.count);
  return solutions;
end pattern_tags;
  
function pattern_mbbs(inputepisode sem_episode, wildchar varchar, method integer,previous_episode_solutions sem_stbleafentrymid_tab,
  solutions_from_tags sem_stbleafentrymid_tab, stbtree varchar2) return sem_stbleafentrymid_tab is
  /*
  This function finds the stbtree leaf entries for input episode based on its mbb. If previous solutions have been found
  (input wildchar is not null and so is should not input solutions_tags) then combine function is used to find the solutions.
  It comes in two methods though method 1 seems faster. Usually is run after pattern_tags.
  */  
  stmt     varchar2(5000);
  stmt0     varchar2(5000);
  stmt1     varchar2(5000);
  stmt2     varchar2(5000);
  stmt3     varchar2(5000);
  new_solutions     sem_stbleafentrymid_tab;
  solutions sem_stbleafentrymid_tab := sem_stbleafentrymid_tab();
begin
  stmt := 'begin select sem_stbleafentrymid(e.o_id,e.semtraj_id,e.lid,e.entryid,e.numofentries)
          bulk collect into :ntab
          from (select distinct l.leaf.id.o_id o_id,l.leaf.id.semtraj_id semtraj_id,l.lid,n.entryid,l.leaf.numofentries numofentries
            from ' || stbtree || '_tags t,table(t.nodes) n, ' || stbtree || '_leaf l
            where l.lid = n.stbnodeid) e;end;';
          
  stmt0 := 'begin select sem_stbleafentrymid(e.o_id,e.semtraj_id,e.lid,e.entryid,e.numofentries)
        bulk collect into :ntab
        from(select distinct l.leaf.id.o_id o_id,l.leaf.id.semtraj_id semtraj_id,l.lid,n.entryid,l.leaf.numofentries numofentries
          from ' || stbtree || '_leaf l, table(l.leaf.leafentries) le,' || stbtree || '_tags t,table(t.nodes) n
          where l.lid = n.stbnodeid
          and le.mbb.intersects01(:inmbb)=1) e;end;';
        
  stmt1 := 'begin select sem_stbleafentrymid(e.o_id,e.semtraj_id,e.stbnodeid,e.entryid,e.numofentries)
        bulk collect into :ntab
        from (select l.leaf.id.o_id o_id,l.leaf.id.semtraj_id semtraj_id,ta.stbnodeid,ta.entryid,l.leaf.numofentries numofentries, le.mbb mbb
          from ' || stbtree || '_leaf l, table(l.leaf.leafentries) le, table(:solutions_tags) ta
          where l.lid=ta.stbnodeid and deref(le.tlink).subtraj_id=ta.entryid) e
        where e.mbb.intersects01(:inmbb)=1;end;';
        
  stmt2 := 'begin select sem_stbleafentrymid(t.o_id,t.traj_id,t.stbnodeid,t.entryid,t.numofentries)
        bulk collect into :ntab
        from table(std.stb_range_leafentries(:episode,'''||stbtree||''')) t
        where (t.stbnodeid, t.entryid) in (select ta.stbnodeid, ta.entryid from table(:solutions_tags) ta);end;'; 
        
  stmt3 := 'begin select sem_stbleafentrymid(t.o_id,t.traj_id,t.stbnodeid,t.entryid,t.numofentries)
        bulk collect into :ntab
        from table(std.stb_range_leafentries(:episode,'''||stbtree||''')) t;end;';
               
  if method=1 then--scan leafs given current solutions_tags
    if inputepisode.mbb is null then--no mbb given
      --return episodes either from solutions_from_tags if not empty or all episodes
      --Note: if is used in combination with pattern_tags then caller should avoid execution by checking this before calling pattern_mbbs
      --else we assume that pattern_mbbs called as a standalone so return all episodes
      if (solutions_from_tags.count > 0 ) then
        --return episodes in solutions_from_tags
        new_solutions := solutions_from_tags;
      else
        --return all episodes
        execute immediate stmt using out new_solutions;
      end if;  
    else--mbb given
      --return episodes intersecting given mbb using solutions_from_tags if not empty
      --Note: if is used in combination with pattern_tags then caller should avoid execution by checking this before calling pattern_mbbs
      --else we assume that pattern_mbbs called as a standalone so return episodes intersecting given mbb
      if (solutions_from_tags.count > 0 ) then
        execute immediate stmt1 using out new_solutions, in solutions_from_tags, in inputepisode.mbb;
      else
        execute immediate stmt0 using out new_solutions, in inputepisode.mbb;
      end if;  
    end if;
  elsif method =2 then--descend the tree given current solutions_tags
    if inputepisode.mbb is null then--no mbb given
      --return episodes either from solutions_from_tags if not empty or all episodes
      --Note: if is used in combination with pattern_tags then caller should avoid execution by checking this before calling pattern_mbbs
      --else we assume that pattern_mbbs called as a standalone so return all episodes
      if (solutions_from_tags.count > 0 ) then
        --return episodes in solutions_from_tags
        new_solutions := solutions_from_tags;
      else
        --return all episodes
        execute immediate stmt using out new_solutions;
      end if;  
    else--mbb given
      --return episodes intersecting given mbb using solutions_from_tags if not empty
      --Note: if is used in combination with pattern_tags then caller should avoid execution by checking this before calling pattern_mbbs
      --else we assume that pattern_mbbs called as a standalone so return episodes intersecting given mbb
      if (solutions_from_tags.count > 0 ) then
        execute immediate stmt2 using out new_solutions, in inputepisode, in solutions_from_tags;
      else
        execute immediate stmt3 using out new_solutions, in inputepisode;
      end if;  
    end if;
  end if; 
  if wildchar is null then--no previous input episode
    --no combine to do
    solutions:= new_solutions;
  else--previous input episode exists  so combine solutions
    solutions:=combine(previous_episode_solutions, new_solutions, wildchar,stbtree);
  end if;
  --dbms_output.put_line('solutions from pattern_mbbs='||solutions.count);
  return solutions;
end pattern_mbbs;

begin
  -- Initialization
  null;
end STD;
/


