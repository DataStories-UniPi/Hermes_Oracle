Prompt Function SED;
CREATE OR REPLACE FUNCTION SED (xs number, ys number, ts tau_tll.d_timepoint_sec, xe number, ye number, te tau_tll.d_timepoint_sec, xi number, yi number, ti tau_tll.d_timepoint_sec, tol IN number)
return number is

unit unit_moving_point;
xyiNEW coords;
dist number;
SRID pls_integer;

begin
    select value into SRID from parameters where id='SRID' and upper(table_name)='IMIS_3DAYS_MPOINTS';

    unit := HERMES.unit_moving_point(
                                     TAU_TLL.d_period_sec(
                                                            ts,
                                                            te
                                                        ),
                                                        HERMES.unit_function(xs, ys, xe, ye, null, null, null, null, null, 'PLNML_1')
                                     );
    xyiNEW := unit.f_interpolate(ti);

    SELECT SDO_GEOM.SDO_DISTANCE(mdsys.sdo_geometry(2001, SRID, mdsys.sdo_point_type(xi,yi,NULL), NULL, NULL),
                                 mdsys.sdo_geometry(2001, SRID, mdsys.sdo_point_type(xyiNEW(1),xyiNEW(2),NULL), NULL, NULL),
                                tol,
                                'unit=M') INTO dist FROM dual;

    return dist;

END;
/


