connect TAU_TLL/TAU_TLL@&1
spool tau_tll_short.mylog;
@CreateDB\scripts\TAU_TLL.sql
spool off;
exit;