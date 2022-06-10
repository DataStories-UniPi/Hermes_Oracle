Prompt Package Body TBFUNCTIONS;
CREATE OR REPLACE PACKAGE BODY TBFUNCTIONS AS

        --returns true in the SourceMBR overlaps the InsertedMBR
    Function Overlapss(SourceMBb tbMBB, InsertedMBb tbMBB,Dimensions integer) return Boolean is
        sDimension integer;
        eDimension integer;
    BEGIN


      If Dimensions is null Then
        sDimension := 1;
        eDimension := 3;
      ElsIf Dimensions = 1 Then
        sDimension := 3;
        eDimension := 3;
     ElsIf Dimensions = 2 Then
        sDimension := 1;
        eDimension := 2;
        End If;

        For i in sDimension..eDimension Loop
            If Not
            ((InsertedMBb.MinPoint.x(i) <= SourceMBb.MinPoint.x(i) And SourceMBb.MaxPoint.x(i) <= InsertedMBb.MaxPoint.x(i)) Or
            (InsertedMBb.MaxPoint.x(i) >= SourceMBb.MaxPoint.x(i) And SourceMBb.MaxPoint.x(i) > InsertedMBb.MinPoint.x(i)) Or
            (InsertedMBb.MaxPoint.x(i) > SourceMBb.MinPoint.x(i) And SourceMBb.MinPoint.x(i) >= InsertedMBb.MinPoint.x(i)) Or
            (InsertedMBb.MaxPoint.x(i) <= SourceMBb.MaxPoint.x(i) And SourceMBb.MinPoint.x(i) < InsertedMBb.MinPoint.x(i))) Then
                return False;
            End If;
        End Loop;

        Return True;
        End Overlapss;

        --a procedure used to update the stored tree height value
        --when necessary
        procedure updateTreeHeight is
        begin
        --we store the value of the tree height in the moving objects table
        --with a virtual id of -1
        update movingobjects set ptrlastleaf=ptrlastleaf+1 where id=-1;
        end updateTreeHeight;

        --A procedure which adds or updates the MovingObjects Table
        procedure MoAdd(IMO tbMovingObject) is
        ok boolean;
        c integer:=0;
    /*  stmt varchar2(500);
        cnum INTEGER;
        junk NUMBER;*/
        begin
        ok:=false;
        begin
        EXECUTE IMMEDIATE 'begin select id into :ptr from movingobjects where id='||IMO.ID||';end;' using out c;
            exception when no_data_found then
            EXECUTE IMMEDIATE 'begin insert into movingobjects(ID,ptrLastLeaf) values (:ID,:ptrLL); end;' using in IMO.ID,IMO.ptrLastLeaf;--COMMIT WORK;
        end;

        EXECUTE IMMEDIATE 'begin update movingobjects set ptrLastLeaf=:IMOptrLL where id='||IMO.ID||' ;end;' using in IMO.ptrLastLeaf;--COMMIT WORK;
        --end if;
            /*for i in IMOCol.first..IMOCol.last loop
                if(IMOCol(i).ID=IMO.ID)then
                    if(IMOCol(i).ptrlastLeaf=IMO.ptrLastLeaf) then
                        ok:=true;
                        exit;
                    else
                        EXECUTE IMMEDIATE 'begin update movingobjects set ptrLastLeaf=:IMOptrLL where id='||IMO.ID||' ;end;' using in IMO.ptrLastLeaf;COMMIT WORK;
                    --  stmt:='update movingobjects set ptrLastLeaf='||IMO.ptrLastLeaf||' where id='||IMO.ID;
                        -- Execute the statement.
                        /*cnum := dbms_sql.open_cursor;
                        dbms_sql.parse(cnum, stmt, dbms_sql.native);
                        junk := dbms_sql.execute(cnum);
                        dbms_sql.close_cursor(cnum);*/
                    /*  IMOCol(i).ptrlastLeaf:=IMO.ptrLastLeaf;
                        ok:=true;
                        exit;
                    end if;
                end if;
            end loop;
            if(ok=false) then
                EXECUTE IMMEDIATE 'begin insert into movingobjects(ID,ptrLastLeaf) values (:ID,:ptrLL); end;' using in IMO.ID,IMO.ptrLastLeaf;COMMIT WORK;
                --ImoCol.extend(1);
                --imoCol(ImoCol.last).ID:=Imo.ID;
                --IMOCol(ImoCol.last).ptrlastLeaf:=IMO.ptrLastLeaf;
                /*stmt:='begin insert into movingobjects(ID,ptrLastLeaf) values (:ID,:ptrLL); end;' using in IMO.ID,IMO.ptrLastLeaf;COMMIT WORK;
                -- Execute the statement.
                /*cnum := dbms_sql.open_cursor;
                dbms_sql.parse(cnum, stmt, dbms_sql.native);
                junk := dbms_sql.execute(cnum);
                dbms_sql.close_cursor(cnum);*/
            --end if;
        end MoAdd;

        --Finds The Maximum Between 2 NUMBERS
        FUNCTION TBMAX (A1 NUMBER,A2 NUMBER) RETURN NUMBER IS
        BEGIN
            If a1 > a2 Then
                RETURN a1;
            Else RETURN a2;
            End If;
        END TBMAX;

        --Finds The MINIMUM Between 2 NUMBERS
        FUNCTION TBMIN (A1 NUMBER,A2 NUMBER) RETURN NUMBER IS
        BEGIN
            If a1 < a2 Then
                RETURN a1;
            Else RETURN a2;
            End If;
        END TBMIN;

        Function Equals(P1 tbPoint, P2 tbPoint) return Boolean is
        --'returns true if P1 and P2 are very close (are equal..)
        b boolean;
        begin
        b:=true;
        For i in P1.x(0)..P1.x(2) loop
        If Abs(P1.x(i) - P2.x(i)) > 0.01 Then
            b := False;
        End If;
        end loop;
        return b;
        End Equals;

        --Function to read a LEAF node
        FUNCTION READLEAFNODE(PTRNODE varchar2,tab varchar2) RETURN tbTreeLeaf IS
        /*stmt varchar2(500);
        cnum INTEGER;
        junk NUMBER;*/
        tbLeaf tbTreeLeaf:=tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,leafEntries(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1)));
        begin

        EXECUTE IMMEDIATE 'begin select node into :tt from '||tab||' where r='||ptrnode||'; end;' using out tbLeaf;
        return tbLeaf;
        end READLEAFNODE;


        FUNCTION READNODE(PTRNODE varchar2,tab varchar2) RETURN tbTreenode IS
        /*stmt varchar2(500);
        cnum INTEGER;
        junk NUMBER;*/
        tbNode tbTreeNode:=tbTreeNode(-1,-1,-1,null);
        BEGIN
        EXECUTE IMMEDIATE 'begin select node into :tt from '||tab||' where r='||ptrnode||'; end;' using out tbNode;
        return tbNode;
        end READNODE;


        --descent the TB-tree until you find the last (right-most) leaf node
        Function ChooseLastLeaf(nodetab varchar2, leaftab varchar2) return tbTreeLeaf is
        /*stmt varchar2(500);
        cnum INTEGER;
        junk NUMBER;*/
        tmpNode tbTreeNode;
        tmpLeaf tbTreeLeaf;
        begin
        EXECUTE IMMEDIATE 'begin select node into :tmpnode from '||nodetab||' where r=0;end;'using out tmpnode;
        --<<loops>>
         while (tmpNode.tbTreeNodeEntries(tmpNode.counter).ptr<10000) loop

            EXECUTE IMMEDIATE 'begin select node into :tmpnode from '||nodetab||' where r=:entry;end;'using out tmpnode,in tmpNode.tbTreeNodeEntries(tmpNode.counter).ptr;

            /*stmt:='select into tmpnode from nodetab where r=tmpNode.tbTreeNodeEntries(tmpNode.tbTreeNodeEntries.last).ptr';
            -- Execute the statement.
            cnum := dbms_sql.open_cursor;
            dbms_sql.parse(cnum, stmt, dbms_sql.native);
            junk := dbms_sql.execute(cnum);*/
        end loop;
        EXECUTE IMMEDIATE 'begin select node into :tmpleaf from '||leaftab||' where r=:r;end;' using out tmpleaf,in tmpNode.tbTreeNodeEntries(tmpNode.counter).ptr;
        /*stmt:='select into tmpleaf from leaftab where r=tmpNode.tbTreeNodeEntries(tmpNode.tbTreeNodeEntries.last).ptr';
        -- Execute the statement.
        cnum := dbms_sql.open_cursor;
        dbms_sql.parse(cnum, stmt, dbms_sql.native);
        junk := dbms_sql.execute(cnum);*/
        return tmpLeaf;
        end chooselastleaf;



        -- ' convert a 3D R-tree entry to a D3Entry with starting point the _
        --(X1,Y1,T1) and ending point the (X2,Y2,T2)
        Function ConstructEntry(Ent tbTreeLeafEntry, Id integer) return tbMovingObjectEntry is
        CE tbMovingObjectEntry:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
        begin
        CE.Id := Id;
        --depending on the "orientation" flag, _
        -- the x1,y1,x2,y2 take the following values
        If Ent.Orientation = 1 Then
            CE.P1.x(1) := Ent.MBB.MinPoint.x(1);
            CE.P1.x(2) := Ent.MBB.MinPoint.x(2);
            CE.P2.x(1) := Ent.MBB.MaxPoint.x(1);
            CE.P2.x(2) := Ent.MBB.MaxPoint.x(2);
        ElsIf Ent.Orientation = 2 Then
            CE.P1.x(1) := Ent.MBB.MinPoint.x(1);
            CE.P1.x(2) := Ent.MBB.MaxPoint.x(2);
            CE.P2.x(1) := Ent.MBB.MaxPoint.x(1);
            CE.P2.x(2) := Ent.MBB.MinPoint.x(2);
        ElsIf Ent.Orientation = 3 Then
            CE.P1.x(1) := Ent.MBB.MaxPoint.x(1);
            CE.P1.x(2) := Ent.MBB.MinPoint.x(2);
            CE.P2.x(1) := Ent.MBB.MinPoint.x(1);
            CE.P2.x(2) := Ent.MBB.MaxPoint.x(2);
        ElsIf Ent.Orientation = 4 Then
            CE.P1.x(1) := Ent.MBB.MaxPoint.x(1);
            CE.P1.x(2) := Ent.MBB.MaxPoint.x(2);
            CE.P2.x(1) := Ent.MBB.MinPoint.x(1);
            CE.P2.x(2) := Ent.MBB.MinPoint.x(2);
        End If;

        --' the T1 and T2 are always TMin and TMax respectivelly
        CE.P1.x(3) := Ent.MBB.MinPoint.x(3);
        CE.P2.x(3) := Ent.MBB.MaxPoint.x(3);
        return CE;
        end ConstructEntry;

        --a procedure used to save an internal node of the tree to the corresponding table
        procedure savenode(Node tbtreenode,nodetab varchar2,existence boolean,r integer) is
        /*stmt varchar2(100);
        cnum integer;
        junk number;*/
        begin
        if existence=false then
            execute immediate 'begin insert into '||nodetab||'(r,node) values (:r,:node);end;' using in node.ptrcurrentnode,node; --COMMIT WORK;
            --EXECUTE IMMEDIATE 'begin update movingobjects set ptrlastleaf=ptrlastleaf+1 where id=-2;end;';--COMMIT WORK;
        else
            EXECUTE IMMEDIATE 'begin update '||nodetab||' set r=:r,node=:node where r=:rr;end;' using  in Node.ptrCurrentNode,Node,r;--COMMIT WORK;
        end if;
            /*stmt:='insert into nodetab(r,node) values ('||Node.ptrCurrentNode||','||Node||');';
            -- Execute the statement.
            cnum := dbms_sql.open_cursor;
            dbms_sql.parse(cnum, stmt, dbms_sql.native);
            junk := dbms_sql.execute(cnum);
            dbms_sql.close_cursor(cnum);*/
        end savenode;

        --a procedure used to save an internal node of the tree to the corresponding table
        procedure saveleaf(Node tbtreeleaf,leaftab varchar2,existence boolean) is
        /*stmt varchar2(100);
        cnum integer;
        junk number;*/
        begin
        if existence = false then
        execute immediate 'begin insert into '||leaftab||'(r,ROID,node) values (:r,:rr,:node);end;' using in node.ptrcurrentnode,in node.roid, in node;--COMMIT WORK;
        --EXECUTE IMMEDIATE 'begin update movingobjects set ptrlastleaf=ptrlastleaf+1 where id=-3;end;';--COMMIT WORK;
        else
        EXECUTE IMMEDIATE 'begin update '||leaftab||' set node=:node where r=:rr;end;' using  in Node,Node.ptrCurrentNode;--COMMIT WORK;
        end if;
        /*  stmt:='insert into leaftab(r,node) values (Node.ptrCurrentNode,Node)';
            -- Execute the statement.
            cnum := dbms_sql.open_cursor;
            dbms_sql.parse(cnum, stmt, dbms_sql.native);
            junk := dbms_sql.execute(cnum);
            dbms_sql.close_cursor(cnum);*/
        end saveleaf;

        --calculates the covering rectangle of a rTree Leaf Node
        Function LCoveringMBB(Node tbTreeLeaf) return tbMBB is
        TmpMBB tbMBB;
        begin
        TmpMBB:=Node.tbtreeleafentries(1).MBB;
        For i in 2..Node.counter loop
            For j in 1..3 loop
                TmpMBB.MinPoint.x(j):=tbMin(TmpMBB.MinPoint.x(j),Node.tbtreeleafentries(i).MBB.MinPoint.x(j));
                TmpMBB.MaxPoint.x(j):=tbMax(TmpMBB.MaxPoint.x(j),Node.tbtreeleafentries(i).MBB.MaxPoint.x(j));
            end loop;
        End loop;
        return TmpMBB;
        end LCoveringMBB;

        --calculates the covering rectangle of a rTree internal Node
        Function NCoveringMBB(Node tbTreeNode) return tbMBB is
        TmpMBB tbMBB;
        begin
        TmpMBB:=Node.tbtreenodeentries(1).MBB;
        For i in 2..Node.counter loop
            For j in 1..3 loop
                TmpMBB.MinPoint.x(j):=tbMin(TmpMBB.MinPoint.x(j),Node.tbtreenodeentries(i).MBB.MinPoint.x(j));
                TmpMBB.MaxPoint.x(j):=tbMax(TmpMBB.MaxPoint.x(j),Node.tbtreenodeentries(i).MBB.MaxPoint.x(j));
            end loop;
        End loop;
        return TmpMBB;
        end NCoveringMBB;

        --returns true in the SourceMBR includes the InsertedMBR
        Function Includes(SourceMBR tbMBB, InsertedMBR tbMBB, Dimensions integer) return Boolean is
        sDimension integer;
        eDimension integer;
        begin
            If Dimensions is null Then
                sDimension := 1;
                eDimension := 3;
            ElsIf Dimensions = 1 Then
                sDimension := 3;
                eDimension := 3;
            ElsIf Dimensions = 2 Then
                sDimension := 1;
                eDimension := 2;
            End If;
            For i in sDimension..eDimension loop
            If Not
            (SourceMBR.MinPoint.x(i) <= InsertedMBR.MinPoint.x(i) And
             SourceMBR.MaxPoint.x(i) >= InsertedMBR.MaxPoint.x(i)) Then
                return False;
            End If;
            end loop;

            return true;
        end Includes;

        --Algorithm AdjustTree by Antonin Guttman
        Function AdjustTree(L tbTreeLeaf,LL tbTreeLeaf,nodetab varchar2,leaftab varchar2) return tbtreenode is
        --Ascend from a leaf node L to the root, adjusting covering _
        --rectangles and propagating node splits as necessary. If L was _
        --previously split, LL is the resulted second node
        N hybrid_node;
        NN hybrid_node;
        TempLeaf tbTreeLeaf;
        TempNode tbTreeNode;
        P tbTreeNode;
        PP tbTreeNode;
        En tbTreeNodeEntry;
        Enn tbTreeNodeEntry;
        PreviousMBB tbMBB;
        it integer;
        pagesize pls_integer :=8192;
        maxentries integer;
        minentries integer;
        stmt varchar2(1000);
        cnum integer;
        junk number;
        Splited Boolean :=False;
        Added Boolean := False;
        Begin

        cnum:=0;
        it:=1;
        --tLeaf tbTreeLeaf:=tbTreeLeaf(-1,-1,-1,-1,-1,leafEntries(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1)));
        --afairw apo to mege8os selidas to xwro tou r kai twn ptrcurrentnode,ptrparentnode kai ayto pou menei to diairw me to mege8os enos
        -- node entry

        maxentries:=155;
            minentries:=3;
        --1st Step of the AdjustTree Algorithm
        --set N=L
        N.isLeaf:=1;
        N.MoID:=L.MoID;
        N.RID:=L.RoID;
        N.ptrParentNode:=L.PtrParentNode;
        N.ptrCurrentNode:=L.PtrCurrentNode;
        N.ptrNextNode:=L.ptrNextNode;
        N.ptrPreviousNode:=L.ptrPreviousNode;
        N.counter:=L.counter;
        N.tbTreeLeafEntries:=L.tbTreeLeafEntries;

        /************************************************************************/
        /* Operation need to resolve the number of nodes in the node table*******/
        /************************************************************************/
        --AVOID TABLE MOVINGOBJECTS
        --select ptrlastleaf into NumberOfNodes from movingobjects where id=-2;
        stmt := 'begin select count(R) into :numofnodes from '||nodetab||'; end;';
        execute immediate stmt using out NumberOfNodes;
        --EXECUTE IMMEDIATE 'begin select max(r) into :NoN from '||nodetab||'; end;' using out NumberOfNodes;
        /*stmt:='select max(r) into '||NumberofNodes||'from nodetab';
        -- Execute the statement.
        cnum := dbms_sql.open_cursor;
        dbms_sql.parse(cnum, stmt, dbms_sql.native);
        junk := dbms_sql.execute(cnum);
        dbms_sql.close_cursor(cnum);*/
        /*************************************************************************/
        /*************************************************************************/
        IF NOT (LL is null) then
            NN.isLeaf:=1;
            NN.MoID:=LL.MoID;
            NN.RID:=LL.RoID;
            NN.ptrParentNode:=LL.PtrParentNode;
            NN.ptrCurrentNode:=LL.PtrCurrentNode;
            NN.ptrNextNode:=LL.PtrNextNode;
            NN.ptrPreviousNode:=LL.ptrPreviousNode;
            NN.counter:=LL.counter;
            NN.tbTreeLeafEntries:=LL.tbTreeLeafEntries;
        else NN.isLeaf:=-1;
        end if;
        --2nd step of the AdjustTree algorithm
        --if N is the root of the tree then stop
        --stmt:='select node into P from '||nodetab||' where nodetab.node.ptrcurrentnode='||N.ptrparentnode;
        <<overall_loop>>
        --EXECUTE IMMEDIATE 'begin select node into :P from '||nodetab||' e where r=:NPrnt;end;' using out P,in N.PtrParentNode;
     loop
        -- Let P be the parent node of N
            EXECUTE IMMEDIATE 'begin select node into :P from '||nodetab||' e where e.node.ptrcurrentnode=:NPrnt;end;' using out P,in N.PtrParentNode;
            exit overall_loop when ((N.PtrParentNode=0)AND(N.ptrCurrentNode=0));--(cnum>0));
            cnum:=cnum+1;
            -- Execute the statement.
            --cnum := dbms_sql.open_cursor;
            --dbms_sql.parse(cnum, stmt, dbms_sql.native);
            --junk := dbms_sql.execute(cnum);
            --dbms_sql.close_cursor(cnum);
            --exit overall_loop when N.ptrParentNode=0;
            /*3rd Step of the AdjustTree Algorithm
             Adjust the covering rectangle in the parent entry
            */

            For i in 1..p.counter loop
                if (p.tbtreenodeentries(i).Ptr=N.ptrCurrentNode) then
                    Exit;
                end if;
                it:=it+1;
            end loop;
            --Store P's covering rectangle in order to compare _
            --it with the covering rectangle resulting after the _
            --following modifications
            PreviousMBB := NCoveringMBB(p);
            --Adjust En so that tightly encloses all entry rectangles in N
            if N.isLeaf=1 then
                TempLeaf:=tbtreeleaf(N.MoID,N.RID,N.PtrParentNode,N.PtrCurrentNode,N.PtrNextNode,N.PtrPreviousNode,N.counter,N.tbtreeleafentries);
                /*TempLeaf.ptrParentNode:=N.PtrParentNode;
                TempLeaf.ptrCurrentNode:=;
                TempLeaf.ptrNextNode:=;
                TempLeaf.ptrPreviousNode:=;
                TempLeaf.tbTreeLeafEntries:=N.tbTreeLeafEntries;*/
                p.tbTreeNodeEntries(it).MBB := LCoveringMBB(TempLeaf);
            elsif N.isLeaf=0 then
                TempNode:=tbtreenode(N.PtrParentNode,N.PtrCurrentNode,N.counter,N.tbTreeNodeEntries);
                /*TempNode.ptrParentNode:=;
                TempNode.ptrCurrentNode:=;
                TempNode.tbTreeNodeEntries:=;*/
                p.tbtreenodeentries(it).MBB := NCoveringMBB(TempNode);
            end if;
            --4th step of the AdjustTree algorithm
            --If N has a partner NN from an earlier split
            If (NN.isLeaf!=-1)  Then
                --Adjust Enn's covering rectangle so as to cover _
                --the NN 's covering rectangle
                if NN.isLeaf=1 then
                    TempLeaf:=tbtreeleaf(NN.MoID,NN.RID,NN.PtrParentNode,NN.PtrCurrentNode,NN.PtrNextNode,NN.PtrPreviousNode,NN.counter,NN.tbTreeLeafEntries);
                    /*TempLeaf.MoID:=;
                    TempLeaf.ptrParentNode:=;
                    TempLeaf.ptrCurrentNode:=;
                    TempLeaf.ptrNextNode:=;
                    TempLeaf.ptrPreviousNode:=;
                    TempLeaf.tbTreeLeafEntries:=;*/
                    Enn:=tbtreenodeentry(NN.ptrCurrentNode,LCoveringMBB(TempLeaf));
                    --SaveLeaf(TempLeaf,leaftab,false);
                    --Enn.MBB := LCoveringMBB(TempLeaf);
                elsif(NN.isLeaf=0) then
                    TempNode.ptrParentNode:=NN.PtrParentNode;
                    TempNode.ptrCurrentNode:=NN.PtrCurrentNode;
                    TempNode.counter:=NN.counter;
                    TempNode.tbTreeNodeEntries:=NN.tbTreeNodeEntries;
                    Enn:=tbtreenodeentry(NN.ptrCurrentNode,NCoveringMBB(TempNode));
                    --Enn.MBB := NCoveringMBB(TempNode);
                end if;

                --The pointer of Enn points to the node NN (resulted from a split)
            --  Enn.Ptr := NN.ptrCurrentNode;

                --If there is room in P for another entry
                If (p.counter < maxentries) Then
                    --add the new entry to P
                    p.tbtreenodeentries.extend(1);
                    p.counter:=p.counter+1;
                    p.tbtreenodeentries(p.counter) := Enn;
                    NN.ptrParentNode := p.ptrCurrentNode;
                    Added:=True;
                Else
                    --Otherwise create node PP containing Enn
                    NumberOfNodes:=NumberOfNodes+1;
                    pp:=tbtreenode(-1,NumberOfNodes,1,nodeentries(Enn));
                    --pp.ptrCurrentNode:=;
                    --pp.tbtreenodeentries.extend(1);
                    --PP.tbtreenodeentries(PP.tbtreenodeentries.last) := Enn;
                    --Splited is a variable indicating whether a split has
                --occured or not.
                    Splited := True;
                    NN.ptrParentNode:=PP.ptrCurrentNode;
                End If;
                --savenode NN
             if NN.isLeaf=1 then
                TempLeaf:=tbtreeleaf(NN.MoID,NN.RID,NN.PtrParentNode,NN.PtrCurrentNode,NN.PtrNextNode,NN.PtrPreviousNode,NN.counter,NN.tbTreeLeafEntries);
                /*TempLeaf.MoID:=;
                TempLeaf.ptrParentNode:=;
                TempLeaf.ptrCurrentNode:=;
                TempLeaf.ptrNextNode:=;
                TempLeaf.ptrPreviousNode:=;
                TempLeaf.tbTreeLeafEntries:=;*/
                SaveLeaf(TempLeaf,leaftab,false);
            elsif NN.isLeaf=0 then
                TempNode:=tbtreenode(NN.PtrParentNode,NN.PtrCurrentNode,NN.counter,NN.tbTreeNodeEntries);
                /*TempNode.ptrParentNode:=;
                TempNode.ptrCurrentNode:=;
                TempNode.tbTreeNodeEntries:=;*/
                SaveNode(TempNode,nodetab,false,0);
             End If;
            end if;
             SaveNode(p,nodetab,true,p.ptrCurrentNode);
            --N=P
             N.isLeaf:=0;
             N.ptrParentNode:=p.PtrParentNode;
             N.ptrCurrentNode:=p.PtrCurrentNode;
             N.counter:=p.counter;
             N.tbTreeNodeEntries:=p.tbTreeNodeEntries;
             --Set NN=PP if a split occured
             If Splited=true then
                 NN.isleaf :=0;
                 NN.ptrParentNode:=PP.PtrParentNode;
                 NN.ptrCurrentNode:=PP.PtrCurrentNode;
                 NN.counter:=PP.counter;
                 NN.tbTreeNodeEntries:=PP.tbTreeNodeEntries;
             else NN.isLeaf:=-1;
             End if;

             --' if no split occured and the node's bounding rectangle _
              --was not modified, there is no reason to ascend to higher nodes
        If Splited = False And Includes(PreviousMBB, p.tbtreenodeEntries(it).MBB,null) And ((Added = True And Includes(PreviousMBB, p.tbtreenodeEntries(p.counter).MBB,null)) Or Added = False) Then
           exit overall_loop ;
        End If;

        Splited := False;
        Added := False;
        it:=1;
        end loop;
        if NN.isleaf=-1 then TempNode:=tbTreeNode(-1,-1,-1,null);
        else
            tempNode:=tbtreenode(NN.ptrParentNode,NN.ptrCurrentNode,NN.counter,NN.tbTreeNodeEntries);
            /*tempNode.ptrParentNode:=;
            tempNode.ptrCurrentNode:=;
            tempNode.tbTreeNodeEntries:=;*/
        end if;
        return TempNode;
        --return tbTreeNode(-1,-1,null);
        end AdjustTree;

        -- function which uses the hashed structure containing each trajectory's last position and returns the
        -- appropriate leaf
        FUNCTION HFINDNODE(IDD INTEGER, P1 TBPOINT,tab varchar2) RETURN tbTreeLeaf IS
        IMO tbMovingObject:=tbMovingObject(-1,-1);
        tLeaf tbTreeLeaf:=tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,leafEntries(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1)));
        tent tbmovingobjectentry:=tbmovingobjectentry(-1,tbpoint(tbx(-1,-1,-1)),tbpoint(tbx(-1,-1,-1)));
        stmt varchar(1000);
        /*
        cnum1 INTEGER;
        junk1 NUMBER;*/
        /*cursor c is select * from movingobjects;
        BEGIN
            for item in c loop --select item.id,item.ptrlastleaf into Imo.id,imo.ptrlastleaf from dual;
            if item.id=ID then
            Imo.id:=id;
            imo.ptrlastleaf:=item.ptrlastleaf;
            exit ; */
            /*elsif c%notfound then
            return tbTreeLeaf(-1,'x',-1,-1,-1,-1,leafEntries(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1)));*/
            /*end if;
            end loop;*/
            begin
            begin
            --AVOID TABLE MOVINGOBJECTS
            --select id,ptrlastleaf into imo.id,imo.ptrlastleaf from movingobjects where id=IDD;
            stmt:='begin select l.node.moid, max(l.r) into :id,:lastleaf from '||tab||' l where l.node.moid=:idd
              group by l.node.moid;end;';
            execute immediate stmt using out imo.id, out imo.ptrlastleaf, in idd;
            if (imo.ptrlastleaf is null) then
              raise NO_DATA_FOUND;--this is to catch the following NO_DATA_FOUND case from previous select
            end if;
        exception when NO_DATA_FOUND then
            return tbtreeleaf(-1,'x',-1,-1,-1,-1,-1,leafentries(tbtreeleafentry(tbmbb(tbpoint(tbx(-1,-1,-1)),tbpoint(tbx(-1,-1,-1))),-1)));
            end;
        --end if;
        --dbms_output.put_line(IMO.ptrlastleaf||','||tab);
        tLeaf:=readleafnode(IMO.ptrlastleaf,tab);
        tEnt := ConstructEntry(tLeaf.tbtreeleafentries(tLeaf.counter), tLeaf.moid);
        --if  Equals(tEnt.p2,p1) then
            return tLeaf;
        --else return tbTreeLeaf(-1,'x',-1,-1,-1,-1,leafEntries(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1)));
        --end if;
        END HFINDNODE;

        --The Insertion Method of the TB-Tree
        PROCEDURE TBINSERT(POINT1 TBPOINT, POINT2 TBPOINT, MOVINGOBJECTID INTEGER,RID varCHAR2,leaftab VARCHAR2,nodetab VARCHAR2)  IS
        NEWENTRY tbTreeLeafEntry:=tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1);
        NODE tbTreeLeaf:=tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,null);
        NNODE tbTreeLeaf:=tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,null);
        NewRootNode tbTreeNode:=tbTreeNode(-1,-1,-1,null);
        NewEntry1 tbTreeNodeEntry:=tbTreenodeEntry(null,tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))));
        NewEntry2  tbTreeNodeEntry:=tbTreenodeEntry(null,tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))));
        NNNODE tbTreeNode:=tbTreeNode(-1,-1,-1,nodeentries(NewEntry1));
        OldRootNode tbTreeNode:=tbTreeNode(-1,-1,-1,null);
        IMO tbMovingObject:=tbMovingObject(-1,-1);
        stmt varchar2(1000);
        cnum integer;
        junk number;
        rowscount integer;
        pagesize pls_integer:=8192;
        maxleafentries integer;
        minleafentries integer;
        irrelevant tbTreeNode;
        treeheight integer;
    --  hptr integer;
        --select all pairs regarding already stored moving object ids as well as the pointer to their last leaf
        --cursor c is SELECT * FROM MovingObjects;
        BEGIN

            maxleafentries:=155;
            --for item in c loop select item.id,item.ptrlastleaf into Imo.id,imo.ptrlastleaf from dual;
            --ImoCol.extend(1);ImoCol(ImoCol.last):=Imo;end loop;
            --calculate the min and max in each dimension
            For i IN 1..3 LOOP
                NewEntry.MBB.MinPoint.x(i):=tbmin(Point1.x(i), Point2.x(i));
                NewEntry.MBB.MaxPoint.x(i) :=tbmax(Point1.x(i), Point2.x(i));
            END LOOP;
            --Calculation of the Orientation flag
            /*Orientation is a flag defining the orientation of the line segment inside _
            its Minimum Bounding Box. For further information refer to the paper _
            Pfoser et al. "Novel approches to the IndexIng of Moving Object _
            Trajectories", In Proceedings of the 26th International Conference on Very Large _
            Databases, Cairo, Egypt, 2000*/
            If (NewEntry.MBB.MinPoint.x(1) = Point1.x(1) And NewEntry.MBB.MinPoint.x(2) = Point1.x(2)) Then
                NewEntry.Orientation := 1;
            ElsIf (NewEntry.MBB.MinPoint.x(1) = Point1.x(1) And NewEntry.MBB.MaxPoint.x(2) = Point1.x(2)) Then
                NewEntry.Orientation := 2;
            ElsIf (NewEntry.MBB.MaxPoint.x(1) = Point1.x(1) And NewEntry.MBB.MinPoint.x(2) = Point1.x(2)) Then
                NewEntry.Orientation := 3;
            ElsIf (NewEntry.MBB.MaxPoint.x(1) = Point1.x(1) And NewEntry.MBB.MaxPoint.x(2) = Point1.x(2)) Then
                NewEntry.Orientation := 4;
            End If;
            IMO.Id:=MOVINGOBJECTID;
            Node := tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,leafEntries(NewEntry));
            --' if this is the first entry, the root belongs the first m.o.id
            --The first entry will simultaneously constitute a node and a leaf. Thus, it needs to be stored in the
            --corresponding tables
            --EXECUTE IMMEDIATE 'begin select count(r) into :rr from '||nodetab||'; end;' using out rowscount;

            --ston pinaka movingobjects me id -2 periexetai h timh tou ari8mou ten eswterikwn kombwn tou dentrou
            --select ptrlastleaf into rowscount from movingobjects where id=-2;
            stmt := 'begin select count(r) into :numofnodes from '||nodetab||'; end;';
            execute immediate stmt using out rowscount;
            If rowscount = 0 Then
            Node := tbTreeLeaf(MovingObjectId,RID,0,10000,10000,10000,1,leafEntries(NewEntry));
            NewEntry1:=tbTreenodeEntry(10000,NewEntry.MBB);
            NNNODE:=tbTreeNode(0,0,1,nodeentries(NewEntry1));
            saveleaf(Node,leaftab,false);
            savenode(nnnode,nodetab,false,0);
            imo.ptrlastleaf:=node.ptrcurrentnode;
            --EXECUTE IMMEDIATE 'begin insert into movingobjects(ID,ptrLastLeaf) values (:ID,:ptrLL); end;' using in IMO.ID,IMO.ptrLastLeaf;--COMMIT WORK;
            --EXECUTE IMMEDIATE 'begin update movingobjects set ptrlastleaf=10000 where id=-3; end;';--COMMIT WORK;
            return;
            End If;
            Node := hFindNode(MOVINGOBJECTID, Point1,leaftab);
            --' If the FindNode returned an existing node (e.g. Node.MoID!=-1), and _
            --the node has room for another entry, install the new entry in it
                If Node.counter < maxleafentries AND Node.MoID<>-1  then
                    Node.tbtreeleafentries.extend(1);
                    Node.counter:=Node.counter+1;
                    Node.tbtreeleafentries(Node.counter) := NewEntry;
                    --Propagate Changes upwards using AdjustTree algorithm
                    irrelevant:=AdjustTree(Node,null,nodetab,leaftab);
                    SaveLeaf(Node,leaftab,true);
                    imo.ptrlastleaf:=node.ptrcurrentnode;
                    --MoAdd(IMO);--no needed anymore

                Else
                    --Create a new node (NNode)
                    --set the NNode's moving object id to be the current moving object id
                    nnode:= tbtreeleaf(MovingObjectID,RID,-1,-1,-1,-1,1,leafEntries(NewEntry));
                    --Update the pointers from and to the new node
                    --ston moving objects me id=-3 apo8hkeyetai o ari8mow twn kombwn fyllwn
                    --select ptrlastleaf into numberofleaves from movingobjects where id=-3;
                    stmt := 'begin select max(r) into :numofleaves from '||leaftab||'; end;';--same as count(r)
                    execute immediate stmt using out numberofleaves;
                    --EXECUTE IMMEDIATE 'begin select max(r) into :NoN from '||leaftab||'; end;' using out NumberOfLeaves;
                /*  stmt:='select max(r) into NumberOfLeaves from leaftab';
                    -- Execute the statement.
                    cnum := dbms_sql.open_cursor;
                    dbms_sql.parse(cnum, stmt, dbms_sql.native);
                    junk := dbms_sql.execute(cnum);
                    dbms_sql.close_cursor(cnum);*/

                    --if (NumberOfLeaves=0) then NumberOfLeaves:=10000;
                    --else
                    NumberOfLeaves:= NumberOfLeaves+1;

                    --end if;
                    nNode.ptrCurrentNode:=NumberOfLeaves;
                    nNode.ptrNextNode:=nNode.ptrCurrentNode;

                    if(Node.ptrCurrentnode!=-1)then
                        nNode.ptrPreviousNode:=Node.ptrCurrentNode;
                        Node.ptrNextNode:=nNode.ptrCurrentNode;
                    elsif (Node.ptrCurrentNode=-1)then
                        nNode.ptrPreviousNode:=nNode.ptrCurrentNode;
                    end if;
                    --Update The moving objects Collection
                    IMO.ID:=nNode.MoID;
                    imo.ptrlastleaf:=nnode.ptrcurrentnode;
                    --MoAdd(IMO);--no needed anymore
                        --EXECUTE IMMEDIATE 'begin insert into movingobjects(ID,ptrLastLeaf) values (:ID,:ptrLL); end;' using in IMO.ID,IMO.ptrLastLeaf;COMMIT WORK;

                    --save the last existing node which was modified with the ptrNextNode
                    if (Node.ptrCurrentnode!=-1) then
                        saveLeaf(Node,leaftab,true);
                    end if;
                    --  nNode.ptrParentNode:=0;
                    --  nNode.ptrNextNode:=nNode.ptrCurrentNode;
                    --  saveleaf(nNode,leaftab,false);
                    --end if;

                --invoke ChooselastLeaf to select the last (right-most) leaf of the tbTree
                    Node:=ChooseLastLeaf(nodetab,leaftab);

                    --Propagate Changes upwards using AdjustTree algorithm, passing _
                    --also NNode because of the previous performed split.
                    NNNODE:=AdjustTree(Node,nNode,nodetab,leaftab);
                    --If necessary, create a new root whose children are _
                    --the old root node and the new one resulted from _
                    --the split propagation (grow tree taller)
                    --AdjustTree algorithm returns a node only if the node _
                    --split propagation caused the Root to split
                If (NNNODE.ptrcurrentnode!=-1) then
                        --create a new node
                        --Update the pointers from and to the new node
                        --select ptrlastleaf into NumberOfNodes from movingobjects where id=-2;
                        stmt := 'begin select count(r) into :numofnodes from '||nodetab||'; end;';
                        execute immediate stmt using out NumberOfNodes;
                        --EXECUTE IMMEDIATE 'begin select max(r) into :NumberOfNodes from '||nodetab||';end;' using out NumberOfNodes;
                        /*stmt:='select max(r) into NumberOfNodes from nodetab';
                        -- Execute the statement.
                        cnum := dbms_sql.open_cursor;
                        dbms_sql.parse(cnum, stmt, dbms_sql.native);
                        junk := dbms_sql.execute(cnum);
                        dbms_sql.close_cursor(cnum);*/
                        --savenode(NNNode,nodetab,false);
                        NumberOfNodes:=NumberOfNodes+2;
                        NewRootNode.ptrCurrentNode:=0;
                        NewRootNode.ptrParentNode:=0;

                        --Set the old root pointing to its father (the new root)
                        EXECUTE IMMEDIATE 'begin select node into :OldRootNode from '||nodetab||' where r=0;end;' using out OldRootNode;
                    /*  stmt:='select node into OldRootNode from nodetab where r=0';
                        -- Execute the statement.
                        cnum := dbms_sql.open_cursor;
                        dbms_sql.parse(cnum, stmt, dbms_sql.native);
                        junk := dbms_sql.execute(cnum);
                        dbms_sql.close_cursor(cnum);*/
                        OldRootNode.ptrParentNode:=0;
                        OldRootNode.ptrCurrentNode:=NumberOfNodes;
                        EXECUTE IMMEDIATE 'begin update '||nodetab||' l set l.node.ptrParentNode=:oldroot where l.node.ptrParentNode=0;end;'using in OldRootNode.ptrCurrentNode;
                        savenode(OldRootnode,nodetab,true,0);

                        --Create two new entries (NewEntry1, NewEntry2) of the new root
                        -- Set the one new entry pointing to the old tree root
                        NewEntry1.ptr:=OldRootNode.ptrCurrentNode;
                    --  EXECUTE IMMEDIATE 'begin update '||nodetab||' set r=:ORN '||
                    --  ' where r=0;end;'using in OldRootNode.ptrCurrentNode;
                        /*node.ptrCurrentNode=:OldRootNodeptrCurrentNode node.ptrParentNode=0
                        stmt:='update nodetab set r=OldRootNode.ptrCurrentNode,node.ptrCurrentNode=OldRootNode.ptrCurrentNode,'||
                        'node.ptrParentNode=OldRootNode.ptrParentNode where r=0';
                         -- Execute the statement.
                        cnum := dbms_sql.open_cursor;
                        dbms_sql.parse(cnum, stmt, dbms_sql.native);
                        junk := dbms_sql.execute(cnum);
                        dbms_sql.close_cursor(cnum);*/
                        --' adjust the covering rectangle of this first new entry
                        NewEntry1.MBB:=NCoveringMBB(OldRootNode);
                        --' Set the second new entry pointing to the resulted node
                        NewEntry2.ptr:=NNNode.ptrCurrentNode;
                        --' adjust the covering rectangle of this first new entry
                        NewEntry2.MBB:=NCoveringMBB(NNNode);
                        NNNode.ptrParentNode:=0;
                        SaveNode(NNNode,nodetab,false,0);
                        --Add the new entries to the new root
                        NewRootNode:=tbtreenode(0,0,1,nodeentries(NewEntry1));
                        NewRootNode.tbtreenodeentries.extend(1);
                        NewRootNode.counter:=NewRootNode.counter+1;
                        --NewRootNode.tbtreenodeentries(1) := NewEntry1;
                        NewRootNode.tbtreenodeentries(NewRootNode.counter) := NewEntry2;
                        SaveNode(NewRootNode,nodetab,false,0);
                        execute immediate 'begin update '||leaftab||' l set l.node.ptrParentNode=:oldroot where l.node.ptrParentNode=0;end;'using in oldrootnode.ptrcurrentnode;
                        --updatetreeheight;--no need anymore
                    --  update movingobjects set ptrlastleaf=ptrlastleaf+1 where id=-1.0;
                    --  EXECUTE IMMEDIATE 'begin select ptrlastleaf into :hei from movingobjects where id=:mm; end;' using out treeheight,in -1;--COMMIT WORK;
                    --  treeheight:=treeheight+1;
                    --  EXECUTE IMMEDIATE 'begin update movingobjects set ptrLastLeaf=:IMOptrLL where id='||-1||' ;end;' using in treeheight;--COMMIT WORK;
                    --  EXECUTE IMMEDIATE 'begin update movingobjects set ptrlastleaf=:ll where id=:id;end;' using in treeheight+1,-1;
                    end if;
                End if;
        END TBINSERT;


        --returns true in the SourceMBR overlaps the InsertedMBR
        FUNCTION OVERLAPS1D(SourceMin Number, SourceMax Number, InsertedMin Number, InsertedMax Number) return boolean is
        BEGIN
            if (NOT((InsertedMin <= SourceMin And SourceMax <= InsertedMax)or
                    (InsertedMax >= SourceMax And SourceMax > InsertedMin) Or
                    (InsertedMax > SourceMin And SourceMin >= InsertedMin) Or
                    (InsertedMax <= SourceMax And SourceMin < InsertedMin))) Then
                    return false;
            else return true;
            end if;
        end Overlaps1D;

        --transforms a tb tree leaf entry to a coprresponding hermes.unit_moving_point
    Function leafentry_to_unit_moving_point (tble tbtreeleafentry) return hermes.unit_moving_point is
    m hermes.unit_function;
    m_y integer:=2011;
    m_m integer:=1;
    m_d integer:=25;
    m_h integer:=12;
    m_min integer:=50;
    m_sec integer:=50;
    tp1 tau_tll.D_Timepoint_Sec;
    tp2 tau_tll.D_Timepoint_Sec;
    p tau_tll.D_Period_Sec;
    --um hermes.unit_moving_point;
    begin
        if tble.orientation=1 then
                        m:=unit_function(tble.MBB.MinPoint.x(1),
                                 tble.MBB.MinPoint.x(2),
                                 tble.MBB.MaxPoint.x(1),
                                 tble.MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif tble.orientation=2 then
                        m:=unit_function(tble.MBB.MinPoint.x(1),
                                tble.MBB.MaxPoint.x(2),
                                 tble.MBB.MaxPoint.x(1),
                                 tble.MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif tble.orientation=3 then
                        m:=unit_function(tble.MBB.MaxPoint.x(1),
                                 tble.MBB.MinPoint.x(2),
                                tble.MBB.MinPoint.x(1),
                                 tble.MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif tble.orientation=4 then
                        m:=unit_function(tble.MBB.MaxPoint.x(1),
                                 tble.MBB.MaxPoint.x(2),
                                 tble.MBB.MinPoint.x(1),
                                 tble.MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    end if;
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,tble.MBB.MinPoint.x(3));
                    tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,tble.MBB.Maxpoint.x(3));
                    tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    p:=tau_tll.D_period_sec(tp1,tp2);
                    return unit_moving_point(p,m);
    end leafentry_to_unit_moving_point;
        /**********************************************************************************/
        /***********This point forward hermes moving point member functions****************/
        /***********are redefined so as to take advantage of the tbtree********************/
        /****************************index structure***************************************/
        /**********************************************************************************/

        --Returns that Unit_Moving_Point of a moving_point with identifier traj_id
        --that corresponds to a specific timepoint
        /*Function tb_unit_type (traj_id integer,tp tau_tll.D_Timepoint_Sec) return hermes.unit_moving_point is
        leaf tbtreeleaf;
        node tbtreenode;
        lnode tbtreeleaf;
        nodeid integer;
        result unit_moving_point;
        h integer;
        t number;
        Type ptr is table of integer;
        nodeptr ptr;
        leafptr ptr;
        ptrs ptr;
        p tau_tll.D_period_sec;
        m unit_function;
        m_y integer:=2011;
        m_m integer:=1;
        m_d integer:=25;
        m_h integer:=12;
        m_min integer:=50;
        m_sec integer:=50;
        tp1 tau_tll.D_Timepoint_Sec;
        tp2 tau_tll.D_Timepoint_Sec;
        begin
        t:=tp.get_abs_date;
        --nested tables initialization
        nodeptr:=ptr(0);
        leafptr:=ptr(0);
        ptrs:=ptr(0);
        --acquire the height of the tree
        select distinct ptrlastleaf into h from movingobjects where id=-1;
        for j in 1..h loop
            for w in 1..nodeptr.counter loop

                EXECUTE IMMEDIATE 'begin select node into :node from TBTREEIDX_NON_LEAF where r=:r;end;' using out node,in nodeptr(w);

                for i in 1..node.tbtreenodeentries.counter loop
                    if (node.tbtreenodeentries(i).MBB.MinPoint.x(3)<=t) AND (t<=node.tbtreenodeentries(i).MBB.Maxpoint.x(3)) then
                        if (node.tbtreenodeentries(i).ptr>=10000) then
                            if leafptr.count<>1 then leafptr.extend(1); end if;
                            leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                        else
                        if ptrs.count<>1 then ptrs.extend(1); end if;
                        ptrs(ptrs.last):=node.tbtreenodeentries(i).ptr;
                        end if;
                    end if;
                end loop;
        end loop;
        nodeptr:=ptrs;
        end loop;

        for z in leafptr.first..leafptr.last loop
        EXECUTE IMMEDIATE 'begin select node into :lnode from TBTREEIDX_LEAF where r=:r;end;' using out lnode,in leafptr(z);
            if lnode.Moid=traj_id then
            for e in 1..lnode.tbtreeleafentries.counter loop
                if (lnode.tbtreeleafentries(e).MBB.MinPoint.x(3)<=t) AND (t<=lnode.tbtreeleafentries(e).MBB.Maxpoint.x(3)) then
                    /*if lnode.tbtreeleafentries(e).orientation=1 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=2 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=3 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=4 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    end if;
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(e).MBB.MinPoint.x(3));
                    tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(e).MBB.Maxpoint.x(3));
                    tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    p:=tau_tll.D_period_sec(tp1,tp2);
                    return unit_moving_point(p,m);*/
                    /*return leafentry_to_unit_moving_point(lnode.tbtreeleafentries(e));
                end if;
            end loop;end if;
        end loop;
        return null;
        end tb_unit_type ;*/

        -- Returns that part of a moving_point with identifier traj_id
        -- that contains a specific timeperiod
        Function tb_mp_contains_timeperiod (traj_id integer,tp tau_tll.D_Period_Sec, leaftab varchar2, nodetab varchar2) return hermes.moving_point is
        leaf_b tbtreeleaf;
        leaf_e tbtreeleaf;
        node tbtreeleaf;
        nnode tbtreenode;
        Templeaf tbtreeleaf;
        m hermes.moving_point;
        h integer;
        tb number;
        te number;
        m_y integer:=2011;
        m_m integer:=1;
        m_d integer:=25;
        m_h integer:=12;
        m_min integer:=50;
        m_sec integer:=50;
        Type ptr is table of integer;
        nodeptr ptr;
        leafptr_b ptr;  --pointers to leaf nodes containing the beginning of the timeperiod
        leafptr_e ptr;  --pointers to leaf nodes containing the end of the timeperiod
        ptrs ptr;
        up hermes.unit_moving_point;
        p tau_tll.D_Period_Sec;
        mm hermes.unit_function;
        tp1 tau_tll.D_Timepoint_Sec;
        tp2 tau_tll.D_Timepoint_Sec;
        y integer;
        flag integer:=0;
        stmt varchar2(1000);
        BEGIN
        tb:=tp.b.get_abs_date;
        te:=tp.e.get_abs_Date;
        --nested tables initialization
        nodeptr:=ptr(0);
        leafptr_b:=ptr(0);
        leafptr_e:=ptr(0);
        ptrs:=ptr(0);
        node:=tbTreeLeaf(-1,'x',-1,-1,-1,-1,-1,null);
        m :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),traj_id, null);
        --acquire the height of the tree
        --select ptrlastleaf into h from movingobjects where id=-1;
        /*use a pseudo stack datatype like stbtree or a hier query  */
        stmt := 'begin
          select max(level)--level pseudocolumn
          into :h
          from '||nodetab||' l
          start with l.r=0 --root
          connect by nocycle prior l.r=l.node.ptrparentnode ;--parent child relation, nocycle as root.parent=root  for us
          end;';
        execute immediate stmt using out h;
        for j in 1..h loop
            for w in nodeptr.first..nodeptr.last loop

            EXECUTE IMMEDIATE 'begin select node into :node from '||nodetab||' where r=:r;end;' using out nnode,in nodeptr(w);

            for i in nnode.tbtreenodeentries.first..nnode.tbtreenodeentries.last loop

                if (nnode.tbtreenodeentries(i).MBB.MinPoint.x(3)<=tb) AND (tb<=nnode.tbtreenodeentries(i).MBB.Maxpoint.x(3)) then
                    if (nnode.tbtreenodeentries(i).ptr>=10000) then
                        if leafptr_b.count<>1 then leafptr_b.extend(1); end if;
                        leafptr_b(leafptr_b.last):= nnode.tbtreenodeentries(i).ptr;
                    else
                    if ptrs.count<>1 then ptrs.extend(1); end if;
                    ptrs(ptrs.last):=nnode.tbtreenodeentries(i).ptr;

                    end if;
                end if;

                    if (nnode.tbtreenodeentries(i).MBB.MinPoint.x(3)<=te) AND (te<=nnode.tbtreenodeentries(i).MBB.Maxpoint.x(3)) then
                        if (nnode.tbtreenodeentries(i).ptr>=10000) then
                            if leafptr_e.count<>1 then leafptr_e.extend(1); end if;
                            leafptr_e(leafptr_e.last):= nnode.tbtreenodeentries(i).ptr;
                        --An sto MBB periexetai kai h arxh kai to telos ths periodou o pointer pros ton child node prepei na mpainei mia fora
                        --ara elegxw an periexetai kai h arxh ektos apo to telos prokeimenou na mhn ksanabalw ton idio deikth 2 fores kai kanw
                        --perittes anakthseis.
                        elsif Not ((nnode.tbtreenodeentries(i).MBB.MinPoint.x(3)<=tb) AND (tb<=nnode.tbtreenodeentries(i).MBB.Maxpoint.x(3))) then
                            if ptrs.count<>1 then ptrs.extend(1); end if;
                            ptrs(ptrs.last):=nnode.tbtreenodeentries(i).ptr;
                        end if;
                    end if;

                end loop;
            end loop;
            nodeptr:=ptrs;
        end loop;

    --epelekse ton kombo tou moving point me traj_id ayto pou dinetai ws parametros pou periexei thn arxh ths xronikhs periodou
    for w in leafptr_b.first..leafptr_b.last loop
        EXECUTE IMMEDIATE 'begin select node into :n from '||leaftab||
                ' m  where r=:rr;end;' using out leaf_b, in leafptr_b(w);
        --EXECUTE IMMEDIATE '   insert into movingobjects (-15,:lb)' using in leaf_b.ptrcurrentnode;
        if leaf_b.moid=traj_id then exit ;else leaf_b:=null; end if;

    end loop;

    --epelekse ton kombo tou moving point me traj_id ayto pou dinetai ws parametros pou periexei to telos ths xronikhs periodou
    for x in leafptr_e.first..leafptr_e.last loop
        EXECUTE IMMEDIATE 'begin select node into :n from '||leaftab||
                ' m  where r=:rr;end;' using out leaf_e, in leafptr_e(x);
        --EXECUTE IMMEDIATE '   insert into movingobjects (-16,:lb)' using in leaf_e.ptrcurrentnode;
        if leaf_e.moid=traj_id then exit; else leaf_e:=null; end if;
    end loop;

    if (not (leaf_b is null)) AND (not (leaf_e is null))then
    TempLeaf:=null;
    if (leaf_b.ptrcurrentnode=leaf_e.ptrcurrentnode) then
        for o in leaf_b.tbtreeleafentries.first..leaf_b.tbtreeleafentries.last loop
            if ((leaf_b.tbtreeleafentries(o).MBB.minpoint.x(3)<=tb) AND (tb<=leaf_b.tbtreeleafentries(o).MBB.maxpoint.x(3))) then
                TempLeaf:=tbTreeLeaf(leaf_b.Moid,leaf_b.RoID,leaf_b.ptrparentnode,leaf_b.ptrcurrentnode,leaf_b.counter,leaf_b.ptrnextnode,
                    leaf_b.ptrpreviousnode,leafEntries(leaf_b.tbtreeleafentries(o)));
            elsif NOT (TempLeaf is null) then
                TempLeaf.tbtreeleafentries.extend(1);
                TempLeaf.tbtreeleafentries(TempLeaf.tbtreeleafentries.last):=leaf_b.tbtreeleafentries(o);
            end if;
            if (leaf_e.tbtreeleafentries(o).MBB.minpoint.x(3)<=te) AND (te<=leaf_e.tbtreeleafentries(o).MBB.maxpoint.x(3)) then
                leaf_b:=TempLeaf;
                TempLeaf:=null;
                exit;
            end if;
        end loop;

    else
        --bazw ston arxiko kombo leaf_b mono to kommati tou ekeino apo to MBB pou periexei thn arxh ths
        --xronikhs periodou kai pera
        for m in leaf_b.tbtreeleafentries.first..leaf_b.tbtreeleafentries.last loop
            if (leaf_b.tbtreeleafentries(m).MBB.minpoint.x(3)<=tb) AND (tb<=leaf_b.tbtreeleafentries(m).MBB.maxpoint.x(3)) AND Flag=0 then
                TempLeaf:=tbTreeLeaf(leaf_b.Moid,leaf_b.RoID,leaf_b.ptrparentnode,leaf_b.ptrcurrentnode,leaf_b.ptrnextnode,
                    leaf_b.ptrpreviousnode,leaf_b.counter,leafEntries(leaf_b.tbtreeleafentries(m)));

            end if;
            if flag=1 then
                TempLeaf.tbtreeleafentries.extend(1);
                TempLeaf.tbtreeleafentries(TempLeaf.tbtreeleafentries.last):=leaf_b.tbtreeleafentries(m);
            end if;
            if not (TempLeaf is null) then flag:=1; end if;
        end loop;
        leaf_b:=Templeaf;
        TempLeaf:=null;

        for y in leaf_e.tbtreeleafentries.first..leaf_e.tbtreeleafentries.last loop
            if y=leaf_e.tbtreeleafentries.first then
                TempLeaf:=tbTreeLeaf(leaf_e.Moid,leaf_e.RoID,leaf_e.ptrparentnode,leaf_e.ptrcurrentnode,leaf_e.ptrnextnode,
                        leaf_e.ptrpreviousnode,leaf_e.counter,leafEntries(leaf_e.tbtreeleafentries(y)));
            else
                TempLeaf.tbtreeleafentries.extend(1);
                tempLeaf.tbtreeleafentries(tempLeaf.tbtreeleafentries.last):=leaf_e.tbtreeleafentries(y);
            end if;
            if (leaf_e.tbtreeleafentries(y).MBB.minpoint.x(3)<=te) AND (te<=leaf_e.tbtreeleafentries(y).MBB.maxpoint.x(3)) then
                exit;
            end if;
        end loop;
        leaf_e:=TempLeaf;
    end if;



    --having acquired the leafnodes of the moving point (with traj_id the given parameter) that contain the beggining and
    --the end of the given timeperiod we start from the leaf containg the strating point until we reach the leaf containing the final
    --point

        node:=leaf_b;

        <<lop>>
        loop
            for z in node.tbtreeleafentries.first..node.tbtreeleafentries.last loop
                    /*if node.tbtreeleafentries(z).orientation=1 then
                        mm:=unit_function(node.tbtreeleafentries(z).MBB.MinPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(2),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif node.tbtreeleafentries(z).orientation=2 then
                        mm:=unit_function(node.tbtreeleafentries(z).MBB.MinPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(2),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif node.tbtreeleafentries(z).orientation=3 then
                        mm:=unit_function(node.tbtreeleafentries(z).MBB.MaxPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(2),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif node.tbtreeleafentries(z).orientation=4 then
                        mm:=unit_function(node.tbtreeleafentries(z).MBB.MaxPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MaxPoint.x(2),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(1),
                                 node.tbtreeleafentries(z).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    end if;
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,node.tbtreeleafentries(z).MBB.MinPoint.x(3));
                    tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,node.tbtreeleafentries(z).MBB.Maxpoint.x(3));
                    tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    p:=tau_tll.D_period_sec(tp1,tp2);
                    up:=unit_moving_point(p,mm);*/
                    up:=leafentry_to_unit_moving_point(node.tbtreeleafentries(z));
                    m.u_tab(m.u_tab.last):=up;
                    m.u_tab.extend(1);
                    if (node.ptrcurrentnode=leaf_e.ptrcurrentnode) AND (z=node.tbtreeleafentries.last) then
                        m.u_tab.trim(1);
                    end if;
            end loop;
            exit lop when (node.ptrcurrentnode=leaf_e.ptrcurrentnode) or (leaf_b.ptrcurrentnode=leaf_e.ptrcurrentnode) ;
            if (node.ptrnextnode=leaf_e.ptrcurrentnode) then
                node:=leaf_e;
            else
                EXECUTE IMMEDIATE 'begin select node into :node from '||leaftab||' where r=:rt;end;' using out node, in node.ptrnextnode;
            end if;
        end loop;
        return m;
    else return null;
    end if;
    end tb_mp_contains_timeperiod;


    -- Returns that parts of a moving_point with identifier traj_id
    --that contain the timeperiods of a hermes's Temporal Element expressed in seconds
    Function tb_mp_contains_temp_element (traj_id integer,tp tau_tll.D_Temp_Element_Sec, leaftab varchar2, nodetab varchar2)
    return hermes.moving_point is
    m hermes.moving_point;
    mm hermes.moving_point;
    begin
    for i in tp.te.first..tp.te.last loop
        mm:=tb_mp_contains_timeperiod(traj_id,tp.te(i), leaftab, nodetab);
        if mm is null then return null;
        else
            if m is null then
                m:=mm;
            else
                m:=m.merge_moving_points(m,mm);
            end if;
        end if;
    end loop;
    return m;
    end tb_mp_contains_temp_element;




    -- Returns a MDSYS.SDO_GEOMETRY of Point type as the result of Mapping/Projecting the Moving_Point at a specific timepoint
    Function tb_at_instant (traj_id integer, tp tau_tll.D_Timepoint_Sec, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY is
    leaf tbtreeleaf;
    node tbtreenode;
    lnode tbtreeleaf;
    nodeid integer;
    result unit_moving_point;
    h integer;
    t number;
    Type ptr is table of integer;
    nodeptr ptr;
    leafptr ptr;
    ptrs ptr;
    p tau_tll.D_period_sec;
    m unit_function;
    m_y integer:=2011;
    m_m integer:=1;
    m_d integer:=25;
    m_h integer:=12;
    m_min integer:=50;
    m_sec integer:=50;
    um hermes.unit_moving_point;
    tp1 tau_tll.D_Timepoint_Sec;
    tp2 tau_tll.D_Timepoint_Sec;
    xy  hermes.coords:= coords (0.0, 0.0);
    stmt varchar2(1000);
    begin
    t:=tp.get_abs_date;
    --nested tables initialization
    nodeptr:=ptr(0);
    leafptr:=ptr(0);
    ptrs:=ptr(0);
    --acquire the height of the tree
    --select distinct ptrlastleaf into h from movingobjects where id=-1;
    /*use a pseudo stack datatype like stbtree or a hier query  */
    stmt := 'begin
      select max(level)--level pseudocolumn
      into :h
      from '||nodetab||' l
      start with l.r=0 --root
      connect by nocycle prior l.r=l.node.ptrparentnode ;--parent child relation, nocycle as root.parent=root  for us
      end;';
    execute immediate stmt using out h;
    for j in 1..h loop
        for w in nodeptr.first..nodeptr.last loop

            EXECUTE IMMEDIATE 'begin select node into :node from '||nodetab||' where r=:r;end;' using out node,in nodeptr(w);

            for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
                if (node.tbtreenodeentries(i).MBB.MinPoint.x(3)<=t) AND (t<=node.tbtreenodeentries(i).MBB.Maxpoint.x(3)) then
                    if (node.tbtreenodeentries(i).ptr>=10000) then
                        if leafptr.count<>1 then leafptr.extend(1); end if;
                        leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                    else
                    if ptrs.count<>1 then ptrs.extend(1); end if;
                    ptrs(ptrs.last):=node.tbtreenodeentries(i).ptr;
                    end if;
                end if;
            end loop;
    end loop;
    nodeptr:=ptrs;
    end loop;

    for z in leafptr.first..leafptr.last loop
    EXECUTE IMMEDIATE 'begin select node into :lnode from '||leaftab||' where r=:r;end;' using out lnode,in leafptr(z);
        if lnode.Moid=traj_id then
        for e in lnode.tbtreeleafentries.first..lnode.tbtreeleafentries.last loop
            if (lnode.tbtreeleafentries(e).MBB.MinPoint.x(3)<=t) AND (t<=lnode.tbtreeleafentries(e).MBB.Maxpoint.x(3)) then
                um:=leafentry_to_unit_moving_point(lnode.tbtreeleafentries(e));
                /*  if lnode.tbtreeleafentries(e).orientation=1 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=2 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=3 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    elsif lnode.tbtreeleafentries(e).orientation=4 then
                        m:=unit_function(lnode.tbtreeleafentries(e).MBB.MaxPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MaxPoint.x(2),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(1),
                                 lnode.tbtreeleafentries(e).MBB.MinPoint.x(2),
                                 NULL,NULL,NULL,NULL,NULL,'PLNML_1');
                    end if;
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(e).MBB.MinPoint.x(3));
                    tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(e).MBB.Maxpoint.x(3));
                    tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                    p:=tau_tll.D_period_sec(tp1,tp2);
                    um:=unit_moving_point(p,m); */
                end if;
            end loop;end if;
        end loop;
        if um is null then
            return null;
        else
            xy := um.f_interpolate (tp);
            return
               MDSYS.SDO_GEOMETRY
                                 (2001,      -- SDO_GTYPE: 2-Dimensional point
                                  NULL, -- SDO_SRID:  Spatial Reference System
                                  MDSYS.sdo_point_type (xy (1), xy (2), NULL),
                                  -- SDO_POINT: X and Y coordinates of the 2-D point
                                  NULL,                      -- SDO_ELEM_INFO:
                                  NULL                       -- SDO_ORDINATES:
                                 );
        end if;
    end tb_at_instant;


    --Returns the moving point constructed by leaf nodes respresenting partial trajectory of interest (the part of the trajectory
    --that participates in the intersection)
    Function tb_mp_geom_intersect_constr(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return hermes.moving_point is
    leaf tbtreeleaf;
    node tbtreenode;
    lnode tbtreeleaf;
    TempEntry tbtreeleafEntry;
    nodeid integer;
    ump hermes.unit_moving_point;
    m hermes.moving_point;
    h integer;
    t number;
    Type ptr is table of integer;
    nodeptr ptr;
    leafptr ptr;
    ptrs ptr;
    p1 tau_tll.D_period_sec;
    p2 tau_tll.D_period_sec;
    m_y integer:=2011;
    m_m integer:=1;
    m_d integer:=25;
    m_h integer:=12;
    m_min integer:=50;
    m_sec integer:=50;
    tp1 tau_tll.D_Timepoint_Sec;
    tp2 tau_tll.D_Timepoint_Sec;
    rectangle MDSYS.SDO_GEOMETRY;
    tolerance NUMBER:= 0.001;
    mpoint MDSYS.SDO_GEOMETRY;
    intersection mdsys.sdo_geometry;
    stmt varchar2(1000);
    begin
    TempEntry:=tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1);
    m :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),traj_id, null);
    nodeptr:= ptr(0);
    leafptr:= ptr(0);
    ptrs:= ptr(0);
    --acquire the height of the tree (the value is stored in the moving objects table
    --with an ID of -1 so as to be distinguished from actual moving objects)
    --select ptrlastleaf into h from movingobjects where id=-1;
    /*use a pseudo stack datatype like stbtree or a hier query  */
    stmt := 'begin
      select max(level)--level pseudocolumn
      into :h
      from '||nodetab||' l
      start with l.r=0 --root
      connect by nocycle prior l.r=l.node.ptrparentnode ;--parent child relation, nocycle as root.parent=root  for us
      end;';
    execute immediate stmt using out h;
    for j in 1..h loop
    for w in nodeptr.first..nodeptr.last loop

        EXECUTE IMMEDIATE 'begin select node into :node from '||nodetab||' where r=:r;end;' using out node,in nodeptr(w);
            for i in node.tbtreenodeentries.first..node.tbtreenodeentries.last loop
                rectangle:=SDO_GEOMETRY(2003,
                                        NULL,
                                        NULL,
                                        SDO_ELEM_INFO_ARRAY(1,1003,3),
                SDO_ORDINATE_ARRAY(node.tbtreenodeentries(i).MBB.MinPoint.x(1),node.tbtreenodeentries(i).MBB.MinPoint.x(2), node.tbtreenodeentries(i).MBB.MaxPoint.x(1),node.tbtreenodeentries(i).MBB.MaxPoint.x(2))
                                        );
                intersection:= MDSYS.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
                if NOT (intersection is NULL) then
                    if (node.tbtreenodeentries(i).ptr>=10000) then
                        if leafptr.count<>1 then leafptr.extend(1); end if;
                        leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                    else
                    if ptrs.count<>1 then ptrs.extend(1); end if;
                    ptrs(ptrs.last):=node.tbtreenodeentries(i).ptr;

                    end if;
                end if;
            end loop;
    end loop;
    nodeptr:=ptrs;
    end loop;

    --apo tous kombous fylla krata ekeinous pou anaferontai sto moid=traj_id se xronikh seira kai baltous se ena fyllo oloys
    for k in leafptr.first..leafptr.last loop
            EXECUTE IMMEDIATE 'begin select node into :n from '||leaftab||
                ' m  where r=:rr;end;' using out lnode, in leafptr(k);
            if lnode.moid=traj_id then
                if leaf is null then
                    leaf:=tbTreeLeaf(lnode.Moid,lnode.RoID,lnode.ptrparentnode,lnode.ptrcurrentnode,lnode.ptrnextnode,
                    lnode.ptrpreviousnode,lnode.counter,lnode.tbtreeleafentries);
                else
                    for l in lnode.tbtreeleafentries.first..lnode.tbtreeleafentries.last loop
                        tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(l).MBB.MinPoint.x(3));
                        tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                        tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,lnode.tbtreeleafentries(l).MBB.Maxpoint.x(3));
                        tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                        --this is the time period of the last entry of the retrieved leaf node
                        p1:=tau_tll.D_period_sec(tp1,tp2);

                        tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,leaf.tbtreeleafentries(leaf.tbtreeleafentries.last).MBB.MinPoint.x(3));
                        tp1:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                        tau_tll.D_Timepoint_Sec_Package.set_abs_date(m_y,m_m,m_d,m_h,m_min,m_sec,leaf.tbtreeleafentries(leaf.tbtreeleafentries.last).MBB.Maxpoint.x(3));
                        tp2:=tau_tll.D_Timepoint_Sec(m_y,m_m,m_d,m_h,m_min,m_sec);
                        --this is the the time period of the last entry of the constructed leaf node
                        p2:=tau_tll.D_period_sec(tp1,tp2);

                        if p1.f_precedes(p1,p2)=1 then
                            TempEntry:=leaf.tbtreeleafentries(leaf.tbtreeleafentries.last);
                            leaf.tbtreeleafentries(leaf.tbtreeleafentries.last):=lnode.tbtreeleafentries(l);
                            leaf.tbtreeleafentries.extend(1);
                            leaf.tbtreeleafentries(leaf.tbtreeleafentries.last):=TempEntry;
                        else
                            leaf.tbtreeleafentries.extend(1);
                            leaf.tbtreeleafentries(leaf.tbtreeleafentries.last):=lnode.tbtreeleafentries(l);
                        end if;

                    end loop;
                end if;
            end if;
    end loop;

    --apo ton kombo fyllo pou prokyptei apo to paarapanw loop paragoume ena moving point
    for r in leaf.tbtreeleafentries.first..leaf.tbtreeleafentries.last loop
        ump:=leafentry_to_unit_moving_point(leaf.tbtreeleafentries(r));
        m.u_tab(m.u_tab.last):=ump;
        m.u_tab.extend(1);
        if r=leaf.tbtreeleafentries.last then
        m.u_tab.trim(1);
        end if;
    end loop ;

    return m;

    /*for q in m.u_tab.first..m.u_tab.last loop
        if mpoint is null then
            mpoint:= sdo_geometry (2002, null, null, sdo_elem_info_array (1,2,1),
                           sdo_ordinate_array (m.u_tab(q).m.xi,m.u_tab(q).m.yi));
        else
            mpoint.sdo_ordinate_array.extend(1);
            mpoint.sdo_ordinate_array(mpoint.sdo_ordinate_array.last):=MDSYS.sdo_ordinate_array(m.u_tab(q).m.xi,m.u_tab(q).m.yi);
        end if;
    end loop ;*/

    --return MDSYS.sdo_geom.sdo_intersection (geom, mpoint, tolerance);*/
    --return MDSYS.sdo_geom.sdo_intersection (geom, m.route (), tolerance);
    --return null;--m.f_intersection(geom,tolerance);
    end tb_mp_geom_intersect_constr;

    --Returns the intersection of a moving point with a given geometry expressed in MDSYS.SDO_GEOMETRY
    Function tb_mp_geom_intersection(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY is
    m hermes.moving_point;
    tolerance NUMBER:= 0.001;
    begin
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null;end if;
    --epestrepse thn tomh tou parapanw moving_point me th do8eisa geometria
    return MDSYS.sdo_geom.sdo_intersection (geom, m.route (), tolerance);
    end tb_mp_geom_intersection;

    --Returns the intersection of a moving point with a given geometry expressed in hermes.moving_point
    Function tb_mp_geom_intersection2(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return hermes.moving_point is
    m hermes.moving_point;
    tolerance NUMBER:= 0.001;
    begin
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null;end if;
    --epestrepse thn tomh tou parapanw moving_point me th do8eisa geometria
    return m.f_intersection(geom,tolerance);
    end tb_mp_geom_intersection2;

    -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point with another moving point at a specific timepoint
    function tb_mp_mp_intersect_at_tp(traj_id integer, mp moving_point, tolerance number, tp tau_tll.d_timepoint_sec
    , leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY is
    begin
    RETURN MDSYS.sdo_geom.sdo_intersection (tb_at_instant (traj_id,tp, leaftab, nodetab),
                                        mp.at_instant (tp),
                                        tolerance
                                       );
    end tb_mp_mp_intersect_at_tp;

    -- Returns a geometry object that is the topological intersection (AND operation) of an instanced point at a specific timepoint with another geometry object
    function tb_mp_geom_intersect_at_tp(traj_id integer,geom mdsys.sdo_geometry, tolerance number, tp tau_tll.d_timepoint_sec
    , leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY is
    begin
    RETURN MDSYS.sdo_geom.sdo_intersection (tb_at_instant (traj_id,tp, leaftab, nodetab), geom, tolerance);
    end tb_mp_geom_intersect_at_tp;

    -- Return the enter and leave points of the moving point for a given geometry
    Function tb_get_enter_leave_points(traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) return MDSYS.SDO_GEOMETRY is
    m hermes.moving_point;
    begin
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null;end if;
    --bres ta shmeia eisodou kai eksodou autou tou moving point sth do8eisa geometria
    return m.get_enter_leave_points(geom);
    end tb_get_enter_leave_points;

    -- Returns the points(sorted by time) that the moving point enters inside the area of the polygon argument
    FUNCTION tb_enterpoints (traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY is
    m hermes.moving_point;
    begin
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null;end if;
    return m.f_enterpoints(geom);
    end tb_enterpoints;

    -- Returns the points(sorted by time) that the moving point leaves the area of the polygon argument
    FUNCTION tb_leavepoints (traj_id integer,geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN MDSYS.SDO_GEOMETRY is
    m hermes.moving_point;
    begin
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null;end if;
    return m.f_leavepoints(geom);
    end tb_leavepoints;

    -- Returns the timepoint that the moving point entered the given polygonal geometry
    FUNCTION tb_enter_timepoints (traj_id integer, geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN tau_tll.d_timepoint_sec is
      enter_time_point   tau_tll.d_timepoint_sec;
      enter_points       MDSYS.SDO_GEOMETRY;
      m hermes.moving_point;
    BEGIN
    --bres to kommati ths troxias pou metexei sto intersection kai balto se ena moving_point
    m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);
    if m is null then return null; end if;

    --apo to moving point pou epestrafei bres ta shmeia eisodou
    enter_points := m.f_enterpoints (geom);

     IF enter_points IS NULL THEN
        RETURN NULL;
     END IF;
    --apo to moving point pou epestrafei
      enter_time_point :=
    --find the timepoint that corresponds to a specific xy coords
         m.get_time_point (enter_points.sdo_ordinates (1),
                         enter_points.sdo_ordinates (2)
                        );
      RETURN enter_time_point;
    END tb_enter_timepoints;

    -- Returns the timepoint that the moving point exit the given polygonal geometry
    FUNCTION tb_leave_timepoints (traj_id integer, geom MDSYS.SDO_GEOMETRY, leaftab varchar2, nodetab varchar2) RETURN tau_tll.d_timepoint_sec is
      leave_time_point   tau_tll.d_timepoint_sec;
      leave_points       MDSYS.SDO_GEOMETRY;
      m hermes.moving_point;
      i                  PLS_INTEGER;
    begin
      m:=tb_mp_geom_intersect_constr(traj_id,geom, leaftab, nodetab);

      if m is null then return null;end if;
      leave_points := m.f_leavepoints (geom);

      IF leave_points IS NULL
      THEN
         RETURN NULL;
      END IF;

      i := leave_points.sdo_ordinates.LAST;
      leave_time_point :=
         m.get_time_point (leave_points.sdo_ordinates (i - 1),
                         leave_points.sdo_ordinates (i)
                        );
      RETURN leave_time_point;
   END tb_leave_timepoints;

-- RETURNS the partial trajectories of all moving points restricted in a certain spatiotemporal window
FUNCTION range(geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_period_sec,
       sridin integer, tbtreenodes varchar2, tbtreeleafs varchar2) return hermes.mp_Array is
   leaf tbtreeleaf;
   node tbtreenode;
   Type TbTreeLeavesArray is table of tbTreeLeaf2;
   ump hermes.unit_moving_point;
   Type ptr is table of integer;
   Type lptr is table of integer index by pls_integer;
   --types for descending tbtree
   type nodeStackType is varray(32767) of integer;--varray means you cannot delete(i)
   nodeStack nodeStackType := nodeStackType(0);--0==>root
   top integer:=1;--initial value pointing to element 1 on stack (root)

   --leafptr ptr;
   leafptr integer_nt;
   leafptr_tmp integer_nt;
   templeafid number :=0;
   m_y integer:=2011;
   m_m integer:=1;
   m_d integer:=25;
   m_h integer:=12;
   m_min integer:=50;
   m_sec integer:=50;
   tp1 tau_tll.D_Timepoint_Sec;
   tp2 tau_tll.D_Timepoint_Sec;
   rectangle MDSYS.SDO_GEOMETRY;
   tolerance NUMBER:= 0.01;
   m mp_Array;
   mp hermes.moving_point;
   tbLeaves TbTreeLeavesArray;
   intersection MDSYS.SDO_GEOMETRY;
   lptrs lptr;
   tb number;
   te number;
   SRID INTEGER;
   segm  MDSYS.SDO_GEOMETRY;
   temp hermes.moving_point;
   temp2 hermes.moving_point;
   temp3 hermes.moving_point;
begin
   SRID:=sridin;
   --lptr:= ptrstoleaves(0);
   TbLeaves:=TbTreeLeavesArray(tbTreeLeaf2(-1,'x',-1,-1,-1,-1,-1,leafEntries2(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1))));
   m :=mp_Array(moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),-22, SRID));
   mp :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),-22, SRID);
    tb:=tp.b.get_abs_date;
    te:=tp.e.get_abs_Date;
    --leafptr:= ptr(0);
    leafptr:=integer_nt(0);
    --descend the tree until you reach the lowest level before leaf level
    /*
    the way is : take root then loop all its children
      if child is node add it to stack else leave stack as is (root is overwritten)
      then take the topmost stack element which will be the last child added
      loop its children....
      so leaf are found in a desc order...
    */
    while not top=0 loop
      EXECUTE IMMEDIATE 'begin select node into :node from '||tbtreenodes||' where r=:r;end;'
         using out node, in nodeStack(top);
      top := top-1;--we took node top from stack
      --for each entry of the currently read node (child)
      for i in 1..node.counter loop
        --tranform mBB to rectangular geometry so as to use the sdo_intersection function
        rectangle:=SDO_GEOMETRY(2003,
                                SRID,
                                NULL,
                                SDO_ELEM_INFO_ARRAY(1,1003,3),
        SDO_ORDINATE_ARRAY(node.tbtreenodeentries(i).MBB.MinPoint.x(1),node.tbtreenodeentries(i).MBB.MinPoint.x(2), node.tbtreenodeentries(i).MBB.MaxPoint.x(1),node.tbtreenodeentries(i).MBB.MaxPoint.x(2))
                                );
        --find the intersection of the MBB of the current entry with the given geometry
        intersection:= MDSYS.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
        --get the pointers of those MBBs that intersect the geomentry and concurrently contain a part of the time period
        if (NOT (intersection is NULL)) AND
           tbfunctions.overlaps1d(node.tbtreenodeentries(i).MBB.Minpoint.x(3),node.tbtreenodeentries(i).MBB.Maxpoint.x(3),tb,te) then
          --if the entry's pointer to the child node is >10000 then it points to a leaf so place the pointer in the leafpointers' list
          if (node.tbtreenodeentries(i).ptr>=10000) then
            --sort leaf pointers as you add them
            if leafptr(leafptr.last)=0 then leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
            --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));
            else
              --is not correct as you must move many pointers not one only!!!sider
              /*
              if leafptr(leafptr.last) < node.tbtreenodeentries(i).ptr then
                leafptr.extend(1);
                leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));
              elsif  leafptr(leafptr.last) > node.tbtreenodeentries(i).ptr then
                templeafid:=leafptr(leafptr.last);
                leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
                --dbms_output.put_line('added leaf: '||leafptr.last||'=>'||leafptr(leafptr.last));
                leafptr.extend(1);
                leafptr(leafptr.last):=templeafid;
              end if;
              */
              --so just add them now and sort them later!!!sider
              leafptr.extend(1);
              leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
            end if;
          --otherwise place the pointer to the internal node's list
          else
            if top=0 then--means stack had one element ==> root
              top:=top+1;--overwrite root with its child
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
            else--add child to stack
              top:=top+1;
              nodeStack.extend(1);
              nodeStack(top):=node.tbtreenodeentries(i).ptr;
            end if;
          end if;
        end if;
      end loop;
    end loop;
    --dbms_output.put_line('leafs: '||leafptr.count);
    if (leafptr(leafptr.last)=0)then--no leaf found
      return null;
    end if;

    --for faster oredring !!!sider
    select COLUMN_VALUE
    bulk collect into leafptr_tmp
    from table(leafptr) t
    order by 1;
    leafptr := leafptr_tmp;

    --retreive each leaf in the leaf pointers list
    for k in leafptr.first..leafptr.last loop
       --dbms_output.put_line('visit leaf: '||leafptr(k));
        EXECUTE IMMEDIATE 'begin select node into :node from '||tbtreeleafs||' where r=:r;end;'
         using out leaf,in leafptr(k);
         if leaf.moid=374 then
           top:=9;
         end if;

        --if an entry with the leaf.moid does not exists create a new entry in the leaves array
        if  not lptrs.exists(leaf.moid) then

            TbLeaves.Extend(1);
            TbLeaves(TbLeaves.count):=tbTreeLeaf2(leaf.moid,leaf.roid,leaf.ptrparentnode,leaf.ptrcurrentnode,leaf.ptrnextnode,
            leaf.ptrpreviousnode,leaf.counter,leafEntries2(leaf.tbtreeleafentries(1)));
            for i in 2..leaf.counter loop
                TbLeaves(TbLeaves.count).tbtreeleafentries.extend(1);
                TbLeaves(TbLeaves.count).tbtreeleafentries(i):=leaf.tbtreeleafentries(i);
            end loop;
            lptrs(leaf.moid):=TbLeaves.count;

            --dbms_output.put_line(leaf.moid||'    '||lptrs(leaf.moid)||'    '||tbLeaves.count);

        --otherwise append the current leaf to its previous ones (with the same moid)
        else
            --dbms_output.put_line(leaf.moid||'    '||lptrs(leaf.moid)||'    '||TO_CHAR(TbLeaves(lptrs(leaf.moid)).moid));
            --TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.extend(leaf.counter);
            for y in 1..leaf.counter loop
                 TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.extend(1);
                 TbLeaves(lptrs(leaf.moid)).tbtreeleafentries(TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.last):=leaf.tbtreeleafentries(y);
            end loop;
        end if;
    end loop;

    --dbms_output.put_line(TbLeaves(1).ptrcurrentnode);
    --having constructed a table of leaves where each leaf is a partial trajectory
    --we construct corresponding trajectories
    for e in TbLeaves.first..tbLeaves.last loop
        mp.traj_id:=TbLeaves(e).moid;
        if mp.traj_id=374 then
           top:=9;
         end if;
        for r in TbLeaves(e).tbtreeleafentries.first..TbLeaves(e).tbtreeleafentries.last loop

                --taytoxrona ftiaxne to moving point pou 8a peistrepseis
                --(an den to ftiakso edw 8a prepei meta na kasanadiatreksw thn domh)
                rectangle:=SDO_GEOMETRY(2003,
                                        SRID,
                                        NULL,
                                        SDO_ELEM_INFO_ARRAY(1,1003,3),
                SDO_ORDINATE_ARRAY(TbLeaves(e).tbtreeleafentries(r).MBB.MinPoint.x(1),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MinPoint.x(2),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MaxPoint.x(1),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MaxPoint.x(2))
                                        );
                --find the intersection of the MBB of the current entry with the given geometry
                ---intersection of input window MBB with segment's r MBB---
                intersection:= MDSYS.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
                --get the pointers of those MBBs that intersect the geomentry
                --and concurrently contain a part of the time period

                if (NOT (intersection is NULL)) AND
                            TBFUNCTIONS.overlaps1d(TbLeaves(e).tbtreeleafentries(r).MBB.Minpoint.x(3),
                                        TbLeaves(e).tbtreeleafentries(r).MBB.Maxpoint.x(3),
                                        tb,te) then

                    ump:=TBFUNCTIONS.leafentry_to_unit_moving_point(TbLeaves(e).tbtreeleafentries(r));

                    --CLIP ump inside the given range
                    temp := moving_point(moving_point_tab(ump),-22, null);--dbms_output.put_line('temp=' || temp.to_string());
                    segm := MDSYS.SDO_GEOMETRY (2002, SRID, NULL, sdo_elem_info_array (1, 2, 1),
                                                    sdo_ordinate_array (ump.m.xi, ump.m.yi, ump.m.xe, ump.m.ye));--UTILITIES.print_geometry(segm, 'Segment');

                    ---intersection of input window MBB with segment r(as line)---
                    intersection := mdsys.sdo_geom.sdo_intersection (segm, geom, tolerance); --UTILITIES.print_geometry(intersection, 'Intersection');
                    if ((intersection is not null) AND (intersection.sdo_ordinates.COUNT = 4) AND (segm.sdo_ordinates.COUNT = 4)) then
                        if (SDO_GEOM.SDO_LENGTH(segm, tolerance) > SDO_GEOM.SDO_LENGTH(intersection, tolerance)) then
                            --dbms_output.put_line(e);
                            --dbms_output.put_line(r);
                            tp1 := temp.get_time_point (intersection.sdo_ordinates(1), intersection.sdo_ordinates(2));--dbms_output.put_line('tp1=' || tp1.to_string());
                            tp2 := temp.get_time_point (intersection.sdo_ordinates(3), intersection.sdo_ordinates(4));--dbms_output.put_line('tp2=' || tp2.to_string());
                            --if tp1.get_abs_date() < tp1.get_abs_date() then
                                --make intersection a moving_point
                                --at_period checks timepoints to be tp1 > than tp2 and orders them if they are not
                                --also it checks if tp1 = tp2 but on a second precision. This means that if tp1=2008,1,1,1,1,1 and
                                --tp2 = 2008,1,1,1,1,1.58 then at_period returns null because it makes seconds FLOOR function.
                                temp2 := temp.at_period(tau_tll.d_period_sec(tp1, tp2));

                                if temp2 is not null then
                                  --clip that to query_window temporal range
                                  temp3 := temp2.at_period(tau_tll.d_period_sec(tp.b, tp.e));

                                  if temp3.u_tab is not null AND temp3.u_tab.COUNT = 1 then
                                      --dbms_output.put_line('temp2=' || temp2.to_string());
                                      ump := temp3.u_tab(temp3.u_tab.first);
                                      ---add clipped segment to array---
                                      mp.u_tab(mp.u_tab.last):=ump;
                                      mp.u_tab.extend(1);
                                  else--if temp2.u_tab is null or temp2.u_tab.COUNT <> 1
                                    --do not add any mpoint
                                    null;
                                  end if;
                                end if;
                        else--if segm length is less (better equal) to intersection length
                          ---add whole segment to array---
                          mp.u_tab(mp.u_tab.last):=ump;
                          mp.u_tab.extend(1);
                        end if;
                    else---no intersection with segment r (as line)---
                      --do not add any mpoint
                      null;
                    end if;
                end if;
        end loop;
        mp.u_tab.trim(1);--removes 1 element from the end
        if mp.u_tab.count>0 and mp.traj_id<>-1 then-- <>-22 not -1
        m.extend(1); m(m.last):=mp; end if;

        mp :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),-22, SRID);
    end loop;
    m.delete(1);--daletes element 1
    return m;
    /*
    exception when others then
      dbms_output.put_line(SQLCODE||'->'||TO_CHAR(SQLERRM));
      dbms_output.put_line('Error_Backtrace...' ||
        DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      return null;
      */
