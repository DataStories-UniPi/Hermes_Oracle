Prompt drop Package D_PERIOD_SEC_PACKAGE;
DROP PACKAGE D_PERIOD_SEC_PACKAGE
/

Prompt Package D_PERIOD_SEC_PACKAGE;
CREATE OR REPLACE PACKAGE D_Period_Sec_Package AS

    PROCEDURE change_status(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, special_value pls_integer);
    PROCEDURE f_begin(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision);
    PROCEDURE f_end(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    PROCEDURE set_begin(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision);
    PROCEDURE set_end(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision);
    FUNCTION get_granularity(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision) return pls_integer;
    PROCEDURE duration(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, i_Value OUT double precision);
    FUNCTION to_string(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision) return Varchar2;
    FUNCTION to_temporal_element(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision) return Varchar2;
    PROCEDURE f_ass_period(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision);
    PROCEDURE f_add_interval(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, i_m_Value double precision);
    PROCEDURE f_sub_interval(b_m_y IN OUT pls_integer, b_m_m IN OUT pls_integer, b_m_d IN OUT pls_integer, b_m_h IN OUT pls_integer, b_m_min IN OUT pls_integer, b_m_sec IN OUT double precision, e_m_y IN OUT pls_integer, e_m_m IN OUT pls_integer, e_m_d IN OUT pls_integer, e_m_h IN OUT pls_integer, e_m_min IN OUT pls_integer, e_m_sec IN OUT double precision, i_m_Value double precision);
    PROCEDURE f_add(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, i_m_Value double precision, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    PROCEDURE f_sub(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, i_m_Value double precision, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    FUNCTION f_add(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return Varchar2;
    FUNCTION f_sub(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return Varchar2;
    FUNCTION f_add(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return Varchar2;
    FUNCTION f_sub(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return Varchar2;
    PROCEDURE intersects(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    PROCEDURE intersects(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision, b_y OUT pls_integer, b_m OUT pls_integer, b_d OUT pls_integer, b_h OUT pls_integer, b_min OUT pls_integer, b_sec OUT double precision, e_y OUT pls_integer, e_m OUT pls_integer, e_d OUT pls_integer, e_h OUT pls_integer, e_min OUT pls_integer, e_sec OUT double precision);
    FUNCTION intersects(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return Varchar2;
    FUNCTION f_eq(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_n_eq(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_l(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_l_e(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_b(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_b_e(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p_b_m_y pls_integer, p_b_m_m pls_integer, p_b_m_d pls_integer, p_b_m_h pls_integer, p_b_m_min pls_integer, p_b_m_sec double precision, p_e_m_y pls_integer, p_e_m_m pls_integer, p_e_m_d pls_integer, p_e_m_h pls_integer, p_e_m_min pls_integer, p_e_m_sec double precision, tp_m_y pls_integer, tp_m_m pls_integer, tp_m_d pls_integer, tp_m_h pls_integer, tp_m_min pls_integer, tp_m_sec double precision) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, p2_b_m_y pls_integer, p2_b_m_m pls_integer, p2_b_m_d pls_integer, p2_b_m_h pls_integer, p2_b_m_min pls_integer, p2_b_m_sec double precision, p2_e_m_y pls_integer, p2_e_m_m pls_integer, p2_e_m_d pls_integer, p2_e_m_h pls_integer, p2_e_m_min pls_integer, p2_e_m_sec double precision) return pls_integer;

    FUNCTION f_overlaps(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return pls_integer;
    FUNCTION f_precedes(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return pls_integer;
    FUNCTION f_meets(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return pls_integer;
    FUNCTION f_equal(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return pls_integer;
    FUNCTION f_contains(b_m_y pls_integer, b_m_m pls_integer, b_m_d pls_integer, b_m_h pls_integer, b_m_min pls_integer, b_m_sec double precision, e_m_y pls_integer, e_m_m pls_integer, e_m_d pls_integer, e_m_h pls_integer, e_m_min pls_integer, e_m_sec double precision, p1_b_m_y pls_integer, p1_b_m_m pls_integer, p1_b_m_d pls_integer, p1_b_m_h pls_integer, p1_b_m_min pls_integer, p1_b_m_sec double precision, p1_e_m_y pls_integer, p1_e_m_m pls_integer, p1_e_m_d pls_integer, p1_e_m_h pls_integer, p1_e_m_min pls_integer, p1_e_m_sec double precision, te_string Varchar2) return pls_integer;

END;
/

SHOW ERRORS;


