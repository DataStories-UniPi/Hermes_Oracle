Prompt Package Body OD_MATRIX;
CREATE OR REPLACE PACKAGE BODY od_matrix
AS
   PROCEDURE get_srid IS
   BEGIN
      srid := 2100;--TO_NUMBER (sem_reconstruct.getparameter ('imis_3days_sem_trajs', 'SRID'));
   END;

   PROCEDURE populate_rectangle_tbl (stepx IN PLS_INTEGER, stepy IN PLS_INTEGER) IS
      minx       NUMBER;
      miny       NUMBER;
      maxx       NUMBER;
      maxy       NUMBER;
      cminx      NUMBER;
      cminy      NUMBER;
      cmaxx      NUMBER;
      cmaxy      NUMBER;
      currentx   NUMBER;
      currenty   NUMBER;
      stmt       VARCHAR2 (5000);
   BEGIN
     begin
      stmt := 'DROP INDEX RENCTAGLE_IDX';
      EXECUTE IMMEDIATE stmt;
      exception when others then
        null;
     end;

      stmt :='DELETE FROM user_sdo_geom_metadata WHERE TABLE_NAME=''RECTANGLE''';
      EXECUTE IMMEDIATE stmt;

      stmt := 'TRUNCATE TABLE rectangle REUSE STORAGE';
      EXECUTE IMMEDIATE stmt;

      od_matrix.get_srid;
      stmt :='begin SELECT maxx, minx, maxy, miny  into  :maxX, :minX, :maxY, :minY
           FROM HERMES.imis_3days_global; end;';

      EXECUTE IMMEDIATE stmt USING OUT maxx, OUT minx, OUT maxy, OUT miny;

      currentx := minx;
      currenty := miny;
      DBMS_OUTPUT.put_line (currentx || ' ' || maxx);

      while (currentx <= maxx) loop
         WHILE (currenty <= maxy) LOOP
            cminx := currentx;
            cminy := currenty;
            cmaxx := cminx + stepx;
            cmaxy := cminy + stepy;
            stmt :='INSERT INTO RECTANGLE(GEOGRAPHYID,X_DL,Y_DL,X_UR,Y_UR,RECGEO) VALUES('
               || rec_seq_id.NEXTVAL || ',' || replace(TO_CHAR (cminx, '999.999999'),',','.') 
               || ',' || replace(TO_CHAR (cminy, '999.999999'),',','.')
               || ',' || replace(TO_CHAR (cmaxx, '999.999999'),',','.') 
               || ',' || replace(TO_CHAR (cmaxy, '999.999999'),',','.') 
               || ', :geom)';

            --DBMS_OUTPUT.put_line (stmt);
            EXECUTE IMMEDIATE stmt USING IN MDSYS.SDO_GEOMETRY (2003, srid, NULL,
                     mdsys.sdo_elem_info_array (1, 1003, 3 ), 
                     MDSYS.sdo_ordinate_array (cminx, cminy, cmaxx, cmaxy  ) );

            currenty := currenty + stepy;                           --update Y
         END LOOP;

         currentx := currentx + stepx;                              --update X
         currenty := miny;
      END LOOP;

      stmt := 'insert into user_sdo_geom_metadata values(''rectangle'', ''recgeo'',
             mdsys.sdo_dim_array(
               mdsys.sdo_dim_element(''X_DL'', -180, 180, 0.005),
               mdsys.sdo_dim_element(''Y_DL'', -90, 90, 0.005)), ' || srid || ')';
      EXECUTE IMMEDIATE stmt;

      stmt := 'create index RENCTAGLE_IDX on HERMES.RECTANGLE(recgeo) indextype is mdsys.spatial_index';
      EXECUTE IMMEDIATE stmt;

      COMMIT;
   END;

   PROCEDURE visualize_rectangle_tbl IS
      geom   MDSYS.SDO_GEOMETRY;
   BEGIN
      od_matrix.get_srid;

      FOR geom IN (SELECT geographyid, recgeo FROM hermes.rectangle)
      LOOP
         visualizer.polygon2kml (geom.recgeo, 4326, CONCAT ('geom' || geom.geographyid, '_RECTANGLE.kml'  )  );
      END LOOP;
   END;

   PROCEDURE populate_odmatrix_structure (matrix OUT array2d) IS
      array1d      ARRAY;
      x            INTEGER;

      CURSOR rc IS SELECT ALL ROWNUM, geographyid
               FROM hermes.rectangle ORDER BY 2;

      v_num        INTEGER := 0;
      v_geoid      INTEGER := 0;
      const_vnum   INTEGER := 0;
   BEGIN
      hermes.od_matrix.get_srid;

      OPEN rc;
      LOOP
         FETCH rc INTO v_num, v_geoid;

         EXIT WHEN rc%NOTFOUND;
         array1d (v_geoid) := const_vnum;
      END LOOP;
      CLOSE rc;
      OPEN rc;

      LOOP
         FETCH rc INTO v_num, v_geoid;

         EXIT WHEN rc%NOTFOUND;
         matrix (v_geoid) := (array1d);
      END LOOP;
      CLOSE rc;
