Prompt drop Type Body D_TIMEPOINT_H;
DROP TYPE BODY D_TIMEPOINT_H
/

Prompt Type Body D_TIMEPOINT_H;
CREATE OR REPLACE type body D_Timepoint_H is

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_value pls_integer, special_hours pls_integer, year pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.change_status(m_y, m_m, m_d, m_h, special_value, special_hours, year);
    end;

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_hours pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.change_status(m_y, m_m, m_d, m_h, special_hours);
    end;

    --Returns the year for the Timepoint object.
    MEMBER FUNCTION year return pls_integer is
    y pls_integer := D_Timepoint_H_Package.year(m_y, m_m, m_d, m_h);
    begin
         return y;
    end;

    --Returns the month for the Timepoint object .
    MEMBER FUNCTION month return pls_integer is
    m pls_integer := D_Timepoint_H_Package.month(m_y, m_m, m_d, m_h);
    begin
         return m;
    end;

    --Returns the day for the Timepoint object.
    MEMBER FUNCTION day return pls_integer is
    d pls_integer := D_Timepoint_H_Package.day(m_y, m_m, m_d, m_h);
    begin
         return d;
    end;

    --Returns the hour for the Timepoint object.
    MEMBER FUNCTION hour return pls_integer is
    h pls_integer := D_Timepoint_H_Package.hour(m_y, m_m, m_d, m_h);
    begin
         return h;
    end;

    --Returns the Granularity of the Timepoint object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_Timepoint_H_Package.get_granularity(m_y, m_m, m_d, m_h);
    begin
         return g;
    end;

    --Returns a long number equal to the number of seconds since the begin of the calendar, representing the value of the Timepoint object.
    MEMBER FUNCTION get_Abs_Date return double precision is
    g double precision := D_Timepoint_H_Package.get_Abs_Date(m_y, m_m, m_d, m_h);
    begin
         return g;
    end;

    --Sets the year for the Timepoint object.
    MEMBER PROCEDURE set_year(year pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.set_year(m_y, m_m, m_d, m_h, year);
    end;

    --Sets the month for the Timepoint object.
    MEMBER PROCEDURE set_month(month pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.set_month(m_y, m_m, m_d, m_h, month);
    end;

    --Sets the day for the Timepoint object.
    MEMBER PROCEDURE set_day(day pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.set_day(m_y, m_m, m_d, m_h, day);
    end;

    --Sets the hour for the Timepoint object.
    MEMBER PROCEDURE set_hour(hour pls_integer) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.set_hour(m_y, m_m, m_d, m_h, hour);
    end;

    --Sets the value of the Timepoint object using a long number representing the number of seconds since the begin of the calendar.
    MEMBER PROCEDURE set_Abs_Date(d double precision) is
    begin
    -- m_y, m_m, m_d, m_h IN OUT argument
         D_Timepoint_H_Package.set_Abs_Date(m_y, m_m, m_d, m_h, d);
    end;

    --Converts the Timepoint object to a Period object.
    MEMBER FUNCTION to_period return REF D_Period_H is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    b_m pls_integer := 0;
    e_m pls_integer := 0;
    b_d pls_integer := 0;
    e_d pls_integer := 0;
    b_h pls_integer := 0;
    e_h pls_integer := 0;
    per REF D_Period_H;
    begin
         D_Timepoint_H_Package.to_period(m_y, m_m, m_d, m_h, b_y, b_m, b_d, b_h, e_y, e_m, e_d, e_h);
         INSERT INTO periods_h p
         VALUES (D_Period_H(D_Timepoint_H(b_y, b_m, b_d, b_h), D_Timepoint_H(e_y, e_m, e_d, e_h)))
         RETURNING REF(p) INTO per;
         return per;
    end;

    --Converts the Timepoint object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_H is
    str Varchar2(32766) := '';
    TE_h REF D_Temp_Element_H;
    begin
         str := D_Timepoint_H_Package.to_temporal_element(m_y, m_m, m_d, m_h);
         INSERT INTO temp_elements_h t
         VALUES (D_Temp_Element_H(return_temporal_element_h(str)))
         RETURNING REF(t) INTO TE_h;
         return TE_h;
    end;

    --Creates a string for the Timepoint object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2 is
    s Varchar2(50) := D_Timepoint_H_Package.to_string(m_y, m_m, m_d, m_h);
    begin
         return s;
    end;

    --Returns true if the year of the Timepoint object is a Leap year.
    MEMBER FUNCTION is_Leap_Year return pls_integer is
    b pls_integer := D_Timepoint_H_Package.is_Leap_Year(m_y, m_m, m_d, m_h);
    begin
         return b;
    end;

    --Returns true if parameter year is a Leap year.
    MEMBER FUNCTION is_Leap_Year(year pls_integer) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.is_Leap_Year(m_y, m_m, m_d, m_h, year);
    begin
         return b;
    end;

    --Returns the number of days in the month of the Timepoint object.
    MEMBER FUNCTION days_in_month return pls_integer is
    d pls_integer := D_Timepoint_H_Package.days_in_month(m_y, m_m, m_d, m_h);
    begin
         return d;
    end;

    --Assigns the value of a Timestamp object to the Timepoint object.
    MEMBER PROCEDURE f_ass_timestamp(ts D_Timestamp) is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_ass_timestamp(m_y, m_m, m_d, m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    end;

    --Assigns the value of another Timepoint to the Timepoint object.
    MEMBER PROCEDURE f_ass_timepoint(tp D_Timepoint_H) is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_ass_timepoint(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h);
    end;

    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval) is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_add_interval(m_y, m_m, m_d, m_h, i.m_Value);
    end;

    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval) is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_sub_interval(m_y, m_m, m_d, m_h, i.m_Value);
    end;

    --Increments the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_incr is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_incr(m_y, m_m, m_d, m_h);
    end;

    --Decrements the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_decr is
    -- m_y, m_m, m_d, m_h IN OUT argument
    begin
         D_Timepoint_H_Package.f_decr(m_y, m_m, m_d, m_h);
    end;

    --Returns a Timepoint object representing the sum of an Timepoint object plus a Interval object.
    MEMBER FUNCTION f_add(tp D_Timepoint_H, i D_Interval) return D_Timepoint_H is
    y pls_integer := 0;
    m pls_integer := 0;
    d pls_integer := 0;
    h pls_integer := 0;
    begin
         D_Timepoint_H_Package.f_add(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, i.m_Value, y, m, d, h);
         return D_Timepoint_H(y, m, d, h);
    end;

    --Returns a Timepoint object representing the subtraction of an Interval object from a Timepoint object.
    MEMBER FUNCTION f_sub(tp D_Timepoint_H, i D_Interval) return D_Timepoint_H is
    y pls_integer := 0;
    m pls_integer := 0;
    d pls_integer := 0;
    h pls_integer := 0;
    begin
         D_Timepoint_H_Package.f_sub(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, i.m_Value, y, m, d, y);
         return D_Timepoint_H(y, m, d, h);
    end;

    --Returns a Period object representing the intersection between two Timepoints.
    MEMBER FUNCTION intersects(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return REF D_Period_H is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    b_m pls_integer := 0;
    e_m pls_integer := 0;
    b_d pls_integer := 0;
    e_d pls_integer := 0;
    b_h pls_integer := 0;
    e_h pls_integer := 0;
    per REF D_Period_H;
    begin
         D_Timepoint_H_Package.intersects(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h, b_y, b_m, b_d, b_h, e_y, e_m, e_d, e_h);
         INSERT INTO periods_h p
         VALUES (D_Period_H(D_Timepoint_H(b_y, b_m, b_d, b_h), D_Timepoint_H(e_y, e_m, e_d, e_h)))
         RETURNING REF(p) INTO per;
         return per;
    end;

    --Returns a Period object representing the intersection between a Timepoint and a Period.
    MEMBER FUNCTION intersects(tp D_Timepoint_H, p_h REF D_Period_H) return REF D_Period_H is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    b_m pls_integer := 0;
    e_m pls_integer := 0;
    b_d pls_integer := 0;
    e_d pls_integer := 0;
    b_h pls_integer := 0;
    e_h pls_integer := 0;
    p D_Period_H;
    per REF D_Period_H;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         D_Timepoint_H_Package.intersects(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, b_y, b_m, b_d, b_h, e_y, e_m, e_d, e_h);
         INSERT INTO periods_h ps
         VALUES (D_Period_H(D_Timepoint_H(b_y, b_m, b_d, b_h), D_Timepoint_H(e_y, e_m, e_d, e_h)))
         RETURNING REF(ps) INTO per;
         return per;
    end;

    --Returns a Temporal Element object representing the intersection between a Timepoint and a Temporal Element.
    MEMBER FUNCTION intersects(tp D_Timepoint_H, te REF D_Temp_Element_H) return REF D_Temp_Element_H is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    TE_h REF D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Timepoint_H_Package.intersects(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
         INSERT INTO temp_elements_h t
         VALUES (D_Temp_Element_H(return_temporal_element_h(str)))
         RETURNING REF(t) INTO TE_h;
         return TE_h;
    end;

    --Returns true if the Timepoints have the same value.
    MEMBER FUNCTION f_eq(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_eq(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the Timepoints have different value.
    MEMBER FUNCTION f_n_eq(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_n_eq(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is less than the second.
    MEMBER FUNCTION f_l(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_l(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is less or equal to the second.
    MEMBER FUNCTION f_l_e(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_l_e(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is greater than the second.
    MEMBER FUNCTION f_b(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_b(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is greater or equal to the second.
    MEMBER FUNCTION f_b_e(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_b_e(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns the Interval between two Timepoints.
    MEMBER FUNCTION f_diff(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return D_Interval is
    i_Value double precision := 0;
    begin
         D_Timepoint_H_Package.f_diff(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h, i_Value);
         return D_Interval(i_Value);
    end;

    --Returns true if the Timepoint is equal to the Timestamp.
    MEMBER FUNCTION f_eq(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_eq(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is different from the Timestamp.
    MEMBER FUNCTION f_n_eq(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_n_eq(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is less than the Timestamp.
    MEMBER FUNCTION f_l(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_l(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is less or equal to the Timestamp.
    MEMBER FUNCTION f_l_e(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_l_e(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is greater than the Timestamp.
    MEMBER FUNCTION f_b(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_b(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is greater or equal to the Timestamp.
    MEMBER FUNCTION f_b_e(tp D_Timepoint_H, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_b_e(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if two Timepoints overlap.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_overlaps(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint precedes the second Timepoint.
    MEMBER FUNCTION f_precedes(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_precedes(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint meets the second Timepoint.
    MEMBER FUNCTION f_meets(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_meets(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is equal to the second Timepoint.
    MEMBER FUNCTION f_equal(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_equal(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the first Timepoint contains the second Timepoint.
    MEMBER FUNCTION f_contains(tp1 D_Timepoint_H, tp2 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_contains(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h);
    begin
         return b;
    end;

    --Returns true if the Timepoint overlaps the Period.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_H, p_h REF D_Period_H) return pls_integer is
    p D_Period_H;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         b := D_Timepoint_H_Package.f_overlaps(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h);
         return b;
    end;

    --Returns true if the Timepoint precedes the Period.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_H, p_h REF D_Period_H) return pls_integer is
    p D_Period_H;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         b := D_Timepoint_H_Package.f_precedes(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h);
         return b;
    end;

    --Returns true if the Timepoint meets the Period.
    MEMBER FUNCTION f_meets(tp D_Timepoint_H, p_h REF D_Period_H) return pls_integer is
    p D_Period_H;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         b := D_Timepoint_H_Package.f_meets(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h);
         return b;
    end;

    --Returns true if the Timepoint is equal to the Period.
    MEMBER FUNCTION f_equal(tp D_Timepoint_H, p_h REF D_Period_H) return pls_integer is
    p D_Period_H;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         b := D_Timepoint_H_Package.f_equal(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h);
         return b;
    end;

    --Returns true if the Timepoint contains the Period.
    MEMBER FUNCTION f_contains(tp D_Timepoint_H, p_h REF D_Period_H) return pls_integer is
    p D_Period_H;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_h) INTO p FROM DUAL;
         b := D_Timepoint_H_Package.f_contains(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h);
         return b;
    end;

    --Returns true if the Timepoint overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_H, te REF D_Temp_Element_H) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_H_Package.f_overlaps(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
    end;

    --Returns true if the Timepoint precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_H, te REF D_Temp_Element_H) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_H_Package.f_precedes(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
    end;

    --Returns true if the Timepoint meets the Temporal Element.
    MEMBER FUNCTION f_meets(tp D_Timepoint_H, te REF D_Temp_Element_H) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_H_Package.f_meets(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
    end;

    --Returns true if the Timepoint is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(tp D_Timepoint_H, te REF D_Temp_Element_H) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_H_Package.f_equal(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
    end;

    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(tp D_Timepoint_H, te REF D_Temp_Element_H) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_H;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_H_Package.f_contains(m_y, m_m, m_d, m_h, tp.m_y, tp.m_m, tp.m_d, tp.m_h, te1.to_string());
    end;

    --Returns true if the Period constructed using the first two Timepoints overlaps the Period constructed using the other two Timepoints.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_H, tp2 D_Timepoint_H, tp3 D_Timepoint_H, tp4 D_Timepoint_H) return pls_integer is
    b pls_integer := D_Timepoint_H_Package.f_overlaps(m_y, m_m, m_d, m_h, tp1.m_y, tp1.m_m, tp1.m_d, tp1.m_h, tp2.m_y, tp2.m_m, tp2.m_d, tp2.m_h, tp3.m_y, tp3.m_m, tp3.m_d, tp3.m_h, tp4.m_y, tp4.m_m, tp4.m_d, tp4.m_h);
    begin
         return b;
    end;

end;
/

SHOW ERRORS;