end range;


   Function ConstructMBB(Ent tbMovingObjectEntry) return tbMBB is
CMBB tbMBB;
Begin
    CMBB:=tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    For i in 1..3 Loop
        CMBB.MinPoint.x(i) := tbFunctions.tbMin(Ent.P1.x(i), Ent.P2.x(i));
        CMBB.MaxPoint.x(i) := tbFunctions.tbMax(Ent.P1.x(i), Ent.P2.x(i));
    End Loop;
    return CMBB;
End ConstructMBB;

Function Quadrant(Point tbPoint, CenterAxisPoint tbPoint) return integer is
Begin
    If Point.x(1) >= CenterAxisPoint.x(1) And Point.x(2) >= CenterAxisPoint.x(2) Then
        return 1;
    ElsIf Point.x(1) >= CenterAxisPoint.x(1) And Point.x(2) < CenterAxisPoint.x(2) Then
        return 2;
    ElsIf Point.x(1) < CenterAxisPoint.x(1) And Point.x(2) < CenterAxisPoint.x(2) Then
        return 3;
    Else
        return 4;
    End If;
End Quadrant;

Function Distance2D(P1 tbPoint, P2 tbPoint) return integer is
    -- Calculates the Squared Distance between two points
    DP number:=0;
    ReturnValue integer:=0;
