module mci.vm.memory.libc;

import core.stdc.stdlib,
       std.conv,
       mci.core.container,
       mci.vm.memory.base,
       mci.vm.memory.info;

public final class LibCGarbageCollector : InteractiveGarbageCollector
{
    private Object _cbLock;
    private NoNullList!(void delegate(RuntimeObject*)) _allocCallbacks;
    private NoNullList!(void delegate(RuntimeObject*)) _freeCallbacks;

    public this()
    {
        _cbLock = new typeof(_cbLock)();
        _allocCallbacks = new typeof(_allocCallbacks)();
        _freeCallbacks = new typeof(_freeCallbacks)();
    }

    @property public ulong collections()
    {
        return 0;
    }

    public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
    {
        auto mem = calloc(1, RuntimeObject.sizeof + type.size + extraSize);

        if (!mem)
            return null;

        auto obj = emplace!RuntimeObject(mem[0 .. RuntimeObject.sizeof], type);

        synchronized (_cbLock)
            foreach (cb; _allocCallbacks)
                cb(obj);

        return obj;
    }

    public void free(RuntimeObject* data)
    {
        if (!data)
            return;

        synchronized (_cbLock)
            foreach (cb; _freeCallbacks)
                cb(data);

        .free(data);
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

    public void removeRange(ubyte* ptr, size_t words)
    {
    }

    public size_t pin(RuntimeObject* data)
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

    public void addAllocateCallback(void delegate(RuntimeObject*) callback)
    {
        synchronized (_cbLock)
            _allocCallbacks.add(callback);
    }

    public void addFreeCallback(void delegate(RuntimeObject*) callback)
    {
        synchronized (_cbLock)
            _freeCallbacks.add(callback);
    }
}
