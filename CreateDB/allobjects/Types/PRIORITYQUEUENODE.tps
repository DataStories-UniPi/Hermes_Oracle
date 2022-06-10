Prompt Type PRIORITYQUEUENODE;
CREATE OR REPLACE Type PriorityQueueNode AS OBJECT
(
    Ptr integer, /*For tbtreenodeentry this is a pointer to the child leaf*/
    MBB tbMBB, /*For tbtreenodeentry this is the MBB of the entry*/
    Id number, /*The id of the moving object entry*/
    P1 tbPoint, /* the first point of a moving object entry*/
    P2 tbPoint, /* the last entry of a moving object entry*/
    EType varchar2(20),/* the type of the entry in the form of a line string*/
    Dist number, /*The distance of the queue entry calculated by the
                MinDistLine2D function*/
    PtrNext integer,
    PtrPrevious integer,
    PtrCurrent integer,
    Trajectory tbMovingObjectEntries
);
/


