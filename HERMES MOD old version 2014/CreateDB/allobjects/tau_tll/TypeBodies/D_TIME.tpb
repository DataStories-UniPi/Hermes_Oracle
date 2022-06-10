Prompt drop Type Body D_TIME;
DROP TYPE BODY D_TIME
/

Prompt Type Body D_TIME;
CREATE OR REPLACE type body D_Time is

   MEMBER FUNCTION hour return pls_integer is
     h pls_integer := D_Time_Package.hour(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return h;
   end;

   MEMBER FUNCTION minute return pls_integer is
     m pls_integer := D_Time_Package.minute(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return m;
   end;

   MEMBER FUNCTION second return float is
     s float := D_Time_Package.second(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return s;
   end;

   MEMBER FUNCTION hundr_thSec return pls_integer is
   begin
     return m_100thSec;
   end;

   MEMBER FUNCTION tz_hour return pls_integer is
     tz_h pls_integer := D_Time_Package.tz_hour(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return tz_h;
   end;

   MEMBER FUNCTION tz_minute return pls_integer is
     tz_m pls_integer := D_Time_Package.tz_minute(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return tz_m;
   end;

   MEMBER FUNCTION f_current return D_Time is
     H      pls_integer := 0;
     M      pls_integer := 0;
     S      pls_integer := 0;
     hundr_thS pls_integer := 0;
     tz_H   pls_integer := 0;
     tz_M   pls_integer := 0;
   begin
     D_Time_Package.f_current(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, H, M, S, hundr_thS, tz_H, tz_M);
     return D_Time(H, M, S, hundr_thS, tz_H, tz_M);
   end;

   MEMBER FUNCTION is_valid_time ( h pls_integer, m pls_integer, s float) return pls_integer is
     is_vt pls_integer := D_Time_Package.is_valid_time(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, h, m, s);
   begin
     return is_vt;
   end;

   MEMBER FUNCTION is_valid return pls_integer is
     is_v pls_integer := D_Time_Package.is_valid(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute);
   begin
     return is_v;
   end;

   MEMBER PROCEDURE f_ass_time(t D_Time) is
   begin
   -- m_Hour, m_Minute...==== IN OUT Arguments
     D_Time_Package.f_ass_time(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t.m_Hour, t.m_Minute, t.m_Second, t.m_100thSec, t.m_tzHour, t.m_tzMinute);
   end;

   MEMBER PROCEDURE f_ass_timestamp(tsp REF D_Timestamp) is
     ts D_Timestamp;
    begin
    -- m_Hour, m_Minute...==== IN OUT Arguments
     SELECT DEREF (tsp) INTO ts FROM dual;
     D_Time_Package.f_ass_timestamp(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, ts.f_time().m_Hour, ts.f_time().m_Minute, ts.f_time().m_Second, ts.f_time().m_100thSec, ts.f_time().m_tzHour, ts.f_time().m_tzMinute);
   end;

   MEMBER PROCEDURE f_add_interval(i D_Interval) is
   begin
   -- m_Hour, m_Minute...==== IN OUT Arguments
     D_Time_Package.f_add_interval(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Value);
   end;

   MEMBER PROCEDURE f_sub_interval(i D_Interval) is
   begin
   -- m_Hour, m_Minute...==== IN OUT Arguments
     D_Time_Package.f_sub_interval(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Value);
   end;

   MEMBER FUNCTION f_add(t D_Time, i D_Interval) return D_Time is
     H      pls_integer := 0;
     M      pls_integer := 0;
     S      pls_integer := 0;
     hundr_thS pls_integer := 0;
     tz_H   pls_integer := 0;
     tz_M   pls_integer := 0;
   begin
     D_Time_Package.f_add(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t.m_Hour, t.m_Minute, t.m_Second, t.m_100thSec, t.m_tzHour, t.m_tzMinute, i.m_Value, H, M, S, hundr_thS, tz_H, tz_M);
     return D_Time(H, M, S, hundr_thS, tz_H, tz_M);
   end;

   MEMBER FUNCTION f_sub(t1 D_Time, t2 D_Time) return D_Interval is
     i_Value      double precision := 0;
   begin
     D_Time_Package.f_sub_time_from_time(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t1.m_Hour, t1.m_Minute, t1.m_Second, t1.m_100thSec, t1.m_tzHour, t1.m_tzMinute, t2.m_Hour, t2.m_Minute, t2.m_Second, t2.m_100thSec, t2.m_tzHour, t2.m_tzMinute, i_Value);
     return D_Interval(i_Value);
   end;

   MEMBER FUNCTION f_sub(t D_Time, i D_Interval) return D_Time is
     H      pls_integer := 0;
     M      pls_integer := 0;
     S      pls_integer := 0;
     hundr_thS pls_integer := 0;
     tz_H   pls_integer := 0;
     tz_M   pls_integer := 0;
   begin
     D_Time_Package.f_sub_interval_from_time(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t.m_Hour, t.m_Minute, t.m_Second, t.m_100thSec, t.m_tzHour, t.m_tzMinute, i.m_Value, H, M, S, hundr_thS, tz_H, tz_M);
     return D_Time(H, M, S, hundr_thS, tz_H, tz_M);
   end;

   MEMBER FUNCTION f_eq(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_eq(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_n_eq(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_n_eq(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_l(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_l(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_l_e(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_l_e(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_b(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_b(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_b_e(i D_Time, j D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_b_e(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, i.m_Hour, i.m_Minute, i.m_Second, i.m_100thSec, i.m_tzHour, i.m_tzMinute, j.m_Hour, j.m_Minute, j.m_Second, j.m_100thSec, j.m_tzHour, j.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_overlaps(t1 D_Time, t2 D_Time, t3 D_Time, t4 D_Time) return pls_integer is
     b pls_integer := D_Time_Package.f_overlaps(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t1.m_Hour, t1.m_Minute, t1.m_Second, t1.m_100thSec, t1.m_tzHour, t1.m_tzMinute, t2.m_Hour, t2.m_Minute, t2.m_Second, t2.m_100thSec, t2.m_tzHour, t2.m_tzMinute, t3.m_Hour, t3.m_Minute, t3.m_Second, t3.m_100thSec, t3.m_tzHour, t3.m_tzMinute, t4.m_Hour, t4.m_Minute, t4.m_Second, t4.m_100thSec, t4.m_tzHour, t4.m_tzMinute);
   begin
     return b;
   end;

   MEMBER FUNCTION f_timestamp_overlaps(tsp1 REF D_Timestamp, tsp2 REF D_Timestamp, t1 D_Time, t2 D_Time) return pls_integer is
     b pls_integer := 0;
     ts1 D_Timestamp;
     ts2 D_Timestamp;
   begin
     SELECT DEREF (tsp1) INTO ts1 FROM dual;
     SELECT DEREF (tsp2) INTO ts2 FROM dual;
     b := D_Time_Package.f_timestamp_overlaps(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, ts1.f_time().m_Hour, ts1.f_time().m_Minute, ts1.f_time().m_Second, ts1.f_time().m_100thSec, ts1.f_time().m_tzHour, ts1.f_time().m_tzMinute, ts2.f_time().m_Hour, ts2.f_time().m_Minute, ts2.f_time().m_Second, ts2.f_time().m_100thSec, ts2.f_time().m_tzHour, ts2.f_time().m_tzMinute, t1.m_Hour, t1.m_Minute, t1.m_Second, t1.m_100thSec, t1.m_tzHour, t1.m_tzMinute, t2.m_Hour, t2.m_Minute, t2.m_Second, t2.m_100thSec, t2.m_tzHour, t2.m_tzMinute);
     return b;
   end;

   MEMBER FUNCTION f_time_overlaps(t1 D_Time, t2 D_Time, tsp1 REF D_Timestamp, tsp2 REF D_Timestamp) return pls_integer is
     b pls_integer := 0;
     ts1 D_Timestamp;
     ts2 D_Timestamp;
   begin
     SELECT DEREF (tsp1) INTO ts1 FROM dual;
     SELECT DEREF (tsp2) INTO ts2 FROM dual;
     b := D_Time_Package.f_time_overlaps(m_Hour, m_Minute, m_Second, m_100thSec, m_tzHour, m_tzMinute, t1.m_Hour, t1.m_Minute, t1.m_Second, t1.m_100thSec, t1.m_tzHour, t1.m_tzMinute, t2.m_Hour, t2.m_Minute, t2.m_Second, t2.m_100thSec, t2.m_tzHour, t2.m_tzMinute, ts1.f_time().m_Hour, ts1.f_time().m_Minute, ts1.f_time().m_Second, ts1.f_time().m_100thSec, ts1.f_time().m_tzHour, ts1.f_time().m_tzMinute, ts2.f_time().m_Hour, ts2.f_time().m_Minute, ts2.f_time().m_Second, ts2.f_time().m_100thSec, ts2.f_time().m_tzHour, ts2.f_time().m_tzMinute);
     return b;
   end;

end;
/

SHOW ERRORS;


