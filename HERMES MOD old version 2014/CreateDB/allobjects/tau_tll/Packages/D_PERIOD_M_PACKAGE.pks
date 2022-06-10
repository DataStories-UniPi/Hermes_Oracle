Prompt drop Package D_PERIOD_M_PACKAGE;
DROP PACKAGE D_PERIOD_M_PACKAGE
/

Prompt Package D_PERIOD_M_PACKAGE;
CREATE OR REPLACE PACKAGE D_Period_M_Package AS

    PROCEDURE change_status(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, special_value pls_integer);
    PROCEDURE f_begin(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, b_y OUT pls_integer, b_m OUT pls_integer);
    PROCEDURE f_end(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    PROCEDURE set_begin(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, tp_m_y pls_integer, tp_m_m pls_integer);
    PROCEDURE set_end(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, tp_m_y pls_integer, tp_m_m pls_integer);
    FUNCTION get_granularity(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer) return pls_integer;
    PROCEDURE duration(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, i_Value OUT double precision);
    FUNCTION to_string(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer) return Varchar2;
    FUNCTION to_temporal_element(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer) return Varchar2;
    PROCEDURE f_ass_period(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer);
    PROCEDURE f_add_interval(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, i_m_Value double precision);
    PROCEDURE f_sub_interval(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, i_m_Value double precision);
    PROCEDURE f_add(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, i_m_Value double precision, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    PROCEDURE f_sub(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, i_m_Value double precision, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    FUNCTION f_add(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return Varchar2;
    FUNCTION f_sub(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return Varchar2;
    FUNCTION f_add(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return Varchar2;
    FUNCTION f_sub(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return Varchar2;
    PROCEDURE intersects(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    PROCEDURE intersects(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    FUNCTION intersects(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return Varchar2;
    FUNCTION f_eq(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_n_eq(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_l(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_l_e(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_b(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_b_e(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_e_m_y pls_integer, p2_e_m_m pls_integer) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, e_m_y pls_integer, e_m_m pls_integer, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_e_m_y pls_integer, p1_e_m_m pls_integer, te_string Varchar2) return pls_integer;

END;
/

SHOW ERRORS;


