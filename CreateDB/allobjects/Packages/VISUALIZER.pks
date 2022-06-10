Prompt Package VISUALIZER;
CREATE OR REPLACE PACKAGE visualizer
AS
   TYPE cursortype IS REF CURSOR;

   FUNCTION replaceclob ( srcclob IN  CLOB, replacestr IN  VARCHAR2, replacewith  IN VARCHAR2 ) RETURN CLOB;

   PROCEDURE polygon2kml ( geom MDSYS.SDO_GEOMETRY, outsrid INTEGER, outkmlfile   VARCHAR2 );

   PROCEDURE polygon2volume3d2kml ( geom MDSYS.SDO_GEOMETRY, outsrid INTEGER, outkmlfile VARCHAR2, altitude NUMBER );

   PROCEDURE linestring2kml ( geom MDSYS.SDO_GEOMETRY, outsrid INTEGER, outkmlfile VARCHAR2 );

   PROCEDURE placemark2kml ( geom MDSYS.SDO_GEOMETRY, outsrid INTEGER, outkmlfile VARCHAR2, message1 VARCHAR2, message2 VARCHAR2 );

   PROCEDURE movingpoint2kml ( mp hermes.moving_point, outsrid INTEGER, outkmlfile  VARCHAR2 );

   PROCEDURE movingpointtable2wkt (mps mp_array, outwktfile VARCHAR2, table_name VARCHAR2);

   PROCEDURE MovingPointTable2TXT(mps mp_array, outTXTfile VARCHAR2, table_name VARCHAR2);
-- **
-- * Visualizes a given semantic trajectory, i.e. the MBRs of its episodes and the corresponding raw sub-trajectories
-- *
-- * @param semtraj. The semantic trajectory of intrest
-- * @param bln_mpoints. If we want to visualize the movingi poitns of its episodes(TRUE/FALSE)
-- * @param bln_rect. If we want to visualize the MBR of its episodes(TRUE/FALSE)
-- * @param bln_cent If we want to visualize the centroid of its episodes MBRs
-- **
   PROCEDURE semtrajectory2kml ( semtraj IN sem_trajectory, bln_mpoints IN VARCHAR2, bln_rect IN VARCHAR2, bln_cent IN VARCHAR2 );
   --below are procedures to output kml files. You should use visualizer for this normally
  procedure movingpoint2kml(fileprefix varchar2, mpoint moving_point);
  procedure movingpointtable2kml(fileprefix varchar2, mpoints mp_array);
  procedure episode2kml(episode sem_episode);
  procedure mbr2kml(mbb sdo_geometry, tag varchar2);
  --below are procedures to output wkt files.
  procedure mbr2wkt(mbb sdo_geometry, tag varchar2);
  procedure geom2wkt(geom sdo_geometry, tag varchar2);
  procedure movingpointtable2wkt(mpoints mp_array, tag varchar2);
  procedure episodes2wkt(episodes sem_episode_tab,srid number, tag varchar2);
  --visualizetype takes values: 0 if a semantic trajectory is outputed as sequence of stop episodes(polygons or points)
  --more can be added...        1 if a semantic trajectory is outputed as sequence of stop episodes(polygons or points) and moves(lines)
  --                            2 if a semantic trajectory is outputed as sequence of stop episodes(polygons or points) and moves(polygons)
  procedure semtrajectories2wkt(semtrajs sem_trajectory_tab, tag varchar2, visualizetype number);
END;
/


