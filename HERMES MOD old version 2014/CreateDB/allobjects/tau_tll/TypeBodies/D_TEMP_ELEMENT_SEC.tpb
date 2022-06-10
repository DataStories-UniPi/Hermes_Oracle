Prompt drop Type Body D_TEMP_ELEMENT_SEC;
DROP TYPE BODY D_TEMP_ELEMENT_SEC
/

Prompt Type Body D_TEMP_ELEMENT_SEC;
CREATE OR REPLACE type body D_Temp_Element_Sec is

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
            s := concat(s, TO_CHAR(te(i).b.m_d));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).b.m_h));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).b.m_min));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).b.m_sec));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_y));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_m));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_d));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_h));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_min));
            s := concat(s, ',');
            s := concat(s, TO_CHAR(te(i).e.m_sec));
            s := concat(s, '#');

            i := te.NEXT(i);  -- get subscript of next element
         END LOOP;

         return s;
    end;

    --Creates a Temporal Element object from the string and assigns it to the current TE.
    MEMBER PROCEDURE to_temporal_element(te_string Varchar2) is
    new_te Temp_Element_Sec;
    s Varchar2(32766);
    t1 pls_integer :=0;
    t2 pls_integer :=0;
    t3 pls_integer :=0;
    t4 pls_integer :=0;
    t5 pls_integer :=0;
    t6 double precision :=0;
    t7 pls_integer :=0;
    t8 pls_integer :=0;
    t9 pls_integer :=0;
    t10 pls_integer :=0;
    t11 pls_integer :=0;
    t12 double precision :=0;
    i pls_integer :=0;

    begin
        s := te_string;
        new_te := Temp_Element_Sec();

        WHILE LENGTH(s) != 0 LOOP
            t1 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t2 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t3 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t4 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t5 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t6 := TO_NUMBER( REPLACE( LPAD(s, INSTR(s, ',') - 1), '.', ',') );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t7 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t8 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t9 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t10 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t11 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t12 := TO_NUMBER( REPLACE( LPAD(s, INSTR(s, '#') - 1), '.', ',') );
            s :=  SUBSTR(s, INSTR(s,'#') + 1, LENGTH(s) - INSTR(s,'#') + 1 );

            new_te.EXTEND;
            i := new_te.LAST;
            new_te(i) := D_Period_Sec(D_Timepoint_Sec(t1, t2, t3, t4, t5, t6), D_Timepoint_Sec(t7, t8, t9, t10, t11, t12));
        END LOOP;

        te := new_te;
    end;

    --Creates a Temporal Element object from the string and returns it.
    MEMBER FUNCTION return_temporal_element(te_string Varchar2) return Temp_Element_Sec is
    new_te Temp_Element_Sec;
    s Varchar2(32766);
    t1 pls_integer :=0;
    t2 pls_integer :=0;
    t3 pls_integer :=0;
    t4 pls_integer :=0;
    t5 pls_integer :=0;
    t6 double precision :=0;
    t7 pls_integer :=0;
    t8 pls_integer :=0;
    t9 pls_integer :=0;
    t10 pls_integer :=0;
    t11 pls_integer :=0;
    t12 double precision :=0;
    i pls_integer :=0;

    begin
        s := te_string;
        new_te := Temp_Element_Sec();

        WHILE LENGTH(s) != 0 LOOP
            t1 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t2 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t3 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t4 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t5 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t6 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t7 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t8 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t9 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t10 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t11 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t12 := TO_NUMBER( LPAD(s, INSTR(s, '#') - 1) );
            s :=  SUBSTR(s, INSTR(s,'#') + 1, LENGTH(s) - INSTR(s,'#') + 1 );

            new_te.EXTEND;
            i := new_te.LAST;
            new_te(i) := D_Period_Sec(D_Timepoint_Sec(t1, t2, t3, t4, t5, t6), D_Timepoint_Sec(t7, t8, t9, t10, t11, t12));
        END LOOP;

        return new_te;
    end;

    --Returns the first Period of the Temporal Element object.
    MEMBER FUNCTION f_begin return D_Period_Sec is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    b_h pls_integer := 0;
    b_min pls_integer := 0;
    b_sec double precision := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    e_h pls_integer := 0;
    e_min pls_integer := 0;
    e_sec double precision := 0;
    begin
         D_TE_Sec_Package.f_begin(to_string(), b_y, b_m, b_d, b_h, b_min, b_sec, e_y, e_m, e_d, e_h, e_min, e_sec);
         return D_Period_Sec(D_Timepoint_Sec(b_y, b_m, b_d, b_h, b_min, b_sec), D_Timepoint_Sec(e_y, e_m, e_d, e_h, e_min, e_sec));
    end;

    --Returns the last Period of the Temporal Element object.
    MEMBER FUNCTION f_end return D_Period_Sec is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    b_h pls_integer := 0;
    b_min pls_integer := 0;
    b_sec double precision := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    e_h pls_integer := 0;
    e_min pls_integer := 0;
    e_sec double precision := 0;
    begin
         D_TE_Sec_Package.f_end(to_string(), b_y, b_m, b_d, b_h, b_min, b_sec, e_y, e_m, e_d, e_h, e_min, e_sec);
         return D_Period_Sec(D_Timepoint_Sec(b_y, b_m, b_d, b_h, b_min, b_sec), D_Timepoint_Sec(e_y, e_m, e_d, e_h, e_min, e_sec));
    end;

    --Returns the Granularity of the Temporal Element object.
    MEMBER FUNCTION get_granularity return pls_integer is
    g pls_integer := D_TE_Sec_Package.get_granularity(to_string());
    begin
         return g;
    end;

    --Returns an Interval object representing the sum of the duration of the Periods in the Temporal Element object.
    MEMBER FUNCTION duration return D_Interval is
    i_Value double precision := 0;
    begin
        D_TE_Sec_Package.duration(to_string(), i_Value);
        return D_Interval(i_Value);
    end;

    --Returns the number of Periods contained in the Temporal Element object.
    MEMBER FUNCTION cardinality return pls_integer is
    c pls_integer := D_TE_Sec_Package.cardinality(to_string());
    begin
         return c;
    end;

    --Returns the Period number num inside the Temporal Element object.
    MEMBER FUNCTION go(num pls_integer) return D_Period_Sec is
    b_y pls_integer := 0;
    b_m pls_integer := 0;
    b_d pls_integer := 0;
    b_h pls_integer := 0;
    b_min pls_integer := 0;
    b_sec double precision := 0;
    e_y pls_integer := 0;
    e_m pls_integer := 0;
    e_d pls_integer := 0;
    e_h pls_integer := 0;
    e_min pls_integer := 0;
    e_sec double precision := 0;
    begin
         D_TE_Sec_Package.go(to_string(), num, b_y, b_m, b_d, b_h, b_min, b_sec, e_y, e_m, e_d, e_h, e_min, e_sec);
         return D_Period_Sec(D_Timepoint_Sec(b_y, b_m, b_d, b_h, b_min, b_sec), D_Timepoint_Sec(e_y, e_m, e_d, e_h, e_min, e_sec));
    end;

    --Assigns the value of another Temporal Element to the Temporal Element object.
    MEMBER PROCEDURE f_ass_temp_element(te1 D_Temp_Element_Sec) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_Sec_Package.f_ass_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Adds a Temporal Element to the Temporal Element object. The result is all the times which belong to both the Temporal Element objects.
    MEMBER PROCEDURE f_add_temp_element(te1 D_Temp_Element_Sec) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_Sec_Package.f_add_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Adds a Period to the Temporal Element object. The result is all the times which belong to either the Period and the Temporal Element.
    MEMBER PROCEDURE f_add_period(p D_Period_Sec) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_Sec_Package.f_add_period(te_string, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
         to_temporal_element(te_string);
    end;

    --Subtracts a Temporal Element from the Temporal Element object. The result is all the times which are included in the current Temporal Elementbut not in the other one.
    MEMBER PROCEDURE f_sub_temp_element(te1 D_Temp_Element_Sec) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_Sec_Package.f_sub_temp_element(te_string, te1.to_string());
         to_temporal_element(te_string);
    end;

    --Subtracts a Period from the Temporal Element object. The result is all the times which are included in the current Temporal Element but not in the Period.
    MEMBER PROCEDURE f_sub_period(p D_Period_Sec) is
    te_string Varchar2(32766) := '';
    begin
         te_string := to_string();
         te_string := D_TE_Sec_Package.f_sub_period(te_string, p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
         to_temporal_element(te_string);
    end;

    --Constructs a Temporal Element adding a Period to an existing Temporal Element.
    MEMBER FUNCTION f_add(te1 D_Temp_Element_Sec, p D_Period_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.f_add(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Constructs a Temporal Element adding two Temporal Elements.
    MEMBER FUNCTION f_add(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.f_add(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Constructs a Temporal Element subtracting a Period to an existing Temporal Element.
    MEMBER FUNCTION f_sub(te1 D_Temp_Element_Sec, p D_Period_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.f_sub(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Constructs a Temporal Element subtracting two Temporal Elements.
    MEMBER FUNCTION f_sub(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.f_sub(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between a Temporal Element and a Timepoint.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.intersects(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between a Temporal Element and a Period.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_Sec, p D_Period_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.intersects(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Returns a Temporal Element object representing the intersection between two Temporal Elements.
    MEMBER FUNCTION intersects(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return D_Temp_Element_Sec is
    str Varchar2(32766) := '';
    begin
         str := D_TE_Sec_Package.intersects(to_string(), te1.to_string(), te2.to_string());
         return D_Temp_Element_Sec(return_temporal_element(str));
    end;

    --Returns true if the Temporal Elements have the same value.
    MEMBER FUNCTION f_eq(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_eq(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the Temporal Elements have different value.
    MEMBER FUNCTION f_n_eq(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_n_eq(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the Temporal Element overlaps the Timepoint.
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_overlaps(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element precedes the Timepoint.
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_precedes(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element meets the Timepoint.
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_meets(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element equal the Timepoint.
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_equal(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element contains the Timepoint.
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_Sec, tp D_Timepoint_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_contains(to_string(), te1.to_string(), tp.m_y, tp.m_m, tp.m_d, tp.m_h, tp.m_min, tp.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element overlaps the Period
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Sec, p D_Period_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_overlaps(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element precedes the Period
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Sec, p D_Period_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_precedes(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element meets the Period
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_Sec, p D_Period_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_meets(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element equal the Period
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_Sec, p D_Period_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_equal(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
    begin
         return i;
    end;

    --Returns true if the Temporal Element contains the Period
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_Sec, p D_Period_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_contains(to_string(), te1.to_string(), p.b.m_y, p.b.m_m, p.b.m_d, p.b.m_h, p.b.m_min, p.b.m_sec, p.e.m_y, p.e.m_m, p.e.m_d, p.e.m_h, p.e.m_min, p.e.m_sec);
    begin
         return i;
    end;

    --Returns true if two Temporal Elements overlap.
    MEMBER FUNCTION f_overlaps(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_overlaps(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element precedes the second Temporal Element.
    MEMBER FUNCTION f_precedes(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_precedes(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element meets the second Temporal Element.
    MEMBER FUNCTION f_meets(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_meets(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element is equal to second Temporal Element.
    MEMBER FUNCTION f_equal(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_equal(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

    --Returns true if the first Temporal Element contains the second Temporal Element.
    MEMBER FUNCTION f_contains(te1 D_Temp_Element_Sec, te2 D_Temp_Element_Sec) return pls_integer is
    i pls_integer := D_TE_Sec_Package.f_contains(to_string(), te1.to_string(), te2.to_string());
    begin
         return i;
    end;

end;
/

SHOW ERRORS;


