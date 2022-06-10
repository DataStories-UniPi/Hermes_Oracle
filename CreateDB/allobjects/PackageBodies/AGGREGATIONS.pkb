Prompt Package Body AGGREGATIONS;
CREATE OR REPLACE PACKAGE BODY        AGGREGATIONS AS

FUNCTION Aggregated_CrossX (down_rectangle number, upper_rectangle number, from_period number,
   to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(CrossX) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL = '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.Y_UR <= '||y_upperright||'
  AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||';end;'
  using out RESULT;
END IF;

 RETURN RESULT;
END Aggregated_CrossX;

FUNCTION Aggregated_CrossY (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;


  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(CrossY) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.Y_DL = '||y_downleft||' AND r.X_DL >= '||x_downleft||' AND r.X_UR <= '||x_upperright||'
  AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||';end;'
  using out RESULT;
END IF;

 RETURN RESULT;
END Aggregated_CrossY;

FUNCTION Aggregated_CrossT (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(CrossT) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID = '||from_period||';end;'
  using out RESULT;
END IF;

 RETURN RESULT;
END Aggregated_CrossT;

FUNCTION Aggregated_Distance_Traveled (down_rectangle number, upper_rectangle number,
  from_period number, to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(DISTANCE_TRAVELED) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out RESULT;
END IF;

 RETURN RESULT;
END Aggregated_Distance_Traveled;

FUNCTION Aggregated_Time_Duration (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(TIME_DURATION) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out RESULT;
END IF;

 RETURN RESULT;
END Aggregated_Time_Duration;


FUNCTION Aggregated_Num_of_Trajs (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  CROSSES NUMBER;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(TRAJECTORIES) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out RESULT;

  IF RESULT IS NOT NULL THEN

       CROSSES := 0;

       execute immediate 'begin SELECT SUM(crossX) INTO :CROSSES
       FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
       WHERE f.SPACE_ID=r.GEOGRAPHYID
       AND r.X_DL > '||x_downleft||' AND r.Y_DL >= '||y_downleft||'
       AND r.X_UR <= '||x_upperright||' AND r.Y_UR <= '||y_upperright||'
       AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
       ;end;' using out CROSSES;

  IF CROSSES IS NULL THEN
  CROSSES := 0;
  END IF;

  RESULT := RESULT - CROSSES;

       CROSSES := 0;

       execute immediate 'begin SELECT SUM(crossY) INTO :CROSSES
       FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
       WHERE f.SPACE_ID=r.GEOGRAPHYID
       AND r.X_DL >= '||x_downleft||' AND r.Y_DL > '||y_downleft||'
       AND r.X_UR <= '||x_upperright||' AND r.Y_UR <= '||y_upperright||'
       AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
       ;end;' using out CROSSES;

  IF CROSSES IS NULL THEN
  CROSSES := 0;
  END IF;

  RESULT := RESULT - CROSSES;

       CROSSES := 0;

       execute immediate 'begin SELECT SUM(crossT) INTO :CROSSES
       FROM '||tdwprefix||'_FACTTBL f,'||tdwprefix||'_RECTANGLE r
       WHERE f.SPACE_ID=r.GEOGRAPHYID
       AND r.X_DL >= '||x_downleft||' AND r.Y_DL >=  '||y_downleft||'
       AND r.X_UR <= '||x_upperright||' AND r.Y_UR <= '||y_upperright||'
       AND f.TIME_ID > '||from_period||' AND f.TIME_ID <= '||to_period||'
       ;end;' using out CROSSES;

  IF CROSSES IS NULL THEN
  CROSSES := 0;
  END IF;

  RESULT := RESULT - CROSSES;

  END IF;
END IF;

 RETURN RESULT;
END Aggregated_Num_of_Trajs;

FUNCTION Aggregated_Speed (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  SUM_DISTANCE NUMBER := 0;
  SUM_DURATION NUMBER := 0;
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT SUM(TIME_DURATION) INTO :SUM_DURATION
  FROM '||tdwprefix||'_FACTTBL f, '||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out SUM_DURATION;

  IF SUM_DURATION IS NOT NULL THEN
  execute immediate 'begin SELECT SUM(DISTANCE_TRAVELED) INTO :SUM_DISTANCE
  FROM '||tdwprefix||'_FACTTBL f, '||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out SUM_DISTANCE;

  RESULT := SUM_DISTANCE/SUM_DURATION;
  ELSE
  RESULT := 0;
  END IF;

END IF;
 RETURN RESULT;
END Aggregated_Speed;

FUNCTION Aggregated_Acceleration (down_rectangle number, upper_rectangle number, from_period number,
  to_period number, tdwprefix varchar2) RETURN number IS
  RESULT NUMBER := 0;
  x_downleft number := 0;
  y_downleft number := 0;
  x_upperright number := 0;
  y_upperright number := 0;

  BEGIN

  execute immediate 'begin SELECT X_DL INTO :x_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out x_downleft;

  execute immediate 'begin SELECT Y_DL INTO :y_downleft
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||down_rectangle||';end;' using out y_downleft;

  execute immediate 'begin SELECT X_UR INTO :x_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out x_upperright;

  execute immediate 'begin SELECT Y_UR INTO :y_upperright
  FROM '||tdwprefix||'_RECTANGLE
  WHERE GEOGRAPHYID='||upper_rectangle||';end;' using out y_upperright;

IF x_downleft>=x_upperright AND y_downleft>=y_upperright THEN
  result := 0;
ELSE
  execute immediate 'begin SELECT AVG(Acceleration) INTO :RESULT
  FROM '||tdwprefix||'_FACTTBL f, '||tdwprefix||'_RECTANGLE r
  WHERE f.SPACE_ID=r.GEOGRAPHYID
  AND r.X_DL >= '||x_downleft||' AND r.Y_DL >= '||y_downleft||' AND r.X_UR <= '||x_upperright||'
  AND r.Y_UR <= '||y_upperright||' AND f.TIME_ID >= '||from_period||' AND f.TIME_ID <= '||to_period||'
  ;end;' using out RESULT;

END IF;
 RETURN RESULT;
END Aggregated_Acceleration;

END AGGREGATIONS;
/


