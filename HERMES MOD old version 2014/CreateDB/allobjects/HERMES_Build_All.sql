--
-- Create Schema Script 
--   Database Version   : 11.2.0.1.0 
--   TOAD Version       : 9.7.0.51 
--   DB Connect String  : ORA11G 
--   Schema             : HERMES 
--   Script Created by  : HERMES 
--   Script Created at  : 10/13/2013 11:44:34 PM 
--   Physical Location  :  
--   Notes              :  
--

-- Object Counts: 
--   Users: 1           Sys Privs: 140      Roles: 16            
-- 
--   Directories: 12 
--   Functions: 6       Lines of Code: 371 
--   Indexes: 101       Columns: 134        
--   Java Sources: 26 
--   Libraries: 2 
--   Packages: 23       Lines of Code: 893 
--   Package Bodies: 23 Lines of Code: 21215 
--   Procedures: 3      Lines of Code: 15 
--   Sequences: 26 
--   Tables: 193        Columns: 1163       Constraints: 74     
--   Types: 104 
--   Type Bodies: 15 
--   Views: 6           




--@CreateDB\allobjects\Users/HERMES.sql;
@CreateDB\allobjects\Types/NUMBER_SET.tps;
@CreateDB\allobjects\Types/CENTROID_PAIR.tps;
@CreateDB\allobjects\Types/CLUSTER_PAIR.tps;
@CreateDB\allobjects\Types/CLUSTER_LIST.tps;
@CreateDB\allobjects\Types/COORDS.tps;
@CreateDB\allobjects\Types/DPV.tps;
@CreateDB\allobjects\Types/DPV_NT.tps;
@CreateDB\allobjects\Types/FOCAL_POINT.tps;
@CreateDB\allobjects\Types/FC_PTS_TAB.tps;
@CreateDB\allobjects\Types/GEOM_SET.tps;
@CreateDB\allobjects\Types/GEOM_TBL.tps;
@CreateDB\allobjects\Types/IDS.tps;
@CreateDB\allobjects\Types/INTEGER_NT.tps;
@CreateDB\allobjects\Types/SP_POS.tps;
@CreateDB\allobjects\Types/SP_POS_NT.tps;
@CreateDB\allobjects\Types/SPT_POS.tps;
@CreateDB\allobjects\Types/SPT_POS_NT.tps;
@CreateDB\allobjects\Types/SP_POINT_XY.tps;
@CreateDB\allobjects\Types/SPT_POINT_XY.tps;
@CreateDB\allobjects\Types/SP_BOX_XY.tps;
@CreateDB\allobjects\Types/SPT_POS_ORG.tps;
@CreateDB\allobjects\Types/SPT_POS_ORG_NT.tps;
@CreateDB\allobjects\Types/LINE_SEGMENT_SMALL.tps;
@CreateDB\allobjects\Types/LINE_SEGMENT_SMALL_NT.tps;
@CreateDB\allobjects\Types/LINE_SEGMENT.tps;
@CreateDB\allobjects\Types/LINE_SEGMENT_NT.tps;
@CreateDB\allobjects\Types/INTERNAL_CLUSTER.tps;
@CreateDB\allobjects\Types/INTERNAL_CLUSTER_NT.tps;
@CreateDB\allobjects\Types/LL_POS.tps;
@CreateDB\allobjects\Types/LL_POS_NT.tps;
@CreateDB\allobjects\Types/TBX.tps;
@CreateDB\allobjects\Types/TBPOINT.tps;
@CreateDB\allobjects\Types/TBMBB.tps;
@CreateDB\allobjects\Types/TBTREELEAFENTRY.tps;
@CreateDB\allobjects\Types/LEAFENTRIES.tps;
@CreateDB\allobjects\Types/LEAFENTRIES2.tps;
@CreateDB\allobjects\Types/UNIT_CENTROID_TAB.tps;
@CreateDB\allobjects\Types/MODEL_CENTROID.tps;
@CreateDB\allobjects\Types/MODEL_CLUSTER.tps;
@CreateDB\allobjects\Types/UNIT_DIR.tps;
@CreateDB\allobjects\Types/UNIT_TAU.tps;
@CreateDB\allobjects\Types/UNIT_FCM.tps;
@CreateDB\allobjects\Types/MODEL_FCM.tps;
@CreateDB\allobjects\Types/UNIT_REGION.tps;
@CreateDB\allobjects\Types/UNIT_INTERVAL.tps;
@CreateDB\allobjects\Types/UNIT_TAS.tps;
@CreateDB\allobjects\Types/UNIT_TAS_TAB.tps;
@CreateDB\allobjects\Types/MODEL_TAS.tps;
@CreateDB\allobjects\Types/UNIT_FUNCTION.tps;
@CreateDB\allobjects\Types/UNIT_MOVING_POINT.tps;
@CreateDB\allobjects\Types/UNIT_MOVING_POINT_NT.tps;
@CreateDB\allobjects\Types/MOVING_POINT_TAB.tps;
@CreateDB\allobjects\Types/MOVING_POINT.tps;
@CreateDB\allobjects\Types/MOVING_POINT_SET.tps;
@CreateDB\allobjects\Types/MP_ARRAY.tps;
@CreateDB\allobjects\Types/TBTREENODEENTRY.tps;
@CreateDB\allobjects\Types/NODEENTRIES.tps;
@CreateDB\allobjects\Types/NUMBER_NT.tps;
@CreateDB\allobjects\Types/VARCHAR_NTAB.tps;
@CreateDB\allobjects\Types/OUT_TYPE.tps;
@CreateDB\allobjects\Types/OUT_TYPE_TAB.tps;
@CreateDB\allobjects\Types/TBMOVINGOBJECTENTRY.tps;
@CreateDB\allobjects\Types/TBMOVINGOBJECTENTRIES.tps;
@CreateDB\allobjects\Types/PRIORITYQUEUENODE.tps;
@CreateDB\allobjects\Types/QUEUEENTRIES.tps;
@CreateDB\allobjects\Types/PRIORITYQUEUE.tps;
@CreateDB\allobjects\Types/TBMOVINGOBJECT.tps;
@CreateDB\allobjects\Types/TBMOVINGOBJECTSCOLLECTION.tps;
@CreateDB\allobjects\Types/TBMOVINGDISTANCE.tps;
@CreateDB\allobjects\Types/RELMATRIXDB.tps;
@CreateDB\allobjects\Types/T_RELMATRIXDB.tps;
@CreateDB\allobjects\Types/TBTREENODE.tps;
@CreateDB\allobjects\Types/TBTREELEAF.tps;
@CreateDB\allobjects\Types/TBTREELEAF2.tps;
@CreateDB\allobjects\Types/TAU_TIMEPOINT_NTAB.tps;
@CreateDB\allobjects\Types/TBTREE_IDXTYPE_IM.tps;
@CreateDB\allobjects\Types/SEM_ST_POINT.tps;
@CreateDB\allobjects\Types/SEM_MBB.tps;
@CreateDB\allobjects\Types/SUB_MOVING_POINT.tps;
@CreateDB\allobjects\Types/SUB_MOVING_POINT_TAB.tps;
@CreateDB\allobjects\Types/SEM_EPISODE.tps;
@CreateDB\allobjects\Types/SEM_EPISODE_TAB.tps;
@CreateDB\allobjects\Types/SEM_TRAJECTORY.tps;
@CreateDB\allobjects\Types/SEM_TRAJECTORY_TAB.tps;
@CreateDB\allobjects\Types/SEM_TRAJ_ID.tps;
@CreateDB\allobjects\Types/SEM_TRAJ_IDS.tps;
@CreateDB\allobjects\Types/SEM_STBLEAF_ENTRY.tps;
@CreateDB\allobjects\Types/SEM_STBLEAF_ENTRIES.tps;
@CreateDB\allobjects\Types/SEM_STBLEAF_ENTRIES_NT.tps;
@CreateDB\allobjects\Types/SEM_STBLEAF.tps;
@CreateDB\allobjects\Types/SEM_STBLEAFENTRYID.tps;
@CreateDB\allobjects\Types/SEM_STBLEAFENTRYIDS.tps;
@CreateDB\allobjects\Types/SEM_STBLEAFENTRYMID.tps;
@CreateDB\allobjects\Types/SEM_STBLEAFENTRYMID_TAB.tps;
@CreateDB\allobjects\Types/SEM_STBNODE_ENTRY.tps;
@CreateDB\allobjects\Types/SEM_STBNODE_ENTRIES.tps;
@CreateDB\allobjects\Types/SEM_STBNODE_ENTRIES_NT.tps;
@CreateDB\allobjects\Types/SEM_STBNODE.tps;
@CreateDB\allobjects\Types/SEM_STBNODEENTRYID.tps;
@CreateDB\allobjects\Types/SEM_STBNODEENTRYIDS.tps;
@CreateDB\allobjects\Types/STBTREE_LEAVES.tps;
@CreateDB\allobjects\Types/STBTREE_LEAVES_TAB_TYP.tps;
@CreateDB\allobjects\Types/STBTREE_NODES.tps;
@CreateDB\allobjects\Types/STBTREE_NODES_TAB_TYP.tps;
@CreateDB\allobjects\TypeBodies/MODEL_TAS.tpb;
@CreateDB\allobjects\TypeBodies/TBTREE_IDXTYPE_IM.tpb;
@CreateDB\allobjects\TypeBodies/SUB_MOVING_POINT.tpb;
@CreateDB\allobjects\TypeBodies/MOVING_POINT.tpb;
@CreateDB\allobjects\TypeBodies/SEM_MBB.tpb;
@CreateDB\allobjects\TypeBodies/SEM_ST_POINT.tpb;
@CreateDB\allobjects\TypeBodies/SEM_EPISODE.tpb;
@CreateDB\allobjects\TypeBodies/SEM_TRAJECTORY.tpb;
@CreateDB\allobjects\TypeBodies/PRIORITYQUEUE.tpb;
@CreateDB\allobjects\TypeBodies/LINE_SEGMENT_SMALL.tpb;
@CreateDB\allobjects\TypeBodies/LINE_SEGMENT.tpb;
@CreateDB\allobjects\TypeBodies/INTERNAL_CLUSTER.tpb;
@CreateDB\allobjects\TypeBodies/MODEL_CLUSTER.tpb;
@CreateDB\allobjects\TypeBodies/UNIT_MOVING_POINT.tpb;
@CreateDB\allobjects\TypeBodies/SEM_TRAJ_ID.tpb;

