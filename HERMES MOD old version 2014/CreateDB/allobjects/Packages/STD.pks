Prompt Package STD;
CREATE OR REPLACE package        STD is

  -- Public type declarations
  type hybrid_node is record
  (
      isleaf integer,
      id sem_traj_id, /*the moving object id*/
      roid varchar2(32), /*the rowid of the base table record*/
      ptrparent integer, /*a pointer to the parent node*/
      ptrcurrent integer,  /*a pointer to the node itsself*/
      ptrnext integer, /*a pointer to the next node*/
      ptrprevious integer, /*a pointer to the previous node*/
      numofentries integer,
      nodeentries sem_stbnode_entries,
      leafentries sem_stbleaf_entries   /*the actual entries of the node*/
  );
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;
  starting_time  TIMESTAMP WITH TIME ZONE;
  ending_time    TIMESTAMP WITH TIME ZONE;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --4 procedures for the STB-TREE structure
  procedure create_sem_tbtree(idxname varchar2, source_table varchar2);
  procedure create_stbtree_structure(idxname varchar2);
  procedure fill_stbtree_structure(idxname varchar2, source_table varchar2);
  procedure fill_stbtree_structure_par(idxname varchar2, source_table varchar2, from_id number, to_id number);
  procedure create_stbtree_textindx(idxname varchar2);
  procedure fill_stbtree_textindx(idxname varchar2);
  procedure drop_sem_tbtree(idxname varchar2);
  procedure drop_stbtree_textindx(idxname varchar2);
  --fill STB-TREE
  procedure stbinsert(episode sem_episode, sem_trajid sem_traj_id, roid varchar2,
    nodetab varchar2, leaftab varchar2,maxleafentries integer:=155, maxnodeentries integer:=155);
  procedure saveleaf(leaf sem_stbleaf, leaftab varchar2, existence boolean);
  procedure savenode(node sem_stbnode, nodetab varchar2, existence boolean, nid integer);
  function findleaf(sem_trajid sem_traj_id, leaftab varchar2) return sem_stbleaf;
  function chooselastleaf(nodetab varchar2, leaftab varchar2) return sem_stbleaf;
  function adjusttree(l sem_stbleaf,ll sem_stbleaf,nodetab varchar2,leaftab varchar2,maxentries integer:=155) return sem_stbnode;
  function ncoveringmbb(node sem_stbnode) return sem_mbb;
  function lcoveringmbb(leaf sem_stbleaf) return sem_mbb;
  function includes(sourcembr sem_mbb, insertedmbr sem_mbb) return boolean;
  
  --range queries on STB-TREE
  --range that returns episodes intersecting inmbb having defining tag=episode_type or all (if is null)
  function stb_range_episodes(inputepisode sem_episode, stbtreeprefix varchar2) return sem_episode_tab;
  --load full stbtree index in memory and call the following (bad choice)
  function stb_range_episodes(inputepisode sem_episode, nodes stbtree_nodes_tab_typ, leaves stbtree_leaves_tab_typ) return sem_episode_tab;
  --range that returns leaf entries ids for given sem_mbb used by pattern_mbbs function method 2
  function stb_range_leafentries(inputepisode sem_episode, stbtreeprefix varchar2) return sem_stbleafentrymid_tab;
  --this is a range query for MOVE episodes that originate from geomfrom and wind up at geomto and live in tp timeperiod
  function stb_range_episodes(geomfrom mdsys.sdo_geometry, geomto mdsys.sdo_geometry,tp tau_tll.d_period_sec, stbtreeprefix varchar2) return sem_episode_tab;
  function stb_range_episodes(episode_type varchar2, geom mdsys.sdo_geometry, stbtreeprefix varchar2) return sem_episode_tab;
  function stb_range_episodes(episode_type varchar2, tp tau_tll.d_period_sec, stbtreeprefix varchar2) return sem_episode_tab;
  function stb_from_to_via(from_stop sem_episode, to_stop sem_episode, via_move sem_episode, stbtreeprefix varchar2) return sem_episode_tab;
  --range by using first the tag index so to prunn leaves found by rtree.All tags are taken into account
  --function stb_range_episodes(inputepisode sem_episode, validleafentries sem_stbleafentrymid_tab, stbtreeprefix varchar2) return sem_episode_tab;
  function stb_range_episodes(inputepisode sem_episode, validleafentries varchar2, stbtreeprefix varchar2) return sem_episode_tab;
    
  procedure calcfeatures(outputtblfeatures varchar2, refer ref sub_moving_point, episode_type varchar2);
  --mind hard coded value
  procedure calcallfeatures(outputtblfeatures varchar2, intblsemtrajs varchar2);
  
  --pattern query functions
  function stb_patterns_tags(inputquery varchar2, stbtree varchar2) return integer_nt;--pipelined  old version of the next one
  function stb_patterns(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return integer_nt;
  function stb_patterns_semtrajids(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return sem_traj_ids;--alternate of previous
  function stb_patterns_leafids(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return sem_stbleafentrymid_tab;--alternate of previous
  function stb_patterns_episodes(inputepisodes sem_episode_tab, inputchars varchar_ntab, stbtree varchar2, method integer:=1) return sem_episode_tab;--alternate of previous
  function combine(previous_tab sem_stbleafentrymid_tab, after_tab sem_stbleafentrymid_tab, wildchar varchar2, stbtree varchar2) return sem_stbleafentrymid_tab;
  function pattern_tags(epis sem_episode, wildchar varchar2, previous_episode_solutions sem_stbleafentrymid_tab,stbtree varchar2) return sem_stbleafentrymid_tab;
  function pattern_mbbs(inputepisode sem_episode, wildchar varchar, method integer, previous_episode_solutions sem_stbleafentrymid_tab,
    solutions_from_tags sem_stbleafentrymid_tab, stbtree varchar2) return sem_stbleafentrymid_tab;
  
end STD;
/


