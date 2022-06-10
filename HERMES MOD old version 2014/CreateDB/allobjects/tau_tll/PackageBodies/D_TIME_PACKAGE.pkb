Prompt drop Package Body D_TIME_PACKAGE;
DROP PACKAGE BODY D_TIME_PACKAGE
/

Prompt Package Body D_TIME_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Time_Package AS

    FUNCTION hour(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_hour"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION minute(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_minute"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION second(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return float
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_second"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION tz_hour(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_tz_hour"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION tz_minute(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_tz_minute"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_current(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_current"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_valid_time(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, h pls_integer, m pls_integer, s double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_is_valid_time"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_valid(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_is_valid"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_time(m_Hour IN OUT pls_integer, m_Minute IN OUT pls_integer, m_Second IN OUT pls_integer, m_100thSec IN OUT pls_integer, m_tzHour IN OUT pls_integer, m_tzMinute IN OUT pls_integer, t_m_Hour pls_integer, t_m_Minute pls_integer, t_m_Second pls_integer, t_m_100thSec pls_integer, t_m_tzHour pls_integer, t_m_tzMinute pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_ass_time"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_timestamp(m_Hour IN OUT pls_integer, m_Minute IN OUT pls_integer, m_Second IN OUT pls_integer, m_100thSec IN OUT pls_integer, m_tzHour IN OUT pls_integer, m_tzMinute IN OUT pls_integer, ts_m_Hour pls_integer, ts_m_Minute pls_integer, ts_m_Second pls_integer, ts_m_100thSec pls_integer, ts_m_tzHour pls_integer, ts_m_tzMinute pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_ass_timestamp"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_interval(m_Hour IN OUT pls_integer, m_Minute IN OUT pls_integer, m_Second IN OUT pls_integer, m_100thSec IN OUT pls_integer, m_tzHour IN OUT pls_integer, m_tzMinute IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_add_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval(m_Hour IN OUT pls_integer, m_Minute IN OUT pls_integer, m_Second IN OUT pls_integer, m_100thSec IN OUT pls_integer, m_tzHour IN OUT pls_integer, m_tzMinute IN OUT pls_integer,  i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_sub_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, t_m_Hour pls_integer, t_m_Minute pls_integer, t_m_Second pls_integer, t_m_100thSec pls_integer, t_m_tzHour pls_integer, t_m_tzMinute pls_integer, i_m_Value double precision, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_time_from_time(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, t1_m_Hour pls_integer, t1_m_Minute pls_integer, t1_m_Second pls_integer, t1_m_100thSec pls_integer, t1_m_tzHour pls_integer, t1_m_tzMinute pls_integer, t2_m_Hour pls_integer, t2_m_Minute pls_integer, t2_m_Second pls_integer, t2_m_100thSec pls_integer, t2_m_tzHour pls_integer, t2_m_tzMinute pls_integer, i_Value OUT double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval_from_time(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, t_m_Hour pls_integer, t_m_Minute pls_integer, t_m_Second pls_integer, t_m_100thSec pls_integer, t_m_tzHour pls_integer, t_m_tzMinute pls_integer, i_m_Value double precision, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_sub2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, i_m_Hour pls_integer, i_m_Minute pls_integer, i_m_Second pls_integer, i_m_100thSec pls_integer, i_m_tzHour pls_integer, i_m_tzMinute pls_integer, j_m_Hour pls_integer, j_m_Minute pls_integer, j_m_Second pls_integer, j_m_100thSec pls_integer, j_m_tzHour pls_integer, j_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_f_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, t1_m_Hour pls_integer, t1_m_Minute pls_integer, t1_m_Second pls_integer, t1_m_100thSec pls_integer, t1_m_tzHour pls_integer, t1_m_tzMinute pls_integer, t2_m_Hour pls_integer, t2_m_Minute pls_integer, t2_m_Second pls_integer, t2_m_100thSec pls_integer, t2_m_tzHour pls_integer, t2_m_tzMinute pls_integer, t3_m_Hour pls_integer, t3_m_Minute pls_integer, t3_m_Second pls_integer, t3_m_100thSec pls_integer, t3_m_tzHour pls_integer, t3_m_tzMinute pls_integer, t4_m_Hour pls_integer, t4_m_Minute pls_integer, t4_m_Second pls_integer, t4_m_100thSec pls_integer, t4_m_tzHour pls_integer, t4_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_timestamp_overlaps(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, ts1_m_Hour pls_integer, ts1_m_Minute pls_integer, ts1_m_Second pls_integer, ts1_m_100thSec pls_integer, ts1_m_tzHour pls_integer, ts1_m_tzMinute pls_integer, ts2_m_Hour pls_integer, ts2_m_Minute pls_integer, ts2_m_Second pls_integer, ts2_m_100thSec pls_integer, ts2_m_tzHour pls_integer, ts2_m_tzMinute pls_integer, t1_m_Hour pls_integer, t1_m_Minute pls_integer, t1_m_Second pls_integer, t1_m_100thSec pls_integer, t1_m_tzHour pls_integer, t1_m_tzMinute pls_integer, t2_m_Hour pls_integer, t2_m_Minute pls_integer, t2_m_Second pls_integer, t2_m_100thSec pls_integer, t2_m_tzHour pls_integer, t2_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_timestamp_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_time_overlaps(m_Hour pls_integer, m_Minute pls_integer, m_Second pls_integer, m_100thSec pls_integer, m_tzHour pls_integer, m_tzMinute pls_integer, t1_m_Hour pls_integer, t1_m_Minute pls_integer, t1_m_Second pls_integer, t1_m_100thSec pls_integer, t1_m_tzHour pls_integer, t1_m_tzMinute pls_integer, t2_m_Hour pls_integer, t2_m_Minute pls_integer, t2_m_Second pls_integer, t2_m_100thSec pls_integer, t2_m_tzHour pls_integer, t2_m_tzMinute pls_integer, ts1_m_Hour pls_integer, ts1_m_Minute pls_integer, ts1_m_Second pls_integer, ts1_m_100thSec pls_integer, ts1_m_tzHour pls_integer, ts1_m_tzMinute pls_integer, ts2_m_Hour pls_integer, ts2_m_Minute pls_integer, ts2_m_Second pls_integer, ts2_m_100thSec pls_integer, ts2_m_tzHour pls_integer, ts2_m_tzMinute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Time_C_time_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

END;
/

SHOW ERRORS;


