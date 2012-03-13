module mci.vm.threading.id;

import core.thread,
       mci.core.container,
       mci.core.nullable;

private __gshared Dictionary!(Thread, ulong) thread2ID;
private __gshared Dictionary!(ulong, Thread) id2Thread;
private __gshared ulong currentID;

shared static this()
{
    thread2ID = new typeof(thread2ID)();
    id2Thread = new typeof(id2Thread)();
}

static this()
{
    synchronized (thread2ID)
    {
        auto thread = Thread.getThis();
        auto id = currentID++;

        thread2ID.add(thread, id);
        id2Thread.add(id, thread);
    }
}

static ~this()
{
    synchronized (thread2ID)
    {
        auto thread = Thread.getThis();
        auto id = thread2ID[thread];

        thread2ID.remove(thread);
        id2Thread.remove(id);
    }
}

public static ulong getCurrentThreadID()
{
    return getIDByThread(Thread.getThis()).value;
}

public static Nullable!ulong getIDByThread(Thread thread)
in
{
    assert(thread);
}
body
{
    synchronized (thread2ID)
    {
        if (auto id = thread2ID.get(thread))
            return nullable(*id);

        return Nullable!ulong();
    }
}

public static Thread getThreadByID(ulong id)
{
    synchronized (thread2ID)
    {
        if (auto thread = id2Thread.get(id))
            return *thread;

        return null;
    }
}
