Prompt Package TBFUNCTIONS;
CREATE OR REPLACE PACKAGE TBFUNCTIONS AS
        Type hybrid_node is record
        (
            isleaf integer,
            MoID INTEGER /*the moving object id*/,
            RID varCHAR2(20), /*the rowid of the base table record*/
            ptrParentNode INTEGER /*A pointer to the Parent node*/,
            ptrCurrentNode INTEGER  /*A pointer to the node itsself*/,
            ptrNextNode INTEGER /*A pointer to the next node*/,
            ptrPreviousNode INTEGER /*A pointer to the previous node*/ ,
            counter integer,
            tbTreeNodeEntries NodeEntries  ,
            tbTreeLeafEntries LeafEntries   /*The actual entries of the node*/
        );
        IMOCol tbMovingObjectsCollection:=tbMovingObjectsCollection();
        NumberOfNodes integer;
        NumberOfLeaves integer;
        --A procedure which adds or updates the MovingObjects Table
        procedure moadd(imo tbmovingobject);
        procedure UpdateTreeHeight;
        --a procedure used to save or update an internal node of the tree to the corresponding table
        procedure savenode(Node tbtreenode,nodetab varchar2,existence boolean,r integer);
        --a procedure used to save or update a leaf node of the tree to the corresponding table
        procedure saveleaf(Node tbtreeleaf,leaftab varchar2,existence boolean);
        --The Insertion Method of the TB-Tree
        PROCEDURE TBINSERT(POINT1 TBPOINT, POINT2 TBPOINT, MOVINGOBJECTID INTEGER,RID varCHAR2,leaftab VARCHAR2,nodetab VARCHAR2) ;
        --descent the TB-tree until you find the last (right-most) leaf node
        Function ChooseLastLeaf(nodetab varchar2, leaftab varchar2) return tbTreeLeaf;
        --returns true in the SourceMBR includes the InsertedMBR
        Function Includes(SourceMBR tbMBB, InsertedMBR tbMBB, Dimensions integer) return Boolean;
        --Algorithm AdjustTree by Antonin Guttman
        Function AdjustTree(L tbTreeLeaf,LL tbTreeLeaf,nodetab varchar2, leaftab varchar2) return tbTreeNode;
        --calculates the covering rectangle of a rTree Leaf Node
        Function LCoveringMBB(Node tbTreeLeaf) return tbMBB;
        --calculates the covering rectangle of a rTree internal Node
        Function NCoveringMBB(Node tbTreeNode) return tbMBB;
        --returns true in the SourceMBR overlaps the InsertedMBR
        FUNCTION OVERLAPS1D(SourceMin Number, SourceMax Number, InsertedMin Number, InsertedMax Number) return boolean;
        --Finds The Maximum Between 2 NUMBERS
        FUNCTION TBMAX(A1 NUMBER,A2 NUMBER) RETURN NUMBER;
        --Finds The MINIMUM Between 2 NUMBERS
        FUNCTION TBMIN(A1 NUMBER,A2 NUMBER) RETURN NUMBER;
        --'returns true if P1 and P2 are very close (are equal..)
        Function Equals(P1 tbPoint, P2 tbPoint) return Boolean;
        -- function which uses the hashed structure containing each trajectory's last position and returns the
        -- appropriate leaf
        FUNCTION HFINDNODE(IDD integer, P1 TBPOINT,tab varchar2) RETURN tbTreeLeaf;
        --Function to read a LEAF node
        FUNCTION READLEAFNODE(PTRNODE varchar2,tab varchar2) RETURN TBTREELEAF;
        --Function to read an internal node
        FUNCTION READNODE(PTRNODE varchar2,tab varchar2) RETURN TBTREENODE;
        -- ' convert a 3D R-tree entry to a D3Entry with starting point the _
        --(X1,Y1,T1) and ending point the (X2,Y2,T2)
        Function ConstructEntry(Ent tbTreeLeafEntry, Id integer) return tbMovingObjectEntry;
        --checks overlap
        Function Overlapss (sourceMBb TBMBB, insertedMBb TBMBB,Dimensions integer) return boolean;
        --transforms a tb tree leaf entry to the corresponding hermes.unit_moving_point
        Function leafentry_to_unit_moving_point (tble tbtreeleafentry) return hermes.unit_moving_point;
        /**********************************************************************************/
        /***********This point forward hermes moving point member functions****************/
        /***********are redefined so as to take advantage of the tbtree********************/
        /****************************index structure***************************************/
        /**********************************************************************************/

        -- Returns that Unit_Moving_Point of a moving_point with identifier traj_id
        -- that corresponds to a specific timepoint
        --Function tb_unit_type (traj_id integer,tp tau_tll.D_Timepoint_Sec) return hermes.unit_moving_point;
        -- Returns that part of a moving_point with identifier traj_id
        -- that contains a specific timeperiod
        Function tb_mp_contains_timeperiod (traj_id integer,tp tau_tll.D_Period_Sec, leaftab varchar2, nodetab varchar2) return hermes.moving_point;
        -- Returns that parts of a moving_point with identifier traj_id
        -- that contain the timeperiods of a hermes's Temporal Element expressed in seconds
        Function tb_mp_contains_temp_element (traj_id integer,tp tau_tll.D_Temp_Element_Sec, leaftab varchar2, nodetab varchar2) return hermes.moving_point;
        -- Returns a MDSYS.SDO_GEOMETRY of Point type as the result of Mapping/Projecting the Moving_Point at a specific timepoint
        Function tb_at_instant (traj_id integer, tp tau_tll.D_Timepoint_Sec, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY;
        --Returns the moving point constructed by leaf nodes respresenting partial trajectory of interest (the part of the trajectory
        --that participates in the intersection)
        --Den ypologizei to intersection alla to kommati ths troxias pou epistrefetai diatrexontas to dentro kai elegxontas
        --ta MBRs pou kanoun intersect me th do8eisa geometria
        Function tb_mp_geom_intersect_constr(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return hermes.moving_point;
        --Returns the intersection of a moving point with a given geometry expressed in MDSYS.SDO_GEOMETRY
        Function tb_mp_geom_intersection(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY;
        --Returns the intersection of a moving point with a given geometry expressed in hermes.moving_point
        Function tb_mp_geom_intersection2(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return hermes.moving_point;
        -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point with another moving point at a specific timepoint
        Function tb_mp_mp_intersect_at_tp(traj_id integer, mp moving_point, tolerance NUMBER, tp tau_tll.d_timepoint_sec, leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY;
        -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point at a specific timepoint with another geometry object
        function tb_mp_geom_intersect_at_tp(traj_id integer,geom mdsys.sdo_geometry, tolerance number, tp tau_tll.d_timepoint_sec
        , leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY;
        -- Return the enter and leave points of the moving point for a given geometry
        Function tb_get_enter_leave_points(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY;
        -- Returns the points(sorted by time) that the moving point enters inside the area of the polygon argument
        FUNCTION tb_enterpoints (traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY;
        -- Returns the points(sorted by time) that the moving point leaves the area of the polygon argument
        FUNCTION tb_leavepoints (traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY;
        -- Returns the timepoint that the moving point entered the given polygonal geometry
        FUNCTION tb_enter_timepoints (traj_id integer, geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN tau_tll.d_timepoint_sec;
        -- Returns the timepoint that the moving point exit the given polygonal geometry
        FUNCTION tb_leave_timepoints (traj_id integer, geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN tau_tll.d_timepoint_sec;
        -- RETURNS the partial trajectories of all moving points restricted in a certain spatiotemporal window
        -- for use with any tbtree structure (passed as parameter)
        FUNCTION range(geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_period_sec,
                 sridin integer, tbtreenodes varchar2, tbtreeleafs varchar2) return hermes.mp_Array;
        -- same as tb_mp_in_Spatiotemp_Wind but returns an array of SDO_GEOMETRIES to be used in mapviewer
        PROCEDURE mv_query_window(geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_period_sec, leaftab varchar2, nodetab varchar2);
        /********************************************************************************************************************************/
        /********************************************************************************************************************************/
        /**********************This Point Forward defined functions and procedures involve the implementation****************************/
        /********************************of IncrPointNN and IncrTrajectoryNN operators*****************************************/
        /********************************************************************************************************************************/
        /********************************************************************************************************************************/
        Function ConstructMBB(Ent tbMovingObjectEntry) return tbMBB;
        Function Quadrant(Point tbPoint, CenterAxisPoint tbPoint) return integer;
        Function Distance2D(P1 tbPoint, P2 tbPoint) return integer;
        Function MinDist2D(Point tbPoint, MBB tbMBB) return integer;
        Function ActualDist2D(Point tbPoint, P1 tbPoint, P2 tbPoint) return integer;
        Function Intersects2D(Line1 tbMovingObjectEntry, Line2 tbMovingObjectEntry) return Boolean;
        Procedure InterpolateStart(Ent in out tbMovingObjectEntry, T integer);
        Procedure InterpolateEnd(Ent in out tbMovingObjectEntry, T Integer);
        Function MinDistLine2D(Line tbMovingObjectEntry, MBB tbMBB) return integer;
        Function InterpolatePoint(Ent tbMovingObjectEntry, T Number) return tbPoint;
        Function ActualLineDist2D(Line1 tbMovingObjectEntry, Line2 tbMovingObjectEntry) return number;
        Function IncrPointNN(QueryPoint tbMovingObjectEntry, k integer, leaftab varchar2, nodetab varchar2) return tbMovingObjectEntries;
        Function GetTrajectoryPart(Trajectory tbMovingObjectEntries, iMBB tbMBB, traj_size integer) return tbMovingObjectEntries;
        function mindisttrajectory2d(trajectory tbmovingobjectentries, mbb tbmbb, traj_size integer) return number;
        Function IncrTrajectoryNN(QueryTrajectory hermes.moving_point, k number, leaftab varchar2, nodetab varchar2) Return tbMovingObjectEntries;
        --wrapper for incrpointnn and incrtrajectorynn to return moving_points
        function tbMovObjEntrs2MovPoints(moentries tbMovingObjectEntries,srid integer) return mp_array pipelined;
        --Topological query implementation. This function uses the range function to determine trajectories overlapping
        --with the given spatiotemporal window. We utilize moving_object member functions (f_entetrpoints,f_leavepoints) on the resulting moving
        --points so as to finally detect objects of interest depending on a given mask
        function topological(geom mdsys.sdo_geometry,tp tau_tll.d_period_sec,mask varchar2,
          srid integer, tbtreenodes varchar2, tbtreeleafs varchar2) return IDS pipelined;

END tbFunctions;
/


