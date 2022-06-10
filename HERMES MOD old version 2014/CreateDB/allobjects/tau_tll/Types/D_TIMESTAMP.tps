Prompt drop Type D_TIMESTAMP;
DROP TYPE D_TIMESTAMP
/

Prompt Type D_TIMESTAMP;
CREATE OR REPLACE type D_Timestamp as object
(
    m_Date D_Date,
    m_Time D_Time,

    --Return the Date property of the Timestamp object.
    MEMBER FUNCTION f_date return D_Date,
    --Return the Time property of the Timestamp object.
    MEMBER FUNCTION f_time return D_Time,
    --Returns the number corresponding to the year.
    MEMBER FUNCTION year return pls_integer,
    --Returns the number corresponding to the month.
    MEMBER FUNCTION month return pls_integer,
    --Returns the number corresponding to the day.
    MEMBER FUNCTION day return pls_integer,
    --Returns the number corresponding to the hour.
    MEMBER FUNCTION hour return pls_integer,
    --Returns the number corresponding to the minute.
    MEMBER FUNCTION minute return pls_integer,
    --Returns the number corresponding to the second.
    MEMBER FUNCTION second return float,
    --Returns the number corresponding to the 100thSec.
    MEMBER FUNCTION hundr_thSec return pls_integer,
    --Returns the number corresponding to the local timezone hour.
    MEMBER FUNCTION tz_hour return pls_integer,
    --Returns the number corresponding to the local timezone minute.
    MEMBER FUNCTION tz_minute return pls_integer,
    --Returns a Timestamp object representing the current system date and time.
    MEMBER FUNCTION f_current return D_Timestamp,
    --Assigns the value of another Timestamp to the Timestamp object.
    MEMBER PROCEDURE f_ass_timestamp (ts D_Timestamp ),
    --Assigns the value of a Date object to the date property of the Timestamp object.
    MEMBER PROCEDURE f_ass_date (d D_Date),
    --Increments the value of the Timestamp object by a specified Interval.
    MEMBER PROCEDURE f_add_interval (i D_Interval),
    --Decrements the value of the Timestamp object by a specified Interval.
    MEMBER PROCEDURE f_sub_interval (i D_Interval),
    --Adds an Interval to the Timestamp value.
    MEMBER FUNCTION f_add (ts D_Timestamp, i D_Interval) return D_Timestamp,
    --Subtracts an Interval from the Timestamp value.
    MEMBER FUNCTION f_sub (ts D_Timestamp, i D_Interval) return D_Timestamp,
    --Returns true if the Timestamps have the same value.
    MEMBER FUNCTION f_eq (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the Timestamps have different value.
    MEMBER FUNCTION f_n_eq (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the first Timestamp is less than the second.
    MEMBER FUNCTION f_l (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the first Timestamp is less or equal to the second.
    MEMBER FUNCTION f_l_e (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the first Timestamp is greater than the second.
    MEMBER FUNCTION f_b (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the first Timestamp is greater or equal to the second.
    MEMBER FUNCTION f_b_e (ts1 D_Timestamp, ts2 D_Timestamp) return pls_integer,
    --Returns true if the period formed by the first two parameters overlaps the period formed by the other two.
    MEMBER FUNCTION f_overlaps (ts1 D_Timestamp, ts2 D_Timestamp, ts3 D_Timestamp, ts4 D_Timestamp) return pls_integer

);
/

SHOW ERRORS;


