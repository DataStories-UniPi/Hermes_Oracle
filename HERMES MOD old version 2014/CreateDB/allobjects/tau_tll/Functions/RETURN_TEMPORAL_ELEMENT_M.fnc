Prompt drop Function RETURN_TEMPORAL_ELEMENT_M;
DROP FUNCTION RETURN_TEMPORAL_ELEMENT_M
/

Prompt Function RETURN_TEMPORAL_ELEMENT_M;
CREATE OR REPLACE FUNCTION return_temporal_element_m(te_string Varchar2) return Temp_Element_M is
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
/

SHOW ERRORS;


