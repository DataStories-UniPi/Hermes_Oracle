Prompt Type Body SUB_MOVING_POINT;
CREATE OR REPLACE type body sub_moving_point is

  -- Member procedures and functions
  member function getsemmbb return sem_mbb is
    ret_semmbb sem_mbb;
    xmin number:=10000000000;xmax number:=-10000000000;
    ymin number:=10000000000;ymax number:=-10000000000;
  begin
    for i in 1..self.sub_mpoint.u_tab.count loop
      if (sub_mpoint.u_tab(i).m.xi > sub_mpoint.u_tab(i).m.xe) then
        if (sub_mpoint.u_tab(i).m.xi > xmax) then
          xmax:=sub_mpoint.u_tab(i).m.xi;
        end if;
        if (sub_mpoint.u_tab(i).m.xe < xmin) then
          xmin:=sub_mpoint.u_tab(i).m.xe;
        end if;
      else
        if (sub_mpoint.u_tab(i).m.xe > xmax) then
          xmax:=sub_mpoint.u_tab(i).m.xe;
        end if;
        if (sub_mpoint.u_tab(i).m.xi < xmin) then
          xmin:=sub_mpoint.u_tab(i).m.xi;
        end if;
      end if;
      if (sub_mpoint.u_tab(i).m.yi > sub_mpoint.u_tab(i).m.ye) then
        if (sub_mpoint.u_tab(i).m.yi > ymax) then
          ymax:=sub_mpoint.u_tab(i).m.yi;
        end if;
        if (sub_mpoint.u_tab(i).m.ye < ymin) then
          ymin:=sub_mpoint.u_tab(i).m.ye;
        end if;
      else
        if (sub_mpoint.u_tab(i).m.ye > ymax) then
          ymax:=sub_mpoint.u_tab(i).m.ye;
        end if;
        if (sub_mpoint.u_tab(i).m.yi < ymin) then
          ymin:=sub_mpoint.u_tab(i).m.yi;
        end if;
      end if;
    end loop;
    ret_semmbb:=sem_mbb(sem_st_point(xmin,ymin,self.sub_mpoint.f_initial_timepoint()),
                        sem_st_point(xmax,ymax,self.sub_mpoint.f_final_timepoint()));
    return ret_semmbb;
  end;

end;
/


