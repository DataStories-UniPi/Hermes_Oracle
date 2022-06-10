Prompt Type TBMOVINGOBJECTENTRY;
CREATE OR REPLACE TYPE tbMovingObjectEntry AS OBJECT(
--Object ID
Id NUMBER,
--Points
P1 tbPoint,
P2 tbPoint);
/


