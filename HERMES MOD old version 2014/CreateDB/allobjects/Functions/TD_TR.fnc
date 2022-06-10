Prompt Function TD_TR;
CREATE OR REPLACE FUNCTION        TD_TR (mp IN hermes.moving_point, tol IN number)
return hermes.moving_point

is

in_geom mdsys.sdo_geometry;
mp_head hermes.moving_point;
mp_tail hermes.moving_point;
mp_all hermes.moving_point;
head_unit_tab moving_point_tab;
tail_unit_tab moving_point_tab;
all_unit_tab moving_point_tab := HERMES.moving_point_tab();
new_unit unit_moving_point;
coord_head int := 1;
coord_tail int;
coord_far int;
x number;
y number;
dist_now number;
dist_max number := 0;
--head hermes.moving_point;
--tail hermes.moving_point;

begin

    in_geom := mp.route();

    coord_tail := in_geom.sdo_ordinates.COUNT / 2;--DBMS_OUTPUT.put_line ('coord_tail=' || TO_CHAR (coord_tail));DBMS_OUTPUT.put_line ('units=' || TO_CHAR (mp.u_tab.COUNT));
    --check number of coords (must be at least 3 to generalize)
    if coord_tail < 3 then --first and last points
        new_unit := mp.u_tab(1);
        all_unit_tab.EXTEND(1);
        all_unit_tab(all_unit_tab.COUNT) := new_unit;
    else
        --get furthest point from baseline according to SED
        for i in 2 .. coord_tail - 1 loop
            --DBMS_OUTPUT.put_line ('iSTART=' || TO_CHAR (i));
            x := in_geom.sdo_ordinates(i * 2 - 1);
            y := in_geom.sdo_ordinates(i * 2);

            SELECT SED(in_geom.sdo_ordinates(1), in_geom.sdo_ordinates(2), mp.u_tab(1).p.b,
                       in_geom.sdo_ordinates(coord_tail * 2 - 1), in_geom.sdo_ordinates(coord_tail * 2), mp.u_tab(coord_tail - 1).p.e,
                       x, y, mp.u_tab(i).p.b,
                       tol) INTO dist_now FROM dual;

            if dist_now > dist_max then
                dist_max := dist_now;
                coord_far := i;
            end if;
            --DBMS_OUTPUT.put_line ('iEND=' || TO_CHAR (i));
        end loop;

        if dist_max > tol then --recurse
            --DBMS_OUTPUT.put_line ('dist_max=' || TO_CHAR (dist_max));
            --DBMS_OUTPUT.put_line ('coord_far=' || TO_CHAR (coord_far));
            --build head
            head_unit_tab := HERMES.moving_point_tab();
            for i in 1 .. coord_far - 1 loop
                head_unit_tab.EXTEND(1);
                head_unit_tab(head_unit_tab.COUNT) := mp.u_tab(i);
            end loop;
          --head := HERMES.MOVING_POINT(head_unit_tab,mp.traj_id);
            --DBMS_OUTPUT.put_line ('head=' || TO_CHAR (head.to_string()));

            --build tail
            tail_unit_tab := HERMES.moving_point_tab();
            for i in coord_far .. coord_tail - 1 loop
                tail_unit_tab.EXTEND(1);
                tail_unit_tab(tail_unit_tab.COUNT) := mp.u_tab(i);
           end loop;
            --tail := HERMES.MOVING_POINT(tail_unit_tab,mp.traj_id);
            --DBMS_OUTPUT.put_line ('tail=' || TO_CHAR (tail.to_string()));

            --recurse head and tail
            mp_head := TD_TR(HERMES.MOVING_POINT(head_unit_tab,mp.traj_id, mp.srid),tol);
            mp_tail := TD_TR(HERMES.MOVING_POINT(tail_unit_tab,mp.traj_id, mp.srid),tol);

            --merge result
            for i in 1 .. mp_head.u_tab.COUNT loop
                all_unit_tab.EXTEND;
                all_unit_tab(all_unit_tab.COUNT) := mp_head.u_tab(i);
            end loop;
            for i in 1 .. mp_tail.u_tab.COUNT loop
                all_unit_tab.EXTEND;
                all_unit_tab(all_unit_tab.COUNT) := mp_tail.u_tab(i);
            end loop;
        else --generalize
            new_unit := HERMES.unit_moving_point(
                                             TAU_TLL.d_period_sec(
                                                            mp.u_tab(1).p.b,
                                                            mp.u_tab(coord_tail - 1).p.e
                                                        ),
                                                        HERMES.unit_function(mp.u_tab(1).m.xi, mp.u_tab(1).m.yi, mp.u_tab(coord_tail - 1).m.xe, mp.u_tab(coord_tail - 1).m.ye, null, null, null, null, null, 'PLNML_1')
                                             );
            all_unit_tab.EXTEND(1);
            all_unit_tab(all_unit_tab.COUNT) := new_unit;
        end if;
    end if;

    return HERMES.MOVING_POINT(all_unit_tab,mp.traj_id, mp.srid);

END;
/


