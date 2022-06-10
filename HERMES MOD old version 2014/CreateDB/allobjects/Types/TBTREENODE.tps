Prompt Type TBTREENODE;
CREATE OR REPLACE TYPE tbTreeNode AS OBJECT
(
ptrParentNode Integer /*A pointer to the Parent node*/ ,
ptrCurrentNode Integer  /*A pointer to the node itsself*/ ,
counter Integer, /* A counter to hold the current number of node entries*/
tbTreeNodeEntries NodeEntries
);
/


