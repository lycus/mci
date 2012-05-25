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

    public this()
    {
        _pinManager = new typeof(_pinManager)(this);
    }

    public override void terminate()
    {
        super.terminate();

        _pinManager.unpinAll();
        GC.collect();
    }

    @property public override ulong collections() nothrow
    {
        // We can't query D's GC about this.
        return 0;
    }

    public override RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
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

    public override void free(RuntimeObject* data)
    {
        if (data)
            GC.free(data);
    }

    public override void addRoot(RuntimeObject** ptr)
    {
        GC.addRoot(ptr);
    }

    public override void removeRoot(RuntimeObject** ptr)
    {
        GC.removeRoot(ptr);
    }

    public override void addRange(RuntimeObject** ptr, size_t words)
    {
        GC.addRange(ptr, words * size_t.sizeof);
    }

    public override void removeRange(RuntimeObject** ptr, size_t words)
    {
        GC.removeRange(ptr);
    }

    public override size_t pin(RuntimeObject* data)
    {
        return _pinManager.pin(data);
    }

    public override void unpin(size_t handle)
    {
        _pinManager.unpin(handle);
    }

    public override void collect()
    {
        GC.collect();
    }

    public override void minimize()
    {
        GC.minimize();
    }

    public override void attach()
    {
        // Threads are already implicitly attached to druntime.
    }

    public override void detach()
    {
        // Threads are already implicitly detached from druntime.
    }

    @property public override bool isAttached()
    {
        // Threads don't need to detach here. See comments above.
        return false;
    }

    public override void addPressure(size_t amount) pure nothrow
    {
        // D's GC doesn't support pressure notifications.
    }

    public override void removePressure(size_t amount) pure nothrow
    {
        // D's GC doesn't support pressure notifications.
    }

    public override RuntimeObject* createWeak(RuntimeObject* target)
    {
        // FIXME: Can't implement this until 2.060.
        assert(false);
    }

    public override RuntimeObject* getWeakTarget(RuntimeObject* weak)
    {
        assert(false);
    }

    public override void setWeakTarget(RuntimeObject* weak, RuntimeObject* target)
    {
        assert(false);
    }
}
