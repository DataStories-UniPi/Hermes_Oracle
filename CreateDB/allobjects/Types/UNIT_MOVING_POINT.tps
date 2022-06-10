Prompt Type UNIT_MOVING_POINT;
CREATE OR REPLACE TYPE unit_moving_point AS OBJECT (
   -- Time period with granularity second where Unit function is valid
   p   tau_tll.d_period_sec,
   -- Motion during period p
   m   unit_function,
   -- ###### MEMBER FUNCTIONS #####
   -- Polynomial of first degree
   MEMBER FUNCTION f_plnml_1 (tp tau_tll.d_timepoint_sec) RETURN coords,
   -- Polynomial of first degree
   MEMBER FUNCTION r_f_plnml_1 (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec,
   --
   MEMBER FUNCTION f_plnml_3_1 (tp tau_tll.d_timepoint_sec) RETURN coords,
   --
   MEMBER FUNCTION f_plnml_3_2 (tp tau_tll.d_timepoint_sec) RETURN coords,
   --
   MEMBER FUNCTION r_f_plnml_3_x (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec,
   -- Depending on the "descr" of the Unit_Function invokes the appropriate function
   MEMBER FUNCTION f_interpolate (tp tau_tll.d_timepoint_sec) RETURN coords,
   -- Returns the timepoint that corresponds to a specific xy coords
   MEMBER FUNCTION get_time_point (x NUMBER, y NUMBER) RETURN tau_tll.d_timepoint_sec,
   -- Checks if this unit_moving_point contains the given (x, y)
   MEMBER FUNCTION f_contains (x NUMBER, y NUMBER) RETURN BOOLEAN,
   -- Gets the speed at the given timepoint
   MEMBER FUNCTION get_speed (tp tau_tll.d_timepoint_sec) RETURN NUMBER,
   -- Get (x, y) of the
   MEMBER FUNCTION get_midle_point RETURN coords
);
/


