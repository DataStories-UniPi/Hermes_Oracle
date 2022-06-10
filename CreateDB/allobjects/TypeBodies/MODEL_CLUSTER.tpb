Prompt Type Body MODEL_CLUSTER;
CREATE OR REPLACE TYPE BODY MODEL_CLUSTER IS

     MEMBER FUNCTION f_membership(mid NUMBER, threshold NUMBER) RETURN NUMBER IS
     i number;
     cluster_num number;
     change number;
     BEGIN
        i := elements.FIRST;
        cluster_num:=0;
        change:=0;
         WHILE (i IS NOT NULL) LOOP
         if (elements(i).value >= threshold) then change:=1; end if;
         if ((elements(i).value < threshold) and (change=1)) then change:=0; cluster_num:=cluster_num+1; end if;
         if ((elements(i).id=mid) and (change=0)) then return cluster_num; end if;
         if ((elements(i).id=mid) and (change=1)) then return 0; end if;
         i:= elements.next(i);
         END LOOP;
         return -1;
    END;

     MEMBER FUNCTION f_getThresholdFor(num NUMBER) RETURN NUMBER IS
     i number;
     l CLUSTER_PAIR;
     r Number;
     cur number;
     BEGIN
     cur:=99999;
        i := elements.FIRST;
        l:=new CLUSTER_PAIR(99999,99999);
        WHILE (i IS NOT NULL) LOOP
         if (elements(i).value<cur)
         then
          cur:=elements(i).value;
          r:=f_count(cur)-num;  if (r<0) then r:=r*-1; end if;
          if (r<l.id) then
            l:=new CLUSTER_PAIR(r,cur);
            end if;
         end if;
         i:= elements.next(i);
         END LOOP;
         return l.value;
    END;

    MEMBER FUNCTION f_getClusterFor(num NUMBER) RETURN NUMBER IS
     cluster_id number;
     BEGIN
      cluster_id := elements(num).id;
      return cluster_id;
    END;

     MEMBER FUNCTION f_clusters(threshold NUMBER) RETURN CLUSTER_LIST IS
     i number;
     cluster_num number;
     cluster_count number;
     outsider number;
     change number;
     res CLUSTER_LIST;
     cur CLUSTER_PAIR;
     BEGIN
        res:= new CLUSTER_LIST();
        i := elements.FIRST;
        cluster_num:=0;
        cluster_count:=0;
        outsider:=0;
        change:=0;
         WHILE (i IS NOT NULL) LOOP
         if (elements(i).value >= threshold) then change:=1; outsider:=outsider+1; end if;
         if ((elements(i).value < threshold) and (change=0)) then cluster_count:=cluster_count+1; end if;
         if ((elements(i).value < threshold) and (change=1)) then
          cur:= CLUSTER_PAIR(cluster_num,cluster_count);
          res.extend();
          res(res.last):=cur;
          change:=0;
          cluster_num:=cluster_num+1;
          cluster_count:=0;
          end if;
         i:= elements.next(i);
         END LOOP;
         if (change=0)
         then
          cur:= CLUSTER_PAIR(cluster_num,cluster_count);
          res.extend();
          res(res.last):=cur;
          end if;
          cur:= CLUSTER_PAIR(0,outsider);
          res.extend();
          res(res.last):=cur;
          return res;
    END;

    MEMBER FUNCTION f_getNoise(threshold NUMBER) RETURN CLUSTER_LIST IS
     i number;
     noise_start number;
     noise_end number;
     change number;
     res CLUSTER_LIST;
     cur CLUSTER_PAIR;
     BEGIN
        res:= new CLUSTER_LIST();
        i := elements.FIRST;
        noise_start:=0;
        noise_end:=0;
        change:=1;
        WHILE (i IS NOT NULL) LOOP
         if ((elements(i).value < threshold) and (change=0)) then
          change:=1;
          cur:= CLUSTER_PAIR(noise_start,noise_end);
          res.extend();
          res(res.last):=cur;
         end if;
         if ((elements(i).value >= threshold) and (change=0)) then noise_end:=i; end if;
         if ((elements(i).value >= threshold) and (change=1)) then
          change:=0;
          noise_start:=i;
          noise_end:=i;
         end if;
         i:= elements.next(i);
         END LOOP;

         if (change=0)
         then
          cur:= CLUSTER_PAIR(noise_start,noise_end);
          res.extend();
          res(res.last):=cur;
         end if;
         return res;
    END;

     MEMBER FUNCTION f_count(threshold NUMBER) RETURN NUMBER IS
     i number;
     cluster_num number;
     change number;
     BEGIN
        i := elements.FIRST;
        cluster_num:=0;
        change:=0;
         WHILE (i IS NOT NULL) LOOP
         if (elements(i).value >= threshold) then change:=1; end if;
         if ((elements(i).value < threshold) and (change=1)) then change:=0; cluster_num:=cluster_num+1; end if;
         i:= elements.next(i);
         END LOOP;
         return cluster_num+1;
	END;

     MEMBER FUNCTION f_size(id NUMBER, threshold NUMBER) RETURN NUMBER IS
     i number;
     cluster_num number;
     cluster_count number;
     change number;
     BEGIN
        i := elements.FIRST;
        cluster_num:=0;
        cluster_count:=0;
        change:=0;
         WHILE (i IS NOT NULL) LOOP
         if (elements(i).value >= threshold) then change:=1; end if;
         if ((elements(i).value < threshold) and (change=0)) then cluster_count:=cluster_count+1; end if;
         if ((elements(i).value < threshold) and (change=1)) then
          if (cluster_num=id) then return cluster_count; end if;
          change:=0;
          cluster_num:=cluster_num+1;
          cluster_count:=0;
          end if;
         i:= elements.next(i);
         END LOOP;
      if (cluster_num=id) then return cluster_count; else return -1; end if;
      END;

      MEMBER FUNCTION f_getClusters(threshold NUMBER) RETURN CLUSTER_LIST IS
       i number;
       cluster_start number;
       cluster_end number;
       change number;
       res CLUSTER_LIST;
       cur CLUSTER_PAIR;
       BEGIN
          res:= new CLUSTER_LIST();
          i := elements.FIRST;
          cluster_start:=0;
          cluster_end:=0;
          change:=1;
          WHILE (i IS NOT NULL) LOOP
           if ((elements(i).value >= threshold) and (change=0)) then
            change:=1;
            cur:= CLUSTER_PAIR(cluster_start,cluster_end);
            res.extend();
            res(res.last):=cur;
           end if;
           if ((elements(i).value < threshold) and (change=0)) then cluster_end:=i; end if;
           if ((elements(i).value < threshold) and (change=1)) then
            change:=0;
            cluster_start:=i;
            cluster_end:=i;
           end if;
           i:= elements.next(i);
           END LOOP;

           if (change=0)
           then
            cur:= CLUSTER_PAIR(cluster_start,cluster_end);
            res.extend();
            res(res.last):=cur;
           end if;
           return res;
      END;
END;
/


