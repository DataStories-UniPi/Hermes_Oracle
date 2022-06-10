connect system/&2@&1
spool crdirs.mylog;
CREATE OR REPLACE DIRECTORY GML2KML AS '&3\GML2KML';
CREATE OR REPLACE DIRECTORY IO AS '&3\IO';
spool off;
exit;