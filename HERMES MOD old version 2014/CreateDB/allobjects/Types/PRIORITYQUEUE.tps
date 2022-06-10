Prompt Type PRIORITYQUEUE;
CREATE OR REPLACE Type PriorityQueue as OBJECT
(
    Entries QueueEntries,
    Counter Integer,
    Last Integer,
    top integer,
    Member Procedure Initialize ,
    Member Procedure Enqueue (Queueentry in out PriorityQueueNode),
    Member Function Dequeue(self in out PriorityQueue) return PriorityQueueNode
);
/


