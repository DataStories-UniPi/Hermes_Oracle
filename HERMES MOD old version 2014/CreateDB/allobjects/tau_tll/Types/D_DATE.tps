Prompt drop Type D_DATE;
DROP TYPE D_DATE
/

Prompt Type D_DATE;
CREATE OR REPLACE type D_Date as object
(
   m_Year integer,
   m_Month integer,
   m_Day integer,

   MEMBER FUNCTION year return pls_integer,
   MEMBER FUNCTION month return pls_integer,
   MEMBER FUNCTION day return pls_integer,
   MEMBER FUNCTION day_of_year return pls_integer,
   MEMBER FUNCTION day_of_week return pls_integer,
   MEMBER FUNCTION month_of_year return pls_integer,
   MEMBER FUNCTION f_current return D_Date,
   MEMBER FUNCTION f_next(week_day pls_integer) return D_Date,
   MEMBER FUNCTION f_previous(week_day pls_integer) return D_Date,

   MEMBER FUNCTION is_between(b D_Date, e D_Date) return pls_integer,
   MEMBER FUNCTION is_leap_year return pls_integer,
   MEMBER FUNCTION is_leap_year(y pls_integer) return pls_integer,
   MEMBER FUNCTION days_in_year return pls_integer,
   MEMBER FUNCTION days_in_year(y pls_integer) return pls_integer,
   MEMBER FUNCTION days_in_month return pls_integer,
   MEMBER FUNCTION days_in_month(y pls_integer, m pls_integer) return pls_integer,
   MEMBER FUNCTION is_valid_date(y pls_integer, m pls_integer, d pls_integer) return pls_integer,
   MEMBER FUNCTION is_valid return pls_integer,
   MEMBER FUNCTION day_of_the_year(y pls_integer, m pls_integer, d pls_integer) return pls_integer,
   MEMBER FUNCTION julian_day(y pls_integer, m pls_integer, d pls_integer) return double precision,
   MEMBER FUNCTION julian_to_gregorian(JD double precision) return D_Date,
   MEMBER FUNCTION getAbsDate return double precision,
   MEMBER FUNCTION setAbsDate(num_of_days double precision) return D_Date,
   MEMBER FUNCTION Easter(year pls_integer) return D_Date,

   MEMBER PROCEDURE f_ass_date(d D_Date),
   MEMBER PROCEDURE f_ass_timestamp(tsp REF D_Timestamp),
   MEMBER PROCEDURE f_add_interval(i D_Interval),
   MEMBER PROCEDURE f_add_days(i pls_integer),
   MEMBER PROCEDURE f_incr,
   MEMBER PROCEDURE f_sub_interval(i D_Interval),
   MEMBER PROCEDURE f_sub_days(i pls_integer),
   MEMBER PROCEDURE f_decr,

   MEMBER FUNCTION f_add(d D_Date, i D_Interval) return D_Date,
   MEMBER FUNCTION f_sub(d1 D_Date, d2 D_Date) return D_Interval,
   MEMBER FUNCTION f_sub(d D_Date, i D_Interval) return D_Date,
   MEMBER FUNCTION f_eq(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_n_eq(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_l(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_l_e(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_b(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_b_e(i D_Date, j D_Date) return pls_integer,
   MEMBER FUNCTION f_overlaps(d1 D_Date, d2 D_Date, d3 D_Date, d4 D_Date) return pls_integer,
   MEMBER FUNCTION f_timestamp_overlaps(tsp1 REF D_Timestamp, tsp2 REF D_Timestamp, d1 D_Date, d2 D_Date) return pls_integer,
   MEMBER FUNCTION f_date_overlaps(d1 D_Date, d2 D_Date, tsp1 REF D_Timestamp, tsp2 REF D_Timestamp) return pls_integer

);
/

SHOW ERRORS;


