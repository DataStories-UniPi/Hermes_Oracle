Prompt Type Body SEM_TRAJ_ID;
CREATE OR REPLACE type body sem_traj_id is
  
  -- Member procedures and functions
  order member function match(other sem_traj_id) return integer is
  begin
    if self.o_id < other.o_id then
      return -1;
    elsif self.o_id > other.o_id then
      return 1;
    elsif self.o_id = other.o_id then
      if self.semtraj_id < other.semtraj_id then
        return -1;
      elsif self.semtraj_id > other.semtraj_id then
        return 1;
      else
        return 0;
      end if;
    else
      return 0;
    end if;
  end match;
  
end;
/


