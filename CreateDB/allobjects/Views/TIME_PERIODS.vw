Prompt View TIME_PERIODS;
CREATE OR REPLACE VIEW TIME_PERIODS
AS 
SELECT   a.timeid AS timeID,
              a.year AS fy,
              a.month AS fm,
              a.day AS fd,
              a.hour AS fh,
              a.minute AS fmi,
              a.second AS fs,
              b.year AS ty,
              b.month AS tm,
              b.day AS td,
              b.hour AS th,
              b.minute AS tmi,
              b.second AS ts,
              a.datedes AS fromtimestamp,
              b.datedes AS totimestamp
       FROM   timeslots a, timeslots b
      WHERE   b.timeid = a.timeid + 1
   ORDER BY   timeid
/