@CreateDB\allobjects\Tables/BELG_SEM_TRAJS.sql;
@CreateDB\allobjects\Tables/DBMSOUTPUT.sql;
@CreateDB\allobjects\Tables/SUB_MPOINTS_TMP.sql;
@CreateDB\allobjects\Tables/ATTIKI_SUB_MPOINTS.sql;
@CreateDB\allobjects\Tables/PARAMETERS.sql;
@CreateDB\allobjects\Tables/MV_TBL.sql;
@CreateDB\allobjects\Tables/MOVINGOBJECTS.sql;
@CreateDB\allobjects\Tables/FAKES.sql;
@CreateDB\allobjects\Tables/INIT_END.sql;
@CreateDB\allobjects\Tables/HIST.sql;
@CreateDB\allobjects\Tables/HIST_TRAJS.sql;
@CreateDB\allobjects\Tables/H_BENCHMARK.sql;
@CreateDB\allobjects\Tables/H_BENCHMARK_RUN.sql;
@CreateDB\allobjects\Tables/H_FAKE_DUR.sql;
@CreateDB\allobjects\Tables/H_RANGE_DUR.sql;
@CreateDB\allobjects\Tables/H_RANGE_NOP_DUR.sql;
@CreateDB\allobjects\Tables/H_KNN_DUR.sql;
@CreateDB\allobjects\Tables/H_KNN_NOP_DUR.sql;
@CreateDB\allobjects\Tables/POI_MILANO.sql;
@CreateDB\allobjects\Tables/TRACLUS_RESULT.sql;
@CreateDB\allobjects\Tables/TRACLUS_RESULT_EXT.sql;
@CreateDB\allobjects\Tables/TRACLUS_RESULT_DIST.sql;
@CreateDB\allobjects\Tables/DIST_VOL.sql;
@CreateDB\allobjects\Tables/HISTORY_TABLE.sql;
@CreateDB\allobjects\Tables/HIST_CLUSTER_TABLE.sql;
@CreateDB\allobjects\Tables/BRINKHOFF_RESULT.sql;
@CreateDB\allobjects\Tables/BELG_SEM_EPISODES_FEATURES.sql;
@CreateDB\allobjects\Tables/TBTREEIDX_CLONE_NON_LEAF.sql;
@CreateDB\allobjects\Tables/TBTREEIDX_CLONE_LEAF.sql;
@CreateDB\allobjects\Tables/FACTTBL.sql;
@CreateDB\allobjects\Tables/TMPFACTTBL.sql;
@CreateDB\allobjects\Tables/TIMESLOTS.sql;
@CreateDB\allobjects\Tables/DEBUG_MPOINTS.sql;
--@CreateDB\allobjects\Tables/ATTIKI_MPOINTS.sql;
@CreateDB\allobjects\Tables/BRINKHOFF_POIS.sql;
@CreateDB\allobjects\Tables/HPV_RESULT.sql;
@CreateDB\allobjects\Tables/TEMPTEMP.sql;
@CreateDB\allobjects\Tables/RECTANGLE.sql;
@CreateDB\allobjects\Tables/BRINKHOFF_NODES.sql;
@CreateDB\allobjects\Tables/BELGSUB_STOPS_MPOINTS.sql;
@CreateDB\allobjects\Tables/MPOINTS.sql;
@CreateDB\allobjects\Tables/SECUREFILE_TAB.sql;
@CreateDB\allobjects\Tables/BRINKHOFF_TEMP.sql;
@CreateDB\allobjects\Tables/BELGSUB_STOPS_FOUND.sql;
@CreateDB\allobjects\Tables/DATAFORSTATISTICGRAPHS.sql;

