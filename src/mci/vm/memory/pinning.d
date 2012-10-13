module mci.vm.memory.pinning;

import core.stdc.stdlib,
       mci.core.container,
       mci.core.memory,
       mci.core.sync,
       mci.core.tuple,
       mci.vm.memory.base;

public final class PinnedObjectManager
{
    private GarbageCollector _gc;
    private Mutex _mutex;
    private Dictionary!(size_t, RuntimeObject**, false) _objects;
    private size_t _counter;
    private ArrayQueue!size_t _reuseQueue;

    pure nothrow invariant()
    {
        assert(_gc);
        assert(_mutex);
        assert(_objects);
        assert(_reuseQueue);
    }

    public this(GarbageCollector gc)
    in
    {
        assert(gc);
    }
    body
    {
        _gc = gc;
        _mutex = new typeof(_mutex)();
        _objects = new typeof(_objects)();
        _reuseQueue = new typeof(_reuseQueue)();
    }

    public size_t pin(RuntimeObject* rto)
    in
    {
        assert(rto);
        assert(isAligned(rto));
    }
    body
    {
        _mutex.lock();

        scope (exit)
            _mutex.unlock();

        auto handle = getHandle();
        auto mem = cast(RuntimeObject**)calloc(1, (RuntimeObject*).sizeof);

        *mem = rto;

        _gc.addRange(mem, 1);
        _objects.add(handle, mem);

        return handle;
    }

    public void unpin(size_t handle)
    {
        _mutex.lock();

        scope (exit)
            _mutex.unlock();

        auto mem = _objects[handle];

        _objects.remove(handle);
        _gc.removeRange(mem, 1);

        free(mem);

        _reuseQueue.enqueue(handle);
    }

    public void unpinAll()
    {
        _mutex.lock();

        scope (exit)
            _mutex.unlock();

        foreach (pair; _objects)
        {
            _gc.removeRange(pair.y, 1);
            free(pair.y);
        }

        _objects.clear();
        _counter = 0;
        _reuseQueue.clear();
    }

    private size_t getHandle()
    {
        if (!_reuseQueue.empty)
            return _reuseQueue.dequeue();

        return _counter++;
    }
}
