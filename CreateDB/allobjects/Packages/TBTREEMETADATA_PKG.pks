Prompt Package TBTREEMETADATA_PKG;
CREATE OR REPLACE PACKAGE tbTreeMetadata_pkg AS
    FUNCTION getversion(idxschema IN VARCHAR2, idxname IN VARCHAR2,
                            newblock OUT PLS_INTEGER) RETURN VARCHAR2;
    PROCEDURE checkversion (version IN VARCHAR2);
END tbTreeMetadata_pkg;
/


