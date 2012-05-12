module mci.vm.memory.dgc;

import core.exception,
       core.memory,
       core.thread,
       std.conv,
       mci.core.container,
       mci.vm.memory.base,
       mci.vm.memory.info,
       mci.vm.memory.pinning;

public final class DGarbageCollector : GarbageCollector
{
    private PinnedObjectManager _pinManager;

    @property public ulong collections()
    {
        // We can't query D's GC about this.
        return 0;
    }

    public this()
    {
        _pinManager = new typeof(_pinManager)(this);
    }

    public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
    {
        try
        {
            auto mem = GC.calloc(RuntimeObject.sizeof + type.size + extraSize);

            if (!mem)
                return null;

            return emplace!RuntimeObject(mem[0 .. RuntimeObject.sizeof], type);
        }
        catch (OutOfMemoryError)
            return null; // This might not actually work at all due to how D handles catching of Error objects.
    }

    public void free(RuntimeObject* data)
    {
        if (data)
            GC.free(data);
    }

    public void addRoot(RuntimeObject** ptr)
    {
        GC.addRoot(ptr);
    }

    public void removeRoot(RuntimeObject** ptr)
    {
        GC.removeRoot(ptr);
    }

    public void addRange(RuntimeObject** ptr, size_t words)
    {
        GC.addRange(ptr, words * size_t.sizeof);
    }

    public void removeRange(RuntimeObject** ptr, size_t words)
    {
        GC.removeRange(ptr);
    }

    public size_t pin(RuntimeObject* data)
    {
        return _pinManager.pin(data);
    }

    public void unpin(size_t handle)
    {
        _pinManager.unpin(handle);
    }

    public void collect()
    {
        GC.collect();
    }

    public void minimize()
    {
        GC.minimize();
    }

    public void attach()
    {
        // Threads are already implicitly attached to druntime.
    }

    public void detach()
    {
        // Threads are already implicitly detached from druntime.
    }

    public void addPressure(size_t amount)
    {
        // D's GC doesn't support pressure notifications.
    }

    public void removePressure(size_t amount)
    {
        // D's GC doesn't support pressure notifications.
    }

    public RuntimeObject* createWeak(RuntimeObject* target)
    {
        // FIXME: Can't implement this until 2.060.
        assert(false);
    }

    public RuntimeObject* getWeakTarget(RuntimeObject* weak)
    {
        assert(false);
    }

    public void setWeakTarget(RuntimeObject* weak, RuntimeObject* target)
    {
        assert(false);
    }
}
