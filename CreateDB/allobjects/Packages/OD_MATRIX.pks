Prompt Package OD_MATRIX;
CREATE OR REPLACE PACKAGE od_matrix
IS
/******************************************************************************
   NAME:       HREMES.OD_MATRIX
   PURPOSE:    Estimates origin destination matrices from db and dw(to be created...)
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/3/2013            thgoum. Created this package.
   1.1        20/3/2013            thgoum. Major changes in construct_odmatrix procedure
******************************************************************************/
   -- Public type declarations
   TYPE ARRAY IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE array2d IS TABLE OF ARRAY INDEX BY BINARY_INTEGER;

   srid   PLS_INTEGER;
   
   stmt varchar2(5000);

-- **
-- * Sets the global package variable srid
-- **
   procedure get_srid;
-- **
-- * Inputs data into rectangle table with steps that we give,  creates spatial_index therein 
-- * and inserts appropriate records in the table user_sdo_geom_metadata
-- *
-- * @param stepx. The desired step for longitude
-- * @param stepy. The desired step for latitude
-- **
   procedure populate_rectangle_tbl(stepx in pls_integer, stepy in pls_integer);
-- **
-- *  Generates kml files from rectangle table data 
-- **   
   procedure visualize_rectangle_tbl;
-- **
-- * Creates the structure of a two-dimensional table of the form array (array (integer)) 
-- *
-- * @param matrix. Returns the two-dimensional table structure as array2d type
-- **
   PROCEDURE populate_odmatrix_structure (matrix OUT array2d);
-- **
-- * Fills the table created by the above procedure based on the records of the tables rectangle and tbl_name(parameter)
-- *
-- * @param tbl_name. The name of the table where semantic trajectories are
-- * @param matrix. Returns the two-dimensional table filled with data as array2d type
-- **
   PROCEDURE construct_odmatrix (tbl_name in varchar2, matrix OUT array2d);
-- **
-- * Returns the filled matrix in the form of relational table
-- *
-- * @param tbl_name. The name of the table where semantic trajectories are
-- **
   FUNCTION get_odmatrix (tbl_name in varchar2)  RETURN t_relmatrixdb;
END od_matrix;
/


