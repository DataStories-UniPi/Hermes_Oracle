Prompt Package Body RAW_TRAJECTORIES_LOADER;
CREATE OR REPLACE PACKAGE BODY RAW_TRAJECTORIES_LOADER AS

    PROCEDURE  loadmpoint(mpointID integer, OBJ_ID integer, srid integer, raw_table varchar2,
       target_table varchar2) is
    TYPE ORD IS TABLE OF number;
    TYPE PLS_INT IS TABLE OF pls_integer;
    Xs ORD;
    Ys ORD;
    T_YEARs PLS_INT;
    T_MONTHs PLS_INT;
    T_DAYs PLS_INT;
    T_HOURs PLS_INT;
    T_MINs PLS_INT;
    --T_SECs PLS_INT;--truncation of decimal place, mind
    T_SECs ord;--no truncation
    pre_year pls_integer;
    pre_month pls_integer;
    pre_day pls_integer;
    pre_hour pls_integer;
    pre_minute pls_integer;
    --pre_sec pls_integer;
    pre_sec number;--no truncation
    pre_x number;
    pre_y number;
    prepre_x number := -5678.141;
    prepre_y number := -8765.151;
    i pls_integer := 1;
    j pls_integer := 0;
    unit_tab moving_point_tab;
    --prev_last_unit unit_moving_point;
    new_unit unit_moving_point;
    cv1 CursorType;
    sql_stm varchar2(1000);
    begin
        /*
        SELECT X, Y, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND
        BULK COLLECT INTO Xs, Ys, T_YEARs, T_MONTHs, T_DAYs, T_HOURs, T_MINs, T_SECs
        FROM HERMES.MILANO_CL_RAW WHERE TRAJECTORYID = mpointID AND USERID = OBJ_ID ORDER BY YEAR, MONTH, DAY, HOUR, MINUTE, SECOND;
        */
        IF NOT cv1%ISOPEN THEN
            OPEN cv1 FOR 'SELECT X, Y, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND FROM '|| raw_table
            || ' WHERE TRAJECTORYID = '||mpointID||' AND USERID = '||
            OBJ_ID||' ORDER BY YEAR, MONTH, DAY, HOUR, MINUTE, SECOND';
            FETCH cv1 BULK COLLECT INTO Xs, Ys, T_YEARs, T_MONTHs, T_DAYs, T_HOURs, T_MINs, T_SECs;
        END IF;

        /*FOR i IN 1 .. XIs.LAST LOOP
        dbms_output.put_line('X='||TO_CHAR(XIs(i))||' Y='||TO_CHAR(YIs(i)));
        END LOOP;*/

        unit_tab := HERMES.moving_point_tab();
        pre_x := Xs(1);pre_y := Ys(1);
        pre_year:=t_years(1); pre_month:=t_months(1); pre_day:=t_days(1); pre_hour:=t_hours(1);
        pre_minute:=T_MINs(1); pre_sec:=T_SECs(1);
        i := 2;
        WHILE i <= Xs.LAST LOOP
            IF Xs(i) = pre_x AND Ys(i) = pre_y THEN
                NULL;
            --ELSIF UTILITIES.check_colinear(prepre_x, prepre_y, pre_x, pre_y, Xs(i), Ys(i)) = TRUE THEN
            --  NULL;
            elsif t_years(i)=pre_year and t_months(i)=pre_month and t_days(i)=pre_day and t_hours(i)=pre_hour
            AND T_MINs(i)=pre_minute AND T_SECs(i)=pre_sec THEN
                NULL;
            ELSE
                --j := j + 1;
                new_unit := HERMES.unit_moving_point(
                    TAU_TLL.d_period_sec(
                        TAU_TLL.d_timepoint_sec(pre_year, pre_month, pre_day, pre_hour, pre_minute, pre_sec),
                        TAU_TLL.d_timepoint_sec(T_YEARs(i), T_MONTHs(i), T_DAYs(i), T_HOURs(i), T_MINs(i), T_SECs(i))
                    ),
                    HERMES.unit_function(pre_x, pre_y, Xs(i), Ys(i), null, null, null, null, null, 'PLNML_1')
                );
                unit_tab.EXTEND(1);
                unit_tab(unit_tab.COUNT) := new_unit;
                --dbms_output.put_line('unit_tab.COUNT='||TO_CHAR(unit_tab.COUNT));
                --dbms_output.put_line('X='||TO_CHAR(Xs(i))||' Y='||TO_CHAR(Ys(i)));

                prepre_x := pre_x;
                prepre_y := pre_y;
                pre_x := Xs(i);
                pre_y := Ys(i);
                pre_year:=t_years(i); pre_month:=t_months(i); pre_day:=t_days(i); pre_hour:=t_hours(i);
                pre_minute:=T_MINs(i); pre_sec:=T_SECs(i);
            END IF;
            i := i + 1;
        END LOOP;

        sql_stm := 'insert into '||target_table||' values('||OBJ_ID||', '||mpointID||', :mpoint)';
        execute immediate sql_stm using HERMES.MOVING_POINT(unit_tab,mpointID, srid);

    end;

    PROCEDURE  bulkload_RAW_TRAJECTORIES(srid integer, raw_table varchar2, target_table varchar2) is
    cv1 CursorType;
    cv2 CursorType;
    TYPE ID IS TABLE OF INTEGER;
    OBJ_IDs ID;
    TRAJ_IDs ID;
    k pls_integer;
    i pls_integer;
    sql_stm varchar2(1000);
    begin
        sql_stm := 'delete '||target_table;
        execute immediate sql_stm;
        IF NOT cv1%ISOPEN THEN
            OPEN cv1 FOR 'SELECT distinct USERID FROM '|| raw_table;
            FETCH cv1 BULK COLLECT INTO OBJ_IDs;
        END IF;

        FOR k IN OBJ_IDs.FIRST .. OBJ_IDs.LAST LOOP
            IF NOT cv2%ISOPEN THEN
                OPEN cv2 FOR 'SELECT distinct TRAJECTORYID FROM '|| raw_table ||' WHERE USERID = '
                || OBJ_IDs(k);
                FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
            END IF;

            FOR i IN TRAJ_IDs.FIRST .. TRAJ_IDs.LAST LOOP
                --dbms_output.put_line('TRAJ_ID='||TO_CHAR(TRAJ_IDs(i)) ||'   OBJ_ID='|| OBJ_IDs(k));
                loadmpoint(TRAJ_IDs(i), OBJ_IDs(k), srid, raw_table, target_table);
            END LOOP;
            commit;

            CLOSE cv2;
        END LOOP;

        CLOSE cv1;
        remove_empty_MPOINTS(target_table);
    end;

    PROCEDURE  remove_empty_MPOINTS(target_table varchar2) is
    cv1 CursorType;
    cv2 CursorType;
    TYPE ID IS TABLE OF INTEGER;
    OBJ_IDs ID;
    TRAJ_IDs ID;
    k pls_integer;
    i pls_integer;
    mp HERMES.Moving_Point ;
    sql_stm varchar2(1000);
    BEGIN
        IF NOT cv1%ISOPEN THEN
            OPEN cv1 FOR 'SELECT distinct OBJECT_ID FROM '||target_table;
            FETCH cv1 BULK COLLECT INTO OBJ_IDs;
        END IF;

        FOR k IN OBJ_IDs.FIRST .. OBJ_IDs.LAST LOOP
            IF NOT cv2%ISOPEN THEN
                OPEN cv2 FOR 'SELECT distinct TRAJ_ID FROM '||target_table||' WHERE OBJECT_ID = '||OBJ_IDs(k);
                FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
            END IF;

            FOR i IN TRAJ_IDs.FIRST .. TRAJ_IDs.LAST LOOP
                --dbms_output.put_line('TRAJ_ID='||TO_CHAR(TRAJ_IDs(i)) ||'   OBJ_ID='|| OBJ_IDs(k));
                sql_stm := 'select a.mpoint from '||target_table||' a where a.OBJECT_ID = '||OBJ_IDs(k)||' and a.TRAJ_ID = '||TRAJ_IDs(i);
                execute immediate sql_stm into mp;
                IF mp is null OR mp.u_tab.COUNT = 0 THEN
                  sql_stm := 'delete from '||target_table||' where OBJECT_ID = '||OBJ_IDs(k)||' and TRAJ_ID = '||TRAJ_IDs(i);
                  execute immediate sql_stm;
                END IF;
            END LOOP;

            CLOSE cv2;
        END LOOP;

        CLOSE cv1;
    END;