BEGIN
    For i in 1..2 Loop
        DP := (P1.x(i) - P2.x(i));
        ReturnValue := ReturnValue + DP * DP;
    End Loop;
    return ReturnValue;
End Distance2D;

Function MinDist2D(Point tbPoint, MBB tbMBB) return integer is
    --Calculates the MinDist metric introduced by Rousopoulos et al
    tPoint tbPoint;
    ReturnValue integer:=0;
Begin
    tPoint:=tbPoint(tbX(-1,-1,-1));
    For i in 1..2 Loop
        If Point.x(i) < MBB.MinPoint.x(i) Then
            tPoint.x(i) := MBB.MinPoint.x(i);
        ElsIf Point.x(i) > MBB.MaxPoint.x(i) Then
            tPoint.x(i) := MBB.MaxPoint.x(i);
        Else
            tPoint.x(i) := Point.x(i);
        End If;
    End Loop;
    ReturnValue := Distance2D(tPoint, Point);
    return ReturnValue;
End MinDist2D;

Function ActualDist2D(Point tbPoint, P1 tbPoint, P2 tbPoint) return integer is
    --Calculates the actual distance of a point from a straight line
    U integer:=0;
    tDist integer:=0;
    PointX integer:=0;
    PointY integer:=0;
    X1 integer:=0;
    X2 integer:=0;
    Y1 integer:=0;
    Y2 integer:=0;
    ReturnValue integer:=0;
    Pu tbPoint;
