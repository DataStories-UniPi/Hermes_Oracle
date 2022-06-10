Prompt drop Package Body D_DATE_PACKAGE;
DROP PACKAGE BODY D_DATE_PACKAGE
/

Prompt Package Body D_DATE_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Date_Package AS

    FUNCTION year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION month(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_month"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION day(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_day"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION day_of_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_day_of_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION day_of_week(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_day_of_week"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION month_of_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_month_of_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_current(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_current"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_next(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, week_day pls_integer, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_next"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_previous(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, week_day pls_integer, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_previous"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_between(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, b_Year pls_integer, b_Month pls_integer, b_Day pls_integer, e_Year pls_integer, e_Month pls_integer, e_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_is_between"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_leap_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_is_leap_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_leap_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_is_leap_year2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION days_in_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_days_in_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION days_in_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_days_in_year2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION days_in_month(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_days_in_month"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION days_in_month(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer, m pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_days_in_month2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_valid_date(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer, m pls_integer, d pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_is_valid_date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_valid(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_is_valid"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION day_of_the_year(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer, m pls_integer, d pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_day_of_the_year"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION julian_day(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, y pls_integer, m pls_integer, d pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_julian_day"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE julian_to_gregorian(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, JD double precision, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_julian_to_gregorian"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION getAbsDate(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_getAbsDate"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE setAbsDate(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, num_of_days double precision, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_setAbsDate"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE Easter(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, year pls_integer, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_Easter"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_date(m_Year IN OUT pls_integer, m_Month  IN OUT pls_integer, m_Day IN OUT pls_integer, d_Year pls_integer, d_Month pls_integer, d_Day pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_ass_date"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_timestamp(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer, t_Year pls_integer, t_Month pls_integer, t_Day pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_ass_timestamp"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_interval(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer, i_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_add_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_days(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer, i pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_add_days"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_incr(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_incr"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer, i_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_sub_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_days(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer, i pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_sub_days"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_decr(m_Year IN OUT pls_integer, m_Month IN OUT pls_integer, m_Day IN OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_decr"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, d_Year pls_integer, d_Month pls_integer, d_Day pls_integer, i_Value double precision, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, d1_Year pls_integer, d1_Month pls_integer, d1_Day pls_integer, d2_Year pls_integer, d2_Month pls_integer, d2_Day pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, d_Year pls_integer, d_Month pls_integer, d_Day pls_integer, i_Value double precision, Y OUT pls_integer, M OUT pls_integer, D OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_sub2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, i_Year pls_integer, i_Month pls_integer, i_Day pls_integer, j_Year pls_integer, j_Month pls_integer, j_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, d1_Year pls_integer, d1_Month pls_integer, d1_Day pls_integer, d2_Year pls_integer, d2_Month pls_integer, d2_Day pls_integer,  d3_Year pls_integer, d3_Month pls_integer, d3_Day pls_integer, d4_Year pls_integer, d4_Month pls_integer, d4_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_timestamp_overlaps(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, t1_Year pls_integer, t1_Month pls_integer, t1_Day pls_integer, t2_Year pls_integer, t2_Month pls_integer, t2_Day pls_integer, d1_Year pls_integer, d1_Month pls_integer, d1_Day pls_integer, d2_Year pls_integer, d2_Month pls_integer, d2_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_timestamp_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_date_overlaps(m_Year pls_integer, m_Month pls_integer, m_Day pls_integer, d1_Year pls_integer, d1_Month pls_integer, d1_Day pls_integer, d2_Year pls_integer, d2_Month pls_integer, d2_Day pls_integer, t1_Year pls_integer, t1_Month pls_integer, t1_Day pls_integer, t2_Year pls_integer, t2_Month pls_integer, t2_Day pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Date_C_date_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;


END;
/

SHOW ERRORS;


