Prompt drop Package D_TIMEPOINT_D_PACKAGE;
DROP PACKAGE D_TIMEPOINT_D_PACKAGE
/

Prompt Package D_TIMEPOINT_D_PACKAGE;
CREATE OR REPLACE PACKAGE D_Timepoint_D_Package AS

    PROCEDURE change_status(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, special_value pls_integer, year pls_integer);
    FUNCTION year(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    FUNCTION month(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    FUNCTION day(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    FUNCTION get_granularity(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    FUNCTION get_Abs_Date(m_y pls_integer, m_m pls_integer, m_d pls_integer) return double precision;
    PROCEDURE set_year(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, year pls_integer);
    PROCEDURE set_month(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, month pls_integer);
    PROCEDURE set_day(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, day pls_integer);
    PROCEDURE set_Abs_Date(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, d double precision);
    PROCEDURE to_period(m_y pls_integer, m_m pls_integer, m_d pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer);
    FUNCTION to_temporal_element(m_y pls_integer, m_m pls_integer, m_d pls_integer) return Varchar2;
    FUNCTION to_string(m_y pls_integer, m_m pls_integer, m_d pls_integer) return Varchar2;
    FUNCTION is_Leap_Year(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    FUNCTION is_Leap_Year(m_y pls_integer, m_m pls_integer, m_d pls_integer, year pls_integer) return pls_integer;
    FUNCTION days_in_month(m_y pls_integer, m_m pls_integer, m_d pls_integer) return pls_integer;
    PROCEDURE f_ass_timestamp(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer);
    PROCEDURE f_ass_timepoint(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer);
    PROCEDURE f_add_interval(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, i_m_Value double precision);
    PROCEDURE f_sub_interval(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer, i_m_Value double precision);
    PROCEDURE f_incr(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer);
    PROCEDURE f_decr(m_y IN OUT pls_integer, m_m IN OUT pls_integer, m_d IN OUT pls_integer);
    PROCEDURE f_add(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, i_m_Value double precision, y OUT pls_integer, m OUT pls_integer, d OUT pls_integer);
    PROCEDURE f_sub(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, i_m_Value double precision, y OUT pls_integer, m OUT pls_integer, d OUT pls_integer);
    PROCEDURE intersects(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer);
    PROCEDURE intersects(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer);
    FUNCTION intersects(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return Varchar2;
    FUNCTION f_eq(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_n_eq(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_l(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_l_e(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_b(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_b_e(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    PROCEDURE f_diff(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer, i_Value OUT double precision);
    FUNCTION f_eq(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_n_eq(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_l(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_l_e(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_b(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_b_e(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer) return pls_integer;
    FUNCTION f_overlaps(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_precedes(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_meets(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_equal(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_contains(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer) return pls_integer;
    FUNCTION f_overlaps(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer) return pls_integer;
    FUNCTION f_precedes(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer) return pls_integer;
    FUNCTION f_meets(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer) return pls_integer;
    FUNCTION f_equal(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer) return pls_integer;
    FUNCTION f_contains(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer) return pls_integer;
    FUNCTION f_overlaps(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_precedes(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_meets(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_equal(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_contains(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_overlaps(m_y pls_integer, m_m pls_integer, m_d pls_integer, tp1_m_y pls_integer, tp1_m_m pls_integer, tp1_m_d pls_integer, tp2_m_y pls_integer, tp2_m_m pls_integer, tp2_m_d pls_integer, tp3_m_y pls_integer, tp3_m_m pls_integer, tp3_m_d pls_integer, tp4_m_y pls_integer, tp4_m_m pls_integer, tp4_m_d pls_integer) return pls_integer;

END;
/

SHOW ERRORS;


