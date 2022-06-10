Prompt drop Package Body D_TE_MIN_PACKAGE;
DROP PACKAGE BODY D_TE_MIN_PACKAGE
/

Prompt Package Body D_TE_MIN_PACKAGE;
CREATE OR REPLACE PACKAGE BODY D_TE_Min_Package AS

    FUNCTION to_string(te_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_to_string"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_begin(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_begin"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE f_end(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_end"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION get_granularity(te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_get_granularity"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE duration(te_string Varchar2, i_Value OUT double precision)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_duration"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION cardinality(te_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_cardinality"
        LIBRARY TLL_lib
        WITH CONTEXT;

    PROCEDURE go(te_string Varchar2, num pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer)
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_go"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_ass_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_ass_temp_element"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_add_temp_element"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_add_period"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_sub_temp_element"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_sub_period"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_add"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_add1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_sub"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_sub1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_intersects"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_intersects1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_intersects2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_n_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_f_n_eq"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_overlaps"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_precedes"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_meets"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_equal"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_contains"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_overlaps1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_precedes1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_meets1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_equal1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_contains1"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_overlaps2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_precedes2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_meets2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_equal2"
        LIBRARY TLL_lib
        WITH CONTEXT;

    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer
    IS  EXTERNAL
        LANGUAGE C
        NAME "D_TE_Min_C_contains2"
        LIBRARY TLL_lib
        WITH CONTEXT;

END;
/

SHOW ERRORS;


