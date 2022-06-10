Prompt Type Body PRIORITYQUEUE;
CREATE OR REPLACE Type Body PriorityQueue As

    Member Procedure Initialize Is
    Begin
    Entries:=QueueEntries(PriorityQueueNode(-1,null,-1,null,null,'x',1000000,-1,-1,-1,null));
    last:=0;
    Counter:=0;
    top:=1;
    --  Entries.extend(1);

    End Initialize;

    Member Procedure Enqueue (QueueEntry in out PriorityQueueNode) Is
        TempEntry PriorityQueueNode;
        PreviousExamined pls_integer;
        EntriesCounter pls_integer;
        Begin
            Counter:=Counter+1;
            EntriesCounter:=Entries.count;
            if last=0 then
                QueueEntry.PtrCurrent:=1;
                QueueEntry.PtrNext:=QueueEntry.PtrCurrent;
                QueueEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                --Entries.extend(1);
                Entries:=QueueEntries(QueueEntry);
                last:=1;
                top:=1;
                return;
            elsif EntriesCounter=1 and QueueEntry.Dist<=Entries(top).Dist then
                Entries.Extend(1);
                last:=last+1;
                QueueEntry.PtrCurrent:=last;
                QueueEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                QueueEntry.PtrNext:=Entries(top).PtrCurrent;
                Entries(top).PtrPrevious:=QueueEntry.PtrCurrent;
                top:=QueueEntry.PtrCurrent;
                Entries(last):=QueueEntry;
                return;
            else
                TempEntry:=Entries(top);
                while TempEntry.PtrCurrent!=TempEntry.PtrNext Loop
                    if QueueEntry.Dist<=TempEntry.Dist then
                    if TempEntry.PtrCurrent=top then
                        --dbms_output.put_line(top);
                        Entries.extend(1);
                        last:=last+1;
                        QueueEntry.PtrCurrent:=last;
                        QueueEntry.PtrNext:=TempEntry.PtrCurrent;
                        QueueEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                        TempEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                        top:=QueueEntry.PtrCurrent;
                        Entries(last):=QueueEntry;
                        Entries(TempEntry.PtrCurrent):=TempEntry;
                        --dbms_output.put_line('if TempEntry.PtrCurrent=top then');
                        return;
                    else
                        Entries.extend(1);
                        last:=last+1;
                        QueueEntry.PtrCurrent:=last;
                        QueueEntry.PtrNext:=TempEntry.PtrCurrent;
                        QueueEntry.PtrPrevious:=TempEntry.PtrPrevious;
                        Entries(TempEntry.PtrPrevious).PtrNext:=QueueEntry.PtrCurrent;
                        TempEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                        Entries(last):=QueueEntry;
                        Entries(TempEntry.PtrCurrent):=TempEntry;
                        --dbms_output.put_line('else    Entries.extend(1);');
                        return;
                    End if;
                    End if;
                    TempEntry:=Entries(TempEntry.PtrNext);
                End Loop;

            End if;
            if TempEntry.PtrCurrent=TempEntry.PtrNext then
            Entries.extend(1);
            last:=last+1;
            if TempEntry.Dist<=QueueEntry.Dist then
                --dbms_output.put_line(TempEntry.PtrCurrent);

                QueueEntry.PtrCurrent:=last;
                QueueEntry.PtrNext:=QueueEntry.PtrCurrent;
                QueueEntry.PtrPrevious:=TempEntry.PtrCurrent;
                Entries(TempEntry.PtrCurrent).PtrNext:=QueueEntry.PtrCurrent;
                Entries(last):=QueueEntry;
                --dbms_output.put_line('final');
                return;
            else
                QueueEntry.PtrCurrent:=last;
                QueueEntry.PtrNext:=TempEntry.PtrCurrent;
                QueueEntry.PtrPrevious:=TempEntry.PtrPrevious;
                Entries(TempEntry.PtrPrevious).PtrNext:=QueueEntry.PtrCurrent;
                TempEntry.PtrPrevious:=QueueEntry.PtrCurrent;
                Entries(last):=QueueEntry;
                Entries(TempEntry.PtrCurrent):=TempEntry;
                --dbms_output.put_line('else    Entries.extend(1);');
                return;
                --dbms_output.put_line('gamw ton olympiako');
            end if;
            End if;
        end Enqueue;

        Member Function Dequeue (Self in out priorityqueue) return PriorityQueueNode is
            RNode PriorityQueueNode;
            --counter integer;
            oldtop integer;
        Begin
            --counter:=Entries.count;
            If counter=0 then return null;End If;
            RNode:=Entries(top);
            oldtop:=top;
            if counter>1 then
                top:=Entries(oldtop).ptrNext;
                Entries(top).PtrPrevious:=Entries(top).PtrCurrent;
            End if;
            Entries.delete(oldtop);
            counter:=counter-1;
            return Rnode;
        End Dequeue;

End;
/


