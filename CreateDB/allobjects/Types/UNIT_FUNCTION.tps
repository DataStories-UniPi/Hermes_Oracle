Prompt Type UNIT_FUNCTION;
CREATE OR REPLACE TYPE unit_function AS OBJECT (
   xi      NUMBER,
   yi      NUMBER,                                        -- (xi, yi) initial positions
   xe      NUMBER,
   ye      NUMBER,                                        -- (xe, ye) end position
   xm      NUMBER,
   ym      NUMBER,                                        -- (xm, ym) centre of circle (in case of cyclic motions)
   v       NUMBER,                                        -- initial velocity (in case of accelerating)
   a       NUMBER,                                        -- acceleration
   f       NUMBER,
   descr   VARCHAR2 (20)                                  -- mask describing the type of motion
);
/


