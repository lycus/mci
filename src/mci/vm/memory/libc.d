module mci.vm.memory.libc;

import core.stdc.stdlib,
       std.conv,
       mci.core.container,
       mci.core.typing.types,
       mci.vm.memory.base;

public final class LibCGeneration : GCGeneration
{
    @property public ubyte id()
    {
        return 0;
    }

    @property public ulong collections()
    {
        return 0;
    }

    public void collect()
    {
        // We do no actual collection, since this is just a plain
        // memory manager, not a garbage collector.
    }
}

public final class LibCGarbageCollector : InteractiveGarbageCollector
{
    private LibCGeneration _generation;
    private NoNullList!GCGeneration _generations;
    private Object _lock;
    private Object _cbLock;
    private NoNullList!(void delegate(RuntimeObject)) _allocCallbacks;
    private NoNullList!(void delegate(RuntimeObject)) _freeCallbacks;
    private size_t _objectCount;

    public this()
    {
        _generation = new typeof(_generation)();
        _generations = new typeof(_generations)();
        _lock = new typeof(_lock)();
        _cbLock = new typeof(_cbLock)();
        _allocCallbacks = new typeof(_allocCallbacks)();
        _freeCallbacks = new typeof(_freeCallbacks)();

        _generations.add(_generation);
    }

    ~this()
    {
        assert(!_objectCount);
    }

    @property public ReadOnlyIndexable!GCGeneration generations()
    {
        return _generations;
    }

    public RuntimeObject allocate(Type type, size_t size)
    {
        auto length = __traits(classInstanceSize, RuntimeObject);
        auto mem = calloc(1, length + size);
        auto obj = emplace!RuntimeObject(mem[0 .. length], type, _generation);

        synchronized (_lock)
            _objectCount++;

        synchronized (_cbLock)
            foreach (cb; _allocCallbacks)
                cb(obj);

        return obj;
    }

    public void free(RuntimeObject data)
    {
        synchronized (_cbLock)
            foreach (cb; _freeCallbacks)
                cb(data);

        .free(&data);

        synchronized (_lock)
            _objectCount--;
    }

    public void collect()
    {
        // We do no actual collection, since this is just a plain
        // memory manager, not a garbage collector.
    }

    public void attach()
    {
        // Do nothing.
    }

    public void detach()
    {
        // Do nothing.
    }

    public void addPressure(size_t amount)
    {
        // Do nothing.
    }

    public void removePressure(size_t amount)
    {
        // Do nothing.
    }

    public void addAllocateCallback(void delegate(RuntimeObject) callback)
    {
        synchronized (_cbLock)
            _allocCallbacks.add(callback);
    }

    public void addFreeCallback(void delegate(RuntimeObject) callback)
    {
        synchronized (_cbLock)
            _freeCallbacks.add(callback);
    }
}