Begin
    Pu:=tbPoint(tbX(-1,-1,-1));
    tDist := Distance2D(P1, P2);
    PointX := Point.x(1); PointY := Point.x(2);
    X1 := P1.x(1); X2 := P2.x(2); Y1 := P1.x(2); Y2 := P2.x(2);

    If tDist <> 0 Then
        U := ((PointX - X1) * (X2 - X1) + (PointY - Y1) * (Y2 - Y1)) / (tDist);

        If U <= 0 Then
            ReturnValue := Distance2D(Point, P1);
        ElsIf U >= 1 Then
            ReturnValue := Distance2D(Point, P2);
        Else
            Pu.x(0) := X1 + U * (X2 - X1);
            Pu.x(1) := Y1 + U * (Y2 - Y1);
            ReturnValue := Distance2D(Point, Pu);
        End If;
    Else
        ReturnValue := Distance2D(Point, P1);
    End If;

    return ReturnValue;
End ActualDist2D;

Function Intersects2D(Line1 tbMovingObjectEntry, Line2 tbMovingObjectEntry) return Boolean is
    MBB1  tbMBB;
    MBB2  tbMBB;
    UDenom  integer:=0;
    U1   integer:=0;
    U2   integer:=0;
    X1   integer:=0;
    X2   integer:=0;
    Y1 integer:=0;
    Y2 integer:=0;
    X3 integer:=0;
    X4 integer:=0;
    Y3 integer:=0;
    Y4 integer:=0;
