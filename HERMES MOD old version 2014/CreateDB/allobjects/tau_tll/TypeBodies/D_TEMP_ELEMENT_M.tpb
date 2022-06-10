Prompt drop Type Body D_TEMP_ELEMENT_M;
DROP TYPE BODY D_TEMP_ELEMENT_M
/

Prompt Type Body D_TEMP_ELEMENT_M;
CREATE OR REPLACE type body D_Temp_Element_M is

    --Creates a string for the Temporal Element object.
    MEMBER FUNCTION to_string return Varchar2 is
    i pls_integer;
    s Varchar2(32766) := '';
    begin
         i := te.FIRST;  -- get subscript of first element
         WHILE i IS NOT NULL LOOP
            s := concat(s, TO_CHAR(te(i).b.m_y));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).b.m_m));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_y));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_m));
            s := concat(s, '#');

            i := te.NEXT(i);  -- get subscript of next element
         END LOOP;

         return s;
    end;

    --Creates a Temporal Element object from the string and assigns it to the current TE.
    MEMBER PROCEDURE to_temporal_element(te_string Varchar2) is
    new_te Temp_Element_M;
    s Varchar2(32000);
    t1 pls_integer :=0;
    t2 pls_integer :=0;
    t3 pls_integer :=0;
    t4 pls_integer :=0;
    i pls_integer :=0;

    begin
        s := te_string;
        new_te := Temp_Element_M();

        WHILE LENGTH(s) != 0 LOOP
            t1 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t2 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t3 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t4 := TO_NUMBER( LPAD(s, INSTR(s, '#') - 1) );
            s :=  SUBSTR(s, INSTR(s,'#') + 1, LENGTH(s) - INSTR(s,'#') + 1 );

            new_te.EXTEND;
            i := new_te.LAST;
            new_te(i) := D_Period_M(D_Timepoint_M(t1, t2), D_Timepoint_M(t3, t4));
        END LOOP;

        te := new_te;
    end;

    --Creates a Temporal Element object from the string and returns it.
    MEMBER FUNCTION return_temporal_element(te_string Varchar2) return Temp_Element_M is
    new_te Temp_Element_M;
    s Varchar2(32000);
    t1 pls_integer :=0;
    t2 pls_integer :=0;
    t3 pls_integer :=0;
    t4 pls_integer :=0;
    i pls_integer :=0;

    begin
        s := te_string;
        new_te := Temp_Element_M();

        WHILE LENGTH(s) != 0 LOOP
            t1 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t2 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t3 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t4 := TO_NUMBER( LPAD(s, INSTR(s, '#') - 1) );
            s :=  SUBSTR(s, INSTR(s,'#') + 1, LENGTH(s) - INSTR(s,'#') + 1 );

            new_te.EXTEND;
            i := new_te.LAST;
            new_te(i) := D_Period_M(D_Timepoint_M(t1, t2), D_Timepoint_M(t3, t4));
        END LOOP;

        return new_te;
    end;

    --Returns the first Period of the Temporal Element object.
    MEMBER FUNCTION f_begin return D_Period_M is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    begin
         D_TE_M_Package.f_begin(to_string(), b_y, b_m, e_y, e_m);
         return D_Period_M(D_Timepoint_M(b_y, b_m), D_Timepoint_M(e_y, e_m));
    end;

    --Returns the last Period of the Temporal Element object.
    MEMBER FUNCTION f_end return D_Period_M is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    begin
         D_TE_M_Package.f_end(to_string(), b_y, b_m, e_y, e_m);
         return D_Period_M(D_Timepoint_M(b_y, b_m), D_Timepoint_M(e_y, e_m));
    end;

    --Returns the Granularity of the Temporal Element object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_TE_M_Package.get_granularity(to_string());
    begin
         return g;
    end;

    --Returns an Interval object representing the sum of the duration of the Periods in the Temporal Element object.
    MEMBER FUNCTION duration return D_Interval is
    i_Value double precision := 0;
    begin
        D_TE_M_Package.duration(to_string(), i_Value);
        return D_Interval(i_Value);
    end;

    --Returns the number of Periods contained in the Temporal Element object.
    MEMBER FUNCTION cardinality return pls_integer is
    c pls_integer := D_TE_M_Package.cardinality(to_string());
    begin
         return c;
    end;

    --Returns the Period number num inside the Temporal Element object.
    MEMBER FUNCTION go(num pls_integer) return D_Period_M is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    begin
         D_TE_M_Package.go(to_string(), num, b_y, b_m, e_y, e_m);
         return D_Period_M(D_Timepoint_M(b_y, b_m), D_Timepoint_M(e_y, e_m));
    end;

    --Assigns the value of another Temporal Element to the Temporal Element object.
    MEMBER PROCEDURE f_ass_temp_element(te1 D_Temp_Element_M) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_M_Package.f_ass_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Adds a Temporal Element to the Temporal Element object. The result is all the times which belong to both the Temporal Element objects.
    MEMBER PROCEDURE f_add_temp_element(te1 D_Temp_Element_M) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_M_Package.f_add_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Adds a Period to the Temporal Element object. The result is all the times which belong to either the Period and the Temporal Element.
    MEMBER PROCEDURE f_add_period(p D_Period_M) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_M_Package.f_add_period(te_string, p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
         to_temporal_element(te_string);
    end;

    --Subtracts a Temporal Element from the Temporal Element object. The result is all the times which are included in the current Temporal Elementbut not in the other one.
    MEMBER PROCEDURE f_sub_temp_element(te1 D_Temp_Element_M) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_M_Package.f_sub_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Subtracts a Period from the Temporal Element object. The result is all the times which are included in the current Temporal Element but not in the Period.
    MEMBER PROCEDURE f_sub_period(p D_Period_M) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_M_Package.f_sub_period(te_string, p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
         to_temporal_element(te_string);
    end;

    --Constructs a Temporal Element adding a Period to an existing Temporal Element.
    MEMBER FUNCTION f_add(te1 D_Temp_Element_M, p D_Period_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.f_add(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Constructs a Temporal Element adding two Temporal Elements.
    MEMBER FUNCTION f_add(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.f_add(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Constructs a Temporal Element subtracting a Period to an existing Temporal Element.
    MEMBER FUNCTION f_sub(te1 D_Temp_Element_M, p D_Period_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.f_sub(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Constructs a Temporal Element subtracting two Temporal Elements.
    MEMBER FUNCTION f_sub(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.f_sub(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between a Temporal Element and a Timepoint.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_M, tp D_Timepoint_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.intersects(to_string(), te1.to_string(), tp.m_y, tp.m_m);
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between a Temporal Element and a Period.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_M, p D_Period_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.intersects(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between two Temporal Elements.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return D_Temp_Element_M is
    str Varchar2(32766) := '';
    begin
         str := D_TE_M_Package.intersects(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_M(return_temporal_element(str));
    end;

    --Returns true if the Temporal Elements have the same value.
    MEMBER FUNCTION f_eq(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_eq(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the Temporal Elements have different value.
    MEMBER FUNCTION f_n_eq(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_n_eq(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the Temporal Element overlaps the Timepoint.
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_M, tp D_Timepoint_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_overlaps(to_string(), te1.to_string(), tp.m_y, tp.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element precedes the Timepoint.
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_M, tp D_Timepoint_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_precedes(to_string(), te1.to_string(), tp.m_y, tp.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element meets the Timepoint.
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_M, tp D_Timepoint_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_meets(to_string(), te1.to_string(), tp.m_y, tp.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element equal the Timepoint.
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_M, tp D_Timepoint_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_equal(to_string(), te1.to_string(), tp.m_y, tp.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element contains the Timepoint.
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_M, tp D_Timepoint_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_contains(to_string(), te1.to_string(), tp.m_y, tp.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element overlaps the Period
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_M, p D_Period_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_overlaps(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element precedes the Period
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_M, p D_Period_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_precedes(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element meets the Period
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_M, p D_Period_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_meets(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element equal the Period
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_M, p D_Period_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_equal(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
    begin
         return i;
    end;

    --Returns true if the Temporal Element contains the Period
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_M, p D_Period_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_contains(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.e.m_y, p.e.m_m);
    begin
         return i;
    end;

    --Returns true if two Temporal Elements overlap.
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_overlaps(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element precedes the second Temporal Element.
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_precedes(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element meets the second Temporal Element.
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_meets(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element is equal to second Temporal Element.
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_equal(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element contains the second Temporal Element.
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_M, te2 D_Temp_Element_M) return pls_integer is
    i pls_integer := D_TE_M_Package.f_contains(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

end;
/

SHOW ERRORS;


