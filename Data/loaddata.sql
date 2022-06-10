connect HERMES/HERMES@&1
spool loaddata.mylog;
@Data\ATTIKI_SUB_MPOINTS.sql
@Data\attiki_sem_trajs.sql
@Data\updatetlinks.sql
spool off;
exit;
