Prompt drop Type Body D_INTERVAL;
DROP TYPE BODY D_INTERVAL
/

Prompt Type Body D_INTERVAL;
CREATE OR REPLACE type body D_Interval is

    MEMBER FUNCTION day return double precision is
      d double precision := D_Interval_Package.day(m_Value);
    begin
      return d;
    end;

    MEMBER FUNCTION hour return pls_integer is
      h pls_integer := D_Interval_Package.hour(m_Value);
    begin
      return h;
    end;

    MEMBER FUNCTION minute return pls_integer is
      m pls_integer := D_Interval_Package.minute(m_Value);
    begin
      return m;
    end;

    MEMBER FUNCTION second return double precision is
      s double precision := D_Interval_Package.second(m_Value);
    begin
      return s;
    end;

    MEMBER FUNCTION is_zero return pls_integer is
      z pls_integer := D_Interval_Package.is_zero(m_Value);
    begin
      return z;
    end;

    MEMBER FUNCTION to_string return varchar2 is
      s varchar2(32) := D_Interval_Package.to_string(m_Value);
    begin
      return s;
    end;

    MEMBER PROCEDURE f_ass(i D_Interval) is
    begin
      m_Value := D_Interval_Package.f_ass(m_Value, i.m_Value);
    end;

    MEMBER PROCEDURE f_add_to_self(i D_Interval) is
    begin
      m_Value := D_Interval_Package.f_add_to_self(m_Value, i.m_Value);
    end;

    MEMBER PROCEDURE f_sub_to_self(i D_Interval) is
    begin
      m_Value := D_Interval_Package.f_sub_to_self(m_Value, i.m_Value);
    end;

    MEMBER PROCEDURE f_mul_to_self(i pls_integer) is
    begin
      m_Value := D_Interval_Package.f_mul_to_self(m_Value, i);
    end;

    MEMBER PROCEDURE f_div_to_self(i pls_integer) is
    begin
      m_Value := D_Interval_Package.f_div_to_self(m_Value, i);
    end;

    MEMBER PROCEDURE f_min is
    begin
      m_Value := D_Interval_Package.f_min(m_Value);
    end;

    MEMBER FUNCTION f_add(i D_Interval, j D_Interval) return D_Interval is
      v double precision := D_Interval_Package.f_add(i.m_Value, j.m_Value);
    begin
      return D_Interval(v);
    end;

    MEMBER FUNCTION f_sub(i D_Interval, j D_Interval) return D_Interval is
      v double precision := D_Interval_Package.f_sub(i.m_Value, j.m_Value);
    begin
      return D_Interval(v);
    end;

    MEMBER FUNCTION f_mul(i D_Interval, j pls_integer) return D_Interval is
      v double precision := D_Interval_Package.f_mul(i.m_Value, j);
    begin
      return D_Interval(v);
    end;

    MEMBER FUNCTION f_div(i D_Interval, j pls_integer) return D_Interval is
      v double precision := D_Interval_Package.f_div(i.m_Value, j);
    begin
      return D_Interval(v);
    end;

    MEMBER FUNCTION f_eq(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_eq(i.m_Value, j.m_Value);
    begin
      return b;
    end;

    MEMBER FUNCTION f_n_eq(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_n_eq(i.m_Value, j.m_Value);
    begin
      return b;
    end;

    MEMBER FUNCTION f_l(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_l(i.m_Value, j.m_Value);
    begin
      return b;
    end;

    MEMBER FUNCTION f_l_e(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_l_e(i.m_Value, j.m_Value);
    begin
      return b;
    end;

    MEMBER FUNCTION f_b(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_b(i.m_Value, j.m_Value);
    begin
      return b;
    end;

    MEMBER FUNCTION f_b_e(i D_Interval, j D_Interval) return pls_integer is
       b pls_integer := D_Interval_Package.f_b_e(i.m_Value, j.m_Value);
    begin
      return b;
    end;

end;
/

SHOW ERRORS;