Begin
    MBB1:=tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    MBB2:=tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    MBB1 := ConstructMBB(Line1); MBB2 := ConstructMBB(Line2);
    If Not tbFunctions.Overlapss(MBB1, MBB2, 2) Then return false;end if;

    X1 := Line1.P1.x(1); Y1 := Line1.P1.x(2);
    X2 := Line1.P2.x(1); Y2 := Line1.P2.x(2);
    X3 := Line2.P1.x(1); Y3 := Line2.P1.x(2);
    X4 := Line2.P2.x(1); Y4 := Line2.P2.x(2);

    UDenom := (Y4 - Y3) * (X2 - X1) - (X4 - X3) * (Y2 - Y1);
    If UDenom <> 0 Then
        U1 := ((X4 - X3) * (Y1 - Y3) - (Y4 - Y3) * (X1 - X3)) / UDenom;
        U2 := ((X2 - X1) * (Y1 - Y3) - (Y2 - Y1) * (X1 - X3)) / UDenom;
        If U1 >= 0 And U1 <= 1 And U2 >= 0 And U2 <= 1 Then
            return true;
        else
            return false;
        End If;
    else
      return false;
    End If;
End Intersects2D;

Procedure InterpolateStart(Ent in out tbMovingObjectEntry, T integer) is
    a  integer:=0;
