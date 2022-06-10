Prompt drop Type Body D_DATE;
DROP TYPE BODY D_DATE
/

Prompt Type Body D_DATE;
CREATE OR REPLACE type body D_Date is

   MEMBER FUNCTION year return pls_integer is
     y pls_integer := D_Date_Package.year(m_Year, m_Month, m_Day);
   begin
     return y;
   end;

   MEMBER FUNCTION month return pls_integer is
     m pls_integer := D_Date_Package.month(m_Year, m_Month, m_Day);
   begin
     return m;
   end;

   MEMBER FUNCTION day return pls_integer is
     d pls_integer := D_Date_Package.day(m_Year, m_Month, m_Day);
   begin
     return d;
   end;

   MEMBER FUNCTION day_of_year return pls_integer is
     d_of_y pls_integer := D_Date_Package.day_of_year(m_Year, m_Month, m_Day);
   begin
     return d_of_y;
   end;

   MEMBER FUNCTION day_of_week return pls_integer is
     d_of_w pls_integer := D_Date_Package.day_of_week(m_Year, m_Month, m_Day);
   begin
     return d_of_w;
   end;

   MEMBER FUNCTION month_of_year return pls_integer is
     m_of_y pls_integer := D_Date_Package.month_of_year(m_Year, m_Month, m_Day);
   begin
     return m_of_y;
   end;

   MEMBER FUNCTION f_current return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.f_current(m_Year, m_Month, m_Day, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER FUNCTION f_next(week_Day pls_integer) return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.f_next(m_Year, m_Month, m_Day, week_day, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER FUNCTION f_previous(week_day pls_integer) return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.f_previous(m_Year, m_Month, m_Day, week_day, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER FUNCTION is_between(b D_Date, e D_Date) return pls_integer is
     is_b pls_integer := D_Date_Package.is_between(m_Year, m_Month, m_Day, b.m_Year, b.m_Month, b.m_Day, e.m_Year, e.m_Month, e.m_Day);
   begin
     return is_b;
   end;

   MEMBER FUNCTION is_leap_year return pls_integer is
     is_l_y pls_integer := D_Date_Package.is_leap_year(m_Year, m_Month, m_Day);
   begin
     return is_l_y;
   end;

   MEMBER FUNCTION is_leap_year(y pls_integer) return pls_integer is
     is_l_y pls_integer := D_Date_Package.is_leap_year(m_Year, m_Month, m_Day, y);
   begin
     return is_l_y;
   end;

   MEMBER FUNCTION days_in_year return pls_integer is
     d_in_y pls_integer := D_Date_Package.days_in_year(m_Year, m_Month, m_Day);
   begin
     return d_in_y;
   end;

   MEMBER FUNCTION days_in_year(y pls_integer) return pls_integer is
     d_in_y pls_integer := D_Date_Package.days_in_year(m_Year, m_Month, m_Day, y);
   begin
     return d_in_y;
   end;

   MEMBER FUNCTION days_in_month return pls_integer is
     d_in_m pls_integer := D_Date_Package.days_in_month(m_Year, m_Month, m_Day);
   begin
     return d_in_m;
   end;

   MEMBER FUNCTION days_in_month(y pls_integer, m pls_integer) return pls_integer is
     d_in_m pls_integer := D_Date_Package.days_in_month(m_Year, m_Month, m_Day, y, m);
   begin
     return d_in_m;
   end;

   MEMBER FUNCTION is_valid_date(y pls_integer, m pls_integer, d pls_integer) return pls_integer is
     is_v_d pls_integer := D_Date_Package.is_valid_date(m_Year, m_Month, m_Day, y, m, d);
   begin
     return is_v_d;
   end;

   MEMBER FUNCTION is_valid return pls_integer is
     is_v pls_integer := D_Date_Package.is_valid(m_Year, m_Month, m_Day);
   begin
     return is_v;
   end;

   MEMBER FUNCTION day_of_the_year(y pls_integer, m pls_integer, d pls_integer) return pls_integer is
     d_of_y pls_integer := D_Date_Package.day_of_the_year(m_Year, m_Month, m_Day, y, m, d);
   begin
     return d_of_y;
   end;

   MEMBER FUNCTION julian_day(y pls_integer, m pls_integer, d pls_integer) return double precision is
     jd double precision := D_Date_Package.julian_day(m_Year, m_Month, m_Day, y, m, d);
   begin
     return jd;
   end;

   MEMBER FUNCTION julian_to_gregorian(JD double precision) return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.julian_to_gregorian(m_Year, m_Month, m_Day, JD, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER FUNCTION getAbsDate return double precision is
     d double precision := D_Date_Package.getAbsDate(m_Year, m_Month, m_Day);
   begin
     return d;
   end;

   MEMBER FUNCTION setAbsDate(num_of_days double precision) return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.setAbsDate(m_Year, m_Month, m_Day, num_of_days, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER FUNCTION Easter(year pls_integer) return D_Date is
     Y pls_integer := 0;
     M pls_integer := 0;
     D pls_integer := 0;
   begin
     D_Date_Package.Easter(m_Year, m_Month, m_Day, year, Y, M, D);
     return D_Date(Y, M, D);
   end;

   MEMBER PROCEDURE f_ass_date(d D_Date) is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_ass_date(m_Year, m_Month, m_Day, d.m_Year, d.m_Month, d.m_Day);
   end;

   MEMBER PROCEDURE f_ass_timestamp(tsp REF D_Timestamp) is
     ts D_Timestamp;
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     SELECT DEREF (tsp) INTO ts FROM dual;
     D_Date_Package.f_ass_timestamp(m_Year, m_Month, m_Day, ts.f_date().m_Year, ts.f_date().m_Month, ts.f_date().m_Day);
   end;

   MEMBER PROCEDURE f_add_interval(i D_Interval) is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_add_interval(m_Year, m_Month, m_Day, i.m_Value);
   end;

   MEMBER PROCEDURE f_add_Days(i pls_integer) is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_add_days(m_Year, m_Month, m_Day, i);
   end;

   MEMBER PROCEDURE f_incr is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_incr(m_Year, m_Month, m_Day);
   end;

   MEMBER PROCEDURE f_sub_interval(i D_Interval) is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_sub_interval(m_Year, m_Month, m_Day, i.m_Value);
   end;

   MEMBER PROCEDURE f_sub_days(i pls_integer) is
    begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_sub_days(m_Year, m_Month, m_Day, i);
   end;

   MEMBER PROCEDURE f_decr is
   begin
   -- m_Year, m_Month, m_Day ==== IN OUT Arguments
     D_Date_Package.f_decr(m_Year, m_Month, m_Day);
   end;

  MEMBER FUNCTION f_add(d D_Date, i D_Interval) return D_Date is
     Year pls_integer := 0;
     Month pls_integer := 0;
     Day pls_integer := 0;
   begin
     D_Date_Package.f_add(m_Year, m_Month, m_Day, d.m_Year, d.m_Month, d.m_Day, i.m_Value, Year, Month, Day);
     return D_Date(Year, Month, Day);
   end;

   MEMBER FUNCTION f_sub(d1 D_Date, d2 D_Date) return D_Interval is
     v double precision;
   begin
     v := D_Date_Package.f_sub(m_Year, m_Month, m_Day, d1.m_Year, d1.m_Month, d1.m_Day, d2.m_Year, d2.m_Month, d2.m_Day);
     return D_Interval(v);
   end;

   MEMBER FUNCTION f_sub(d D_Date, i D_Interval) return D_Date is
     Year pls_integer := 0;
     Month pls_integer := 0;
     Day pls_integer := 0;
   begin
     D_Date_Package.f_sub(m_Year, m_Month, m_Day, d.m_Year, d.m_Month, d.m_Day, i.m_Value, Year, Month, Day);
     return D_Date(Year, Month, Day);
   end;

   MEMBER FUNCTION f_eq(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_eq(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_n_eq(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_n_eq(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_l(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_l(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_l_e(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_l_e(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_b(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_b(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_b_e(i D_Date, j D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_b_e(m_Year, m_Month, m_Day, i.m_Year, i.m_Month, i.m_Day, j.m_Year, j.m_Month, j.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_overlaps(d1 D_Date, d2 D_Date, d3 D_Date, d4 D_Date) return pls_integer is
     b pls_integer := D_Date_Package.f_overlaps(m_Year, m_Month, m_Day, d1.m_Year, d1.m_Month, d1.m_Day, d2.m_Year, d2.m_Month, d2.m_Day,  d3.m_Year, d3.m_Month, d3.m_Day, d4.m_Year, d4.m_Month, d4.m_Day);
   begin
     return b;
   end;

   MEMBER FUNCTION f_timestamp_overlaps(tsp1 REF D_Timestamp, tsp2 REF D_Timestamp, d1 D_Date, d2 D_Date) return pls_integer is
     b pls_integer := 0;
     ts1 D_Timestamp;
     ts2 D_Timestamp;
   begin
     SELECT DEREF (tsp1) INTO ts1 FROM dual;
     SELECT DEREF (tsp2) INTO ts2 FROM dual;
     b := D_Date_Package.f_timestamp_overlaps(m_Year, m_Month, m_Day, ts1.f_date().m_Year, ts1.f_date().m_Month, ts1.f_date().m_Day, ts2.f_date().m_Year, ts2.f_date().m_Month, ts2.f_date().m_Day, d1.m_Year, d1.m_Month, d1.m_Day, d2.m_Year, d2.m_Month, d2.m_Day);
     return b;
   end;

   MEMBER FUNCTION f_date_overlaps(d1 D_Date, d2 D_Date, tsp1 REF D_Timestamp, tsp2 REF D_Timestamp) return pls_integer is
     b pls_integer := 0;
     ts1 D_Timestamp;
     ts2 D_Timestamp;
   begin
     SELECT DEREF (tsp1) INTO ts1 FROM dual;
     SELECT DEREF (tsp2) INTO ts2 FROM dual;
     b := D_Date_Package.f_date_overlaps(m_Year, m_Month, m_Day, d1.m_Year, d1.m_Month, d1.m_Day, d2.m_Year, d2.m_Month, d2.m_Day, ts1.f_date().m_Year, ts1.f_date().m_Month, ts1.f_date().m_Day, ts2.f_date().m_Year, ts2.f_date().m_Month, ts2.f_date().m_Day);
     return b;
   end;

end;
/

SHOW ERRORS;


