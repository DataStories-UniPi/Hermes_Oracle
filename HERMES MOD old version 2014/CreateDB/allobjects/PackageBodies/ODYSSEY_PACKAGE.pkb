Prompt Package Body ODYSSEY_PACKAGE;
CREATE OR REPLACE PACKAGE BODY odyssey_package AS


    FUNCTION Tr_FCM(filename VARCHAR2, OUTfilename VARCHAR2, density DOUBLE PRECISION, tau PLS_INTEGER, difftol DOUBLE PRECISION, epsilon DOUBLE PRECISION, deltasigma DOUBLE PRECISION, side PLS_INTEGER, numofclasses PLS_INTEGER) return PLS_INTEGER
    IS  EXTERNAL
        LANGUAGE C
        NAME "Tr_FCM"
        LIBRARY odyssey_lib
        WITH CONTEXT;

    FUNCTION CenTr_I_FCM(filename VARCHAR2, OUTfilename VARCHAR2, density DOUBLE PRECISION, tau PLS_INTEGER, difftol DOUBLE PRECISION, epsilon DOUBLE PRECISION, deltasigma DOUBLE PRECISION, side PLS_INTEGER, numofclasses PLS_INTEGER) return PLS_INTEGER
    IS  EXTERNAL
        LANGUAGE C
        NAME "CenTr_I_FCM"
        LIBRARY odyssey_lib
        WITH CONTEXT;

    FUNCTION CenTra(filename VARCHAR2, density DOUBLE PRECISION, tau PLS_INTEGER, difftol DOUBLE PRECISION, epsilon DOUBLE PRECISION, deltasigma DOUBLE PRECISION, side PLS_INTEGER) return PLS_INTEGER
    IS  EXTERNAL
        LANGUAGE C
        NAME "CenTra"
        LIBRARY odyssey_lib
        WITH CONTEXT;

    FUNCTION TX_CenTra(filename VARCHAR2, density DOUBLE PRECISION, tau PLS_INTEGER, difftol DOUBLE PRECISION, epsilon DOUBLE PRECISION, deltasigma DOUBLE PRECISION, side PLS_INTEGER) return PLS_INTEGER
    IS  EXTERNAL
        LANGUAGE C
        NAME "TX_CenTra"
        LIBRARY odyssey_lib
        WITH CONTEXT;

    FUNCTION T_Sampling(filename VARCHAR2, OUTfilename VARCHAR2, tau PLS_INTEGER, difftol DOUBLE PRECISION, epsilon DOUBLE PRECISION, delta DOUBLE PRECISION, side PLS_INTEGER, numofclasses PLS_INTEGER) return PLS_INTEGER
    IS  EXTERNAL
        LANGUAGE C
        NAME "T_Sampling"
        LIBRARY odyssey_lib
        WITH CONTEXT;


--    FUNCTION Hello(mynum PLS_INTEGER) return PLS_INTEGER
--    IS  EXTERNAL
--        LANGUAGE C
--        NAME "Hello"
--        LIBRARY odyssey_lib
--        WITH CONTEXT;

END;
/