Begin
    If Ent.P1.x(2) = T Then
        return;
    Else
        If (Ent.P2.x(2) - Ent.P1.x(2)) <> 0 Then
            a := (T - Ent.P1.x(2)) / (Ent.P2.x(2) - Ent.P1.x(2));
            For i in 1..2 Loop

                Ent.P1.x(i) := Ent.P1.x(i) + a * (Ent.P2.x(i) - Ent.P1.x(i));
            End Loop;
            Ent.P1.x(2) := T;
        Else
            return;
        End If;
    End If;
End InterpolateStart;

Procedure InterpolateEnd(Ent in out tbMovingObjectEntry, T Integer) is
a Integer:=0;
Begin
    If Ent.P2.x(2) = T Then
        return;
    Else
        If (Ent.P2.x(2) - Ent.P1.x(2)) <> 0 Then
            a := (T - Ent.P1.x(2)) / (Ent.P2.x(2) - Ent.P1.x(2));
            For i in 1..2 Loop
                Ent.P2.x(i) := Ent.P1.x(i) + a * (Ent.P2.x(i) - Ent.P1.x(i));
            End Loop;
            Ent.P2.x(2) := T;
        Else
            Return;
        End If;
    End If;
End InterpolateEnd;


Function MinDistLine2D(Line tbMovingObjectEntry, MBB tbMBB) return integer is

    lMBB tbMBB;
    cLine tbMovingObjectEntry;
    ReturnValue integer:=0;
    Type CP is varray(5) of tbPoint;
    CornerPoint CP;
    tLine tbMovingObjectEntry;
    CenterPoint tbPoint;
    Qs Integer:=0;
    QE Integer:=0;
Begin
    lMBB:=tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    cLine:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    tLine:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    CenterPoint:=tbPoint(tbX(-1,-1,-1));
    CornerPoint:=CP(tbPoint(tbX(-1,-1,-1)));
    If Distance2D(Line.P1, Line.P2) < 0.00001 Then
        ReturnValue := MinDist2D(Line.P1, MBB);
    Else
        cLine := Line;
        If cLine.P1.x(2) < MBB.MinPoint.x(2) Then
            InterpolateStart(cLine, MBB.MinPoint.x(2));
        End If;
        If cLine.P2.x(2) > MBB.MaxPoint.x(2) Then
            InterpolateEnd (cLine, MBB.MaxPoint.x(2));
        End If;

        lMBB := ConstructMBB(cLine);

        If tbFunctions.Includes(MBB, lMBB, 2) Then
            ReturnValue := 0;
            Return ReturnValue;
        End If;

        --CornerPoint.extend(1);
        CornerPoint(1) := MBB.MaxPoint;
        CornerPoint.extend(1);
        CornerPoint(2) := MBB.MaxPoint; CornerPoint(2).x(2) := MBB.MinPoint.x(2);
        CornerPoint.extend(1);
        CornerPoint(3) := MBB.MinPoint;CornerPoint.extend(1);
        CornerPoint(4) := MBB.MinPoint; CornerPoint(4).x(2) := MBB.MaxPoint.x(2);
        CornerPoint.extend(1);
        CornerPoint(5) := CornerPoint(1);


        If tbFunctions.Overlapss(lMBB, MBB, 2) Then
            tLine.P1 := CornerPoint(1); tLine.P2 := CornerPoint(2);
            If Intersects2D(cLine, tLine) Then return ReturnValue;End if;
            tLine.P1 := CornerPoint(1); tLine.P2 := CornerPoint(2);
            If Intersects2D(cLine, tLine) Then return ReturnValue;End if;
            tLine.P1 := CornerPoint(2); tLine.P2 := CornerPoint(3);
            If Intersects2D(cLine, tLine) Then return ReturnValue;End if;
            tLine.P1 := CornerPoint(3); tLine.P2 := CornerPoint(1);
            If Intersects2D(cLine, tLine) Then return ReturnValue;End if;
        End If;

        --Calculates the MinDist metric introduced by Rousopoulos et al


        For i in 1..2 Loop
            CenterPoint.x(i) := (MBB.MinPoint.x(i) + MBB.MaxPoint.x(i)) / 2;
        End Loop;
        Qs := Quadrant(cLine.P1, CenterPoint);
        QE := Quadrant(cLine.P2, CenterPoint);

        If Qs = QE Then
            ReturnValue := ActualDist2D(CornerPoint(Qs), cLine.P1, cLine.P2);
            ReturnValue := tbFunctions.tbMin(ReturnValue, MinDist2D(cLine.P1, MBB));
            ReturnValue := tbFunctions.tbMin(ReturnValue, MinDist2D(cLine.P2, MBB));
        ElsIf Abs(Qs - QE) = 2 Then
            ReturnValue := ActualDist2D(CornerPoint(Qs + 1), cLine.P1, cLine.P2);
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(QE + 1), cLine.P1, cLine.P2));
        Else
            ReturnValue := ActualDist2D(CornerPoint(Qs), cLine.P1, cLine.P2);
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(QE), cLine.P1, cLine.P2));
            ReturnValue := tbFunctions.tbMin(ReturnValue, MinDist2D(cLine.P1, MBB));
            ReturnValue := tbFunctions.tbMin(ReturnValue, MinDist2D(cLine.P2, MBB));
        End If;

    End If;
    return ReturnValue;

End MinDistLine2D;

Function InterpolatePoint(Ent tbMovingObjectEntry, T Number) return tbPoint is
    a  number;
    ReturnValue tbPoint:=tbPoint(tbX(-1,-1,-1));
BEGIN
    a := (T - Ent.P1.x(3)) / (Ent.P2.x(3) - Ent.P1.x(3));
    For i in 1..2 Loop
        ReturnValue.x(i) := Ent.P1.x(i) + a * (Ent.P2.x(i) - Ent.P1.x(i));
    End Loop;
    ReturnValue.x(3) := T;
    return ReturnValue;
