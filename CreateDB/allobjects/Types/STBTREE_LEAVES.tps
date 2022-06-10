Prompt Type STBTREE_LEAVES;
CREATE OR REPLACE type stbtree_leaves as object(
    lid number,
    roid varchar2(32 byte),
    leaf sem_stbleaf);
/


