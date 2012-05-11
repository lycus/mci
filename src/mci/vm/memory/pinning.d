module mci.vm.memory.pinning;

import core.stdc.stdlib,
       mci.core.container,
       mci.core.tuple,
       mci.vm.memory.base;

public final class PinnedObjectManager
{
    private GarbageCollector _gc;
    private Dictionary!(size_t, RuntimeObject**) _objects;
    private size_t _counter;
    private ArrayQueue!size_t _reuseQueue;

    invariant()
    {
        assert(_gc);
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
        _objects = new typeof(_objects)();
        _reuseQueue = new typeof(_reuseQueue)();
    }

    public size_t pin(RuntimeObject* rto)
    in
    {
        assert(rto);
        assert(isSystemAligned(cast(ubyte*)rto));
    }
    body
    {
        auto handle = getHandle();
        auto mem = cast(RuntimeObject**)calloc(1, (RuntimeObject*).sizeof);

        *mem = rto;

        _gc.addRoot(mem);
        _objects.add(handle, mem);

        return handle;
    }

    public void unpin(size_t handle)
    {
        auto mem = _objects[handle];

        _objects.remove(handle);
        _gc.removeRoot(mem);

        free(mem);

        _reuseQueue.enqueue(handle);
    }

    private size_t getHandle()
    {
        if (!_reuseQueue.empty)
            return _reuseQueue.dequeue();

        return _counter++;
    }
}
