Prompt Package Body TBTREEMETADATA_PKG;
CREATE OR REPLACE PACKAGE BODY tbTreeMetadata_pkg AS
    -- iterate is a package-level variable used to maintain state across calls
    -- by Export in this session.
    iterate NUMBER := 0;

    FUNCTION getversion(idxschema IN VARCHAR2, idxname IN VARCHAR2,
                            newblock OUT PLS_INTEGER) RETURN VARCHAR2 IS
    BEGIN
    -- We are generating only one PL/SQL block consisting of one line of code.
    newblock := 1;
    IF iterate = 0
    THEN
        -- Increment iterate so we'll know we're done next time we're called.
        iterate := iterate + 1;
        -- Return a string that calls checkversion with a version 'V1.0'
        -- Note that export adds the surrounding BEGIN/END pair to form the anon.
        -- block... we don't have to.
        RETURN 'tbTreeMetadata_pkg.checkversion(''V1.0'');';
    ELSE
        -- reset iterate for next index
        iterate := 0;
        -- Return a 0-length string; we won't be called again for this index.
        RETURN '';
    END IF;
    END getversion;

    PROCEDURE checkversion (version IN VARCHAR2) IS
        wrong_version EXCEPTION;
    BEGIN
        IF version != 'V1.0' THEN
            RAISE wrong_version;
        END IF;
    END checkversion;
END tbTreeMetadata_pkg;
/


