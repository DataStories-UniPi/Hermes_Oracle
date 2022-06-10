Prompt drop Type Body D_PERIOD_Y;
DROP TYPE BODY D_PERIOD_Y
/

Prompt Type Body D_PERIOD_Y;
CREATE OR REPLACE type body D_Period_Y is

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_value pls_integer) is
    begin
    -- b.m_y, e.m_y IN OUT argument
         D_Period_Y_Package.change_status(b.m_y, e.m_y, special_value);
    end;

    --Returns the begin Timepoint of the Period object.
    MEMBER FUNCTION f_begin return D_Timepoint_Y is
    b_y pls_integer := 0;
    begin
         D_Period_Y_Package.f_begin(b.m_y, e.m_y, b_y);
         return D_Timepoint_Y(b_y);
    end;

    --Returns the end Timepoint of the Period object.
    MEMBER FUNCTION f_end return D_Timepoint_Y is
    e_y pls_integer := 0;
    begin
         D_Period_Y_Package.f_end(b.m_y, e.m_y, e_y);
         return D_Timepoint_Y(e_y);
    end;

    --Sets the begin Timepoint of the Period object.
    MEMBER PROCEDURE set_begin(tp D_Timepoint_Y) is
    -- b.m_y, e.m_y IN OUT argument
    begin
         D_Period_Y_Package.set_begin(b.m_y, e.m_y, tp.m_y);
    end;

    --Sets the end Timepoint of the Period object.
    MEMBER PROCEDURE set_end(tp D_Timepoint_Y) is
    -- b.m_y, e.m_y IN OUT argument
    begin
         D_Period_Y_Package.set_end(b.m_y, e.m_y, tp.m_y);
    end;

    --Returns the Granularity of the Period object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_Period_Y_Package.get_granularity(b.m_y, e.m_y);
    begin
         return g;
    end;

    --Returns an Interval object representing the duration of the Period.
    MEMBER FUNCTION duration return D_Interval is
    i_Value double precision := 0;
    begin
        D_Period_Y_Package.duration(b.m_y, e.m_y, i_Value);
        return D_Interval(i_Value);
    end;

    --Creates a string for the Timepoint object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2 is
    s Varchar2(50) := D_Period_Y_Package.to_string(b.m_y, e.m_y);
    begin
         return s;
    end;

    --Converts the Period object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    TE_y REF D_Temp_Element_Y;
    begin
         str := D_Period_Y_Package.to_temporal_element(b.m_y, e.m_y);
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Assigns the value of another Timepoint to the Timepoint object.
    MEMBER PROCEDURE f_ass_period(p D_Period_Y) is
    -- b.m_y, e.m_y IN OUT argument
    begin
        D_Period_Y_Package.f_ass_period(b.m_y, e.m_y, p.b.m_y, p.e.m_y);
    end;

    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval) is
    -- b.m_y, e.m_y IN OUT argument
    begin
         D_Period_Y_Package.f_add_interval(b.m_y, e.m_y, i.m_Value);
    end;

    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval) is
    -- b.m_y, e.m_y IN OUT argument
    begin
         D_Period_Y_Package.f_sub_interval(b.m_y, e.m_y, i.m_Value);
    end;

    --Adds the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_add(p D_Period_Y, i D_Interval) return D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    begin
         D_Period_Y_Package.f_add(b.m_y, e.m_y, p.b.m_y, p.e.m_y, i.m_Value, b_y, e_y);
         return D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y));
    end;

    --Subtracts the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_sub(p D_Period_Y, i D_Interval) return D_Period_Y  is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    begin
         D_Period_Y_Package.f_sub(b.m_y, e.m_y, p.b.m_y, p.e.m_y, i.m_Value, b_y, e_y);
         return D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y));
    end;

    --Constructs a Temporal Element object adding two Periods.
    MEMBER FUNCTION f_add(p1 D_Period_Y, p2 D_Period_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    TE_y REF D_Temp_Element_Y;
    begin
         str := D_Period_Y_Package.f_add(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Constructs a Temporal Element object subtracting two Periods.
    MEMBER FUNCTION f_sub(p1 D_Period_Y, p2 D_Period_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    TE_y REF D_Temp_Element_Y;
    begin
         str := D_Period_Y_Package.f_sub(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Constructs a Temporal Element object adding a Period to a Temporal Element.
    MEMBER FUNCTION f_add(p D_Period_Y, te REF D_Temp_Element_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    TE_y REF D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_Y_Package.f_add(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Constructs a Temporal Element object subtracting a Temporal Element from a Period.
    MEMBER FUNCTION f_sub(p D_Period_Y, te REF D_Temp_Element_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    TE_y REF D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_Y_Package.f_sub(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Returns a Period object representing the intersection between a Period and a Timepoint.
    MEMBER FUNCTION intersects(p D_Period_Y, tp D_Timepoint_Y) return D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    begin
         D_Period_Y_Package.intersects(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y, b_y, e_y);
         return D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y));
    end;

    --Returns a Period object representing the intersection between two Periods.
    MEMBER FUNCTION intersects(p1 D_Period_Y, p2 D_Period_Y) return D_Period_Y is
    b_y pls_integer := 0;
    e_y pls_integer := 0;
    begin
         D_Period_Y_Package.intersects(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y, b_y, e_y);
         return D_Period_Y(D_Timepoint_Y(b_y), D_Timepoint_Y(e_y));
    end;

    --Returns a Temporal Element object representing the intersection between a Period and a Temporal Element.
    MEMBER FUNCTION intersects(p D_Period_Y, te REF D_Temp_Element_Y) return REF D_Temp_Element_Y is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    TE_y REF D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_Y_Package.intersects(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
         INSERT INTO temp_elements_y t
         VALUES (D_Temp_Element_Y(return_temporal_element_y(str)))
         RETURNING REF(t) INTO TE_y;
         return TE_y;
    end;

    --Returns true if the Periods have the same value.
    MEMBER FUNCTION f_eq(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_eq(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the Periods have different value.
    MEMBER FUNCTION f_n_eq(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_n_eq(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period precedes the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_l(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period precedes or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l_e(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_l_e(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period follows the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_b(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period follows or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b_e(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_b_e(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the Period overlaps the Timepoint.
    MEMBER FUNCTION f_overlaps(p D_Period_Y, tp D_Timepoint_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_overlaps(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y);
    begin
         return i;
    end;

    --Returns true if the Period precedes the Timepoint.
    MEMBER FUNCTION f_precedes(p D_Period_Y, tp D_Timepoint_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_precedes(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y);
    begin
         return i;
    end;

    --Returns true if the Period meets the Timepoint.
    MEMBER FUNCTION f_meets(p D_Period_Y, tp D_Timepoint_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_meets(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y);
    begin
         return i;
    end;

    --Returns true if the Period is equal to Timepoint.
    MEMBER FUNCTION f_equal(p D_Period_Y, tp D_Timepoint_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_equal(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y);
    begin
         return i;
    end;

    --Returns true if the Period contains the Timepoint.
    MEMBER FUNCTION f_contains(p D_Period_Y, tp D_Timepoint_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_contains(b.m_y, e.m_y, p.b.m_y, p.e.m_y, tp.m_y);
    begin
         return i;
    end;

    --Returns true if two Periods overlap.
    MEMBER FUNCTION f_overlaps(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_overlaps(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the first Period precedes the second Period.
    MEMBER FUNCTION f_precedes(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_precedes(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the first Period meets the second Period.
    MEMBER FUNCTION f_meets(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_meets(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the first Period is equal to the second Period.
    MEMBER FUNCTION f_equal(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_equal(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the first Period contains the second Period.
    MEMBER FUNCTION f_contains(p1 D_Period_Y, p2 D_Period_Y) return pls_integer is
    i pls_integer := D_Period_Y_Package.f_contains(b.m_y, e.m_y, p1.b.m_y, p1.e.m_y, p2.b.m_y, p2.e.m_y);
    begin
         return i;
    end;

    --Returns true if the Period overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(p D_Period_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_Y_Package.f_overlaps(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
    end;

    --Returns true if the Period precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(p D_Period_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_Y_Package.f_precedes(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
    end;

    --Returns true if the Period meets the Temporal Element.
    MEMBER FUNCTION f_meets(p D_Period_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_Y_Package.f_meets(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
    end;

    --Returns true if the Period is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(p D_Period_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_Y_Package.f_equal(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
    end;

    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(p D_Period_Y, te REF D_Temp_Element_Y) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_Y;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_Y_Package.f_contains(b.m_y, e.m_y, p.b.m_y, p.e.m_y, te1.to_string());
    end;

end;
/

SHOW ERRORS;


