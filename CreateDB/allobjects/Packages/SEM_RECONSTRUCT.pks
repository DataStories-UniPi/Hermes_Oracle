Prompt Package SEM_RECONSTRUCT;
CREATE OR REPLACE PACKAGE        sem_reconstruct
AS
  ex_custom EXCEPTION;
  stmt      VARCHAR2 (5000);
  srid PLS_INTEGER;
  tolerance NUMBER                := 0.005;
  bltrue    CONSTANT VARCHAR2(10) := 'TRUE';
  blfalse   CONSTANT VARCHAR2(10) := 'FALSE';
  --calling stopfinder java stored procedure
  --MIND COMMAS AND PERIODS. IT NEEDS PERIODS AS DECIMAL SEPARATOR FOR NUMBER
  --IN INPUT FILE
  PROCEDURE stopfinder( dir  VARCHAR2, conf VARCHAR2)
  AS
    language java NAME 'stopfinder.Application.main(java.lang.String[])';
  --output file for T-OPTICS (stopsfinder)
  PROCEDURE stopfinderinputfile( o_id pls_integer, traj_id pls_integer, mpoint moving_point, subtraj_id pls_integer:=0);
  --this procedure takes sem trajs from belgdiariestosemtrajs (ver1) and
  --stops found by t-optics (belgsub_stops_found) and produces new sem trajs based
  --on those stops (belgsub_sem_trajs) ver2
  procedure stops2semtrajs( inputtblstopseqs varchar2, inputtblsemmpoints varchar2, outputtblsubmpoints varchar2, outputtblsemmpoints varchar2);
  --create semantic trajectories with episodes
  procedure rawtrajs2semtrajs( inputtblstopseqs varchar2, inputtblmpoints varchar2, outputtblsubmpoints varchar2, outputtblsemmpoints varchar2);
  --below is a feathers output 2 semantic trajectories constructor
  procedure feathers2semtrajs(featherstab varchar2, subzonestab varchar2, outputtblsemmpoints VARCHAR2, from_person number, to_person number, srid integer:=8307);
  
  procedure discoverepisodes(inputtblstopseqs varchar2, inputtblmpoints varchar2,
    outputtblsubmpoints varchar2, outputtblsmpoints varchar2, outputtblfeatures varchar2);
  function getstoppoints(userid integer, trajid integer, stopid integer, stopstbl varchar2) 
    return moving_point_tab;
  function getmovepoints(mpoint moving_point, inuserid integer,intrajid integer, oldstopid integer,
    newstopid integer, stopstbl varchar2) return moving_point_tab;
  procedure stops2mpoints( inputtblstopseqs varchar2, outputtblsubmpoints varchar2);
  --create trajectories from gps data
  procedure reconstructtrajectories(sourcetblgps varchar2, srid integer, targettblmpoints varchar2
    , spacegapmet number, timegapsec number);
  procedure reconstructtrajectoriestoraw(sourcetblgps varchar2, srid integer,
    targettblraw varchar2, spacegapmet number, timegapsec number);
  function last_distance(p1 unit_function, p2x number, p2y number, srid integer) return number;
  function last_duration(t1 tau_tll.d_period_sec, p2t tau_tll.d_timepoint_sec) return number;
  
  --from diaries to semantic trajectories for belg dataset
  procedure belgdiariestosemtrajs;
  function belggetmove(userid number, semtraj number, subtraj number,tripid number,
    srid number) return sem_episode;
  function belgmakestop(userid number, semtraj number, subtraj number,tripid number,
    srid number,atend boolean,firststop boolean) return sem_episode;
  procedure getusersgpsdiaries;
  --utilities
  procedure exportdata(intblsemtrajs varchar2, outblsemtrajs varchar2, semtrajsfile varchar2, insubmpoints varchar2, outblsubmpoints varchar2, submpointsfile varchar2);
  procedure exportindmp(tblname varchar2);  
  procedure importfromdmp(tblname varchar2);
  procedure exportsemtrajs2import(intblsemtrajs varchar2, outblsemtrajs varchar2, filename varchar2);
  procedure exportsubmpoints2import(intblsubmpoints varchar2, outblsubmpoints varchar2, filename varchar2);
  procedure updatesubmpointrefs(intblsemtrajs varchar2, insubmpoints varchar2);
  
  --fix sub mpoints errors
  procedure fixsubmpoints(oid integer,tid integer,subtid integer,tab integer);
  -- *
  -- * @param tablename. The name of the table with the parameter. Max size 30char. Ex: pkg_x.var_y
  -- * @param parametername. The name of the parameter we want. Max size 30char
  -- * @return varchar2 value
  -- **    
  FUNCTION getparameter( tablename IN VARCHAR2, parametername IN VARCHAR2) RETURN VARCHAR2;
  -- **
  -- * Finds and visualizes POIS that are within given MBB
  -- *
  -- * @param mbb. The mbb of intrest
  -- * @param is4visualize. If we want to visualize and print out the results (TRUE/FALSE)
  -- **
  procedure pois_probability (mbb in sem_mbb, insrid pls_integer, is4visualize in varchar2, poitable varchar2,bestpoitag out varchar2);
  -- **
  -- * Find the K  -Nearest-Neighbor (K-NN) Points-Of-Interest (POI) w.r.t. the centroid of the MBR of an episode
  -- *
  -- * @param mbb. The mbb of intrest
  -- * @param is4visualize. If we want to visualize and print out the results (TRUE/FALSE)
  -- **
  procedure nn_pois (mbb in sem_mbb, k integer, is4visualize in varchar2);
  
  procedure annotate_episodes(semtrajs varchar2, poitable varchar2);
  
  procedure submpointsmerging(submpoints varchar2, mpoints varchar2);
END sem_reconstruct;
/