End InterpolatePoint;

Function ActualLineDist2D(Line1 tbMovingObjectEntry, Line2 tbMovingObjectEntry) return number is

    --Calculates the minimum horizontal distance between 2 3d lines
    tLine1 tbMovingObjectEntry;
    tLine2 tbMovingObjectEntry;
    T1 number;
    T2 number;
    Ti number;
    a number;
    b number;
    c number;
    ReturnValue number;
BEGIN
    tLine1 := Line1;
    tLine2 := Line2;


    T1 := tbFunctions.tbMax(tLine1.P1.x(2), tLine2.P1.x(2));
    InterpolateStart(tLine1, T1);
    InterpolateStart(tLine2, T1);
    T2 := tbFunctions.tbMin(tLine1.P2.x(2), tLine2.P2.x(2));
    InterpolateEnd(tLine1, T2);
    InterpolateEnd(tLine2, T2);


    a := (tLine2.P2.x(1) - tLine2.P1.x(1) - tLine1.P2.x(1) + tLine1.P1.x(1));
    b := (tLine2.P2.x(2) - tLine2.P1.x(2) - tLine1.P2.x(2) + tLine1.P1.x(2));
    c := a * (tLine2.P2.x(1) - tLine2.P1.x(1) - tLine1.P2.x(1) + tLine1.P1.x(1)) +
        b * (tLine2.P2.x(2) - tLine2.P1.x(2) - tLine1.P2.x(2) + tLine1.P1.x(2));

    If c <> 0 Then
        Ti := T1 + (T2 - T1) * (a * (tLine1.P1.x(1) - tLine2.P1.x(1)) + b * (tLine1.P1.x(2) - tLine2.P1.x(2))) / c;

        If T2 <= Ti Then
            ReturnValue := Distance2D(tLine1.P2, tLine2.P2);
        ElsIf Ti <= T1 Then
            ReturnValue := Distance2D(tLine1.P1, tLine2.P1);
        ElsIf T1 < Ti And Ti < T2 Then
            ReturnValue := Distance2D(InterpolatePoint(tLine1, Ti),
                                          InterpolatePoint(tLine2, Ti));
        End If;
    Else
        ReturnValue := tbFunctions.tbMin(Distance2D(tLine1.P1, tLine2.P1),
                               Distance2D(tLine1.P2, tLine2.P2));
    End If;
    return ReturnValue;

End ActualLineDist2D;

Function GetTrajectoryPart(Trajectory tbMovingObjectEntries, iMBB tbMBB, traj_size integer) return tbMovingObjectEntries is
    -- Algorithm GetTrajectoryPart retrieves the part of the Trajectory
    -- temporaly contained inside the temporal component of iMBR
    Ent tbMovingObjectEntry;
    MBB tbMBB;
    i1 Integer:=0;
    i2 Integer:=0;
    hGetTrajectoryPart tbMovingObjectEntries:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));

BEGIN
    For i in 1..traj_size Loop
        Ent := Trajectory(i);
        MBB := ConstructMBB(Ent);
        If tbFunctions.Overlapss(MBB, iMBB, 1) Then
            If i1 = 0 Then
                i1 := i;
                i2 := i1;
            Else
                i2 := i;
            End If;
        End If;
    End Loop;

    --ReDim hGetTrajectoryPart(1 To i2 - i1 + 1)
    hGetTrajectoryPart.extend(i2 - i1);
    if i2=0 then return null;end if;
    --dbms_output.put_line('i1='||i1||'i2='||i2);
    For i in i1..i2 Loop
        hGetTrajectoryPart(1 + i - i1) := Trajectory(i);
    End Loop;
    return hGetTrajectoryPart;
End GetTrajectoryPart;


Function MinDistTrajectory2D(Trajectory tbMovingObjectEntries, MBB tbMBB, traj_size integer) return number is

    lMBB tbMBB;
    Line tbMovingObjectEntry:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    vLine tbMovingObjectEntry:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    tLine tbMovingObjectEntry:=tbMovingObjectEntry(-1,tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    Type Points is table of tbPoint;
    CornerPoint Points:=Points(tbPoint(tbX(-1,-1,-1)));
    CenterPoint tbPoint:=tbPoint(tbX(-1,-1,-1));
    Qs Integer;
    QE Integer;
    Ds number:=0;
    De number;
    ReturnValue number;

BEGIN
    ReturnValue:=1E+36;


    --Dim CornerPoint(4) As tbPoint
    CornerPoint(1) := MBB.MaxPoint;
    CornerPoint.extend(1);
    CornerPoint(2) := MBB.MaxPoint; CornerPoint(2).x(2) := MBB.MinPoint.x(2);
    CornerPoint.extend(1);
    CornerPoint(3) := MBB.MinPoint;
    CornerPoint.extend(1);
    CornerPoint(4) := MBB.MinPoint; CornerPoint(4).x(2) := MBB.MaxPoint.x(2);
    CornerPoint.extend(1);
    CornerPoint(5) := CornerPoint(1);


    For i in 1..2 Loop
        CenterPoint.x(i) := (MBB.MinPoint.x(i) + MBB.MaxPoint.x(i)) / 2;
    End Loop;

    For i in 1..traj_size Loop
        vLine := Trajectory(i);
        Line := Trajectory(i);
        If Not (vLine.P1.x(3) >= MBB.MinPoint.x(3) And vLine.P2.x(3) <= MBB.MaxPoint.x(3)) Then
            InterpolateStart(Line, tbFunctions.tbMax(Line.P1.x(2), MBB.MinPoint.x(2)));
            InterpolateEnd (Line, tbFunctions.tbMin(Line.P2.x(2), MBB.MaxPoint.x(2)));
        End If;

        lMBB := ConstructMBB(Line);

        If tbFunctions.Includes(MBB, lMBB, 2) Then
            ReturnValue := 0;
            Return ReturnValue;
        End If;


        If tbFunctions.Overlapss(lMBB, MBB, 2) Then
            tLine.P1 := CornerPoint(1); tLine.P2 := CornerPoint(2);
            If Intersects2D(Line, tLine) Then
                ReturnValue := 0;
                Return ReturnValue;
            End If;
            tLine.P1 := CornerPoint(2); tLine.P2 := CornerPoint(3);
            If Intersects2D(Line, tLine) Then
                ReturnValue := 0;
                Return ReturnValue;
            End If;
            tLine.P1 := CornerPoint(3); tLine.P2 := CornerPoint(4);
            If Intersects2D(Line, tLine) Then
                ReturnValue := 0;
                Return ReturnValue;
            End If;
            tLine.P1 := CornerPoint(4); tLine.P2 := CornerPoint(5);
            If Intersects2D(Line, tLine) Then
                ReturnValue := 0;
                Return ReturnValue;
            End If;
        End If;

        If Ds = 0 Then
            Qs := Quadrant(Line.P1, CenterPoint);
            Ds := MinDist2D(Line.P1, MBB);
        Else
            Qs := QE;
            Ds := De;
        End If;

        QE := Quadrant(Line.P2, CenterPoint);
        De := MinDist2D(Line.P2, MBB);

        If Qs = QE Then
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(Qs), Line.P1, Line.P2));
            ReturnValue := tbFunctions.tbMin(ReturnValue, Ds);
            ReturnValue := tbFunctions.tbMin(ReturnValue, De);
        ElsIf Abs(Qs - QE) = 2 Then
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(Qs + 1), Line.P1, Line.P2));
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(QE + 1), Line.P1, Line.P2));
        else
            --dbms_output.put_line('Qs='||Qs);
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(Qs), Line.P1, Line.P2));
            ReturnValue := tbFunctions.tbMin(ReturnValue, ActualDist2D(CornerPoint(QE), Line.P1, Line.P2));
            ReturnValue := tbFunctions.tbMin(ReturnValue, Ds);
            ReturnValue := tbFunctions.tbMin(ReturnValue, De);
        End If;
    End Loop;
    Return ReturnValue;
End MinDistTrajectory2D;


Function IncrPointNN(QueryPoint tbMovingObjectEntry, k integer, leaftab varchar2, nodetab varchar2) return tbMovingObjectEntries is
    Queue PriorityQueue;
    Element PriorityQueueNode:=PriorityQueueNode(-1,null,-1,null,null,'x',-1,-1,-1,-1,null);
    Type ExaminedIDs is table of integer index by pls_integer;
    EIDs ExaminedIDs;
    RCollection tbMovingObjectEntries:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));
    QueryMBB tbMBB;
    rEntry tbTreeNodeEntry:=tbTreenodeEntry(null,tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))));
    Dist number;
    tVar tbTreeNode;
    tNode  tbTreeNode;
    tLeaf  tbTreeLeaf;
    tEnt tbMovingObjectEntry;
    QueueEntry PriorityQueueNode;
    TempNode tbTreeNode;
    TempLeaf tbTreeLeaf;
    TempRColEntry tbMovingObjectEntry;

BEGIN
    Queue:=Hermes.PriorityQueue(null,0,0,0);
    Queue.Initialize;
    QueryMBB := ConstructMBB(QueryPoint);

    --tVar = ReadNode(ptrRoot)
    tVar:=tbFunctions.readnode(0,nodetab);
    rEntry.MBB := tbFunctions.NCoveringMBB(tVar);
    rEntry.ptr := tVar.ptrCurrentNode;
    Dist := MinDistLine2D(QueryPoint, rEntry.MBB);
    Element:=PriorityQueueNode(rEntry.Ptr, rEntry.MBB,-1,null,null,'tbTreeNodeEntry',Dist,-1,-1,-1,null);
    Queue.EnQueue(Element); --Queue, rEntry, Dist

    While Queue.Counter >0 Loop

        Element := Queue.DeQueue;
        If Element.EType='x' or Element is null Then
            return RCollection;
        End If;

        If Element.EType = 'tbMovingObjectEntry' Then
            If not EIDs.exists(Element.Id) then
                --RCollection.Add Element(0), CStr(Element(0).Id)
                TempRColEntry:=tbMovingObjectEntry(Element.Id,Element.P1,Element.P2);
                --if RCollection.count>1 then RCollection.extend(1);End if;
                RCollection.extend(1);
                RCollection(RCollection.last):=TempRColEntry;
                EIDs(Element.Id):=1;
                --k+1 giati perilambanetai h arxikopoihsh tou antikeimenou opote h prwth 8esh tou collection exei dummy timh
                If RCollection.Count >= k+1 Then

                    RCollection.delete(1);--diagrafh ths dummy arxikopoihshs
                    return RCollection;
                End If;
            End If;
        Else
            if element.ptr>=10000 then
                                    --dbms_output.put_line(Element.Ptr);
                --tVar = ReadNode(Element(0).ptr)
                tLeaf:=tbFunctions.readleafnode(Element.Ptr,leaftab);
                --If TypeName(tVar) = "tbTreeLeaf" Then
                --tLeaf = tVar
                For i in 1..tLeaf.Counter Loop
                    If tbFunctions.Overlapss(QueryMBB, tLeaf.tbTreeLeafEntries(i).MBB, 1) Then
                        tEnt := tbFunctions.ConstructEntry(tLeaf.tbTreeLeafEntries(i), tLeaf.MOID);
                        Dist := ActualLineDist2D(QueryPoint, tEnt);
                        Element:=PriorityQueueNode(-1,null,tEnt.Id,tEnt.P1,tEnt.P2,'tbMovingObjectEntry',Dist,-1,-1,-1,null);
                        If Queue.Counter=0 then Queue.Initialize; end if;
                        Queue.EnQueue(Element);--tEnt, Dist
                    End If;
                End Loop;
            Elsif Element.EType = 'tbTreeNodeEntry' then

                tNode := tbFunctions.readnode(Element.Ptr,nodetab);
                --dbms_output.put_line(tNode.PtrCurrentNode);
                For i in 1..tNode.Counter Loop
                    If tbFunctions.Overlapss(QueryMBB, tNode.tbTreeNodeEntries(i).MBB, 1) Then
                        Dist := MinDistLine2D(QueryPoint,tNode.tbTreeNodeEntries(i).MBB);
                        Element:=PriorityQueueNode(tNode.tbTreeNodeEntries(i).Ptr,tNode.tbTreeNodeEntries(i).MBB,-1,null,null,'tbTreeNodeEntry',Dist,-1,-1,-1,null);
                        If Queue.counter=0 then Queue.Initialize; end if;
                        queue.enqueue(element);-- Queue, tNode.Entries(i), Dist
                        --dbms_output.put_line(Element.Ptr);

                    End If;
                End Loop;
            End If;
        End If;
    End Loop;
    RCollection.delete(1);
    Return RCollection;

End IncrPointNN;


Function IncrTrajectoryNN(QueryTrajectory hermes.moving_point, k number, leaftab varchar2, nodetab varchar2) Return tbMovingObjectEntries is

    mQueryTrajectory tbMovingObjectEntries:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));
    j1 number;
    j1Start number;
    Queue PriorityQueue;
    Type ExaminedIDs is table of integer index by pls_integer;
    EIDs ExaminedIDs;
    Element PriorityQueueNode:=PriorityQueueNode(-1,null,-1,null,null,'x',-1,-1,-1,-1,null);
    RCollection tbMovingObjectEntries:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));
    --RCollection  mp_Array:=mp_Array(moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(null,null),tau_tll.D_period_sec(null,null),
        --unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1')),-22));
    QueryMBB  tbMBB:=tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1)));
    QueryMovingPoint tbMovingObjectEntry;
    rEntry  tbTreeNodeEntry:=tbTreenodeEntry(null,tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))));
    Dist  number;
    hTrajectory  tbMovingObjectEntries:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));
    tVar  tbTreeNode;
    tNode  tbTreeNode;
    tLeaf  tbTreeLeaf;
    tEnt  tbMovingObjectEntry;
    tTrajectory tbMovingObjectEntries;--:=tbMovingObjectEntries(tbMovingObjectEntry(-1,null,null));
    tMBB  tbMBB;
    TempRColEntry tbMovingObjectEntry;
    u_tab_counter integer;
    counter integer;--a general counter, used on demand
    UMV unit_moving_point;
    UF unit_function;
    t tau_tll.d_period_sec;
    tbPoint1 tbPoint;
    tbPoint2 tbPoint;
