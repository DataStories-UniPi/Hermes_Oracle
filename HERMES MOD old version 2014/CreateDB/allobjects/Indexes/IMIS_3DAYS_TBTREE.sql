Prompt Index IMIS_3DAYS_TBTREE;
CREATE INDEX IMIS_3DAYS_TBTREE ON IMIS_3DAYS_MPOINTS
(MPOINT)
INDEXTYPE IS TBTREE
PARAMETERS('traj_id')
/


