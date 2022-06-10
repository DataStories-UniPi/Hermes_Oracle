Prompt Type TBTREE_IDXTYPE_IM;
CREATE OR REPLACE TYPE tbTree_idxtype_im AS OBJECT
(
curnum number,

STATIC FUNCTION ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexCreate (ia sys.ODCIIndexInfo, parms VARCHAR2,
env sys.ODCIEnv) RETURN NUMBER,
STATIC FUNCTION ODCIIndexDrop(ia sys.ODCIIndexInfo, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexInsert(ia sys.ODCIIndexInfo,rid varchar2,
newval moving_point, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexUpdate(ia sys.ODCIIndexInfo, rid VARCHAR2,
oldval moving_point,newval moving_point, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexGetMetadata(ia sys.ODCIIndexInfo,
expversion VARCHAR2,
newblock OUT PLS_INTEGER,
env sys.ODCIEnv)
RETURN VARCHAR2,

STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,
ia sys.ODCIIndexInfo,
op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,
tp tau_tll.D_timepoint_sec, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,
ia sys.ODCIIndexInfo,
op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,
geom MDSYS.SDO_geometry, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,
ia sys.ODCIIndexInfo,
op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,
tp tau_tll.D_Period_Sec, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,ia sys.ODCIIndexInfo,op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,tp tau_tll.D_Temp_Element_Sec, env sys.ODCIEnv)
RETURN NUMBER,
STATIC FUNCTION ODCIIndexStart(sctx IN OUT tbTree_idxtype_im,
ia sys.ODCIIndexInfo,
op sys.ODCIPredInfo, qi sys.ODCIQueryInfo,
strt NUMBER, stop NUMBER,
geom MDSYS.SDO_geometry,tp tau_tll.D_period_sec, env sys.ODCIEnv)
RETURN NUMBER,

MEMBER FUNCTION ODCIIndexFetch(nrows NUMBER, rids OUT sys.ODCIRidList,
env sys.ODCIEnv) RETURN NUMBER,
MEMBER FUNCTION ODCIIndexClose (env sys.ODCIEnv) RETURN NUMBER
/*,
STATIC FUNCTION ODCIIndexDelete(ia sys.ODCIIndexInfo, rid VARCHAR2,
oldval PowerDemand_Typ, env sys.ODCIEnv)
RETURN NUMBER,

*/
);
/


