Prompt drop Type D_TIMEPOINT_Y;
DROP TYPE D_TIMEPOINT_Y
/

Prompt Type D_TIMEPOINT_Y;
CREATE OR REPLACE type D_Timepoint_Y as object
(
    m_y integer,

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_value pls_integer),
    --Returns the year for the Timepoint object.
    MEMBER FUNCTION year return pls_integer,
    --Returns the Granularity of the Timepoint object.
    MEMBER FUNCTION get_granularity return pls_integer,
    --Returns a long number equal to the number of seconds since the begin of the calendar, representing the value of the Timepoint object.
    MEMBER FUNCTION get_Abs_Date return double precision,
    --Sets the year for the Timepoint object.
    MEMBER PROCEDURE set_year(year pls_integer),
    --Sets the value of the Timepoint object using a long number representing the number of seconds since the begin of the calendar.
    MEMBER PROCEDURE set_Abs_Date(d double precision),
    --Converts the Timepoint object to a Period object.
    MEMBER FUNCTION to_period return REF D_Period_Y,
    --Converts the Timepoint object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_Y,
    --Creates a string for the Timepoint object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2,
    --Returns true if the year of the Timepoint object is a Leap year.
    MEMBER FUNCTION is_Leap_Year return pls_integer,
    --Returns true if parameter year is a Leap year.
    MEMBER FUNCTION is_Leap_Year(year pls_integer) return pls_integer,
    --Assigns the value of a Timestamp object to the Timepoint object.
    MEMBER PROCEDURE f_ass_timestamp(ts D_Timestamp),
    --Assigns the value of another Timepoint to the Timepoint object.
    MEMBER PROCEDURE f_ass_timepoint(tp D_Timepoint_Y),
    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval),
    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval),
    --Increments the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_incr,
    --Decrements the Timepoint object by one granule (Prefix operator).
    MEMBER PROCEDURE f_decr,
    --Returns a Timepoint object representing the sum of an Timepoint object plus a Interval object.
    MEMBER FUNCTION f_add(tp D_Timepoint_Y, i D_Interval)return D_Timepoint_Y,
    --Returns a Timepoint object representing the subtraction of an Interval object from a Timepoint object.
    MEMBER FUNCTION f_sub(tp D_Timepoint_Y, i D_Interval) return D_Timepoint_Y,
    --Returns a Period object representing the intersection between two Timepoints.
    MEMBER FUNCTION intersects(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return REF D_Period_Y,
    --Returns a Period object representing the intersection between a Timepoint and a Period.
    MEMBER FUNCTION intersects(tp D_Timepoint_Y, p_y REF D_Period_Y) return REF D_Period_Y,
    --Returns a Temporal Element object representing the intersection between a Timepoint and a Temporal Element.
    MEMBER FUNCTION intersects(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return REF D_Temp_Element_Y,
    --Returns true if the Timepoints have the same value.
    MEMBER FUNCTION f_eq(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the Timepoints have different value.
    MEMBER FUNCTION f_n_eq(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint is less than the second.
    MEMBER FUNCTION f_l(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint is less or equal to the second.
    MEMBER FUNCTION f_l_e(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint is greater than the second.
    MEMBER FUNCTION f_b(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint is greater or equal to the second.
    MEMBER FUNCTION f_b_e(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns the Interval between two Timepoints.
    MEMBER FUNCTION f_diff(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return D_Interval,
    --Returns true if the Timepoint is equal to the Timestamp.
    MEMBER FUNCTION f_eq(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if the Timepoint is different from the Timestamp.
    MEMBER FUNCTION f_n_eq(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if the Timepoint is less than the Timestamp.
    MEMBER FUNCTION f_l(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if the Timepoint is less or equal to the Timestamp.
    MEMBER FUNCTION f_l_e(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if the Timepoint is greater than the Timestamp.
    MEMBER FUNCTION f_b(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if the Timepoint is greater or equal to the Timestamp.
    MEMBER FUNCTION f_b_e(tp D_Timepoint_Y, ts D_Timestamp) return pls_integer,
    --Returns true if two Timepoints overlap.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint precedes the second Timepoint.
    MEMBER FUNCTION f_precedes(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint meets the second Timepoint.
    MEMBER FUNCTION f_meets(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint is equal to the second Timepoint.
    MEMBER FUNCTION f_equal(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the first Timepoint contains the second Timepoint.
    MEMBER FUNCTION f_contains(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y) return pls_integer,
    --Returns true if the Timepoint overlaps the Period.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer,
    --Returns true if the Timepoint precedes the Period.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer,
    --Returns true if the Timepoint meets the Period.
    MEMBER FUNCTION f_meets(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer,
    --Returns true if the Timepoint is equal to the Period.
    MEMBER FUNCTION f_equal(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer,
    --Returns true if the Timepoint contains the Period.
    MEMBER FUNCTION f_contains(tp D_Timepoint_Y, p_y REF D_Period_Y) return pls_integer,
    --Returns true if the Timepoint overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer,
    --Returns true if the Timepoint precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer,
    --Returns true if the Timepoint meets the Temporal Element.
    MEMBER FUNCTION f_meets(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer,
    --Returns true if the Timepoint is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer,
    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(tp D_Timepoint_Y, te REF D_Temp_Element_Y) return pls_integer,
    --Returns true if the Period constructed using the first two Timepoints overlaps the Period constructed using the other two Timepoints.
    MEMBER FUNCTION f_overlaps(tp1 D_Timepoint_Y, tp2 D_Timepoint_Y, tp3 D_Timepoint_Y, tp4 D_Timepoint_Y) return pls_integer

);
/

SHOW ERRORS;


