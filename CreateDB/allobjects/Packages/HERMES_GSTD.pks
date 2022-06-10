Prompt Package HERMES_GSTD;
CREATE OR REPLACE package hermes_gstd is

       function he_GSTD_distance(x1 double precision, y1 double precision,
         x2 double precision, y2 double precision)
       return double precision;

       function he_GSTD_azimuth(x1 double precision, y1 double precision,
         x2 double precision, y2 double precision)
       return double precision;

       function he_GSTD_random
       return double precision;

       function he_GSTD(fc_pts fc_pts_tab,
         NMO integer,  maximum_interval interval day to second,
         interval_mean interval day to second, interval_variance double precision,
         velocity_variance_fraction double precision,
         box sp_box_xy DEFAULT NULL
         )
       return out_type_tab pipelined;

       procedure he_gstdtompoints(gstdparameters in varchar2,
         out_table in varchar2);

end hermes_gstd;
/


