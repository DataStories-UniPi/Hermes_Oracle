connect HERMES/HERMES@&1
spool wallet.mylog;
ALTER SYSTEM SET ENCRYPTION KEY AUTHENTICATED BY "hermes";

ALTER SYSTEM SET ENCRYPTION WALLET OPEN IDENTIFIED BY "hermes";

--ALTER SYSTEM SET WALLET CLOSE;
spool off;
exit;


