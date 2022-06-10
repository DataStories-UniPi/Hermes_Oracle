Prompt Type Body SEM_ST_POINT;
CREATE OR REPLACE type body sem_st_point as
  member function isspatialequalto(aPoint sem_st_point ) return number is
    
  begin
    if (self.x = apoint.x) and (self.y = apoint.y) then
      return 1;
    else
      return 0;
    end if;
  end;
END;
/


