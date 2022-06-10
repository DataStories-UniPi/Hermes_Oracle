Prompt drop Type D_TIME;
DROP TYPE D_TIME
/

Prompt Type D_TIME;
CREATE OR REPLACE type D_Time as object
(
   m_Hour integer,
   m_Minute integer,
   m_Second integer,
   m_100thSec integer,
   m_tzHour integer,
   m_tzMinute integer,

   MEMBER FUNCTION hour  return pls_integer,
   MEMBER FUNCTION minute  return pls_integer,
   MEMBER FUNCTION second  return float,
   MEMBER FUNCTION hundr_thSec return pls_integer,
   MEMBER FUNCTION tz_hour  return pls_integer,
   MEMBER FUNCTION tz_minute  return pls_integer,

   MEMBER FUNCTION f_current return D_Time,
   MEMBER FUNCTION is_valid_time (h pls_integer, m pls_integer, s float) return pls_integer,
   MEMBER FUNCTION is_valid return pls_integer,

   MEMBER PROCEDURE f_ass_time(t D_Time),
   MEMBER PROCEDURE f_ass_timestamp(tsp REF D_Timestamp),
   MEMBER PROCEDURE f_add_interval(i D_Interval),
   MEMBER PROCEDURE f_sub_interval(i D_Interval),

   MEMBER FUNCTION f_add(t D_Time, i D_Interval) return D_Time,
   MEMBER FUNCTION f_sub(t1 D_Time, t2 D_Time) return D_Interval,
   MEMBER FUNCTION f_sub(t D_Time, i D_Interval) return D_Time,
   MEMBER FUNCTION f_eq(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_n_eq(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_l(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_l_e(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_b(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_b_e(i D_Time, j D_Time) return pls_integer,
   MEMBER FUNCTION f_overlaps(t1 D_Time, t2 D_Time, t3 D_Time, t4 D_Time) return pls_integer,
   MEMBER FUNCTION f_timestamp_overlaps(tsp1 REF D_Timestamp, tsp2 REF D_Timestamp, t1 D_Time, t2 D_Time) return pls_integer,
   MEMBER FUNCTION f_time_overlaps(t1 D_Time, t2 D_Time, tsp1 REF D_Timestamp, tsp2 REF D_Timestamp) return pls_integer

);
/

SHOW ERRORS;


