Prompt Package RAW_TRAJECTORIES_LOADER;
CREATE OR REPLACE PACKAGE RAW_TRAJECTORIES_LOADER AS
    TYPE CursorType IS REF CURSOR;

    PROCEDURE  loadmpoint(mpointID integer, OBJ_ID integer, srid integer, raw_table varchar2, target_table varchar2);
    PROCEDURE  bulkload_RAW_TRAJECTORIES(srid integer, raw_table varchar2, target_table varchar2);
    PROCEDURE  remove_empty_MPOINTS(target_table varchar2);
    procedure  loadfromfile_id_n_t_x_y(file_name varchar2, table_name varchar2);
    PROCEDURE  MovingPointTable2TXT(outTXTfile VARCHAR2, table_name VARCHAR2);

END;
/


