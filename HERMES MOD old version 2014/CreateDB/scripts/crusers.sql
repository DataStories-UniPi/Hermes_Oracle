connect system/&2@&1
spool crusers.mylog;
@CreateDB\allobjects\Users\HERMES.sql
@CreateDB\scripts\CREATE_GRANT_TAU_TLL.sql
spool off;
exit;