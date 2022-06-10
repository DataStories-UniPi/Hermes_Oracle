Prompt Type Body SEM_EPISODE;
CREATE OR REPLACE type body sem_episode is

  -- Member procedures and functions
  member function duration return tau_tll.d_interval is
  begin
    return mbb.duration();
  end duration;
  
  member function sim_episodes(e sem_episode,dbtable varchar2:=null,indxprefix varchar2:=null,
  lamda number:=0.5, weight number_nt:=number_nt(0.333,0.333,0.333)) return number is
  /*
  This function takes as input another sem_episode object, a dataset table for calculating global values
  needed , an optional index prefix if such an index (STBTREE) is built, an optional value for lamda parameter,
  an optional 3 number array for weight parameter. It returns a number that defines the distance between
  this episode object and the input episode.
  */
  stmt varchar2(4000);
  cur_tag sys_refcursor;
  tags varchar_ntab;
  mbbe1 number_nt:=number_nt(self.mbb.maxpoint.x-self.mbb.minpoint.x,self.mbb.maxpoint.y-self.mbb.minpoint.y,
    self.mbb.maxpoint.t.get_abs_date()-self.mbb.minpoint.t.get_abs_date());
  mbbe2 number_nt:=number_nt(e.mbb.maxpoint.x-e.mbb.minpoint.x,e.mbb.maxpoint.y-e.mbb.minpoint.y,
    e.mbb.maxpoint.t.get_abs_date()-e.mbb.minpoint.t.get_abs_date());
  maxdist number_nt:=number_nt(0,0,0);
  mbbunion number_nt:=number_nt(0,0,0);
  mbbintersection number_nt:=number_nt(0,0,0);
  invalidcoords exception;logicerror exception;
  distth number:=0;
  type kvector_typ is table of number index by varchar2(50);
  ke1vector kvector_typ;
  ke2vector kvector_typ;
  ke1norm2 number:=0;
  ke2norm2 number:=0;
  ke1ke2innerprod number:=0;
  distk number:=0;
  dist number:=0;
  begin
    if (self.mbb.ispoint()=1 and e.mbb.ispoint()=1) then
      raise invalidcoords;
    end if;
    if ((dbtable is null) and (indxprefix is not null))then
      raise logicerror;
    end if;
    if (dbtable is not null) then--or from dataset dimensions
      execute immediate 'begin select max(e.mbb.maxpoint.x)-min(e.mbb.minpoint.x) 
        ,max(e.mbb.maxpoint.y) - min(e.mbb.minpoint.y)
        ,max(e.mbb.maxpoint.t.get_abs_date()) - min(e.mbb.minpoint.t.get_abs_date())
        into :maxdist1, :maxdist2, :maxdist3
        from '||dbtable||' t,table(t.episodes) e;end;'
        using out maxdist(1),out maxdist(2),out maxdist(3);
    else
      --raise logicerror;--although it can be run without a dataset see mydebug
      maxdist(1):=greatest(self.mbb.maxpoint.x,e.mbb.maxpoint.x)-least(self.mbb.minpoint.x,e.mbb.minpoint.x);
      maxdist(2):=greatest(self.mbb.maxpoint.y,e.mbb.maxpoint.y)-least(self.mbb.minpoint.y,e.mbb.minpoint.y);
      maxdist(3):=greatest(self.mbb.maxpoint.t.get_abs_date(),e.mbb.maxpoint.t.get_abs_date())
      -least(self.mbb.minpoint.t.get_abs_date(),e.mbb.minpoint.t.get_abs_date());
    end if;
    
    mbbunion(1):=greatest(self.mbb.maxpoint.x,e.mbb.maxpoint.x)-least(self.mbb.minpoint.x,e.mbb.minpoint.x);
    mbbunion(2):=greatest(self.mbb.maxpoint.y,e.mbb.maxpoint.y)-least(self.mbb.minpoint.y,e.mbb.minpoint.y);
    mbbunion(3):=greatest(self.mbb.maxpoint.t.get_abs_date(),e.mbb.maxpoint.t.get_abs_date())
      -least(self.mbb.minpoint.t.get_abs_date(),e.mbb.minpoint.t.get_abs_date());
    
    mbbintersection(1):= least(self.mbb.maxpoint.x,e.mbb.maxpoint.x)-greatest(self.mbb.minpoint.x,e.mbb.minpoint.x);
    mbbintersection(2):= least(self.mbb.maxpoint.y,e.mbb.maxpoint.y)-greatest(self.mbb.minpoint.y,e.mbb.minpoint.y);
    mbbintersection(3):= least(self.mbb.maxpoint.t.get_abs_date(),e.mbb.maxpoint.t.get_abs_date()
      -greatest(self.mbb.minpoint.t.get_abs_date(),e.mbb.minpoint.t.get_abs_date()));
    
    for i in 1..3 loop--check negativity
      if mbbunion(i)<0 then mbbunion(i):=0; end if;
      if mbbintersection(i)<0 then mbbintersection(i):=0; end if;
      if (mbbe1(i)<0) or (mbbe2(i)<0) then raise invalidcoords; end if;
    end loop;
    for i in 1..3 loop--calc spatiotemporal distance, 0 if ispoint some episode
      if (maxdist(i) = 0) then
        null;--distth:=distth + 0*weight(i);
      elsif (greatest(mbbe1(i),mbbe2(i)) = 0) then
        --distth:=distth + 1*weight(i);
        distth:=distth+ weight(i)*((mbbunion(i)-mbbintersection(i))/maxdist(i));
      else
        distth:=distth+ weight(i)*((mbbunion(i)-mbbintersection(i))/maxdist(i))*(least(mbbe1(i),mbbe2(i))/greatest(mbbe1(i),mbbe2(i)));
      end if;
    end loop;
    if (e.defining_tag='****') and (e.episode_tag='****')
    and (e.activity_tag='****') then--gap episode
      distk:=1;
    else
      if (indxprefix is not null) then
        stmt:='select upper(t.tag) from '||indxprefix||'_tag_epis_indx t order by t.tag';--should be distinct already
        open cur_tag for stmt;
        loop
          fetch cur_tag bulk collect into tags;
          exit when tags.count=0;
          for i in tags.first..tags.last loop
            --exact matching as index is built based on all existing tags
            if (upper(tags(i))=upper(nvl(self.defining_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(self.episode_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(self.activity_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            else  
              ke1vector(upper(tags(i))):=0;
            end if;  
            if (upper(tags(i))=upper(nvl(e.defining_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(e.episode_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(e.activity_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            else  
              ke2vector(upper(tags(i))):=0;
            end if;
            
            ke1norm2:=ke1norm2+ke1vector(upper(tags(i)));
            ke2norm2:=ke2norm2+ke2vector(upper(tags(i)));
            ke1ke2innerprod:=ke1ke2innerprod+(ke1vector(upper(tags(i)))*ke2vector(upper(tags(i))));
          end loop;
        end loop;
        close cur_tag;
      else--no tag index exists
        --get all tag
        --defining_tag not in index for now
        if (dbtable is not null) then--tags are those of the dataset
          stmt:='select nvl(upper(t.d),upper(''nulltag'')) tags from (
            select distinct upper(e.defining_tag) d from '||dbtable||' b,table(b.episodes) e
            union
            select distinct upper(e.episode_tag) d from '||dbtable||' b,table(b.episodes) e
            union
            select distinct upper(e.activity_tag) d from '||dbtable||' b,table(b.episodes) e) t';--should be distinct already
          open cur_tag for stmt;
        else--tags are those of the two episodes
          stmt:='select distinct nvl(upper(t.d),upper(''nulltag'')) tags from (
            select upper(:self_defining_tag) d from dual
            union
            select upper(:e_defining_tag) d from dual
            union
            select upper(:self_episode_tag) d from dual
            union
            select upper(:e_episode_tag) d from dual
            union
            select upper(:self_activity_tag) d from dual
            union
            select upper(:e_activity_tag) d from dual ) t';
          open cur_tag for stmt using in self.defining_tag,in e.defining_tag,
            in self.episode_tag,in e.episode_tag, in self.activity_tag,in e.activity_tag;
        end if;
        
        loop
          fetch cur_tag bulk collect into tags;
          exit when tags.count=0;
          for i in tags.first..tags.last loop
             --exact matching as index is built based on all existing tags.
            if (upper(tags(i))=upper(nvl(self.defining_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(self.episode_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(self.activity_tag,'nulltag'))) then
              ke1vector(upper(tags(i))):=1;
            else  
              ke1vector(upper(tags(i))):=0;
            end if;   
            if (upper(tags(i))=upper(nvl(e.defining_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(e.episode_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            elsif (upper(tags(i))=upper(nvl(e.activity_tag,'nulltag'))) then
              ke2vector(upper(tags(i))):=1;
            else  
              ke2vector(upper(tags(i))):=0;
            end if;
            
            ke1norm2:=ke1norm2+ke1vector(upper(tags(i)));
            ke2norm2:=ke2norm2+ke2vector(upper(tags(i)));
            ke1ke2innerprod:=ke1ke2innerprod+(ke1vector(upper(tags(i)))*ke2vector(upper(tags(i))));
          end loop;
        end loop;
        close cur_tag;
      end if;
      --distk:=ke1ke2innerprod/(ke1norm2+ke2norm2-ke1ke2innerprod);--old type
      distk:=1-(ke1ke2innerprod/(ke1norm2+ke2norm2-ke1ke2innerprod));
    end if;
    
    --dist:=(distk-distth)*lamda+1-distk;--old type for Dep
    dist:=(distth-distk)*lamda+distk;--another type for Dep
    dbms_output.put_line('distk='||distk||',distth='||distth||',dist='||dist);
    return dist;
    exception
      when invalidcoords then
        dbms_output.put_line('invalid x,y,t coords of episodes');
        raise_application_error(-20000,'invalid x,y,t coords of episodes');
      when logicerror then
        dbms_output.put_line('can not have index without a dataset');
        raise_application_error(-20000,'can not have index without a dataset');
  end sim_episodes;

end;
/