@CreateDB\allobjects\Tables/ATTIKI_STBTREE_NON_LEAF.sql;
@CreateDB\allobjects\Tables/ATTIKI_STBTREE_LEAF.sql;
@CreateDB\allobjects\Views/TIME_PERIODS.vw;

@CreateDB\allobjects\Functions/GET_LONG_LAT_PT.fnc;
--@CreateDB\allobjects\Indexes/BRINKHOFF_NODES_IDX.sql;
@CreateDB\allobjects\Indexes/ATTIKI_PK.sql;
@CreateDB\allobjects\Indexes/HPV_RESULT_PK.sql;
@CreateDB\allobjects\Indexes/H_BENCHMARK_RUN_PK.sql;
@CreateDB\allobjects\Indexes/H_BENCHMARK_PK.sql;
@CreateDB\allobjects\Indexes/HIST_TRAJS_PK.sql;
@CreateDB\allobjects\Indexes/HIST_PK.sql;
@CreateDB\allobjects\Indexes/INIT_END_PK.sql;
@CreateDB\allobjects\Indexes/FAKES_PK.sql;
@CreateDB\allobjects\Indexes/MOVINGOBJECTSIDX.sql;
@CreateDB\allobjects\Indexes/UNG_PARAMETER.sql;

@CreateDB\allobjects\Sequences/REC_SEQ_ID.sql;
@CreateDB\allobjects\Sequences/TIMESLOT_SEQ_ID.sql;

