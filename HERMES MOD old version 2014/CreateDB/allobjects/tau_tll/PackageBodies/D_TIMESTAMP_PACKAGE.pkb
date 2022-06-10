Prompt drop Package Body D_TIMESTAMP_PACKAGE;
DROP PACKAGE BODY D_TIMESTAMP_PACKAGE
/

Prompt Package Body D_TIMESTAMP_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Timestamp_Package AS

    PROCEDURE f_date(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_time(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_time"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION year(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION month(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_month"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION day(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_day"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION hour(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_hour"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION minute(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_minute"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION second(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return float
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_second"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION tz_hour(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_tz_hour"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION tz_minute(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_tz_minute"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_current(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, Year OUT pls_integer, Month OUT pls_integer, Day OUT pls_integer, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_current"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_timestamp(m_Date_m_Year IN OUT pls_integer, m_Date_m_Month IN OUT pls_integer, m_Date_m_Day IN OUT pls_integer, m_Time_m_Hour IN OUT pls_integer, m_Time_m_Minute IN OUT pls_integer, m_Time_m_Second IN OUT pls_integer, m_Time_m_100thSec IN OUT pls_integer, m_Time_m_tzHour IN OUT pls_integer, m_Time_m_tzMinute IN OUT pls_integer, ts_m_Date_m_Year pls_integer, ts_m_Date_m_Month pls_integer, ts_m_Date_m_Day pls_integer, ts_m_Time_m_Hour pls_integer, ts_m_Time_m_Minute pls_integer, ts_m_Time_m_Second pls_integer, ts_m_Time_m_100thSec pls_integer, ts_m_Time_m_tzHour pls_integer, ts_m_Time_m_tzMinute pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_ass_timestamp"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_date(m_Date_m_Year IN OUT pls_integer, m_Date_m_Month IN OUT pls_integer, m_Date_m_Day IN OUT pls_integer, m_Time_m_Hour pls_integer, m_Time_m_Minute pls_integer, m_Time_m_Second pls_integer, m_Time_m_100thSec pls_integer, m_Time_m_tzHour pls_integer, m_Time_m_tzMinute pls_integer, d_m_Year pls_integer, d_m_Month pls_integer, d_m_Day pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_ass_date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_interval(m_Date_m_Year IN OUT pls_integer, m_Date_m_Month IN OUT pls_integer, m_Date_m_Day IN OUT pls_integer, m_Time_m_Hour IN OUT pls_integer, m_Time_m_Minute IN OUT pls_integer, m_Time_m_Second IN OUT pls_integer, m_Time_m_100thSec IN OUT pls_integer, m_Time_m_tzHour IN OUT pls_integer, m_Time_m_tzMinute IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_add_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval(m_Date_m_Year IN OUT pls_integer, m_Date_m_Month IN OUT pls_integer, m_Date_m_Day IN OUT pls_integer, m_Time_m_Hour IN OUT pls_integer, m_Time_m_Minute IN OUT pls_integer, m_Time_m_Second IN OUT pls_integer, m_Time_m_100thSec IN OUT pls_integer, m_Time_m_tzHour IN OUT pls_integer, m_Time_m_tzMinute IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_sub_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts_year pls_integer, ts_month pls_integer, ts_day pls_integer, ts_hour pls_integer, ts_minute pls_integer, ts_second pls_integer, ts_hundr_thSec pls_integer, ts_tz_hour pls_integer, ts_tz_minute pls_integer, i_m_Value double precision, Year OUT pls_integer, Month OUT pls_integer, Day OUT pls_integer, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts_year pls_integer, ts_month pls_integer, ts_day pls_integer, ts_hour pls_integer, ts_minute pls_integer, ts_second pls_integer, ts_hundr_thSec pls_integer, ts_tz_hour pls_integer, ts_tz_minute pls_integer, i_m_Value double precision, Year OUT pls_integer, Month OUT pls_integer, Day OUT pls_integer, H OUT pls_integer, M OUT pls_integer, S OUT pls_integer, hundr_thS OUT pls_integer, tz_H OUT pls_integer, tz_M OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_f_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_Date_year pls_integer, m_Date_month pls_integer, m_Date_day pls_integer, m_Time_hour pls_integer, m_Time_minute pls_integer, m_Time_second pls_integer, m_Time_hundr_thSec pls_integer, m_Time_tz_hour pls_integer, m_Time_tz_minute pls_integer, ts1_m_Date_year pls_integer, ts1_m_Date_month pls_integer, ts1_m_Date_day pls_integer, ts1_m_Time_hour pls_integer, ts1_m_Time_minute pls_integer, ts1_m_Time_second pls_integer, ts1_m_Time_hundr_thSec pls_integer, ts1_m_Time_tz_hour pls_integer, ts1_m_Time_tz_minute pls_integer, ts2_m_Date_year pls_integer, ts2_m_Date_month pls_integer, ts2_m_Date_day pls_integer, ts2_m_Time_hour pls_integer, ts2_m_Time_minute pls_integer, ts2_m_Time_second pls_integer, ts2_m_Time_hundr_thSec pls_integer, ts2_m_Time_tz_hour pls_integer, ts2_m_Time_tz_minute pls_integer, ts3_m_Date_year pls_integer, ts3_m_Date_month pls_integer, ts3_m_Date_day pls_integer, ts3_m_Time_hour pls_integer, ts3_m_Time_minute pls_integer, ts3_m_Time_second pls_integer, ts3_m_Time_hundr_thSec pls_integer, ts3_m_Time_tz_hour pls_integer, ts3_m_Time_tz_minute pls_integer, ts4_m_Date_year pls_integer, ts4_m_Date_month pls_integer, ts4_m_Date_day pls_integer, ts4_m_Time_hour pls_integer, ts4_m_Time_minute pls_integer, ts4_m_Time_second pls_integer, ts4_m_Time_hundr_thSec pls_integer, ts4_m_Time_tz_hour pls_integer, ts4_m_Time_tz_minute pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Timestamp_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

END;
/

SHOW ERRORS;


