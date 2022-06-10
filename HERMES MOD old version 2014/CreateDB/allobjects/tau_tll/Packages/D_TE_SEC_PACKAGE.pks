Prompt drop Package D_TE_SEC_PACKAGE;
DROP PACKAGE D_TE_SEC_PACKAGE
/

Prompt Package D_TE_SEC_PACKAGE;
CREATE OR REPLACE PACKAGE D_TE_Sec_Package AS

    FUNCTION to_string(te_string Varchar2) return Varchar2;
    PROCEDURE f_begin(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    PROCEDURE f_end(te_string Varchar2, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    FUNCTION get_granularity(te_string Varchar2) return pls_integer;
    PROCEDURE duration(te_string Varchar2, i_Value OUT double precision);
    FUNCTION cardinality(te_string Varchar2) return pls_integer;
    PROCEDURE go(te_string Varchar2, num pls_integer, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    FUNCTION f_ass_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_add_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_add_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return Varchar2;
    FUNCTION f_sub_temp_element(te_string Varchar2, te1_string Varchar2) return Varchar2;
    FUNCTION f_sub_period(te_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return Varchar2;
    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return Varchar2;
    FUNCTION f_add(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return Varchar2;
    FUNCTION f_sub(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return Varchar2;
    FUNCTION intersects(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return Varchar2;
    FUNCTION f_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_n_eq(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision) return pls_integer;
    FUNCTION f_overlaps(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_precedes(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_meets(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_equal(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;
    FUNCTION f_contains(te_string Varchar2, te1_string Varchar2, te2_string Varchar2) return pls_integer;

END;
/

SHOW ERRORS;


