Prompt Type MOVING_POINT;
CREATE OR REPLACE TYPE moving_point AS OBJECT (
   -- A series of Unit_Moving_Point defining the consequent parts of a Moving_Point
   u_tab   moving_point_tab,        -- previous name of the attribute was "p"
   --The trajectory id should be placed in the moving object so as to be retrieved by
   --ODCIIndexUpdate and ODCIIndexInsert
   traj_id Integer,
   --srid also is need it by many member functions
   srid integer,
   -- Returns moving point as a CLOB
   -- ###### MEMBER FUNCTIONS #####
   MEMBER FUNCTION to_clob RETURN CLOB,
   -- Returns moving point as a string
   MEMBER FUNCTION to_string RETURN VARCHAR2,
   -- Prints moving point to standard output
   MEMBER PROCEDURE print_moving_point,
   -- Add a unit_moving_point
   MEMBER PROCEDURE add_unit (new_unit unit_moving_point),
   -- Merge two Moving_Points
   MEMBER FUNCTION merge_moving_points (mp1 moving_point, mp2 moving_point) RETURN moving_point,
   --Checks if there is an ascending sorting of the periods in the nested table
   MEMBER FUNCTION check_sorting RETURN BOOLEAN,
   --Checks if even one period in the nested table overlaps with the next in order period...THEN returns FALSE
   MEMBER FUNCTION check_disjoint RETURN BOOLEAN,
   --Checks if even one period in the nested table does NOT meets with the next in order period...THEN returns FALSE
   MEMBER FUNCTION check_meet RETURN BOOLEAN,
   -- Returns that Unit_Moving_Point that corresponds to a specific timepoint
   MEMBER FUNCTION unit_type (tp tau_tll.d_timepoint_sec) RETURN unit_moving_point,
   -- Sorts the multi-point argument geometry by time
   MEMBER FUNCTION sort_by_time (mpoint IN OUT MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY,
   -- Return the enter and leave points of the moving point for a given geometry
   MEMBER FUNCTION get_enter_leave_points (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY,
   -- Returns a MDSYS.SDO_GEOMETRY of Point type as the result of Mapping/Projecting the Moving_Point at a specific timepoint
   MEMBER FUNCTION at_instant (tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
   -- Returns a moving point restricted at a specific period
   MEMBER FUNCTION at_period (per tau_tll.d_period_sec) RETURN moving_point,
   -- Returns a moving point restricted at a specific temporal element
   MEMBER FUNCTION at_temp_element (te tau_tll.d_temp_element_sec) RETURN moving_point,
   -- Restricts the moving point at the space specified by the linestring parameter which is supposed to be part of his route
   MEMBER FUNCTION at_linestring (line MDSYS.SDO_GEOMETRY) RETURN moving_point,
   -- Returns tha last valid timepoint of the lifespan of the moving point
   MEMBER FUNCTION f_final_timepoint RETURN tau_tll.d_timepoint_sec,
   -- Returns tha first valid timepoint of the lifespan of the moving point
   MEMBER FUNCTION f_initial_timepoint RETURN tau_tll.d_timepoint_sec,
   -- Returns the timepoint that corresponds to a specific xy coords
   MEMBER FUNCTION get_time_point (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec,
   -- Returns a linestring geometry representing the points that this moving point traverses! NOTE: For linear motions use "f_trajectory2"
   MEMBER FUNCTION f_trajectory RETURN MDSYS.SDO_GEOMETRY,
   MEMBER FUNCTION f_trajectory2 RETURN MDSYS.SDO_GEOMETRY,
   -- Returns a temporal element constructed by the union of the periods for which the moving point is defined
   MEMBER FUNCTION f_temp_element RETURN tau_tll.d_temp_element_sec,
   -- Returns the instanced point as this is defined at the first valid second
   MEMBER FUNCTION f_initial RETURN MDSYS.SDO_GEOMETRY,
   -- Returns the instanced point as this is defined at the last valid second
   MEMBER FUNCTION f_final RETURN MDSYS.SDO_GEOMETRY,
   -- Returns the angle of the moving point' s direction
   MEMBER FUNCTION f_direction (tp tau_tll.d_timepoint_sec) RETURN NUMBER,
   -- Returns TRUE for objects being in front of moving point at the given timepoint
   MEMBER FUNCTION f_front (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min   NUMBER, angle_max   NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being behind of moving point at the given timepoint
   MEMBER FUNCTION f_behind (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being left of moving point at the given timepoint
   MEMBER FUNCTION f_left (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being right of moving point at the given timepoint
   MEMBER FUNCTION f_right (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being north of moving point at the given timepoint
   MEMBER FUNCTION f_north (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being south of moving point at the given timepoint
   MEMBER FUNCTION f_south (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being east of moving point at the given timepoint
   MEMBER FUNCTION f_east (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE for objects being west of moving point at the given timepoint
   MEMBER FUNCTION f_west (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER,
   -- Returns TRUE when the moving point is between the multi-geometry at the given timepoint
   MEMBER FUNCTION f_between (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER,
    -- Returns the rate of change of the Euclidean distance (speed) that the moving point traverses at a specific time point
   MEMBER FUNCTION f_speed (tp tau_tll.d_timepoint_sec) RETURN NUMBER,
    -- Generates a buffer polygon around an instanced point at a specific timepoint
   MEMBER FUNCTION f_buffer (distance NUMBER, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Computes the distance between two moving points instanced at a specific timepoint.
    -- The distance between two geometry objects is the distance between the closest pair of points or segments of the two objects
   MEMBER FUNCTION f_distance (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN NUMBER,
    -- Computes the distance between a moving point instanced at a specific timepoint and another geometry type.
    -- The distance between two geometry objects is the distance between the closest pair of points or segments of the two objects
   MEMBER FUNCTION f_distance (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN NUMBER,
    -- Determines if this moving point is within some specified Euclidean distance from other moving objects at  a specific timepoint
   MEMBER FUNCTION f_within_distance (distance NUMBER, moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2,
    -- Determines if this moving point is within some specified Euclidean distance from other geometry objects at a specific timepoint
   MEMBER FUNCTION f_within_distance (distance NUMBER, geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2,
    -- Examines current Moving_Point to determine its spatial relationship with another moving point
   MEMBER FUNCTION f_relate (MASK VARCHAR2, moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2,
    -- Examines current Moving_Point to determine its spatial relationship with other geometry objects
   MEMBER FUNCTION f_relate (MASK VARCHAR2, geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN VARCHAR2,
    -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point with another moving point at a specific timepoint
   MEMBER FUNCTION f_intersection (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point at a specific timepoint with another geometry object
   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns a moving point that is the restriction (intersection) of the calling moving point inside the polygon argument
   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER) RETURN moving_point,
    -- Returns a moving point that is the restriction (intersection) of the calling moving point inside the polygon argument
   MEMBER FUNCTION f_intersection2 (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER) RETURN moving_point,
    -- Computes the linestring and the period that is the restriction (intersection) of the calling moving point inside the polygon argument
   MEMBER PROCEDURE f_intersection (geom MDSYS.SDO_GEOMETRY, line_inside OUT MDSYS.SDO_GEOMETRY, period_inside OUT tau_tll.d_period_sec, tolerance NUMBER),
    -- Returns a moving point (and the corresponding linestring and period) that is the restriction (intersection) of the calling moving point inside the polygon argument
   MEMBER FUNCTION f_intersection (geom MDSYS.SDO_GEOMETRY, line_inside OUT MDSYS.SDO_GEOMETRY, period_inside OUT tau_tll.d_period_sec, tolerance NUMBER) RETURN moving_point,
    -- Returns a geometry object that is the topological union (OR operation) of an instanced point with this moving point at a specific timepoint
   MEMBER FUNCTION f_union (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns a geometry object that is the topological union (OR operation) of an instanced point at a specific timepoint with another geometry object
   MEMBER FUNCTION f_union (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns a geometry object that is the topological symmetric difference (XOR operation) of an instanced point with this moving point at a specific timepoint
   MEMBER FUNCTION f_xor (moving_point moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
   -- Returns a geometry object that is the topological symmetric difference (XOR operation) of an instanced point at a specific timepoint with another geometry object
   MEMBER FUNCTION f_xor (geom MDSYS.SDO_GEOMETRY, tolerance NUMBER, tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns the points(sorted by time) that the moving point enters inside the area of the polygon argument
   MEMBER FUNCTION f_enterpoints (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns the points(sorted by time) that the moving point leaves the area of the polygon argument
   MEMBER FUNCTION f_leavepoints (geom MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY,
    -- Returns the timepoint that the moving point entered the given polygonal geometry
   MEMBER FUNCTION f_enter (geom MDSYS.SDO_GEOMETRY) RETURN tau_tll.d_timepoint_sec,
    -- Returns the timepoint that the moving point left the given polygonal geometry
   MEMBER FUNCTION f_leave (geom MDSYS.SDO_GEOMETRY) RETURN tau_tll.d_timepoint_sec,
    -- Returns the average speed of a moving point during its lifespan
    MEMBER FUNCTION f_avg_speed RETURN NUMBER,
    -- Returns the average acceleration of a moving point during its lifespan
    MEMBER FUNCTION f_avg_acceleration RETURN NUMBER,
    -- Returns the average direction of a moving point during its lifespan
    MEMBER FUNCTION f_avg_direction RETURN NUMBER,
	-- Returns the lifespan of a moving point
    MEMBER FUNCTION f_duration RETURN NUMBER,
    -- Transfers moving point to the starting point of Sm. The translation is dx on XX' and dy in YY'
    MEMBER FUNCTION transfer2(Qm moving_point, Sm IN OUT moving_point) return moving_point,
    -- Returns the timepoint when the moving point passes from (x,y). The algorithm starts looking from "old_pos"
    MEMBER FUNCTION f_timepoint(line MDSYS.SDO_GEOMETRY, x number, y number, old_pos pls_integer,  new_pos OUT pls_integer) return TAU_TLL.D_Timepoint_Sec,
    -- Returns the Locality In-between Polylines=projections of the two moving points
    MEMBER FUNCTION LIP(m_point Moving_Point, trans boolean) return number,
    -- Returns the Spatio-Temporal Distance between two moving points
    MEMBER FUNCTION STLIP(S IN OUT Moving_Point, trans boolean, t TAU_TLL.D_Interval, Q_LEN number, S_LEN   number, kapa number) return number,
    -- Returns the Speed-Pattern STLIP between two moving points following arbitrary trajectories
    MEMBER FUNCTION SPSTLIP(S IN OUT Moving_Point, trans boolean, t TAU_TLL.D_Interval, Q_LEN number, S_LEN number) return number,
    -- Returns the Direction Distance between the spatial projections of two moving points
    MEMBER FUNCTION DDIST(m_point Moving_Point, policy pls_integer) return number,
    -- Returns the Direction Distance between two moving points
    MEMBER FUNCTION TDDIST(S IN OUT Moving_Point, policy pls_integer) return number,
    -- Integrates STLIP
    MEMBER FUNCTION GenSTLIP_OSP(S_M IN OUT Moving_Point, trans boolean, policy pls_integer, Q_LEN number, S_LEN number, kapa number, delta number) return number,
  -- Calculate Potential Activity Area
    MEMBER FUNCTION potential_activity_area(tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
  MEMBER FUNCTION f_max_speed RETURN NUMBER,
   MEMBER FUNCTION potential_activity_area(tp tau_tll.d_timepoint_sec, max_speed NUMBER) RETURN MDSYS.SDO_GEOMETRY,
   --MEMBER FUNCTION potential_activity_area(tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY,
   MEMBER FUNCTION potential_activity_area(tp tau_tll.d_timepoint_sec, max_speed NUMBER, seg OUT moving_point) RETURN MDSYS.SDO_GEOMETRY,
   -- Calculate How Many times Close
  MEMBER FUNCTION number_of_times_close(tr2 moving_point, thr NUMBER, tol NUMBER) RETURN NUMBER


)                                          -- END OF moving_point declaration
 alter type moving_point add member function radius_of_gyration return number cascade
 alter type moving_point add member function mass_center return coords cascade
 alter type moving_point drop member function mass_center return coords cascade
 alter type moving_point add member function mass_center return sp_pos cascade
 alter type moving_point add member function f_speed_var return number cascade
 alter type moving_point add member function at_period_no_lib (per tau_tll.d_period_sec) RETURN moving_point cascade
 alter type moving_point add member function route return MDSYS.SDO_GEOMETRY cascade
 alter type moving_point drop member function potential_activity_area(tp tau_tll.d_timepoint_sec) RETURN MDSYS.SDO_GEOMETRY cascade
 alter type moving_point drop member function potential_activity_area(tp tau_tll.d_timepoint_sec, max_speed NUMBER) RETURN MDSYS.SDO_GEOMETRY cascade
 alter type moving_point drop member function potential_activity_area(tp tau_tll.d_timepoint_sec, max_speed NUMBER, seg OUT moving_point) RETURN MDSYS.SDO_GEOMETRY cascade
 alter type moving_point add member function potential_activity_area RETURN MDSYS.SDO_GEOMETRY cascade
 alter type moving_point drop member function f_behind (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER cascade
 alter type moving_point drop member function f_front (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min   NUMBER, angle_max   NUMBER) RETURN NUMBER cascade
 alter type moving_point drop member function f_left (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER cascade
 alter type moving_point drop member function f_right (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec, angle_min NUMBER, angle_max NUMBER) RETURN NUMBER cascade
 alter type moving_point add MEMBER FUNCTION f_east (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER cascade
 alter type moving_point add MEMBER FUNCTION f_west (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER cascade
 alter type moving_point add MEMBER FUNCTION f_south (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER cascade
 alter type moving_point add MEMBER FUNCTION f_north (geom MDSYS.SDO_GEOMETRY, tp tau_tll.d_timepoint_sec) RETURN NUMBER cascade
 alter type moving_point add member function sortbytime (ingeom in out mdsys.sdo_geometry) return mdsys.sdo_geometry cascade
/


