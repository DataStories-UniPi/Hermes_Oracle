Prompt drop Type D_PERIOD_D;
DROP TYPE D_PERIOD_D
/

Prompt Type D_PERIOD_D;
CREATE OR REPLACE type D_Period_D as object
(
   b D_Timepoint_D,
   e D_Timepoint_D,

    --Changes the status of the Period object
    MEMBER PROCEDURE change_status(special_value pls_integer),
    --Returns the begin Timepoint of the Period object.
    MEMBER FUNCTION f_begin return D_Timepoint_D,
    --Returns the end Timepoint of the Period object.
    MEMBER FUNCTION f_end return D_Timepoint_D,
    --Sets the begin Timepoint of the Period object.
    MEMBER PROCEDURE set_begin(tp D_Timepoint_D),
    --Sets the end Timepoint of the Period object.
    MEMBER PROCEDURE set_end(tp D_Timepoint_D),
    --Returns the Granularity of the Period object.
    MEMBER FUNCTION get_granularity return pls_integer,
    --Returns an Interval object representing the duration of the Period.
    MEMBER FUNCTION duration return D_Interval,
    --Creates a string for the Period object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2,
    --Converts the Period object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_D,
    --Assigns the value of another Period to the Period object.
    MEMBER PROCEDURE f_ass_period(p D_Period_D),
    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval),
    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval),
    --Adds the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_add(p D_Period_D, i D_Interval)return D_Period_D,
    --Subtracts the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_sub(p D_Period_D, i D_Interval) return D_Period_D,
    --Constructs a Temporal Element object adding two Periods.
    MEMBER FUNCTION f_add(p1 D_Period_D, p2 D_Period_D) return REF D_Temp_Element_D,
    --Constructs a Temporal Element object subtracting two Periods.
    MEMBER FUNCTION f_sub(p1 D_Period_D, p2 D_Period_D) return REF D_Temp_Element_D,
    --Constructs a Temporal Element object adding a Period to a Temporal Element.
    MEMBER FUNCTION f_add(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D,
    --Constructs a Temporal Element object subtracting a Temporal Element from a Period.
    MEMBER FUNCTION f_sub(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D,
    --Returns a Period object representing the intersection between a Period and a Timepoint.
    MEMBER FUNCTION intersects(p D_Period_D, tp D_Timepoint_D) return D_Period_D,
    --Returns a Period object representing the intersection between two Periods.
    MEMBER FUNCTION intersects(p1 D_Period_D, p2 D_Period_D) return D_Period_D,
    --Returns a Temporal Element object representing the intersection between a Period and a Temporal Element.
    MEMBER FUNCTION intersects(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D,
    --Returns true if the Periods have the same value.
    MEMBER FUNCTION f_eq(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the Periods have different value.
    MEMBER FUNCTION f_n_eq(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the begin Timepoint of the first Period precedes the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the begin Timepoint of the first Period precedes or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l_e(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the begin Timepoint of the first Period follows the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the begin Timepoint of the first Period follows or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b_e(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the Period overlaps the Timepoint.
    MEMBER FUNCTION f_overlaps(p D_Period_D, tp D_Timepoint_D) return pls_integer,
    --Returns true if the Period precedes the Timepoint.
    MEMBER FUNCTION f_precedes(p D_Period_D, tp D_Timepoint_D) return pls_integer,
    --Returns true if the Period meets the Timepoint.
    MEMBER FUNCTION f_meets(p D_Period_D, tp D_Timepoint_D) return pls_integer,
    --Returns true if the Period is equal to Timepoint.
    MEMBER FUNCTION f_equal(p D_Period_D, tp D_Timepoint_D) return pls_integer,
    --Returns true if the Period contains the Timepoint.
    MEMBER FUNCTION f_contains(p D_Period_D, tp D_Timepoint_D) return pls_integer,
    --Returns true if two Periods overlap.
    MEMBER FUNCTION f_overlaps(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the first Period precedes the second Period.
    MEMBER FUNCTION f_precedes(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the first Period meets the second Period.
    MEMBER FUNCTION f_meets(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the first Period is equal to the second Period.
    MEMBER FUNCTION f_equal(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the first Period contains the second Period.
    MEMBER FUNCTION f_contains(p1 D_Period_D, p2 D_Period_D) return pls_integer,
    --Returns true if the Period overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(p D_Period_D, te REF D_Temp_Element_D) return pls_integer,
    --Returns true if the Period precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(p D_Period_D, te REF D_Temp_Element_D) return pls_integer,
    --Returns true if the Period meets the Temporal Element.
    MEMBER FUNCTION f_meets(p D_Period_D, te REF D_Temp_Element_D) return pls_integer,
    --Returns true if the Period is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(p D_Period_D, te REF D_Temp_Element_D) return pls_integer,
    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(p D_Period_D, te REF D_Temp_Element_D) return pls_integer

);
/

SHOW ERRORS;


