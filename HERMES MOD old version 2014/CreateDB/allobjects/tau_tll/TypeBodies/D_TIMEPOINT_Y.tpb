Prompt drop Type Body D_TIMEPOINT_Y;
DROP TYPE BODY D_TIMEPOINT_Y
/

Prompt Type Body D_TIMEPOINT_Y;
CREATE OR REPLACE type body D_Timepoint_Y is

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_value pls_integer) is
    begin
    -- m_y IN OUT argument
         D_Timepoint_Y_Package.change_status(m_y, special_value);
    end;

    --Returns the year for the Timepoint object.
    MEMBER FUNCTION year return pls_integer is
    y pls_integer := D_Timepoint_Y_Package.year(m_y);
    begin
         return y;
    end;

    --Returns the Granularity of the Timepoint object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_Timepoint_Y_Package.get_granularity(m_y);
    begin
         return g;
    end;

    --Returns a long number equal to the number of seconds since the begin of the calendar, representing the value of the Timepoint object.
    MEMBER FUNCTION get_Abs_Date return double precision is
    g double precision := D_Timepoint_Y_Package.get_Abs_Date(m_y);
    begin
         return g;
    end;

    --Sets the year for the Timepoint object.
    MEMBER PROCEDURE set_year(year pls_integer) is
    begin
    -- m_y IN OUT argument
         D_Timepoint_Y_Package.set_year(m_y, year);
    end;

    --Sets the value of the Timepoint object using a long number representing the number of seconds since the begin of the calendar.
    MEMBER PROCEDURE set_Abs_Date(d double precision) is
    begin
    -- m_y IN OUT argument
         D_Timepoint_Y_Package.set_Abs_Date(m_y, d);
    end;

    --Converts the Timepoint object to a Period object.
    MEMBER FUNCTION to_period return REF D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    per REF D_Period_Y;
    begin
         D_Timepoint_Y_Package.to_period(m_y, b_y, e_y);
         INSERT INTO periods_y p
         VALUES (D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y)))
         RETURNING REF(p) INTO per;
         return per;
    end;

    --Converts the Timepoint object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    TE_y REF D_Temp_Element_Y;
    begin
         str := D_Timepoint_Y_Package.to_temporal_element(m_y);
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Creates a string for the Timepoint object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2 is
    s Varchar2(50) := D_Timepoint_Y_Package.to_string(m_y);
    begin
         return s;
    end;

    --Returns true if the year of the Timepoint object is a Leap year.
    MEMBER FUNCTION is_Leap_Year return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.is_Leap_Year(m_y);
    begin
         return b;
    end;

    --Returns true if parameter year is a Leap year.
    MEMBER FUNCTION is_Leap_Year(year pls_integer) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.is_Leap_Year(m_y, year);
    begin
         return b;
    end;

    --Assigns the value of a Timestamp object to the Timepoint object.
    MEMBER PROCEDURE f_ass_timestamp(ts D_Timestamp) is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_ass_timestamp(m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    end;

    --Assigns the value of another Timepoint to the Timepoint object.
    MEMBER PROCEDURE f_ass_timepoint(tp D_Timepoint_Y) is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_ass_timepoint(m_y, tp.m_y);
    end;

    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval) is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_add_interval(m_y, i.m_Value);
    end;

    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval) is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_sub_interval(m_y, i.m_Value);
    end;

    --Increments the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_incr is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_incr(m_y);
    end;

    --Decrements the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_decr is
    -- m_y IN OUT argument
    begin
         D_Timepoint_Y_Package.f_decr(m_y);
    end;

    --Returns a Timepoint object representing the sum of an Timepoint object plus a Interval object.
    MEMBER FUNCTION f_add(tp D_Timepoint_Y, i D_Interval) return D_Timepoint_Y is
    y pls_integer := 0;
    begin
         D_Timepoint_Y_Package.f_add(m_y, tp.m_y, i.m_Value, y);
         return D_Timepoint_Y(y);
    end;

    --Returns a Timepoint object representing the subtraction of an Interval object from a Timepoint object.
    MEMBER FUNCTION f_sub(tp D_Timepoint_Y, i D_Interval) return D_Timepoint_Y is
    y pls_integer := 0;
    begin
         D_Timepoint_Y_Package.f_sub(m_y, tp.m_y, i.m_Value, y);
         return D_Timepoint_Y(y);
    end;

    --Returns a Period object representing the intersection between two Timepoints.
    MEMBER FUNCTION intersects(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return REF D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    per REF D_Period_Y;
    begin
         D_Timepoint_Y_Package.intersects(m_y, tp1.m_y, tp2.m_y, b_y, e_y);
         INSERT INTO periods_y p
         VALUES (D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y)))
         RETURNING REF(p) INTO per;
         return per;
    end;

    --Returns a Period object representing the intersection between a Timepoint and a Period.
    MEMBER FUNCTION intersects(tp D_Timepoint_Y, p_y REF D_Period_Y) return REF D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    p D_Period_Y;
    per REF D_Period_Y;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         D_Timepoint_Y_Package.intersects(m_y, tp.m_y, p.b.m_y, p.e.m_y, b_y, e_y);
         INSERT INTO periods_y ps
         VALUES (D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y)))
         RETURNING REF(ps) INTO per;
         return per;
    end;

    --Returns a Temporal Element object representing the intersection between a Timepoint and a Temporal Element.
    MEMBER FUNCTION intersects(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    TE_y REF D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Timepoint_Y_Package.intersects(m_y, tp.m_y, te1.to_string());
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Returns true if the Timepoints have the same value.
    MEMBER FUNCTION f_eq(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_eq(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the Timepoints have different value.
    MEMBER FUNCTION f_n_eq(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_n_eq(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is less than the second.
    MEMBER FUNCTION f_l(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_l(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is less or equal to the second.
    MEMBER FUNCTION f_l_e(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_l_e(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is greater than the second.
    MEMBER FUNCTION f_b(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_b(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is greater or equal to the second.
    MEMBER FUNCTION f_b_e(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_b_e(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns the Interval between two Timepoints.
    MEMBER FUNCTION f_diff(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return D_Interval is
    i_Value double precision := 0;
    begin
         D_Timepoint_Y_Package.f_diff(m_y, tp1.m_y, tp2.m_y, i_Value);
         return D_Interval(i_Value);
    end;

    --Returns true if the Timepoint is equal to the Timestamp.
    MEMBER FUNCTION f_eq(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_eq(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is different from the Timestamp.
    MEMBER FUNCTION f_n_eq(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_n_eq(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is less than the Timestamp.
    MEMBER FUNCTION f_l(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_l(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is less or equal to the Timestamp.
    MEMBER FUNCTION f_l_e(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_l_e(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is greater than the Timestamp.
    MEMBER FUNCTION f_b(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_b(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if the Timepoint is greater or equal to the Timestamp.
    MEMBER FUNCTION f_b_e(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_b_e(m_y, tp.m_y, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    begin
         return b;
    end;

    --Returns true if two Timepoints overlap.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_overlaps(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint precedes the second Timepoint.
    MEMBER FUNCTION f_precedes(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_precedes(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint meets the second Timepoint.
    MEMBER FUNCTION f_meets(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_meets(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint is equal to the second Timepoint.
    MEMBER FUNCTION f_equal(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_equal(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the first Timepoint contains the second Timepoint.
    MEMBER FUNCTION f_contains(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_contains(m_y, tp1.m_y, tp2.m_y);
    begin
         return b;
    end;

    --Returns true if the Timepoint overlaps the Period.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer is
    p D_Period_Y;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         b := D_Timepoint_Y_Package.f_overlaps(m_y, tp.m_y, p.b.m_y, p.e.m_y);
         return b;
    end;

    --Returns true if the Timepoint precedes the Period.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer is
    p D_Period_Y;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         b := D_Timepoint_Y_Package.f_precedes(m_y, tp.m_y, p.b.m_y, p.e.m_y);
         return b;
    end;

    --Returns true if the Timepoint meets the Period.
    MEMBER FUNCTION f_meets(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer is
    p D_Period_Y;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         b := D_Timepoint_Y_Package.f_meets(m_y, tp.m_y, p.b.m_y, p.e.m_y);
         return b;
    end;

    --Returns true if the Timepoint is equal to the Period.
    MEMBER FUNCTION f_equal(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer is
    p D_Period_Y;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         b := D_Timepoint_Y_Package.f_equal(m_y, tp.m_y, p.b.m_y, p.e.m_y);
         return b;
    end;

    --Returns true if the Timepoint contains the Period.
    MEMBER FUNCTION f_contains(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer is
    p D_Period_Y;
    b pls_integer := 0;
    begin
         SELECT DEREF(p_y) INTO p FROM DUAL;
         b := D_Timepoint_Y_Package.f_contains(m_y, tp.m_y, p.b.m_y, p.e.m_y);
         return b;
    end;

    --Returns true if the Timepoint overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_Y_Package.f_overlaps(m_y, tp.m_y, te1.to_string());
    end;

    --Returns true if the Timepoint precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_Y_Package.f_precedes(m_y, tp.m_y, te1.to_string());
    end;

    --Returns true if the Timepoint meets the Temporal Element.
    MEMBER FUNCTION f_meets(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_Y_Package.f_meets(m_y, tp.m_y, te1.to_string());
    end;

    --Returns true if the Timepoint is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_Y_Package.f_equal(m_y, tp.m_y, te1.to_string());
    end;

    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Timepoint_Y_Package.f_contains(m_y, tp.m_y, te1.to_string());
    end;

    --Returns true if the Period constructed using the first two Timepoints overlaps the Period constructed using the other two Timepoints.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y, tp3 D_Timepoint_Y, tp4 D_Timepoint_Y) return pls_integer is
    b pls_integer := D_Timepoint_Y_Package.f_overlaps(m_y, tp1.m_y, tp2.m_y, tp3.m_y, tp4.m_y);
    begin
         return b;
    end;

end;
/

SHOW ERRORS;


