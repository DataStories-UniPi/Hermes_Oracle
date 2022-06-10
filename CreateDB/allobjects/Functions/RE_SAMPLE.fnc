Prompt Function RE_SAMPLE;
CREATE OR REPLACE function re_sample(inmpoints in mp_array, intimepoints in tau_timepoint_ntab) return mp_array pipelined as
outmpoint moving_point;
atpoint sdo_geometry;
begin
  --intimepoints should be ordered
  --for every mpoint
  for i in inmpoints.first..inmpoints.last loop
    --if there is a time intersection
    if (inmpoints(i).u_tab(inmpoints(i).u_tab.first).p.b.f_l(inmpoints(i).u_tab(inmpoints(i).u_tab.first).p.b,intimepoints(intimepoints.last))=1)
    and (inmpoints(i).u_tab(inmpoints(i).u_tab.last).p.e.f_b(inmpoints(i).u_tab(inmpoints(i).u_tab.last).p.e,intimepoints(intimepoints.first))=1)
    then--assuming times inside mpoint are ordered
      --create new mpoint
      outmpoint := moving_point(moving_point_tab(),inmpoints(i).traj_id,inmpoints(i).srid);
      --for every timepoint
      for j in intimepoints.first..intimepoints.last loop
        --get the at_instant of mpoint, should be a sdo_geometry 2001=>point
        --at_instant return point geometry null on sdo_orinates!!!
        atpoint:=inmpoints(i).at_instant(intimepoints(j));
        --if at point not null
        if (atpoint is not null) then
          --if no segments on new mpoint so far
          if (outmpoint.u_tab.count = 0) then
            --extend u_tab and add the first point
            outmpoint.u_tab.extend;
            outmpoint.u_tab(outmpoint.u_tab.last) := unit_moving_point(tau_tll.d_period_sec(intimepoints(j),null),
              unit_function(atpoint.sdo_point.x,atpoint.sdo_point.y,null,null,null,null,null,null,null,'PLNML_1'));
          else
            --add end of segment, extend and add new segment begin
            outmpoint.u_tab(outmpoint.u_tab.last).p.e := intimepoints(j);
            outmpoint.u_tab(outmpoint.u_tab.last).m.xe := atpoint.sdo_point.x;
            outmpoint.u_tab(outmpoint.u_tab.last).m.ye := atpoint.sdo_point.y;
            outmpoint.u_tab.extend;
            outmpoint.u_tab(outmpoint.u_tab.last) := unit_moving_point(tau_tll.d_period_sec(intimepoints(j),null),
              unit_function(atpoint.sdo_point.x,atpoint.sdo_point.y,null,null,null,null,null,null,null,'PLNML_1'));
          end if;
        end if;
      end loop;
      --after all timepoints
      --trim last segment as it was prepared for next point
      outmpoint.u_tab.trim;
      --dbms_output.put_line(outmpoint.u_tab.count);
      --if mpoint has segments
      if(outmpoint.u_tab.count > 0) then
        --pipe mpoint
        pipe row(outmpoint);
      else
        pipe row(null);
      end if;
    end if;
  end loop;
  return;
end re_sample;
/


