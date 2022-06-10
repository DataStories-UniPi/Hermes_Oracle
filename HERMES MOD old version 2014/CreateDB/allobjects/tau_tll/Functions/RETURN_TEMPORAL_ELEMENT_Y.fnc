Prompt drop Function RETURN_TEMPORAL_ELEMENT_Y;
DROP FUNCTION RETURN_TEMPORAL_ELEMENT_Y
/

Prompt Function RETURN_TEMPORAL_ELEMENT_Y;
CREATE OR REPLACE FUNCTION return_temporal_element_y(te_string Varchar2) return temp_element_y is
    new_te temp_element_y;
    s Varchar2(32000);
    t1 pls_integer :=0;
    t2 pls_integer :=0;
    i pls_integer :=0;

    begin
        s := te_string;
        new_te := temp_element_y();

        WHILE LENGTH(s) != 0 LOOP
            t1 := TO_NUMBER( LPAD(s, INSTR(s, ',') - 1) );
            s :=  SUBSTR(s, INSTR(s,',') + 1, LENGTH(s) - INSTR(s,',') + 1 );
            t2 := TO_NUMBER( LPAD(s, INSTR(s, '#') - 1) );
            s :=  SUBSTR(s, INSTR(s,'#') + 1, LENGTH(s) - INSTR(s,'#') + 1 );

            new_te.EXTEND;
            i := new_te.LAST;
            new_te(i) := d_period_y(d_timepoint_y(t1), d_timepoint_y(t2));
        END LOOP;

        return new_te;
    end;
/

SHOW ERRORS;


