Prompt Type MODEL_TAS;
CREATE OR REPLACE TYPE MODEL_TAS AS OBJECT (

u_tab Unit_TAS_Tab,
support NUMBER,
id NUMBER,

MEMBER FUNCTION f_membership(mp Hermes.MOVING_POINT, traj_id NUMBER) RETURN NUMBER,
MEMBER FUNCTION get_num_geometries RETURN NUMBER,
MEMBER FUNCTION get_geometry RETURN MDSYS.SDO_GEOMETRY,
MEMBER FUNCTION get_nth_geometry(n NUMBER) RETURN MDSYS.SDO_GEOMETRY,
MEMBER FUNCTION get_nth_time_interval(n NUMBER) RETURN UNIT_INTERVAL,
MEMBER FUNCTION f_nth_geometry_violate(mp Hermes.MOVING_POINT) RETURN NUMBER,
MEMBER FUNCTION f_geometry_violate(mp Hermes.MOVING_POINT) RETURN NUMBER_SET,
MEMBER FUNCTION f_intervals_violate(mp Hermes.MOVING_POINT) RETURN NUMBER_SET,
MEMBER FUNCTION getId RETURN NUMBER,

--other function
MEMBER FUNCTION satisfyInterval(mp Hermes.MOVING_POINT, traj_id NUMBER, t_min tau_tll.d_timepoint_sec, t_max tau_tll.d_timepoint_sec, edge NUMBER) RETURN BOOLEAN,
MEMBER FUNCTION getSegments(mp Hermes.Moving_Point, traj_id NUMBER) RETURN MOVING_POINT_SET
);
/


