@echo off
echo Installation of HERMES MOD in Oracle 11g database in progress...
echo ==== DO NOT WORRY ABOUT COMPILATION ERRORS! ======
echo Enter Oracle sid:
set /p ORACLE_SID=
echo Enter password for user system:
set /p systempassword=
echo Creating directories for IO...
set curdir=%CD%
mkdir %curdir%\IO
mkdir %curdir%\GML2KML
echo Registering directories in DBMS...
sqlplus /nolog @CreateDB\scripts\crdirs.sql %ORACLE_SID% %systempassword% %curdir%
echo Done with directories.
pause
echo Dropping users and their objects...
sqlplus /nolog @CreateDB\scripts\dropusers.sql %ORACLE_SID% %systempassword%
echo Done.
pause
echo Creating user HERMES and TAU_TLL...
sqlplus /nolog @CreateDB\scripts\crusers.sql %ORACLE_SID% %systempassword%
echo Users created.
pause
echo
echo ###########           ACTION BY YOU            ##############
echo
echo Copy file %curdir%\Libraries\TLLWrapper.dll to ORACLEHOME\BIN\ directory....
echo Creating library in database as user TAU_TLL...
echo
echo ###########           ACTION BY YOU            ##############
echo
echo LOGIN INTO THE SERVER AS "TAU_TLL" USER, PASSWD: "TAU_TLL"
echo issue: CREATE OR REPLACE LIBRARY TLL_lib AS 'ORACLEHOME\BIN\TLLWrapper.dll';
pause
echo Done.
echo Installing TAU_TLL Data Cartridge...
sqlplus /nolog @CreateDB\scripts\TAU_TLL_short.sql %ORACLE_SID%
echo Done.
pause
echo ###########           ACTION BY YOU            ##############
echo
echo Change your "sqlnet.ora" that resides in 'ORACLEHOME\NETWORK\ADMIN\...'
echo Basically, you have to add a line like the following one:
echo ENCRYPTION_WALLET_LOCATION = (SOURCE = (METHOD=FILE) (METHOD_DATA = (DIRECTORY = ORACLEHOME\admin\wallet)))
echo Check if the folder in the DIRECTORY path variable exists. If it does not exist, create a folder with name "wallet" inside 'ORACLEHOME\admin\'
pause
sqlplus /nolog @CreateDB\scripts\wallet.sql %ORACLE_SID%
echo Done.
pause
echo Installing HERMES Data Cartridge...
sqlplus /nolog @CreateDB\scripts\HERMES_short.sql %ORACLE_SID%
echo Done.
pause
echo Install odyssey library...
echo
echo ###########           ACTION BY YOU            ##############
echo
echo Copy file %curdir%\Libraries\odyssey.dll to ORACLEHOME\BIN\ directory....
echo
echo ###########           ACTION BY YOU            ##############
echo
echo LOGIN INTO THE SERVER AS "HERMES" USER, PASSWD: "HERMES"
echo issue: CREATE OR REPLACE LIBRARY odyssey_lib AS 'ORACLEHOME\BIN\odyssey.dll';
pause
echo Recompile invalid objects....
sqlplus /nolog @CreateDB\scripts\recompile.sql %ORACLE_SID%
echo Done.
pause
echo
echo You can read log files created now. They will be deleted next.
pause
del *.mylog
echo Done.
pause
