Prompt View ATTIKI_TIME_PERIODS;
CREATE OR REPLACE VIEW ATTIKI_TIME_PERIODS
AS 
select a.timeid as timeID, a.year as fy, a.month as fm, a.day as fd, a.hour as fh, a.minute as fmi,
                a.second as fs,b.year as ty, b.month as tm, b.day as td, b.hour as th, b.minute as tmi, b.second as ts,
                a.datedes as fromtimestamp, b.datedes as totimestamp
                from attiki_timeslots a, attiki_timeslots b
                where b.timeid=a.timeid+1
                order by timeid
/


