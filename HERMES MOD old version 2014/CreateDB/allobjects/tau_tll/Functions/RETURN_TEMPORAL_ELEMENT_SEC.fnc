Prompt drop Function RETURN_TEMPORAL_ELEMENT_SEC;
DROP FUNCTION RETURN_TEMPORAL_ELEMENT_SEC
/

Prompt Function RETURN_TEMPORAL_ELEMENT_SEC;
CREATE OR REPLACE FUNCTION return_temporal_element_sec(te_string Varchar2) return Temp_Element_Sec is
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
/

SHOW ERRORS;