BEGIN

    u_tab_counter:=QueryTrajectory.u_tab.count;
    Queue:=Hermes.PriorityQueue(null,0,0,0);
    Queue.Initialize;
    mQueryTrajectory.extend(u_tab_counter-1);

    for i in 1..u_tab_counter loop
        umv:=QueryTrajectory.u_tab(i);
        uf:=umv.m;
        t:=umv.p;
        tbpoint1:=tbPoint(tbX(uf.xi,uf.yi,tau_tll.D_timepoint_Sec_package.get_abs_date(t.b.m_y,t.b.m_m,t.b.m_d,t.b.m_h,t.b.m_min,t.b.m_sec)));
        tbPoint2:=tbPoint(tbX(uf.xe,uf.ye,tau_tll.D_timepoint_Sec_package.get_abs_date(t.e.m_y,t.e.m_m,t.e.m_d,t.e.m_h,t.e.m_min,t.e.m_sec)));
        mQueryTrajectory(i):=tbMovingObjectEntry(QueryTrajectory.traj_id,tbpoint1,tbpoint2);
    end loop;


    tVar := tbFunctions.ReadNode(0,nodetab);
    rEntry.MBB := tbFunctions.NCoveringMBB(tVar);
    rEntry.ptr := tVar.ptrCurrentNode;
    tTrajectory := GetTrajectoryPart(mQueryTrajectory, rEntry.MBB,u_tab_counter);
    if tTrajectory is null then return null; End if;
    counter:=tTrajectory.count;
    Dist := MinDistTrajectory2D(tTrajectory, rEntry.MBB,counter);
    --EnQueue Queue, rEntry, Dist, tTrajectory
    Element:=PriorityQueueNode(rEntry.Ptr, rEntry.MBB,-1,null,null,'tbTreeNodeEntry',Dist,-1,-1,-1,tTrajectory);
    Queue.Enqueue(Element);

    While Queue.Counter > 0 Loop
        Element := Queue.DeQueue;

        If Element.EType='x' or Element is null Then
            return RCollection;
        End If;

        If Element.EType = 'tbMovingObjectEntry' Then
            If not EIDs.exists(Element.Id) then
                --RCollection.Add Element(0), CStr(Element(0).Id)
                TempRColEntry:=tbMovingObjectEntry(Element.Id,Element.P1,Element.P2);
                --if RCollection.count>1 then RCollection.extend(1);End if;
                RCollection.extend(1);
                RCollection(RCollection.last):=TempRColEntry;
                EIDs(Element.Id):=1;
                --k+1 giati perilambanetai h arxikopoihsh tou antikeimenou opote h prwth 8esh tou collection exei dummy timh
                If RCollection.Count >= k+1 Then

                    RCollection.delete(1);--diagrafh ths dummy arxikopoihshs
                    return RCollection;
                End If;
            End If;
        Else
           -- tVar := ReadNode(Element(0).ptr)
            tMBB := Element.MBB;
            tTrajectory := Element.Trajectory;
            counter:=tTrajectory.count;
            If Element.Ptr>=10000 Then
                j1 := 1;
                tLeaf :=tbFunctions.readleafnode(Element.Ptr,leaftab);
                <<loop1>>
                For i in 1..tLeaf.Counter Loop

                    tEnt := tbFunctions.ConstructEntry(tLeaf.tbtreeleafEntries(i), tLeaf.MOId);

                    <<loop2>>
                    Loop

                        Exit loop2 when tTrajectory(j1).P2.x(3) >= tEnt.P1.x(3);
                        j1 := j1 + 1;
                        Exit loop1 when j1 > counter;
                    End Loop;

                    j1Start := j1;

                    <<loop3>>
                    Loop
                        Exit loop3 when j1 > counter;
                        QueryMovingPoint := tTrajectory(j1);
                        Exit loop3 when QueryMovingPoint.P1.x(3) > tLeaf.tbtreeleafEntries(i).MBB.MaxPoint.x(3);

                        Dist := ActualLineDist2D(QueryMovingPoint, tEnt);
                        --EnQueue Queue, tEnt, Dist
                        Element:=PriorityQueueNode(-1,null,tEnt.Id,tEnt.P1,tEnt.P2,'tbMovingObjectEntry',Dist,-1,-1,-1,null);
                        If Queue.Counter=0 then Queue.Initialize; end if;
                        Queue.EnQueue(Element);--tEnt, Dist
                        j1 := j1 + 1;

                    End Loop;
                    j1 := j1Start;
                End Loop;
            Else
                QueryMBB.MinPoint.x(3) := tTrajectory(1).P1.x(3);
                querymbb.maxpoint.x(3) := ttrajectory(counter).p2.x(3);
                tNode := tbFunctions.readnode(Element.ptr,nodetab);
                For i in 1..tNode.Counter Loop
                    If tbFunctions.Overlapss(QueryMBB, tNode.tbtreenodeEntries(i).MBB, 1) Then
                        hTrajectory := GetTrajectoryPart(tTrajectory, tNode.tbtreenodeEntries(i).MBB,counter);
                        Dist := MinDistTrajectory2D(hTrajectory, tNode.tbtreenodeEntries(i).MBB,hTrajectory.count);
                        --EnQueue Queue, tNode.Entries(i), Dist, hTrajectory
                        Element:=PriorityQueueNode(tNode.tbTreeNodeEntries(i).Ptr,tNode.tbTreeNodeEntries(i).MBB,-1,null,null,'tbTreeNodeEntry',Dist,-1,-1,-1,hTrajectory);
                        If Queue.counter=0 then Queue.Initialize; end if;
                        Queue.EnQueue(Element);-- Queue, tNode.Entries(i), Dist
                    End If;
                End Loop;
            End If;
        End If;
    End Loop;
    RCollection.delete(1);
    Return RCollection;
End IncrTrajectoryNN;

function tbMovObjEntrs2MovPoints(moentries tbMovingObjectEntries,srid integer) return mp_array
  pipelined is
  old_id integer:=-1;
  cur_traj moving_point;
  inputentries tbmovingobjectentries;
  begintime tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
  endtime tau_tll.d_timepoint_sec:=tau_tll.d_timepoint_sec(1,1,1,1,1,1);
  /*
  This function takes the result of incrpointnn or incrtrajectorynn function
  and transform it to moving_points which are returned by pipe
  */
begin
  --sort input on traj_ids
  select tbmovingobjectentry(t.id,t.p1,t.p2)
  bulk collect into inputentries
  from table(moentries) t
  order by t.id;
  --dbms_output.put_line(inputentries.count);
  --for every input row
  for i in inputentries.first..inputentries.last loop
    --if old_id<>cur_id=>new traj
    if (old_id<>inputentries(i).id) then
      --store cur_traj if not null
      if (cur_traj is not null) then
        pipe row(cur_traj);
      end if;
      --create new cur_traj
      begintime.set_Abs_Date(inputentries(i).p1.x(3));
      endtime.set_Abs_Date(inputentries(i).p2.x(3));
      cur_traj:=moving_point(moving_point_tab(unit_moving_point(tau_tll.d_period_sec(begintime,endtime),
        unit_function(inputentries(i).p1.x(1),inputentries(i).p1.x(2),inputentries(i).p2.x(1),inputentries(i).p2.x(2),null,null,null,null,null,'PLNML_1'))),
        inputentries(i).id,srid);
    --else =>same traj
    else
      --add tbMoObjEntry to cur_traj
      begintime.set_Abs_Date(inputentries(i).p1.x(3));
      endtime.set_Abs_Date(inputentries(i).p2.x(3));
      cur_traj.u_tab.extend;
      cur_traj.u_tab(cur_traj.u_tab.last):=unit_moving_point(tau_tll.d_period_sec(begintime,endtime),
        unit_function(inputentries(i).p1.x(1),inputentries(i).p1.x(2),inputentries(i).p2.x(1),inputentries(i).p2.x(2),null,null,null,null,null,'PLNML_1'));
    end if;
  end loop;
  if (cur_traj is not null) then
    pipe row(cur_traj);
  end if;
  return;
end tbMovObjEntrs2MovPoints;

-- same as tb_mp_in_Spatiotemp_Wind but returns an array of SDO_GEOMETRIES to be used in mapviewer
PROCEDURE mv_query_window(geom MDSYS.SDO_GEOMETRY,tp tau_tll.D_period_sec, leaftab varchar2, nodetab varchar2) is
   leaf tbtreeleaf;
   node tbtreenode;
   lnode tbtreeleaf;
   Type TbTreeLeavesArray is table of tbTreeLeaf2;
   TempEntry tbtreeleafEntry;
   nodeid integer;
   ump hermes.unit_moving_point;
   h integer;
   t number;
   Type ptr is table of integer;
   Type lptr is table of integer index by pls_integer;
   nodeptr ptr;
   leafptr ptr;
   ptrs ptr;
   templeafid number :=0;
   p1 tau_tll.D_period_sec;
   p2 tau_tll.D_period_sec;
   m_y integer:=2011;
   m_m integer:=1;
   m_d integer:=25;
   m_h integer:=12;
   m_min integer:=50;
   m_sec integer:=50;
   tp1 tau_tll.D_Timepoint_Sec;
   tp2 tau_tll.D_Timepoint_Sec;
   rectangle MDSYS.SDO_GEOMETRY;
   tolerance NUMBER:= 0.001;
   m Geom_tbl;
   mp hermes.moving_point;
   tbLeaves TbTreeLeavesArray;
   intersection MDSYS.SDO_GEOMETRY;
   timepointcount pls_integer :=0;
   lptrs lptr;
   tb number;
   te number;
   stmt varchar2(1000);

   begin
   delete from mv_tbl;
   --lptr:= ptrstoleaves(0);
   TbLeaves:=TbTreeLeavesArray(tbTreeLeaf2(-1,'x',-1,-1,-1,-1,-1,leafEntries2(tbTreeLeafEntry(tbMBB(tbPoint(tbX(-1,-1,-1)),tbPoint(tbX(-1,-1,-1))),-1))));
   m :=Geom_tbl(SDO_GEOMETRY(null,null,null,null,null));
   mp :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),-22, null);
    tb:=tp.b.get_abs_date;
    te:=tp.e.get_abs_Date;
    nodeptr:= ptr(0);
    leafptr:= ptr(0);
    ptrs:= ptr(0);
    --lptrs(0):=0;
    --acquire the height of the tree (the value is stored in the moving objects table
    --with an ID of -1 so as to be distinguished from actual moving objects)
    --select ptrlastleaf into h from movingobjects where id=-1;
    /*use a pseudo stack datatype like stbtree or a hier query  */
    stmt := 'begin
      select max(level)--level pseudocolumn
      into :h
      from '||nodetab||' l
      start with l.r=0 --root
      connect by nocycle prior l.r=l.node.ptrparentnode ;--parent child relation, nocycle as root.parent=root  for us
      end;';
    execute immediate stmt using out h;
    begin
    --descend the tree until you reach the lowest level before leaf level
    for j in 1..h loop
    --for each node that you read.....
    for w in nodeptr.first..nodeptr.last loop

        EXECUTE IMMEDIATE 'begin select node into :node from '||nodetab||' where r=:r;end;' using out node,in nodeptr(w);
            --for each entry of the currently read node
            for i in 1..node.counter loop
                --tranform mBB to rectangular geometry so as to use the sdo_intersection function
                rectangle:=SDO_GEOMETRY(2003,
                                        NULL,
                                        NULL,
                                        SDO_ELEM_INFO_ARRAY(1,1003,3),
                SDO_ORDINATE_ARRAY(node.tbtreenodeentries(i).MBB.MinPoint.x(1),node.tbtreenodeentries(i).MBB.MinPoint.x(2), node.tbtreenodeentries(i).MBB.MaxPoint.x(1),node.tbtreenodeentries(i).MBB.MaxPoint.x(2))
                                        );
                --find the intersection of the MBB of the current entry with the given geometry
                intersection:= MDSYS.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
                --get the pointers of those MBBs that intersect the geomentry and concurrently contain a part of the time period
                if (NOT (intersection is NULL)) AND
                            overlaps1d(node.tbtreenodeentries(i).MBB.Minpoint.x(3),node.tbtreenodeentries(i).MBB.Maxpoint.x(3),tb,te) then
                    --if the entry's pointer to the child node is >10000 then it points to a leaf so place the pointer in the leafpointers' list
                    if (node.tbtreenodeentries(i).ptr>=10000) then

                        --sort leaf pointers as you add them
                        if leafptr(leafptr.last)=0 then leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
                        else

                          if leafptr(leafptr.last)<node.tbtreenodeentries(i).ptr then
                            leafptr.extend(1);
                            leafptr(leafptr.last):= node.tbtreenodeentries(i).ptr;
                          elsif  leafptr(leafptr.last)>node.tbtreenodeentries(i).ptr then
                            templeafid:=leafptr(leafptr.last);
                            leafptr(leafptr.last):=node.tbtreenodeentries(i).ptr;
                            leafptr.extend(1);
                            leafptr(leafptr.last):=templeafid;
                          end if;
                        end if;


                    --otherwise place the pointer to the internal node's list
                    --(these pointers will be used in the next iteration to choose which part of the tree to descend)
                    --see below (nodeptr:=ptrs)
                    else
                    if ptrs.count<>1 then ptrs.extend(1); end if;
                    ptrs(ptrs.last):=node.tbtreenodeentries(i).ptr;

                    end if;
                end if;
            end loop;
    end loop;
    nodeptr:=ptrs;
    --dbms_output.put_line(nodeptr.count||' '||leafptr.count);
    end loop;

    --retreive each leaf in the leaf pointers list
    for k in leafptr.first..leafptr.last loop
       --dbms_output.put_line(leafptr(k));
        EXECUTE IMMEDIATE 'begin select node into :node from '||leaftab||' where r=:r;end;' using out leaf,in leafptr(k);

        --if an entry with the leaf.moid does not exists create a new entry in the leaves array
        if  not lptrs.exists(leaf.moid) then

            TbLeaves.Extend(1);
            TbLeaves(TbLeaves.count):=tbTreeLeaf2(leaf.moid,leaf.roid,leaf.ptrparentnode,leaf.ptrcurrentnode,leaf.ptrnextnode,
            leaf.ptrpreviousnode,leaf.counter,leafEntries2(leaf.tbtreeleafentries(1)));
            for i in 2..leaf.counter loop
                TbLeaves(TbLeaves.count).tbtreeleafentries.extend(1);
                TbLeaves(TbLeaves.count).tbtreeleafentries(i):=leaf.tbtreeleafentries(i);
            end loop;
            lptrs(leaf.moid):=TbLeaves.count;

            --dbms_output.put_line(leaf.moid||'    '||lptrs(leaf.moid)||'    '||tbLeaves.count);

        --otherwise append the current leaf to its previous ones (with the same moid)
        else
            --dbms_output.put_line(leaf.moid||'    '||lptrs(leaf.moid)||'    '||TO_CHAR(TbLeaves(lptrs(leaf.moid)).moid));
            --TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.extend(leaf.counter);
            for y in 1..leaf.counter loop
                 TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.extend(1);
                 TbLeaves(lptrs(leaf.moid)).tbtreeleafentries(TbLeaves(lptrs(leaf.moid)).tbtreeleafentries.last):=leaf.tbtreeleafentries(y);
            end loop;
        end if;
    end loop;

    --dbms_output.put_line(TbLeaves(1).ptrcurrentnode);
    --having constructed a table of leaves where each leaf is a partial trajectory
    --we construct corresponding trajectories
    for e in TbLeaves.first..tbLeaves.last loop
        mp.traj_id:=TbLeaves(e).moid;
        for r in TbLeaves(e).tbtreeleafentries.first..TbLeaves(e).tbtreeleafentries.last loop

                --taytoxrona ftiaxne to moving point pou 8a peistrepseis
                --(an den to ftiakso edw 8a prepei meta na kasanadiatreksw thn domh)
                rectangle:=SDO_GEOMETRY(2003,
                                        NULL,
                                        NULL,
                                        SDO_ELEM_INFO_ARRAY(1,1003,3),
                SDO_ORDINATE_ARRAY(TbLeaves(e).tbtreeleafentries(r).MBB.MinPoint.x(1),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MinPoint.x(2),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MaxPoint.x(1),
                                   TbLeaves(e).tbtreeleafentries(r).MBB.MaxPoint.x(2))
                                        );
                --find the intersection of the MBB of the current entry with the given geometry
                intersection:= MDSYS.sdo_geom.sdo_intersection (geom, rectangle, tolerance);
                --get the pointers of those MBBs that intersect the geomentry and concurrently contain a part of the time period
                if (NOT (intersection is NULL)) AND
                            overlaps1d(TbLeaves(e).tbtreeleafentries(r).MBB.Minpoint.x(3),
                                        TbLeaves(e).tbtreeleafentries(r).MBB.Maxpoint.x(3),
                                        tb,te) then

                ump:=leafentry_to_unit_moving_point(tbleaves(e).tbtreeleafentries(r));
                --dbms_output.put_line(TbLeaves(e).tbtreeleafentries(r).MBB.MinPoint.x(3));
                mp.u_tab(mp.u_tab.last):=ump;
                mp.u_tab.extend(1);

                end if;


        end loop;
        mp.u_tab.trim(1);
        --if m.count>1 then m.extend(1); end if;
        --  m(m.last):=mp.route();
        if mp.traj_id<>-1 and mp.u_tab.count>0 then
        insert into mv_tbl (label,geometry) values (mp.traj_id,mp.route());
        end if;
        mp :=moving_point(moving_point_tab(unit_moving_point (tau_tll.D_period_sec(tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec),tau_tll.D_Timepoint_sec(m_y,m_m,m_d,m_h,m_min,m_sec)),
        unit_function(0,0,0,0,NULL,NULL,NULL,NULL,NULL,'PLNML_1'))),-22, null);
    end loop;
    exception when others then null;end;

    --for i in 1..m.count loop
    --  insert into mv_tbl values (m(i));
    --end loop;

end mv_query_window;

function topological(geom mdsys.sdo_geometry,tp tau_tll.d_period_sec,mask varchar2,
  srid integer, tbtreenodes varchar2, tbtreeleafs varchar2) return IDS pipelined is
m_array mp_Array;
m Hermes.moving_point;
BEGIN

m_array:=tbFunctions.range(geom,tp,srid, tbtreenodes, tbtreeleafs);

If (not (m_array is null)) and (m_array.count>0) then
dbms_output.put_line('range='||m_array.count);
For i in m_array.first..m_array.last Loop
    m:=m_array(i);
    dbms_output.put_line(m.traj_id);

    if upper(mask)='ENTER_LEAVE' or upper(mask)='ENTER' then
        if Not (m.f_enterpoints(geom) is null) then
          pipe row(m.traj_id);
        End if;
    End if;

    if upper(mask)='ENTER_LEAVE' or upper(mask)='LEAVE' then
        if Not (m.f_leavepoints(geom) is null) then
          pipe row(m.traj_id);
        End if;
    End if;
End Loop;

return;

Else
  return;
End if;

END Topological;


END tbFunctions;
/


