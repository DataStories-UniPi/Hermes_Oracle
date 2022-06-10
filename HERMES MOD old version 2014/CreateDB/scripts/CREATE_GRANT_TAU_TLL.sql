/*
1. Firstly, an Oracle user must be created and by this action a synonymous schema is
implicitly constructed under which all the temporal object types will be defined and
stored. For this run the following statement:
*/

CREATE USER TAU_TLL IDENTIFIED
BY TAU_TLL
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
/

/*
2. Secondly, a series of roles should be granted to the above Oracle user in order to
have the necessary privileges to perform specialized operations (e.g. creating,
replacing or dropping an object type and/or registering a Dynamic Link Library used
to facilitate external object methods). Run the following statements:
*/

GRANT AQ_ADMINISTRATOR_ROLE TO TAU_TLL 
/
GRANT AQ_USER_ROLE TO TAU_TLL 
/
GRANT CONNECT TO TAU_TLL 
/
GRANT DBA TO TAU_TLL 
/
GRANT DELETE_CATALOG_ROLE TO TAU_TLL 
/
GRANT EXECUTE_CATALOG_ROLE TO TAU_TLL 
/
GRANT EXP_FULL_DATABASE TO TAU_TLL 
/
GRANT HS_ADMIN_ROLE TO TAU_TLL 
/
GRANT IMP_FULL_DATABASE TO TAU_TLL 
/
GRANT RECOVERY_CATALOG_OWNER TO TAU_TLL 
/
GRANT RESOURCE TO TAU_TLL 
/
GRANT SELECT_CATALOG_ROLE TO TAU_TLL 
/

