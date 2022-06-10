@echo off
rem first we export sub_mpoints as sql insert file from sqldeveloper, mind the two last fields on big sub_mpoints
rem then executing SEM_RECONSTRUCT.EXPORTSEMTRAJS2IMPORT to export sem trajectories with null tlink on episodes

echo Enter Oracle sid:
set /p ORACLE_SID=

echo Loading data for attiki...
sqlplus /nolog @Data\loaddata.sql %ORACLE_SID%
echo Done.
echo
echo You can read log files created now. They will be deleted next.
pause
del *.mylog
echo Done.
pause