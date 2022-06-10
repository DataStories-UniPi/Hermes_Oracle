Prompt Type Body SEM_MBB;
CREATE OR REPLACE type body sem_mbb is

  -- Member procedures and functions
  member function to_sem_mbb(geom sdo_geometry,period tau_tll.d_period_sec) return sem_mbb is
  /*
  This function takes as input a geometry object (other than point or line) and a time period.
  It constructs a sem_mbb instance filling atributes from these parameters.
  Default constructor also have two parameters so be carefull.
  */
  result sem_mbb:=sem_mbb(sem_st_point(null,null,null),sem_st_point(null,null,null));
  mbr sdo_geometry;
  geomnull exception;periodnull exception;
  invalidcoords exception;
  begin
    mbr:=sdo_geom.sdo_mbr(geom);
    if (geom is null) then
      raise geomnull;
    end if;
    if (period is null) then
      raise periodnull;
    end if;
    if (mbr.get_gtype()=1) then--point
      result.minpoint:=sem_st_point(mbr.sdo_ordinates(1),mbr.sdo_ordinates(2),period.b);
      result.maxpoint:=sem_st_point(mbr.sdo_ordinates(1),mbr.sdo_ordinates(2),period.e);
    elsif (mbr.get_gtype()>=2) then--line, rectangle and up
      if (mbr.sdo_ordinates(1)>mbr.sdo_ordinates(3)
      or (mbr.sdo_ordinates(2)>mbr.sdo_ordinates(4))
      or (period.e.get_abs_date()<period.b.get_abs_date())) then
        raise invalidcoords;
      else
        result.minpoint:=sem_st_point(mbr.sdo_ordinates(1),mbr.sdo_ordinates(2),period.b);
        result.maxpoint:=sem_st_point(mbr.sdo_ordinates(3),mbr.sdo_ordinates(4),period.e);
      end if;
    end if;
    return result;
    exception
      when geomnull then
        dbms_output.put_line('null input geometry');
        raise_application_error(-20000,'null input geometry');
      when periodnull then
        dbms_output.put_line('null input period');
        raise_application_error(-20000,'null input period');
      when invalidcoords then
        dbms_output.put_line('invalid x,y,t coords');
        raise_application_error(-20000,'invalid x,y,t coords');
  end to_sem_mbb;
  
  member function area(srid integer) return number is--add srid as parameter!!!
   x number:=0;
  begin
    select sdo_geom.sdo_area(sdo_geometry(2003,srid,null,sdo_elem_info_array(1,1003,3),
       sdo_ordinate_array(minpoint.x,minpoint.y,maxpoint.x,maxpoint.y)), 0.005)
       into x--square meters
       from dual;
    return x;
  end area;

  member function area return number is--add srid as parameter!!!
   x number:=0;
  begin
    select sdo_geom.sdo_area(sdo_geometry(2003,null,null,sdo_elem_info_array(1,1003,3),
       sdo_ordinate_array(minpoint.x,minpoint.y,maxpoint.x,maxpoint.y)), 0.005)
       into x--square meters
       from dual;
    return x;
  end area;

  member function duration return tau_tll.d_interval is
  begin
    return maxpoint.t.f_diff(maxpoint.t, minpoint.t);
  end duration;
  
  member function getrectangle return mdsys.sdo_geometry is
    resgeom mdsys.sdo_geometry;
  begin
    select sdo_geometry(2003,null,null,sdo_elem_info_array(1,1003,3),
       sdo_ordinate_array(minpoint.x,minpoint.y,maxpoint.x,maxpoint.y))
       into resgeom
       from dual;
    return resgeom;
  end getrectangle;
  
  member function getrectangle(srid integer) return mdsys.sdo_geometry is
    resgeom mdsys.sdo_geometry;
  begin
    if (minpoint.x=maxpoint.x) and (minpoint.y=maxpoint.y) then--is a point actually
      select sdo_geometry(2001,srid,sdo_point_type(minpoint.x,minpoint.y,null),null,null)
       into resgeom
       from dual;
    else
      select sdo_geometry(2003,srid,null,sdo_elem_info_array(1,1003,3),
       sdo_ordinate_array(minpoint.x,minpoint.y,maxpoint.x,maxpoint.y))
       into resgeom
       from dual;
    end if;
    return resgeom;
  end getrectangle;
  
  member function intersectsperdim(inmbb sem_mbb) return integer_nt is
  /*
  This function takes as input another sem_mbb object. It checks whether an intersection exists in each dimension of sem_mbb [x,y,t].
  It returns a 3 element nested table of integers. Each element is 0 or 1. If exists an intersection on x(y,t) dimension then
  element 1(2,3) is 1 otherwise is 0.
  */
  mbb1mint integer;mbb1maxt integer;--watchout overflow...
  mbb2mint integer;mbb2maxt integer;
  intersection integer_nt:= integer_nt(0,0,0);
  inmbbnull exception;
  begin
    if (inmbb is null) then
      raise inmbbnull;
    end if;
    if (self.minpoint.x=self.maxpoint.x) and (self.minpoint.y=self.maxpoint.y) then
      --self is a point
      if (inmbb.minpoint.x <= self.minpoint.x) and (self.minpoint.x <= inmbb.maxpoint.x) then
        intersection(1):=1;
      end if;
      if (inmbb.minpoint.y <= self.minpoint.y) and (self.minpoint.y <= inmbb.maxpoint.y) then
        intersection(2):=1;
      end if;
    elsif (inmbb.minpoint.x=inmbb.maxpoint.x) and (inmbb.minpoint.y=inmbb.maxpoint.y) then
      --inmbb is a point
      if (self.minpoint.x <= inmbb.minpoint.x) and (inmbb.minpoint.x <= self.maxpoint.x) then
        intersection(1):=1;
      end if;
      if (self.minpoint.y <= inmbb.minpoint.y) and (inmbb.minpoint.y <= self.maxpoint.y) then
        intersection(2):=1;
      end if;
    else--neither are points
      if (inmbb.maxpoint.x > self.minpoint.x) and (inmbb.minpoint.x < self.maxpoint.x) then
        intersection(1):=1;
      end if;
      if (inmbb.maxpoint.y > self.minpoint.y) and (inmbb.minpoint.y < self.maxpoint.y) then
        intersection(2):=1;
      end if;
    end if;--end of spatial check
    
    mbb2mint:=inmbb.minpoint.t.get_abs_date();mbb1mint:=self.minpoint.t.get_abs_date();
    mbb2maxt:=inmbb.maxpoint.t.get_abs_date();mbb1maxt:=self.maxpoint.t.get_abs_date();
    if (mbb2maxt > mbb1mint) and (mbb2mint < mbb1maxt) then
      intersection(3):=1;
    end if;
    return intersection; 
    exception
     when inmbbnull then
       dbms_output.put_line('null input sem_mbb');
       raise_application_error(-20000,'null input sem_mbb');
  end intersectsperdim;
  
  member function intersects(inmbb sem_mbb) return boolean is
  /*
  This function takes as input another sem_mbb object. It checks whether an intersection exists between them in all dimensions.
  If exists it returns true otherwise it returns false.
  */
  intersection integer_nt;
  inmbbnull exception;
  begin
    if (inmbb is null) then
      raise inmbbnull;
    end if;
    intersection:=self.intersectsperdim(inmbb);
    if intersection(1)=1 and intersection(2)=1 and intersection(3)=1 then
      return true;
    else
      return false;
    end if;
    exception
     when inmbbnull then
       dbms_output.put_line('null input sem_mbb');
       raise_application_error(-20000,'null input sem_mbb');
  end intersects;
  
  member function intersects01(inmbb sem_mbb) return pls_integer is
  /*
  This function takes as input another sem_mbb object. It checks whether an intersection exists between them in all dimensions.
  If exists it returns true otherwise it returns false.
  */
  intersection integer_nt;
  inmbbnull exception;
  begin
    if (inmbb is null) then
      raise inmbbnull;
    end if;
    intersection:=self.intersectsperdim(inmbb);
    if intersection(1)=1 and intersection(2)=1 and intersection(3)=1 then
      return 1;
    else
      return 0;
    end if;
    exception
     when inmbbnull then
       dbms_output.put_line('null input sem_mbb');
       raise_application_error(-20000,'null input sem_mbb');
  end intersects01;
  
  member function ispoint return number is
  
  begin
    return self.maxpoint.isspatialequalto(self.minpoint);
  end ispoint;
  
end;
/


