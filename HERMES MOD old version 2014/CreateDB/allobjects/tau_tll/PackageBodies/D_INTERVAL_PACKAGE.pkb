Prompt drop Package Body D_INTERVAL_PACKAGE;
DROP PACKAGE BODY D_INTERVAL_PACKAGE
/

Prompt Package Body D_INTERVAL_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Interval_Package AS
    FUNCTION day(m_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_day"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION hour(m_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_hour"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION minute(m_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_minute"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION second(m_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_second"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION is_zero(m_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_is_zero"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION to_string(m_Value double precision) return varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_to_string"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_ass(m_Value double precision, i_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_ass"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add_to_self(m_Value double precision, i_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_add_to_self"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub_to_self(m_Value double precision, i_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_sub_to_self"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_mul_to_self(m_Value double precision, i pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_mul_to_self"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_div_to_self(m_Value double precision, i pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_div_to_self"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_min(m_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_min"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add(i_Value double precision, j_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(i_Value double precision, j_Value double precision) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_mul(i_Value double precision, j pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_mul"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_div(i_Value double precision, j pls_integer) return double precision
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_div"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(i_Value double precision, j_Value double precision) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Interval_C_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

END;
/

SHOW ERRORS;


