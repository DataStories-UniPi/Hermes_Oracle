Prompt drop Type Body D_TIMESTAMP;
DROP TYPE BODY D_TIMESTAMP
/

Prompt Type Body D_TIMESTAMP;
CREATE OR REPLACE type body D_Timestamp is

    --Return the Date property of the Timestamp object.
    MEMBER FUNCTION f_date return D_Date is
    Y pls_integer := 0;
    M pls_integer := 0;
    D pls_integer := 0;
    begin
        D_Timestamp_Package.f_date(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), Y, M, D);
        return D_Date(Y, M, D);
    end;

    --Return the Time property of the Timestamp object.
    MEMBER FUNCTION f_time return D_Time is
    H      pls_integer := 0;
    M      pls_integer := 0;
    S      pls_integer := 0;
    hundr_thS pls_integer := 0;
    tz_H   pls_integer := 0;
    tz_M   pls_integer := 0;
    begin
        D_Timestamp_Package.f_time(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), H, M, S, hundr_thS, tz_H, tz_M);
        return D_Time(H, M, S, hundr_thS, tz_H, tz_M);
    end;

    --Returns the number corresponding to the year.
    MEMBER FUNCTION year return pls_integer is
    y pls_integer := D_Timestamp_Package.year(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return y;
    end;

    --Returns the number corresponding to the month.
    MEMBER FUNCTION month return pls_integer is
    m pls_integer := D_Timestamp_Package.month(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return m;
    end;

    --Returns the number corresponding to the day.
    MEMBER FUNCTION day return pls_integer is
    d pls_integer := D_Timestamp_Package.day(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return d;
    end;

    --Returns the number corresponding to the hour.
    MEMBER FUNCTION hour return pls_integer is
    h pls_integer := D_Timestamp_Package.hour(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return h;
    end;

    --Returns the number corresponding to the minute.
    MEMBER FUNCTION minute return pls_integer is
    m pls_integer := D_Timestamp_Package.minute(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return m;
    end;

    --Returns the number corresponding to the second.
    MEMBER FUNCTION second return float is
    s float := D_Timestamp_Package.second(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return s;
    end;

    --Returns the number corresponding to the 100thSec.
    MEMBER FUNCTION hundr_thSec return pls_integer is
    begin
        return m_Time.hundr_thSec();
    end;

    --Returns the number corresponding to the local timezone hour.
    MEMBER FUNCTION tz_hour return pls_integer is
    tz_h pls_integer := D_Timestamp_Package.tz_hour(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return tz_h;
    end;

    --Returns the number corresponding to the local timezone minute.
    MEMBER FUNCTION tz_minute return pls_integer is
    tz_m pls_integer := D_Timestamp_Package.tz_minute(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute());
    begin
        return tz_m;
    end;

    --Returns a Timestamp object representing the current system date and time.
    MEMBER FUNCTION f_current return D_Timestamp is
    Year   pls_integer := 0;
    Month  pls_integer := 0;
    Day    pls_integer := 0;
    H      pls_integer := 0;
    M      pls_integer := 0;
    S      pls_integer := 0;
    hundr_thS pls_integer := 0;
    tz_H   pls_integer := 0;
    tz_M   pls_integer := 0;
    begin
        D_Timestamp_Package.f_current(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), Year, Month, Day, H, M, S, hundr_thS, tz_H, tz_M);
        return D_Timestamp(D_Date(Year, Month, Day), D_Time(H, M, S, hundr_thS, tz_H, tz_M));
    end;

    --Assigns the value of another Timestamp to the Timestamp object.
    MEMBER PROCEDURE f_ass_timestamp (ts D_Timestamp ) is
    -- m_Year,..., m_Hour, m_Minute,...==== IN OUT Arguments
    begin
        D_Timestamp_Package.f_ass_timestamp(m_Date.m_Year, m_Date.m_Month, m_Date.m_Day, m_Time.m_Hour, m_Time.m_Minute, m_Time.m_Second, m_Time.m_100thSec, m_Time.m_tzHour, m_Time.m_tzMinute, ts.m_Date.m_Year, ts.m_Date.m_Month, ts.m_Date.m_Day, ts.m_Time.m_Hour, ts.m_Time.m_Minute, ts.m_Time.m_Second, ts.m_Time.m_100thSec, ts.m_Time.m_tzHour, ts.m_Time.m_tzMinute);
    end;

    --Assigns the value of a Date object to the date property of the Timestamp object.
    MEMBER PROCEDURE f_ass_date (d D_Date) is
    -- m_Year,m_Month,m_Day==== IN OUT Arguments
    begin
        D_Timestamp_Package.f_ass_date(m_Date.m_Year, m_Date.m_Month, m_Date.m_Day, m_Time.m_Hour, m_Time.m_Minute, m_Time.m_Second, m_Time.m_100thSec, m_Time.m_tzHour, m_Time.m_tzMinute, d.m_Year, d.m_Month, d.m_Day);
    end;

    --Increments the value of the Timestamp object by a specified Interval.
    MEMBER PROCEDURE f_add_interval (i D_Interval) is
    -- m_Year,..., m_Hour, m_Minute,...==== IN OUT Arguments
    begin
        D_Timestamp_Package.f_add_interval(m_Date.m_Year, m_Date.m_Month, m_Date.m_Day, m_Time.m_Hour, m_Time.m_Minute, m_Time.m_Second, m_Time.m_100thSec, m_Time.m_tzHour, m_Time.m_tzMinute, i.m_Value);
    end;

    --Decrements the value of the Timestamp object by a specified Interval.
    MEMBER PROCEDURE f_sub_interval (i D_Interval) is
    -- m_Year,..., m_Hour, m_Minute,...==== IN OUT Arguments
    begin
        D_Timestamp_Package.f_sub_interval(m_Date.m_Year, m_Date.m_Month, m_Date.m_Day, m_Time.m_Hour, m_Time.m_Minute, m_Time.m_Second, m_Time.m_100thSec, m_Time.m_tzHour, m_Time.m_tzMinute, i.m_Value);
    end;

    --Adds an Interval to the Timestamp value.
    MEMBER FUNCTION f_add (ts D_Timestamp, i D_Interval) return D_Timestamp is
    Year   pls_integer := 0;
    Month  pls_integer := 0;
    Day    pls_integer := 0;
    H      pls_integer := 0;
    M      pls_integer := 0;
    S      pls_integer := 0;
    hundr_thS pls_integer := 0;
    tz_H   pls_integer := 0;
    tz_M   pls_integer := 0;
    begin
        D_Timestamp_Package.f_add(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts.year(), ts.month(), ts.day(), ts.hour(), ts.minute(), ts.second(), ts.hundr_thSec(), ts.tz_hour(), ts.tz_minute(), i.m_Value, Year, Month, Day, H, M, S, hundr_thS, tz_H, tz_M);
        return D_Timestamp(D_Date(Year, Month, Day), D_Time(H, M, S, hundr_thS, tz_H, tz_M));
    end;

    --Subtracts an Interval from the Timestamp value.
    MEMBER FUNCTION f_sub (ts D_Timestamp, i D_Interval) return D_Timestamp is
    Year   pls_integer := 0;
    Month  pls_integer := 0;
    Day    pls_integer := 0;
    H      pls_integer := 0;
    M      pls_integer := 0;
    S      pls_integer := 0;
    hundr_thS pls_integer := 0;
    tz_H   pls_integer := 0;
    tz_M   pls_integer := 0;
    begin
        D_Timestamp_Package.f_sub(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts.year(), ts.month(), ts.day(), ts.hour(), ts.minute(), ts.second(), ts.hundr_thSec(), ts.tz_hour(), ts.tz_minute(), i.m_Value, Year, Month, Day, H, M, S, hundr_thS, tz_H, tz_M);
        return D_Timestamp(D_Date(Year, Month, Day), D_Time(H, M, S, hundr_thS, tz_H, tz_M));
    end;

    --Returns true if the Timestamps have the same value.
    MEMBER FUNCTION f_eq (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
    b pls_integer := D_Timestamp_Package.f_eq(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the Timestamps have different value.
    MEMBER FUNCTION f_n_eq (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_n_eq(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the first Timestamp is less than the second.
    MEMBER FUNCTION f_l (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_l(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the first Timestamp is less or equal to the second.
    MEMBER FUNCTION f_l_e (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_l_e(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the first Timestamp is greater than the second.
    MEMBER FUNCTION f_b (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_b(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the first Timestamp is greater or equal to the second.
    MEMBER FUNCTION f_b_e (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_b_e(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute());
    begin
        return b;
    end;

    --Returns true if the period formed by the first two parameters overlaps the period formed by the other two.
    MEMBER FUNCTION f_overlaps (ts1 D_Timestamp, ts2 D_Timestamp, ts3 D_Timestamp, ts4 D_Timestamp) return pls_integer is
     b pls_integer := D_Timestamp_Package.f_overlaps(m_Date.year(), m_Date.month(), m_Date.day(), m_Time.hour(), m_Time.minute(), m_Time.second(), m_Time.hundr_thSec(), m_Time.tz_hour(), m_Time.tz_minute(), ts1.m_Date.year(), ts1.m_Date.month(), ts1.m_Date.day(), ts1.m_Time.hour(), ts1.m_Time.minute(), ts1.m_Time.second(), ts1.m_Time.hundr_thSec(), ts1.m_Time.tz_hour(), ts1.m_Time.tz_minute(), ts2.m_Date.year(), ts2.m_Date.month(), ts2.m_Date.day(), ts2.m_Time.hour(), ts2.m_Time.minute(), ts2.m_Time.second(), ts2.m_Time.hundr_thSec(), ts2.m_Time.tz_hour(), ts2.m_Time.tz_minute(), ts3.m_Date.year(), ts3.m_Date.month(), ts3.m_Date.day(), ts3.m_Time.hour(), ts3.m_Time.minute(), ts3.m_Time.second(), ts3.m_Time.hundr_thSec(), ts3.m_Time.tz_hour(), ts3.m_Time.tz_minute(), ts4.m_Date.year(), ts4.m_Date.month(), ts4.m_Date.day(), ts4.m_Time.hour(), ts4.m_Time.minute(), ts4.m_Time.second(), ts4.m_Time.hundr_thSec(), ts4.m_Time.tz_hour(), ts4.m_Time.tz_minute());
    begin
        return b;
    end;

end;
/

SHOW ERRORS;


