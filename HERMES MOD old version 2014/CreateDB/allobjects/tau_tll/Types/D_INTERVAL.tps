Prompt drop Type D_INTERVAL;
DROP TYPE D_INTERVAL
/

Prompt Type D_INTERVAL;
CREATE OR REPLACE type D_Interval as object
(
   m_Value double precision,

   MEMBER FUNCTION day return double precision,
   MEMBER FUNCTION hour return pls_integer,
   MEMBER FUNCTION minute return pls_integer,
   MEMBER FUNCTION second return double precision,
   MEMBER FUNCTION is_zero return pls_integer,
   MEMBER FUNCTION to_string return varchar2,

   MEMBER PROCEDURE f_ass(i D_Interval),
   MEMBER PROCEDURE f_add_to_self(i D_Interval),
   MEMBER PROCEDURE f_sub_to_self(i D_Interval),
   MEMBER PROCEDURE f_mul_to_self(i pls_integer),
   MEMBER PROCEDURE f_div_to_self(i pls_integer),
   MEMBER PROCEDURE f_min,

   MEMBER FUNCTION f_add(i D_Interval, j D_Interval) return D_Interval,
   MEMBER FUNCTION f_sub(i D_Interval, j D_Interval) return D_Interval,
   MEMBER FUNCTION f_mul(i D_Interval, j pls_integer) return D_Interval,
   MEMBER FUNCTION f_div(i D_Interval, j pls_integer) return D_Interval,
   MEMBER FUNCTION f_eq(i D_Interval, j D_Interval) return pls_integer,
   MEMBER FUNCTION f_n_eq(i D_Interval, j D_Interval) return pls_integer,
   MEMBER FUNCTION f_l(i D_Interval, j D_Interval) return pls_integer,
   MEMBER FUNCTION f_l_e(i D_Interval, j D_Interval) return pls_integer,
   MEMBER FUNCTION f_b(i D_Interval, j D_Interval) return pls_integer,
   MEMBER FUNCTION f_b_e(i D_Interval, j D_Interval) return pls_integer

);
/

SHOW ERRORS;


