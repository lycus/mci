module mci.vm.memory.libc;

import core.atomic,
       core.stdc.stdlib,
       std.conv,
       mci.core.container,
       mci.core.typing.types,
       mci.vm.memory.base,
       mci.vm.memory.info;

public final class LibCGarbageCollector : InteractiveGarbageCollector
{
    private Object _lock;
    private Object _cbLock;
    private NoNullList!(void delegate(RuntimeObject)) _allocCallbacks;
    private NoNullList!(void delegate(RuntimeObject)) _freeCallbacks;

    public this()
    {
        _lock = new typeof(_lock)();
        _cbLock = new typeof(_cbLock)();
        _allocCallbacks = new typeof(_allocCallbacks)();
        _freeCallbacks = new typeof(_freeCallbacks)();
    }

    @property public ulong collections()
    {
        return 0;
    }

    public RuntimeObject allocate(RuntimeTypeInfo type, size_t extraSize = 0)
    {
        auto length = __traits(classInstanceSize, RuntimeObject);
        auto mem = calloc(1, length + type.size + extraSize);

        if (!mem)
            return null;

        auto obj = emplace!RuntimeObject(mem[0 .. length], type);

        synchronized (_cbLock)
            foreach (cb; _allocCallbacks)
                cb(obj);

        return obj;
    }

    public void free(RuntimeObject data)
    {
        if (!data)
            return;

        synchronized (_cbLock)
            foreach (cb; _freeCallbacks)
                cb(data);

        .free(&data);
    }

    public void addRoot(ubyte* ptr)
    {
    }

    public void removeRoot(ubyte* ptr)
    {
    }

    public void addRange(ubyte* ptr, size_t words)
    {
    }

    public void removeRange(ubyte* ptr)
    {
    }

    public size_t pin(RuntimeObject data)
    {
        return 0;
    }

    public void unpin(size_t handle)
    {
    }

    public void collect()
    {
        // We do no actual collection, since this is just a plain
        // memory manager, not a garbage collector.
    }

    public void minimize()
    {
    }

    public void attach()
    {
    }

    public void detach()
    {
    }

    public void addPressure(size_t amount)
    {
    }

    public void removePressure(size_t amount)
    {
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
