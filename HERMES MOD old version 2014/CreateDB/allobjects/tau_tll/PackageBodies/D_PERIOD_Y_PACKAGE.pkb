Prompt drop Package Body D_PERIOD_Y_PACKAGE;
DROP PACKAGE BODY D_PERIOD_Y_PACKAGE
/

Prompt Package Body D_PERIOD_Y_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_Period_Y_Package AS

    PROCEDURE change_status(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, special_value pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_change_status"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_begin(b_m_y pls_integer, e_m_y pls_integer, b_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_begin"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_end(b_m_y pls_integer, e_m_y pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_end"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE set_begin(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, tp_m_y pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_set_begin"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE set_end(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, tp_m_y pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_set_end"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION get_granularity(b_m_y pls_integer, e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_get_granularity"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE duration(b_m_y pls_integer, e_m_y pls_integer, i_Value OUT double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_duration"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION to_string(b_m_y pls_integer, e_m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_to_string"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION to_temporal_element(b_m_y pls_integer, e_m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_to_temporal_elem"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_ass_period(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_ass_period"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add_interval(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_add_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub_interval(b_m_y IN OUT pls_integer, e_m_y IN OUT pls_integer, i_m_Value double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_sub_interval"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_add(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, i_m_Value double precision, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_sub(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, i_m_Value double precision, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_add1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_sub1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_add2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_sub2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE intersects(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_intersects"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE intersects(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer, b_y OUT pls_integer, e_y OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_intersects1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION intersects(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_intersects2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_l"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_l_e(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_l_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_b"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_b_e(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_f_b_e"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_precedes"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_meets"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_equal"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(b_m_y pls_integer, e_m_y pls_integer, p_b_m_y pls_integer, p_e_m_y pls_integer, tp_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_contains"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_overlaps1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_precedes1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_meets1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_equal1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, p2_b_m_y pls_integer, p2_e_m_y pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_contains1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_overlaps2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_precedes2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_meets2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_equal2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(b_m_y pls_integer, e_m_y pls_integer, p1_b_m_y pls_integer, p1_e_m_y pls_integer, te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_Period_Y_C_contains2"
        LIBRARY TLL_lib
        WITH CONTEXT;


END;
/

SHOW ERRORS;


