Prompt Type MOVING_POINT_TAB;
CREATE OR REPLACE TYPE moving_point_tab AS VARRAY(7000) OF unit_moving_point
 alter type moving_point_tab modify limit 10000 cascade
 alter type moving_point_tab modify limit 20000 cascade
 alter type moving_point_tab modify limit 100000 cascade
/


