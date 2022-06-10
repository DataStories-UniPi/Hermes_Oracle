Prompt Package UTILITIES;
CREATE OR REPLACE PACKAGE utilities AS TYPE CursorType IS REF CURSOR;

    -- Checks if three point are co-linear
    FUNCTION check_colinear (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER, x3 NUMBER, y3 NUMBER,tolerance number:=0.01) RETURN BOOLEAN;
    -- Checks if the segment defined by the first two points overlaps with the segment defined by the last two points
    FUNCTION check_overlap (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER, x3 NUMBER, y3 NUMBER) RETURN BOOLEAN;
    -- Prints a MDSYS.SDO_GEOMETRY
    PROCEDURE print_geometry (geom MDSYS.SDO_GEOMETRY, descr VARCHAR2);
    -- Adds two angles
    FUNCTION add_angles (angle1 NUMBER, angle2 NUMBER) RETURN NUMBER;
    -- Adds two angles
    FUNCTION is_angle_between (min_angle NUMBER, angle NUMBER, max_angle NUMBER) RETURN BOOLEAN;
    -- Returns the angle (in degrees) between the segment defined by the two points (arguments) and the xx' axis
    FUNCTION direction (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER) RETURN NUMBER;
    -- Returns the angle (in degrees) between the segment defined by the two points (arguments) and the xx' axis
    FUNCTION direction (geom1 MDSYS.SDO_GEOMETRY, geom2 MDSYS.SDO_GEOMETRY) RETURN NUMBER;
    -- Returns the angle (in degrees) between the segment defined by the two points (arguments) and the xx' axis
    FUNCTION get_tan (geom1 MDSYS.SDO_GEOMETRY, geom2 MDSYS.SDO_GEOMETRY) RETURN NUMBER;
    -- Returns the angle (in degrees 0-180) between the segment defined by the points Q_start -> Q_end and the segment defined by the points S_start -> S_end
    FUNCTION angle (q_start MDSYS.SDO_GEOMETRY, q_end MDSYS.SDO_GEOMETRY, s_start MDSYS.SDO_GEOMETRY, s_end MDSYS.SDO_GEOMETRY) RETURN NUMBER;
    -- Returns the angle (in degrees) between the segment defined by the points Q_start -> Q_end and the S_angle
    FUNCTION angle2(Q_angle number, S_angle number) return number;
    -- Returns the angle (in degrees 0-360) between the segment defined by the points Q_start -> Q_end and the segment defined by the points S_start -> S_end
    FUNCTION angle3 (q_start MDSYS.SDO_GEOMETRY, q_end MDSYS.SDO_GEOMETRY, s_start MDSYS.SDO_GEOMETRY, s_end MDSYS.SDO_GEOMETRY) RETURN NUMBER;
    -- Returns the distance between two points
    FUNCTION distance (x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER) RETURN NUMBER;
    -- Sorts the multi-point argument geometry according to the direction of a single linestring (segment)
    FUNCTION f_sort (mpoint IN OUT MDSYS.SDO_GEOMETRY, line MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY;
    -- Returns the points being at odd positions 1,3,5 etc
    FUNCTION get_odd_points (multipoint MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY;
    -- Returns the points being at odd positions 2,4,6, etc
    FUNCTION get_even_points (multipoint MDSYS.SDO_GEOMETRY) RETURN MDSYS.SDO_GEOMETRY;
    -- Transfers linestring S according to the first point of linestring Q.
    FUNCTION transfer(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY) return MDSYS.SDO_GEOMETRY;
    FUNCTION transfer2(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY) return MDSYS.SDO_GEOMETRY;
    -- Computes the cost (area in m^2) for transfering segment Q towards S.
    FUNCTION transfer_cost(Q MDSYS.SDO_GEOMETRY, S MDSYS.SDO_GEOMETRY, dir number) return number;
    -- Constructs a segment (single linestring) from the two argument points
    FUNCTION f_segment(xi number, yi number, xe number, ye number) return MDSYS.SDO_GEOMETRY;
    -- Returns the number of the segment of the linestring where the point resides. The algorithm starts from from segment with number "old_pos"
    FUNCTION position(line MDSYS.SDO_GEOMETRY, x number, y number, old_pos pls_integer) return pls_integer;
    -- Checks if Q's (PQ) or S's (PS) point "sees" the last segment of Q_line or S_line without intersecting the previous segments of the latter
    FUNCTION BadSegment(Q_line MDSYS.SDO_GEOMETRY, S_line MDSYS.SDO_GEOMETRY, PQx number, PQy number, PSx number, PSy number) return boolean;
    -- Smooth linestring
    PROCEDURE SmoothLine(L IN OUT MDSYS.SDO_GEOMETRY);
    -- Spatial Similarity
    FUNCTION LIP(Q MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, Q_LEN number, S_LEN  number) return number;
    -- Integrates LIP
    FUNCTION FindBadSegments(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, policy pls_integer, Q_LEN number, S_LEN   number) return number;
    -- Second policy
    FUNCTION GenLIP(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, trans boolean, policy pls_integer, Q_LEN number, S_LEN    number) return number; --, avg_sim  IN OUT number, NoLIPgrams IN OUT pls_integer
    -- Direction Distance
    FUNCTION DDIST(Q IN OUT MDSYS.SDO_GEOMETRY, S IN OUT MDSYS.SDO_GEOMETRY, policy pls_integer) return number;
    -- Computes MDI
    function compute_mdi (startq_tp tau_tll.d_timepoint_sec, endq_tp tau_tll.d_timepoint_sec, starts_tp tau_tll.d_timepoint_sec, ends_tp tau_tll.d_timepoint_sec, delta tau_tll.d_interval) return number;
    --azimuth of a segment
    function azimuth(xi number,yi number,xe number,ye number) return number;
    function azimuth(geom1 sdo_geometry, geom2 sdo_geometry) return number;
    --check if point x,y is between points min-max with tolerance
    function is_point_between(minx number, miny number, maxx number, maxy number, x number, y number,tolerance number:=0.001) return boolean;
END;
/


