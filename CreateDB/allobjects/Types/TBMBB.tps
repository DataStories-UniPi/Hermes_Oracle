Prompt Type TBMBB;
CREATE OR REPLACE TYPE tbMBB AS OBJECT(
--the lower left point of the MBB
MinPoint tbPoint,
--the upper right point of the MBB
MaxPoint tbPoint);
/