@CreateDB\allobjects\Packages/VISUALIZER.pks;
@CreateDB\allobjects\Packages/UTILITIES.pks;
@CreateDB\allobjects\Packages/TRACLUS.pks;
@CreateDB\allobjects\Packages/TDW.pks;
@CreateDB\allobjects\Packages/TBTREEMETADATA_PKG.pks;
@CreateDB\allobjects\Packages/TBOPERATOR_FUNCTIONAL_IMPL.pks;
@CreateDB\allobjects\Packages/TBFUNCTIONS.pks;
@CreateDB\allobjects\Packages/STD.pks;
@CreateDB\allobjects\Packages/STATISTICS.pks;
--@CreateDB\allobjects\Packages/SESS_MEM_USAGE.pks;
@CreateDB\allobjects\Packages/SEM_RECONSTRUCT.pks;
@CreateDB\allobjects\Packages/SDW.pks;
@CreateDB\allobjects\Packages/RAW_TRAJECTORIES_LOADER.pks;
@CreateDB\allobjects\Packages/OD_MATRIX.pks;
@CreateDB\allobjects\Packages/ODYSSEY_PACKAGE.pks;
@CreateDB\allobjects\Packages/HPV.pks;
@CreateDB\allobjects\Packages/HERMOUPOLIS.pks;
@CreateDB\allobjects\Packages/HERMES_GSTD.pks;
@CreateDB\allobjects\Packages/FORDEBUGING.pks;
@CreateDB\allobjects\Packages/DISTORTION.pks;
--@CreateDB\allobjects\Packages/DEBUG_EXTPROC.pks;
@CreateDB\allobjects\Packages/BRINKHOFF.pks;
@CreateDB\allobjects\Packages/AGGREGATIONS.pks;
@CreateDB\allobjects\PackageBodies/VISUALIZER.pkb;
@CreateDB\allobjects\PackageBodies/UTILITIES.pkb;
@CreateDB\allobjects\PackageBodies/TRACLUS.pkb;
@CreateDB\allobjects\PackageBodies/TDW.pkb;
@CreateDB\allobjects\PackageBodies/TBTREEMETADATA_PKG.pkb;
@CreateDB\allobjects\PackageBodies/TBOPERATOR_FUNCTIONAL_IMPL.pkb;
@CreateDB\allobjects\PackageBodies/TBFUNCTIONS.pkb;
@CreateDB\allobjects\PackageBodies/STD.pkb;
@CreateDB\allobjects\PackageBodies/STATISTICS.pkb;
--@CreateDB\allobjects\PackageBodies/SESS_MEM_USAGE.pkb;
@CreateDB\allobjects\PackageBodies/SEM_RECONSTRUCT.pkb;
@CreateDB\allobjects\PackageBodies/SDW.pkb;
@CreateDB\allobjects\PackageBodies/RAW_TRAJECTORIES_LOADER.pkb;
@CreateDB\allobjects\PackageBodies/OD_MATRIX.pkb;
@CreateDB\allobjects\PackageBodies/ODYSSEY_PACKAGE.pkb;
@CreateDB\allobjects\PackageBodies/HPV.pkb;
@CreateDB\allobjects\PackageBodies/HERMOUPOLIS.pkb;
@CreateDB\allobjects\PackageBodies/HERMES_GSTD.pkb;
@CreateDB\allobjects\PackageBodies/FORDEBUGING.pkb;
@CreateDB\allobjects\PackageBodies/DISTORTION.pkb;
--@CreateDB\allobjects\PackageBodies/DEBUG_EXTPROC.pkb;
@CreateDB\allobjects\PackageBodies/BRINKHOFF.pkb;
@CreateDB\allobjects\PackageBodies/AGGREGATIONS.pkb;

