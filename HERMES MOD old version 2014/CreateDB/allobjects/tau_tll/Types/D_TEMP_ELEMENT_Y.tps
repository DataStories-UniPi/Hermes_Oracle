Prompt drop Type D_TEMP_ELEMENT_Y;
DROP TYPE D_TEMP_ELEMENT_Y
/

Prompt Type D_TEMP_ELEMENT_Y;
CREATE OR REPLACE type D_Temp_Element_Y as object
(
   te Temp_Element_Y,

   --Creates a string for the Temporal Element object.
   MEMBER FUNCTION to_string return Varchar2,
   --Creates a Temporal Element object from the string and assigns it to the current TE.
   MEMBER PROCEDURE to_temporal_element(te_string Varchar2),
   --Creates a Temporal Element object from the string and returns it.
   MEMBER FUNCTION return_temporal_element(te_string Varchar2) return temp_element_y,
   --Returns the first Period of the Temporal Element object.
   MEMBER FUNCTION f_begin return D_Period_Y,
   --Returns the last Period of the Temporal Element object.
   MEMBER FUNCTION f_end return D_Period_Y,
   --Returns the Granularity of the Temporal Element object.
   MEMBER FUNCTION get_granularity return pls_integer,
   --Returns an Interval object representing the sum of the duration of the Periods in the Temporal Element object.
   MEMBER FUNCTION duration return D_Interval,
   --Returns the number of Periods contained in the Temporal Element object.
   MEMBER FUNCTION cardinality return pls_integer,
   --Returns the Period number num inside the Temporal Element object.
   MEMBER FUNCTION go(num pls_integer) return D_Period_Y,
   --Assigns the value of another Temporal Element to the Temporal Element object.
   MEMBER PROCEDURE f_ass_temp_element(te1 D_Temp_Element_Y),
   --Adds a Temporal Element to the Temporal Element object. The result is all the times which belong to both the Temporal Element objects.
   MEMBER PROCEDURE f_add_temp_element(te1 D_Temp_Element_Y),
   --Adds a Period to the Temporal Element object. The result is all the times which belong to either the Period and the Temporal Element.
   MEMBER PROCEDURE f_add_period(p D_Period_Y),
   --Subtracts a Temporal Element from the Temporal Element object. The result is all the times which are included in the current Temporal Elementbut not in the other one.
   MEMBER PROCEDURE f_sub_temp_element(te1 D_Temp_Element_Y),
   --Subtracts a Period from the Temporal Element object. The result is all the times which are included in the current Temporal Element but not in the Period.
   MEMBER PROCEDURE f_sub_period(p D_Period_Y),
   --Constructs a Temporal Element adding a Period to an existing Temporal Element.
   MEMBER FUNCTION f_add(te1 D_Temp_Element_Y, p D_Period_Y) return D_Temp_Element_Y,
   --Constructs a Temporal Element adding two Temporal Elements.
   MEMBER FUNCTION f_add(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return D_Temp_Element_Y,
   --Constructs a Temporal Element subtracting a Period to an existing Temporal Element.
   MEMBER FUNCTION f_sub(te1 D_Temp_Element_Y, p D_Period_Y) return D_Temp_Element_Y,
   --Constructs a Temporal Element subtracting two Temporal Elements.
   MEMBER FUNCTION f_sub(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return D_Temp_Element_Y,
   --Returns a Temporal Element object representing the intersection between a Temporal Element and a Timepoint.
   MEMBER FUNCTION intersects(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return D_Temp_Element_Y,
   --Returns a Temporal Element object representing the intersection between a Temporal Element and a Period.
   MEMBER FUNCTION intersects(te1 D_Temp_Element_Y, p D_Period_Y) return D_Temp_Element_Y,
   --Returns a Temporal Element object representing the intersection between two Temporal Elements.
   MEMBER FUNCTION intersects(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return D_Temp_Element_Y,
   --Returns true if the Temporal Elements have the same value.
   MEMBER FUNCTION f_eq(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the Temporal Elements have different value.
   MEMBER FUNCTION f_n_eq(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the Temporal Element overlaps the Timepoint.
   MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return pls_integer,
   --Returns true if the Temporal Element precedes the Timepoint.
   MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return pls_integer,
   --Returns true if the Temporal Element meets the Timepoint.
   MEMBER FUNCTION f_meets(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return pls_integer,
   --Returns true if the Temporal Element equal the Timepoint.
   MEMBER FUNCTION f_equal(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return pls_integer,
   --Returns true if the Temporal Element contains the Timepoint.
   MEMBER FUNCTION f_contains(te1 D_Temp_Element_Y, tp D_Timepoint_Y) return pls_integer,
   --Returns true if the Temporal Element overlaps the Period
   MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Y, p D_Period_Y) return pls_integer,
   --Returns true if the Temporal Element precedes the Period
   MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Y, p D_Period_Y) return pls_integer,
   --Returns true if the Temporal Element meets the Period
   MEMBER FUNCTION f_meets(te1 D_Temp_Element_Y, p D_Period_Y) return pls_integer,
   --Returns true if the Temporal Element equal the Period
   MEMBER FUNCTION f_equal(te1 D_Temp_Element_Y, p D_Period_Y) return pls_integer,
   --Returns true if the Temporal Element contains the Period
   MEMBER FUNCTION f_contains(te1 D_Temp_Element_Y, p D_Period_Y) return pls_integer,
   --Returns true if two Temporal Elements overlap.
   MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the first Temporal Element precedes the second Temporal Element.
   MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the first Temporal Element meets the second Temporal Element.
   MEMBER FUNCTION f_meets(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the first Temporal Element is equal to second Temporal Element.
   MEMBER FUNCTION f_equal(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer,
   --Returns true if the first Temporal Element contains the second Temporal Element.
   MEMBER FUNCTION f_contains(te1 D_Temp_Element_Y, te2 D_Temp_Element_Y) return pls_integer

);
/

SHOW ERRORS;