PROCEDURE LoadFromFile_ID_N_t_x_y(file_name VARCHAR2, table_name VARCHAR2) is
--table_name VARCHAR2(100);
infile CLOB;
line VARCHAR2(32767);
lineCLOB CLOB;
token VARCHAR2(100);
CLOBsize PLS_INTEGER;
pattern1 VARCHAR2(1);
pattern2 VARCHAR2(1);
offset PLS_INTEGER;
occur PLS_INTEGER;
position1 PLS_INTEGER := 0;
position2 PLS_INTEGER;
position3 PLS_INTEGER;
position4 PLS_INTEGER;
id    PLS_INTEGER;
N     PLS_INTEGER;
pre_t double precision;
pre_x number;
pre_y number;
pre_year PLS_INTEGER := 2000;
pre_month PLS_INTEGER := 1;
pre_day PLS_INTEGER := 1;
pre_hour PLS_INTEGER := 1;
pre_minute PLS_INTEGER := 1;
pre_sec double precision := 1;
t double precision;
x number;
y number;
T_YEAR PLS_INTEGER := 2000;
T_MONTH PLS_INTEGER := 1;
T_DAY PLS_INTEGER := 1;
T_HOUR PLS_INTEGER := 1;
T_MIN PLS_INTEGER := 1;
T_SEC double precision := 1;
tmp PLS_INTEGER;
unit_tab moving_point_tab;
new_unit unit_moving_point;
i PLS_INTEGER;
stmt1 VARCHAR2(32767);
cnum1 PLS_INTEGER;
junk1 NUMBER;
tp tau_tll.D_Timepoint_Sec;
BEGIN
  /*table_name := 'HERMES.' || file_name || '_MPOINTS';
  stmt1 := 'CREATE TABLE ' || table_name || '(object_id NUMBER(*,0), traj_id NUMBER(*,0), mpoint HERMES.MOVING_POINT)';
  cnum1 := dbms_sql.open_cursor;
  dbms_sql.parse(cnum1, stmt1, dbms_sql.native);
  junk1 := dbms_sql.execute(cnum1);
  dbms_sql.close_cursor(cnum1);
  commit;*/

  --load KML TEMPLATE file
  infile := dbms_xslprocessor.read2clob ('IO', file_name); --DBMS_OUTPUT.PUT_LINE('infile = ' || TO_CHAR(infile));

  --Compute the length of the CLOB
  --CLOBsize := DBMS_LOB.GETLENGTH(infile); DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));

  --Find 'XXX' pattern inside template kml
  pattern1 := CHR(10);-- || CHR(13);
  pattern2 := ' ';
  occur := 1;
  offset := 1;
  LOOP
    BEGIN
        position2 := DBMS_LOB.INSTR(infile, pattern1, position1+1, occur); --DBMS_OUTPUT.PUT_LINE('position2 = ' || TO_CHAR(position2));
        line := DBMS_LOB.SUBSTR(infile, position2-position1, position1+1); --DBMS_OUTPUT.PUT_LINE(line);
        lineCLOB := TO_CLOB(line);
        position1 := position2;

        position3 := 0;
        position4 := DBMS_LOB.INSTR(lineCLOB, pattern2, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
        token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
        id := to_number (token); --DBMS_OUTPUT.PUT_LINE('id = ' || TO_CHAR(id));
        position3 := position4;

        IF ID is null THEN EXIT; END IF;

        position4 := DBMS_LOB.INSTR(lineCLOB, pattern2, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
        token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
        N := to_number (token); --DBMS_OUTPUT.PUT_LINE('N = ' || TO_CHAR(N));
        position3 := position4;

        i := 1;
        unit_tab := HERMES.moving_point_tab();
        LOOP
            BEGIN
                position4 := DBMS_LOB.INSTR(lineCLOB, pattern2, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
                token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
                t := to_number (token); --DBMS_OUTPUT.PUT_LINE('t = ' || TO_CHAR(t));
                position3 := position4;

                position4 := DBMS_LOB.INSTR(lineCLOB, pattern2, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
                token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
                x := to_number (rtrim(token), '999999999.999999999', ' NLS_NUMERIC_CHARACTERS = '',.'' '); --DBMS_OUTPUT.PUT_LINE('x = ' || TO_CHAR(x));
                position3 := position4;

                position4 := DBMS_LOB.INSTR(lineCLOB, pattern2, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
                IF position4 = 0 THEN
                    position4 := DBMS_LOB.INSTR(lineCLOB, pattern1, position3+1, occur); --DBMS_OUTPUT.PUT_LINE('position4 = ' || TO_CHAR(position4));
                    token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
                    y := to_number (rtrim(token, pattern1), '999999999.999999999', ' NLS_NUMERIC_CHARACTERS = '',.'' '); --DBMS_OUTPUT.PUT_LINE('y = ' || TO_CHAR(y));
                    --DBMS_OUTPUT.PUT_LINE('LAST(t,x,y) = (' || TO_CHAR(t) ||'#' || TO_CHAR(x) || '#' || TO_CHAR(y) || ')');
                    position4 := 0;
                ELSE
                    token := DBMS_LOB.SUBSTR(lineCLOB, position4-position3, position3+1); --DBMS_OUTPUT.PUT_LINE(token);
                    y := to_number (rtrim(token), '999999999.999999999', ' NLS_NUMERIC_CHARACTERS = '',.'' '); --DBMS_OUTPUT.PUT_LINE('y = ' || TO_CHAR(y));
                    position3 := position4;
                END IF;

                IF i = 1 THEN
                    pre_x := x ; pre_y := y; pre_t := t;
                ELSE
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(pre_year, pre_month, pre_day, pre_hour, pre_minute, pre_sec, pre_t);
                    --tp:=tau_tll.D_Timepoint_Sec(pre_year, pre_month, pre_day, pre_hour, pre_minute, pre_sec); dbms_output.put_line('PRE_T='||to_string(tp));
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(T_YEAR, T_MONTH, T_DAY, T_HOUR, T_MIN, T_SEC, t);
                    --tp:=tau_tll.D_Timepoint_Sec(T_YEAR, T_MONTH, T_DAY, T_HOUR, T_MIN, T_SEC); dbms_output.put_line('T='||to_string(tp));

                    --pre_sec := MOD(pre_t, 60); tmp := (pre_t - pre_sec)/60; dbms_output.put_line('pre_sec='||TO_CHAR(pre_sec)||' tmp='||TO_CHAR(tmp));
                    --pre_minute := MOD(tmp, 60); tmp := (pre_t - pre_sec - pre_minute*60)/(60*60);  dbms_output.put_line('pre_minute='||TO_CHAR(pre_minute)||' tmp='||TO_CHAR(tmp));
                    --pre_hour := MOD(tmp, 24); tmp := (pre_t - pre_sec - pre_minute*60 - pre_hour*60)/(60*60*24);  dbms_output.put_line('pre_hour='||TO_CHAR(pre_hour)||' tmp='||TO_CHAR(tmp));
                    --pre_day := MOD(tmp, 30); tmp := (pre_t - pre_sec - pre_minute*60 - pre_hour*24 - pre_day*24)/(60*60*24*30);  dbms_output.put_line('pre_day='||TO_CHAR(pre_day)||' tmp='||TO_CHAR(tmp));
                    --pre_month := MOD(tmp, 12); tmp := (pre_t - pre_sec - pre_minute*60 - pre_hour*24 -pre_day*30 - pre_month*12)/(60*60*24*30*12);  dbms_output.put_line('pre_month='||TO_CHAR(pre_month)||' tmp='||TO_CHAR(tmp));
                    --pre_year := tmp;  dbms_output.put_line('pre_year='||TO_CHAR(pre_year)||' tmp='||TO_CHAR(tmp));
                    --dbms_output.put_line('PRE_T='||TO_CHAR(pre_year*60*60*24*30*12+pre_month*60*60*24*30+pre_day*60*60*24+pre_hour*60*60+pre_minute*60+pre_sec));

                    --T_SEC := MOD(t, 60); tmp := (t - T_SEC)/60; dbms_output.put_line('T_SEC='||TO_CHAR(T_SEC)||' tmp='||TO_CHAR(tmp));
                    --T_MIN := MOD(tmp, 60); tmp := (t - T_SEC - T_MIN*60)/(60*60);  dbms_output.put_line('T_MIN='||TO_CHAR(T_MIN)||' tmp='||TO_CHAR(tmp));
                    --T_HOUR := MOD(tmp, 24); tmp := (t - T_SEC - T_MIN*60 - T_HOUR*60)/(60*60*24);  dbms_output.put_line('T_HOUR='||TO_CHAR(T_HOUR)||' tmp='||TO_CHAR(tmp));
                    --T_DAY := MOD(tmp, 30); tmp := (t - T_SEC - T_MIN*60 - T_HOUR*24 - T_DAY*24)/(60*60*24*30);  dbms_output.put_line('T_DAY='||TO_CHAR(T_DAY)||' tmp='||TO_CHAR(tmp));
                    --T_MONTH := MOD(tmp, 12); tmp := (t - T_SEC - T_MIN*60 - T_HOUR*24 -T_DAY*30 - T_MONTH*12)/(60*60*24*30*12);  dbms_output.put_line('T_MONTH='||TO_CHAR(T_MONTH)||' tmp='||TO_CHAR(tmp));
                    --T_YEAR := tmp;  dbms_output.put_line('T_YEAR='||TO_CHAR(T_YEAR)||' tmp='||TO_CHAR(tmp));
                    --dbms_output.put_line('T='||TO_CHAR(T_YEAR*60*60*24*30*12+T_MONTH*60*60*24*30+T_DAY*60*60*24+T_HOUR*60*60+T_MIN*60+T_SEC));

                    new_unit := HERMES.unit_moving_point(
                                                        TAU_TLL.d_period_sec(
                                                            TAU_TLL.d_timepoint_sec(pre_year, pre_month, pre_day, pre_hour, pre_minute, pre_sec),
                                                            TAU_TLL.d_timepoint_sec(T_YEAR, T_MONTH, T_DAY, T_HOUR, T_MIN, T_SEC)
                                                        ),
                                                        HERMES.unit_function(pre_x, pre_y, x, y, null, null, null, null, null, 'PLNML_1')
                                                    );
                    unit_tab.EXTEND(1);
                    unit_tab(unit_tab.COUNT) := new_unit;
                    --dbms_output.put_line('unit_tab.COUNT='||TO_CHAR(unit_tab.COUNT));
                    --dbms_output.put_line('T='||TO_CHAR(T_YEAR*60*60*24*30*12+T_MONTH*60*60*24*30+T_DAY*60*60*24+T_HOUR*60*60+T_MIN*60+T_SEC)||' X='||TO_CHAR(x)||' Y='||TO_CHAR(y));

                    pre_x := x;
                    pre_y := y;
                    pre_t := t;
                END IF;
                i := i + 1;

                --DBMS_OUTPUT.PUT_LINE('(t,x,y) = (' || TO_CHAR(t) ||'#' || TO_CHAR(x) || '#' || TO_CHAR(y) || ')');
                IF position4 = 0 THEN EXIT; END IF;
            END;
        END LOOP;

        --INSERT INTO HERMES.TEST VALUES (id,id,HERMES.MOVING_POINT(unit_tab,id));
        --INSERT INTO HERMES.MILANO_CL_MPOINTS VALUES (id,id,HERMES.MOVING_POINT(unit_tab,id));
        --INSERT INTO HERMES.TRUCKS_MPOINTS VALUES (id,id,HERMES.MOVING_POINT(unit_tab,id));
        --stmt1 := 'INSERT INTO ' || UPPER(table_name) || ' VALUES (' || TO_CHAR(id) || ',' || TO_CHAR(id) || ', HERMES.MOVING_POINT(unit_tab,' || TO_CHAR(id) || '));';
        --stmt1 := 'INSERT INTO ' || UPPER(table_name) || ' VALUES (:1,:2, HERMES.MOVING_POINT(:3,:4));';
        --stmt1 := 'BEGIN INSERT INTO ' || table_name || ' VALUES (' || TO_CHAR(id) || ',' || TO_CHAR(id) || ', HERMES.MOVING_POINT(:UTAB,' || TO_CHAR(id) || ')); END;';
        --DBMS_OUTPUT.PUT_LINE(stmt1);
        --EXECUTE IMMEDIATE 'BEGIN INSERT INTO :TNAME VALUES (:ID1,:ID2, HERMES.MOVING_POINT(:UTAB,:ID3)); END;' USING IN table_name, id, id, unit_tab, id;
        EXECUTE IMMEDIATE 'BEGIN INSERT INTO ' || table_name || ' VALUES (' || TO_CHAR(id) || ',' || TO_CHAR(id) || ', HERMES.MOVING_POINT(:UTAB,' || TO_CHAR(id) || ')); END;' USING IN unit_tab;
        commit;

        IF position2 = 0 THEN EXIT; END IF;
    END;
  END LOOP;
  commit;

END;

  PROCEDURE MovingPointTable2TXT(outTXTfile VARCHAR2, table_name VARCHAR2) is
   BEGIN
     visualizer.MovingPointTable2TXT(null, outTXTfile,table_name);
   END MovingPointTable2TXT;

END;
/