--@CreateDB\allobjects\Procedures/MEM_USE_KILO.prc;
@CreateDB\allobjects\Procedures/HOST_COMMAND2.prc;
@CreateDB\allobjects\Procedures/HOST_COMMAND.prc;
@CreateDB\allobjects\Procedures/TASK_IN_PARALLEL.prc;

@CreateDB\allobjects\Functions/TD_TR.fnc;
@CreateDB\allobjects\Functions/SED.fnc;
@CreateDB\allobjects\Functions/RE_SAMPLE.fnc;
@CreateDB\allobjects\Functions/F_DOUGLAS_PEUCKER.fnc;
@CreateDB\allobjects\Functions/BOPW_TR.fnc;

@CreateDB\allobjects\JavaSources/TO_TSAMPLING.jvs;
@CreateDB\allobjects\JavaSources/TO_TPATTERNS.jvs;
@CreateDB\allobjects\JavaSources/TOTRACLUS.jvs;
@CreateDB\allobjects\JavaSources/TOMYTOPTICSSEM.jvs;
@CreateDB\allobjects\JavaSources/TOMYTOPTICS.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_LOADPROPERTY.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_DATAPOINT.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_ENTITY.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_STOP.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_SPATIAL.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_FEATUREVECTOR.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_SEQUENCE.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_LATLONG.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_CARTESIANPOINT.jvs;
@CreateDB\allobjects\JavaSources/STOPFINDER_DISTANCE.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_READDATA.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_LINE.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_ANGELRATE.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_NEIGHBORLIST.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_MOVE.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_CREATESTOPMOVE.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_COMPARECLUSTER.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_OPTICSALGORITHM.jvs;
--@CreateDB\allobjects\JavaSources/STOPFINDER_APPLICATION.jvs;
@CreateDB\allobjects\JavaSources/Host2.jvs;
@CreateDB\allobjects\JavaSources/Host.jvs;

@CreateDB\allobjects\Constraints/PARAMETERS_NonFK.sql;
@CreateDB\allobjects\Constraints/FAKES_NonFK.sql;
@CreateDB\allobjects\Constraints/INIT_END_NonFK.sql;
@CreateDB\allobjects\Constraints/HIST_NonFK.sql;
@CreateDB\allobjects\Constraints/HIST_TRAJS_NonFK.sql;
@CreateDB\allobjects\Constraints/H_BENCHMARK_NonFK.sql;
@CreateDB\allobjects\Constraints/H_BENCHMARK_RUN_NonFK.sql;
@CreateDB\allobjects\Constraints/HISTORY_TABLE_NonFK.sql;
@CreateDB\allobjects\Constraints/HIST_CLUSTER_TABLE_NonFK.sql;
@CreateDB\allobjects\Constraints/HPV_RESULT_NonFK.sql;
@CreateDB\allobjects\Constraints/HIST_TRAJS_FK.sql;
@CreateDB\allobjects\Constraints/H_BENCHMARK_RUN_FK.sql;
@CreateDB\allobjects\Constraints/H_FAKE_DUR_FK.sql;
@CreateDB\allobjects\Constraints/H_RANGE_DUR_FK.sql;
@CreateDB\allobjects\Constraints/H_RANGE_NOP_DUR_FK.sql;
@CreateDB\allobjects\Constraints/H_KNN_DUR_FK.sql;
@CreateDB\allobjects\Constraints/H_KNN_NOP_DUR_FK.sql;
