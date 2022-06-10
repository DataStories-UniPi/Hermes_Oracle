Prompt drop Package Body D_TIMEPOINT_Y_PACKAGE;
DROP PACKAGE BODY D_TIMEPOINT_Y_PACKAGE
/

Prompt Package Body D_TIMEPOINT_Y_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Timepoint_Y_Package AS

    PROCEDURE change_status(m_y IN OUT pls_integer, special_value pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_change_status"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION year(m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION get_granularity(m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_get_granularity"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION get_Abs_Date(m_y pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_get_Abs_Date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE set_year(m_y IN OUT pls_integer, year pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_set_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE set_Abs_Date(m_y IN OUT pls_integer, d double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_set_Abs_Date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE to_period(m_y pls_integer, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_to_period"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION to_temporal_element(m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_to_temporal_elem"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION to_string(m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_to_string"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_Leap_Year(m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_is_Leap_Year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_Leap_Year(m_y pls_integer, year pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_is_Leap_Year2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_timestamp(m_y IN OUT pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_ass_timestamp"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_timepoint(m_y IN OUT pls_integer, tp_m_y pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_ass_timepoint"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_interval(m_y IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_add_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval(m_y IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_sub_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_incr(m_y IN OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_incr"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_decr(m_y IN OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_decr"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add(m_y pls_integer, tp_m_y pls_integer, i_m_Value double precision, y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub(m_y pls_integer, tp_m_y pls_integer, i_m_Value double precision, y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE intersects(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_intersects"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE intersects(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_intersects1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION intersects(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_intersects2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_diff(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer, i_Value OUT double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_diff"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_eq1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_n_eq1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_l1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_l_e1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_b1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(m_y pls_integer, tp_m_y pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_f_b_e1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_precedes"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_meets"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_equal"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_contains"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_overlaps1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_precedes1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_meets1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_equal1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(m_y pls_integer, tp_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_contains1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_overlaps2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_precedes2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_meets2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_equal2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(m_y pls_integer, tp_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_contains2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_y pls_integer, tp1_m_y pls_integer, tp2_m_y pls_integer, tp3_m_y pls_integer, tp4_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TimeP_Y_C_overlaps3"
        LIBRARY TLL_lib
        WITH CONTEXT;

END;
/

SHOW ERRORS;