--      FOR x IN matrix.FIRST .. matrix.LAST
--      LOOP
--         FOR y IN matrix (x).FIRST .. matrix (x).LAST
--         LOOP
--            DBMS_OUTPUT.put_line (x || ':' || y || ' ' || matrix (x) (y));
--         END LOOP;
--      END LOOP;
   END;

   PROCEDURE construct_odmatrix (tbl_name IN VARCHAR2, matrix OUT array2d) IS
      geom1         MDSYS.SDO_GEOMETRY;
      geom2         MDSYS.SDO_GEOMETRY;
      inter_geom    MDSYS.SDO_GEOMETRY;
      tr_fl         VARCHAR2 (200);
      sem_traj      sem_trajectory;
      v_o_id        sem_traj.o_id%TYPE         := 0;
      suc_o_id      sem_traj.o_id%TYPE         := -1;
      v_traj_id     sem_traj.semtraj_id%TYPE   := 0;
      suc_traj_id   sem_traj.semtraj_id%TYPE   := -1;
      v_column      INTEGER                    := -1;
      v_row         INTEGER                    := -1;

      TYPE rc IS REF CURSOR;

      rc_od         rc;

      TYPE type_od IS RECORD (
         o_id         PLS_INTEGER,
         geo          MDSYS.SDO_GEOMETRY,
         subtraj_id   PLS_INTEGER,
         semtraj_id   PLS_INTEGER
      );

      rec_od        type_od;
   BEGIN
      hermes.od_matrix.populate_odmatrix_structure (matrix);
      stmt := 'SELECT   o_id, e1.mbb.getrectangle (srid) geo,
                   DEREF (e1.tlink).subtraj_id subtraj_id, semtraj_id
              FROM (SELECT *  FROM '||tbl_name||' ) t1, TABLE (t1.episodes) e1
             WHERE (DEREF (e1.tlink).subtraj_id IN (
                       SELECT MAX (DEREF (e.tlink).subtraj_id)
                         FROM   '||tbl_name||'   t, TABLE (t1.episodes) e
                        WHERE DEREF (e.tlink).o_id = DEREF (e1.tlink).o_id
                          AND DEREF (e.tlink).traj_id = DEREF (e1.tlink).traj_id) )
                OR (DEREF (e1.tlink).subtraj_id IN (
                       SELECT MIN (DEREF (e.tlink).subtraj_id)
                         FROM   '||tbl_name||'   t, TABLE (t1.episodes) e
                        WHERE DEREF (e.tlink).o_id = DEREF (e1.tlink).o_id
                          AND DEREF (e.tlink).traj_id = DEREF (e1.tlink).traj_id) )
          ORDER BY o_id, semtraj_id, subtraj_id';
     OPEN rc_od FOR stmt;

      LOOP
         FETCH rc_od INTO rec_od;

         EXIT WHEN rc_od%NOTFOUND;
         v_o_id := rec_od.o_id;
         v_traj_id := rec_od.semtraj_id;

         FOR rc_matrix IN (SELECT /*+ ORDERED */ geographyid, recgeo geo
                             FROM hermes.rectangle
                            WHERE sdo_relate (recgeo, rec_od.geo, 'MASK = CONTAINS+TUCH' ) = 'TRUE')
         LOOP
--         DBMS_OUTPUT.put_line
--                                 (tr_fl
--                                  || ' o_id,traj_id,subtraj_id,geomatrix_id '
--                                  || rc_od.o_id
--                                  || ' '
--                                  || rc_od.semtraj_id
--                                  || ' '
--                                  || rc_od.subtraj_id
--                                  || ' '
--                                  || rc_matrix.geographyid
--                                 );
            IF v_o_id != suc_o_id OR v_traj_id != suc_traj_id  THEN
               v_column := -1;
--                  DBMS_OUTPUT.put_line
--                                 (   'INTERACT TRUE '
--                                  || ' o_id,traj_id,subtraj_id,geomatrix_id '
--                                  || rc_od.o_id
--                                  || ' '
--                                  || rc_od.semtraj_id
--                                  || ' '
--                                  || rc_od.subtraj_id
--                                  || ' COLUMN '
--                                  || rc_matrix.geographyid
--                                 );
               v_column := rc_matrix.geographyid;
            END IF;

            IF v_o_id = suc_o_id AND v_traj_id = suc_traj_id THEN
               v_row := -1;
--                  DBMS_OUTPUT.put_line
--                                 (   'INTERACT TRUE '
--                                  || ' o_id,traj_id,subtraj_id,geomatrix_id '
--                                  || rc_od.o_id
--                                  || ' '
--                                  || rc_od.semtraj_id
--                                  || ' '
--                                  || rc_od.subtraj_id
--                                  || ' ROW '
--                                  || rc_matrix.geographyid
--                                 );
               v_row := rc_matrix.geographyid;
               matrix (v_column) (v_row) := matrix (v_column) (v_row) + 1;
--                                 DBMS_OUTPUT.put_line (   v_column
--                                        || ':'
--                                        || v_row
--                                        || ' '
--                                        || matrix (v_column) (v_row)
--                                       );
            END IF;

            suc_o_id := rec_od.o_id;
            suc_traj_id := rec_od.semtraj_id;
         END LOOP;
      END LOOP;

   END;

   FUNCTION get_odmatrix (tbl_name in varchar2) RETURN t_relmatrixdb IS
      v_ret    t_relmatrixdb;
      matrix   hermes.od_matrix.array2d;
   BEGIN
      v_ret := t_relmatrixdb ();
      hermes.od_matrix.construct_odmatrix (tbl_name, matrix);

      FOR x IN matrix.FIRST .. matrix.LAST
      LOOP
         FOR y IN matrix (x).FIRST .. matrix (x).LAST
         LOOP
            v_ret.EXTEND;
            v_ret (v_ret.COUNT) := relmatrixdb (x, y, matrix (x) (y));
         END LOOP;
      END LOOP;

      RETURN v_ret;
   END;
END od_matrix;
/


