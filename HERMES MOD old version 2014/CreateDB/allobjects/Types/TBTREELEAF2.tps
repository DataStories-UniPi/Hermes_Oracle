Prompt Type TBTREELEAF2;
CREATE OR REPLACE TYPE tbTreeLeaf2 AS OBJECT
(
--TrajID INTEGER /*the id of the trajectory of a moving object*/,
MoID INTEGER /*the moving object id*/,
ROID varCHAR2(20),/*the rowid of the moving object whose partial trajectory is contained in the leaf
            this is used by the ODCIINDEXFETCH to return batches of base table rows*/
ptrParentNode integer /*A pointer to the Parent node*/,
ptrCurrentNode integer  /*A pointer to the node itsself*/,
ptrNextNode integer /*A pointer to the next node*/,
ptrPreviousNode integer /*A pointer to the previous node*/ ,
counter Integer /*A counter to hold the current number of node entries*/,
tbTreeLeafEntries LeafEntries2 /*The actual entries of the node*/
);
/


