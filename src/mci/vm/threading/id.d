module mci.vm.threading.id;

import core.thread,
       mci.core.container,
       mci.core.nullable,
       mci.core.sync;

private __gshared Dictionary!(Thread, ulong) thread2ID;
private __gshared Dictionary!(ulong, Thread) id2Thread;
private __gshared Mutex lock;
private __gshared ulong currentID;

shared static this()
{
    thread2ID = new typeof(thread2ID)();
    id2Thread = new typeof(id2Thread)();
    lock = new typeof(lock)();
}

static this()
{
    lock.lock();

    scope (exit)
        lock.unlock();

    auto thread = Thread.getThis();
    auto id = currentID++;

    thread2ID.add(thread, id);
    id2Thread.add(id, thread);
}

static ~this()
{
    lock.lock();

    scope (exit)
        lock.unlock();

    auto thread = Thread.getThis();
    auto id = thread2ID[thread];

    thread2ID.remove(thread);
    id2Thread.remove(id);
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
    lock.lock();

    scope (exit)
        lock.unlock();

    if (auto id = thread2ID.get(thread))
        return nullable(*id);

    return Nullable!ulong();
}

public static Thread getThreadByID(ulong id)
{
    lock.lock();

    scope (exit)
        lock.unlock();

    if (auto thread = id2Thread.get(id))
        return *thread;

    return null;
}
