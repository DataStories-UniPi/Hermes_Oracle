Prompt drop Package D_INTERVAL_PACKAGE;
DROP PACKAGE D_INTERVAL_PACKAGE
/

Prompt Package D_INTERVAL_PACKAGE;
CREATE OR REPLACE PACKAGE D_Interval_Package AS
    FUNCTION day(m_Value double precision) return double precision;
    FUNCTION hour(m_Value double precision) return pls_integer;
    FUNCTION minute(m_Value double precision) return pls_integer;
    FUNCTION second(m_Value double precision) return double precision;
    FUNCTION is_zero(m_Value double precision) return pls_integer;
    FUNCTION to_string(m_Value double precision) return varchar2;

    FUNCTION f_ass(m_Value double precision, i_Value double precision) return double precision;
    FUNCTION f_add_to_self(m_Value double precision, i_Value double precision) return double precision;
    FUNCTION f_sub_to_self(m_Value double precision, i_Value double precision) return double precision;
    FUNCTION f_mul_to_self(m_Value double precision, i pls_integer) return double precision;
    FUNCTION f_div_to_self(m_Value double precision, i pls_integer) return double precision;
    FUNCTION f_min(m_Value double precision) return double precision;

    FUNCTION f_add(i_Value double precision, j_Value double precision) return double precision;
    FUNCTION f_sub(i_Value double precision, j_Value double precision) return double precision;
    FUNCTION f_mul(i_Value double precision, j pls_integer) return double precision;
    FUNCTION f_div(i_Value double precision, j pls_integer) return double precision;
    FUNCTION f_eq(i_Value double precision, j_Value double precision) return pls_integer;
    FUNCTION f_n_eq(i_Value double precision, j_Value double precision) return pls_integer;
    FUNCTION f_l(i_Value double precision, j_Value double precision) return pls_integer;
    FUNCTION f_l_e(i_Value double precision, j_Value double precision) return pls_integer;
    FUNCTION f_b(i_Value double precision, j_Value double precision) return pls_integer;
    FUNCTION f_b_e(i_Value double precision, j_Value double precision) return pls_integer;

END;
/

SHOW ERRORS;


