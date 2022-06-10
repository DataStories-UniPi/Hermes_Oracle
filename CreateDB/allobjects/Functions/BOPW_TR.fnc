Prompt Function BOPW_TR;
CREATE OR REPLACE FUNCTION BOPW_TR (mp IN hermes.moving_point, tol IN number)
return hermes.moving_point

is

mp_head hermes.moving_point;
mp_tail hermes.moving_point;
head_unit_tab moving_point_tab := HERMES.moving_point_tab();
all_unit_tab moving_point_tab := HERMES.moving_point_tab();
new_unit unit_moving_point;
coord_head int := 1;
coord_tail int;
coord_far int := 1;
x number;
y number;
dist_now number;
dist_max number := 0;
SRID pls_integer;

--head hermes.moving_point;
--all_mp hermes.moving_point;

begin
    srid:=mp.srid;

    coord_tail := mp.u_tab.COUNT;
    loop
        coord_far := coord_far + 1;

        if coord_tail - coord_far = 0 then --last segment
            new_unit := mp.u_tab(coord_tail);
            all_unit_tab.EXTEND(1);
            all_unit_tab(all_unit_tab.COUNT) := new_unit;
            exit;
        end if;
        --DBMS_OUTPUT.put_line ('LA coord_head=' || TO_CHAR (coord_head)); DBMS_OUTPUT.put_line ('coord_far=' || TO_CHAR (coord_far));
        --sider mind the case x1,y1->x2,y2->x1,y1 then error from sed
        for j in coord_head + 1 .. coord_far loop
            SELECT SED(mp.u_tab(coord_head).m.xi, mp.u_tab(coord_head).m.yi, mp.u_tab(coord_head).p.b,
                       mp.u_tab(coord_far).m.xe, mp.u_tab(coord_far).m.ye, mp.u_tab(coord_far).p.e,
                       mp.u_tab(j).m.xi, mp.u_tab(j).m.yi, mp.u_tab(j).p.b,
                       tol) INTO dist_now FROM dual;--DBMS_OUTPUT.put_line ('SED=' || TO_CHAR (dist_now));

            if dist_now > dist_max then
                dist_max := dist_now;
            end if;
        end loop;

        if dist_max > tol then --new anchor
            all_unit_tab.EXTEND(1);
            all_unit_tab(all_unit_tab.COUNT) := head_unit_tab(head_unit_tab.COUNT);
            coord_head := coord_far;
            dist_max := 0; --DBMS_OUTPUT.put_line ('coord_head=' || TO_CHAR (coord_head)); DBMS_OUTPUT.put_line ('coord_far=' || TO_CHAR (coord_far));

            new_unit := HERMES.unit_moving_point(
                                                TAU_TLL.d_period_sec(
                                                    mp.u_tab(coord_head).p.b,
                                                    mp.u_tab(coord_head).p.e
                                                                    ),
                                                HERMES.unit_function(mp.u_tab(coord_head).m.xi, mp.u_tab(coord_head).m.yi, mp.u_tab(coord_head).m.xe, mp.u_tab(coord_head).m.ye, null, null, null, null, null, 'PLNML_1')
                                                );
            all_unit_tab.EXTEND(1);
            all_unit_tab(all_unit_tab.COUNT) := new_unit;

            --all_mp := HERMES.MOVING_POINT(all_unit_tab,mp.traj_id);DBMS_OUTPUT.put_line ('all_mp=' || TO_CHAR (all_mp.to_string()));
        else --generalize
            if head_unit_tab.COUNT <> 0 then head_unit_tab.TRIM; end if;
            new_unit := HERMES.unit_moving_point(
                                                TAU_TLL.d_period_sec(
                                                    mp.u_tab(coord_head).p.e,
                                                    mp.u_tab(coord_far).p.e
                                                                    ),
                                                HERMES.unit_function(mp.u_tab(coord_head).m.xe, mp.u_tab(coord_head).m.ye, mp.u_tab(coord_far).m.xe, mp.u_tab(coord_far).m.ye, null, null, null, null, null, 'PLNML_1')
                                                );
            --DBMS_OUTPUT.put_line ('LALALALA coord_head=' || TO_CHAR (coord_head)); DBMS_OUTPUT.put_line ('coord_far=' || TO_CHAR (coord_far));
            --head_unit_tab.EXTEND(1); DBMS_OUTPUT.put_line ('head_unit_tab.COUNT=' || TO_CHAR (head_unit_tab.COUNT));
            head_unit_tab.EXTEND(1); --DBMS_OUTPUT.put_line ('head_unit_tab.COUNT=' || TO_CHAR (head_unit_tab.COUNT));
            head_unit_tab(head_unit_tab.COUNT) := new_unit;
            --head := HERMES.MOVING_POINT(head_unit_tab,mp.traj_id);DBMS_OUTPUT.put_line ('head=' || TO_CHAR (head.to_string()));
        end if;
        --DBMS_OUTPUT.put_line ('coord_head=' || TO_CHAR (coord_head)); DBMS_OUTPUT.put_line ('coord_far=' || TO_CHAR (coord_far));
    end loop;

    return HERMES.MOVING_POINT(all_unit_tab,mp.traj_id, mp.srid);

END;
/


