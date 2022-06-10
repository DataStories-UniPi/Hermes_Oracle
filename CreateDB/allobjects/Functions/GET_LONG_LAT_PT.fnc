Prompt Function GET_LONG_LAT_PT;
CREATE OR REPLACE function get_long_lat_pt(longitude in number,
                                           latitude in number, srid in number)
return MDSYS.SDO_GEOMETRY deterministic is
begin
     return mdsys.sdo_geometry(2001, srid ,
                mdsys.sdo_point_type(longitude, latitude, NULL),NULL, NULL);
end;
/


