Prompt drop Package D_TE_M_PACKAGE;
DROP PACKAGE D_TE_M_PACKAGE
/

Prompt Package D_TE_M_PACKAGE;
CREATE OR REPLACE PACKAGE D_TE_M_Package AS

    FUNCTION to_string(te_string Varchar2) return Varchar2;
    PROCEDURE f_begin(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    PROCEDURE f_end(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    FUNCTION get_granularity(te_string Varchar2) return pls_integer;
    PROCEDURE duration(te_string Varchar2, i_Value OUT double precision);
    FUNCTION cardinality(te_string Varchar2) return pls_integer;
    PROCEDURE go(te_string Varchar2, num pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, e_y OUT pls_integer, e_m OUT pls_integer);
    FUNCTION f_ass_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_add_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_add_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return Varchar2;
    FUNCTION f_sub_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_sub_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return Varchar2;
    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return Varchar2;
    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return Varchar2;
    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION f_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_n_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_e_m_y pls_integer, p_e_m_m pls_integer) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;

END;
/

SHOW ERRORS;


