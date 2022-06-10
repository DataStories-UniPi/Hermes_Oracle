Prompt drop Type Body D_PERIOD_D;
DROP TYPE BODY D_PERIOD_D
/

Prompt Type Body D_PERIOD_D;
CREATE OR REPLACE type body D_Period_D is

    --Changes the status of the Timepoint object
    MEMBER PROCEDURE change_status(special_value pls_integer) is
    begin
    -- b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d IN OUT argument
         D_Period_D_Package.change_status(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, special_value);
    end;

    --Returns the begin Timepoint of the Period object.
    MEMBER FUNCTION f_begin return D_Timepoint_D is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    begin
         D_Period_D_Package.f_begin(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, b_y, b_m, b_d);
         return D_Timepoint_D(b_y, b_m, b_d);
    end;

    --Returns the end Timepoint of the Period object.
    MEMBER FUNCTION f_end return D_Timepoint_D is
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    begin
         D_Period_D_Package.f_end(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, e_y, e_m, e_d);
         return D_Timepoint_D(e_y, e_m, e_d);
    end;

    --Sets the begin Timepoint of the Period object.
    MEMBER PROCEDURE set_begin(tp D_Timepoint_D) is
    -- b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d IN OUT argument
    begin
         D_Period_D_Package.set_begin(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, tp.m_y, tp.m_m, tp.m_d);
    end;

    --Sets the end Timepoint of the Period object.
    MEMBER PROCEDURE set_end(tp D_Timepoint_D) is
    -- b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d IN OUT argument
    begin
         D_Period_D_Package.set_end(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, tp.m_y, tp.m_m, tp.m_d);
    end;

    --Returns the Granularity of the Period object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_Period_D_Package.get_granularity(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d);
    begin
         return g;
    end;

    --Returns an Interval object representing the duration of the Period.
    MEMBER FUNCTION duration return D_Interval is
    i_Value double precision := 0;
    begin
        D_Period_D_Package.duration(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, i_Value);
        return D_Interval(i_Value);
    end;

    --Creates a string for the Timepoint object in ISO 8601 format.
    MEMBER FUNCTION to_string return Varchar2 is
    s Varchar2(50) := D_Period_D_Package.to_string(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d);
    begin
         return s;
    end;

    --Converts the Period object to a Temporal Element object.
    MEMBER FUNCTION to_temporal_element return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    TE_d REF D_Temp_Element_D;
    begin
         str := D_Period_D_Package.to_temporal_element(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d);
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Assigns the value of another Timepoint to the Timepoint object.
    MEMBER PROCEDURE f_ass_period(p D_Period_D) is
    -- b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d IN OUT argument
    begin
        D_Period_D_Package.f_ass_period(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d);
    end;

    --Adds an Interval to the Timepoint object.
    MEMBER PROCEDURE f_add_interval(i D_Interval) is
    -- b.m_y, b.m_m, b.m_d, b.m_m, e.m_y, e.m_m, e.m_d IN OUT argument
    begin
         D_Period_D_Package.f_add_interval(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, i.m_Value);
    end;

    --Subtracts an Interval from the Timepoint object.
    MEMBER PROCEDURE f_sub_interval(i D_Interval) is
    -- b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d IN OUT argument
    begin
         D_Period_D_Package.f_sub_interval(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, i.m_Value);
    end;

    --Adds the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_add(p D_Period_D, i D_Interval) return D_Period_D is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    begin
         D_Period_D_Package.f_add(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, i.m_Value, b_y, b_m, b_d, e_y, e_m, e_d);
         return D_Period_D(D_Timepoint_D(b_y, b_m, b_d), D_Timepoint_D(e_y, e_m, e_d));
    end;

    --Subtracts the interval to begin and end Timepoints of the Period object.
    MEMBER FUNCTION f_sub(p D_Period_D, i D_Interval) return D_Period_D  is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    begin
         D_Period_D_Package.f_sub(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, i.m_Value, b_y, b_m, b_d, e_y, e_m, e_d);
         return D_Period_D(D_Timepoint_D(b_y, b_m, b_d), D_Timepoint_D(e_y, e_m, e_d));
    end;

    --Constructs a Temporal Element object adding two Periods.
    MEMBER FUNCTION f_add(p1 D_Period_D, p2 D_Period_D) return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    TE_d REF D_Temp_Element_D;
    begin
         str := D_Period_D_Package.f_add(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Constructs a Temporal Element object subtracting two Periods.
    MEMBER FUNCTION f_sub(p1 D_Period_D, p2 D_Period_D) return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    TE_d REF D_Temp_Element_D;
    begin
         str := D_Period_D_Package.f_sub(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Constructs a Temporal Element object adding a Period to a Temporal Element.
    MEMBER FUNCTION f_add(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    TE_d REF D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_D_Package.f_add(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Constructs a Temporal Element object subtracting a Temporal Element from a Period.
    MEMBER FUNCTION f_sub(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    TE_d REF D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_D_Package.f_sub(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Returns a Period object representing the intersection between a Period and a Timepoint.
    MEMBER FUNCTION intersects(p D_Period_D, tp D_Timepoint_D) return D_Period_D is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    begin
         D_Period_D_Package.intersects(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d, b_y, b_m, b_d, e_y, e_m, e_d);
         return D_Period_D(D_Timepoint_D(b_y, b_m, b_d), D_Timepoint_D(e_y, e_m, e_d));
    end;

    --Returns a Period object representing the intersection between two Periods.
    MEMBER FUNCTION intersects(p1 D_Period_D, p2 D_Period_D) return D_Period_D is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    begin
         D_Period_D_Package.intersects(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d, b_y, b_m, b_d, e_y, e_m, e_d);
         return D_Period_D(D_Timepoint_D(b_y, b_m, b_d), D_Timepoint_D(e_y, e_m, e_d));
    end;

    --Returns a Temporal Element object representing the intersection between a Period and a Temporal Element.
    MEMBER FUNCTION intersects(p D_Period_D, te REF D_Temp_Element_D) return REF D_Temp_Element_D is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    TE_d REF D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         str := D_Period_D_Package.intersects(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
         INSERT INTO temp_elements_d t
         VALUES (D_Temp_Element_D(return_temporal_element_d(str)))
         RETURNING REF(t) INTO TE_d;
         return TE_d;
    end;

    --Returns true if the Periods have the same value.
    MEMBER FUNCTION f_eq(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_eq(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the Periods have different value.
    MEMBER FUNCTION f_n_eq(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_n_eq(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period precedes the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_l(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period precedes or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_l_e(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_l_e(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period follows the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_b(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the begin Timepoint of the first Period follows or is equal to the begin Timepoint of the second Period.
    MEMBER FUNCTION f_b_e(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_b_e(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the Period overlaps the Timepoint.
    MEMBER FUNCTION f_overlaps(p D_Period_D, tp D_Timepoint_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_overlaps(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d);
    begin
         return i;
    end;

    --Returns true if the Period precedes the Timepoint.
    MEMBER FUNCTION f_precedes(p D_Period_D, tp D_Timepoint_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_precedes(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d);
    begin
         return i;
    end;

    --Returns true if the Period meets the Timepoint.
    MEMBER FUNCTION f_meets(p D_Period_D, tp D_Timepoint_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_meets(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d);
    begin
         return i;
    end;

    --Returns true if the Period is equal to Timepoint.
    MEMBER FUNCTION f_equal(p D_Period_D, tp D_Timepoint_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_equal(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d);
    begin
         return i;
    end;

    --Returns true if the Period contains the Timepoint.
    MEMBER FUNCTION f_contains(p D_Period_D, tp D_Timepoint_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_contains(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, tp.m_y, tp.m_m, tp.m_d);
    begin
         return i;
    end;

    --Returns true if two Periods overlap.
    MEMBER FUNCTION f_overlaps(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_overlaps(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the first Period precedes the second Period.
    MEMBER FUNCTION f_precedes(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_precedes(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the first Period meets the second Period.
    MEMBER FUNCTION f_meets(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_meets(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the first Period is equal to the second Period.
    MEMBER FUNCTION f_equal(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_equal(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the first Period contains the second Period.
    MEMBER FUNCTION f_contains(p1 D_Period_D, p2 D_Period_D) return pls_integer is
    i pls_integer := D_Period_D_Package.f_contains(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p1.b.m_y, p1.b.m_m, p1.b.m_d, p1.e.m_y, p1.e.m_m, p1.e.m_d, p2.b.m_y, p2.b.m_m, p2.b.m_d, p2.e.m_y, p2.e.m_m, p2.e.m_d);
    begin
         return i;
    end;

    --Returns true if the Period overlaps the Temporal Element.
    MEMBER FUNCTION f_overlaps(p D_Period_D, te REF D_Temp_Element_D) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_D_Package.f_overlaps(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
    end;

    --Returns true if the Period precedes the Temporal Element.
    MEMBER FUNCTION f_precedes(p D_Period_D, te REF D_Temp_Element_D) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_D_Package.f_precedes(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
    end;

    --Returns true if the Period meets the Temporal Element.
    MEMBER FUNCTION f_meets(p D_Period_D, te REF D_Temp_Element_D) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_D_Package.f_meets(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
    end;

    --Returns true if the Period is equal to the Temporal Element.
    MEMBER FUNCTION f_equal(p D_Period_D, te REF D_Temp_Element_D) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_D_Package.f_equal(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
    end;

    --Returns true if the Timepoint contains the Temporal Element.
    MEMBER FUNCTION f_contains(p D_Period_D, te REF D_Temp_Element_D) return pls_integer is
    str Varchar2(32766) := '';
    te1 D_Temp_Element_D;
    begin
         SELECT DEREF(te) INTO te1 FROM DUAL;
         return D_Period_D_Package.f_contains(b.m_y, b.m_m, b.m_d, e.m_y, e.m_m, e.m_d, p.b.m_y, p.b.m_m, p.b.m_d, p.e.m_y, p.e.m_m, p.e.m_d, te1.to_string());
    end;

end;
/

SHOW ERRORS;


