Prompt Function F_DOUGLAS_PEUCKER;
CREATE OR REPLACE FUNCTION f_Douglas_Peucker (in_geom IN mdsys.sdo_geometry, srid integer, tol IN number)
return mdsys.sdo_geometry

is

geom_head mdsys.sdo_geometry;
geom_tail mdsys.sdo_geometry;
col_head mdsys.sdo_ordinate_array := mdsys.sdo_ordinate_array();
col_tail mdsys.sdo_ordinate_array := mdsys.sdo_ordinate_array();
col_all mdsys.sdo_ordinate_array := mdsys.sdo_ordinate_array();
coord_head int := 1;
coord_tail int := in_geom.sdo_ordinates.COUNT / 2;
coord_far int;
x number;
y number;
dist_now number;
dist_max number := 0;

begin

    --check number of coords (must be at least 3 to generalize)
    if coord_tail < 3 then --first and last points

        col_all.EXTEND(4);
        col_all(col_all.COUNT - 3) := in_geom.sdo_ordinates(1);
        col_all(col_all.COUNT - 2) := in_geom.sdo_ordinates(2);
        col_all(col_all.COUNT - 1) := in_geom.sdo_ordinates(3);
        col_all(col_all.COUNT) := in_geom.sdo_ordinates(4);

    else
        --get furthest orthogonal point from baseline
        for i in 2 .. coord_tail - 1 loop

            x := in_geom.sdo_ordinates(i * 2 - 1);
            y := in_geom.sdo_ordinates(i * 2);
            SELECT SDO_GEOM.SDO_DISTANCE(mdsys.sdo_geometry(2001, SRID,
            mdsys.sdo_point_type(x,y,NULL), NULL, NULL),
            mdsys.sdo_geometry(2002, SRID, NULL,
            mdsys.sdo_elem_info_array(1,2,1),
            mdsys.sdo_ordinate_array(in_geom.sdo_ordinates(1),
            in_geom.sdo_ordinates(2),
            in_geom.sdo_ordinates(coord_tail * 2 - 1),
            in_geom.sdo_ordinates(coord_tail * 2))),
            tol,'unit=M') INTO dist_now FROM dual;

            if dist_now > dist_max then
                dist_max := dist_now;
                coord_far := i;
            end if;

        end loop;

        if dist_max > tol then --recurse

            --build head
            for i in 1 .. coord_far loop
                col_head.EXTEND(2);
                col_head(col_head.COUNT - 1) := in_geom.sdo_ordinates(i * 2 - 1);
                col_head(col_head.COUNT) := in_geom.sdo_ordinates(i * 2);
            end loop;

            --build tail
            for i in coord_far .. coord_tail loop
                col_tail.EXTEND(2);
                col_tail(col_tail.COUNT - 1) := in_geom.sdo_ordinates(i * 2 - 1);
                col_tail(col_tail.COUNT) := in_geom.sdo_ordinates(i * 2);
            end loop;

            --recurse head and tail
            geom_head := f_douglas_peucker(mdsys.sdo_geometry(2002, srid, null,
            mdsys.sdo_elem_info_array(1,2,1),col_head),srid,tol);
            geom_tail := f_douglas_peucker(mdsys.sdo_geometry(2002, srid, null,
            mdsys.sdo_elem_info_array(1,2,1),col_tail),srid,tol);
            --merge result
            for i in 1 .. geom_head.sdo_ordinates.COUNT loop
                col_all.EXTEND;
                col_all(col_all.COUNT) := geom_head.sdo_ordinates(i);
            end loop;
            for i in 3 .. geom_tail.sdo_ordinates.COUNT loop
                col_all.EXTEND;
                col_all(col_all.COUNT) := geom_tail.sdo_ordinates(i);
            end loop;
        else --generalize

            col_all.EXTEND(4);
            col_all(col_all.COUNT - 3) := in_geom.sdo_ordinates(1);
            col_all(col_all.COUNT - 2) := in_geom.sdo_ordinates(2);
            col_all(col_all.COUNT - 1) := in_geom.sdo_ordinates(coord_tail * 2 - 1);
            col_all(col_all.COUNT) := in_geom.sdo_ordinates(coord_tail * 2);

        end if;
    end if;

    return(mdsys.sdo_geometry(2002, SRID, NULL,mdsys.sdo_elem_info_array(1,2,1),col_all));

END;
/


