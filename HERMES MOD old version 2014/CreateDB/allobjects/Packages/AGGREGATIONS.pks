Prompt Package AGGREGATIONS;
CREATE OR REPLACE PACKAGE        AGGREGATIONS AS
     FUNCTION Aggregated_CrossX (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_CrossY (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_CrossT (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_Distance_Traveled (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_Time_Duration (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_Num_of_Trajs (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_Speed (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
     FUNCTION Aggregated_Acceleration (down_rectangle number, upper_rectangle number, from_period number, to_period number, tdwprefix varchar2) RETURN number;
END AGGREGATIONS;
/


