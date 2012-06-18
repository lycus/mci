module mci.vm.memory.dgc;

import core.exception,
       core.memory,
       core.thread,
       std.conv,
       mci.core.container,
       mci.core.sync,
       mci.core.weak,
       mci.vm.intrinsics.declarations,
       mci.vm.memory.base,
       mci.vm.memory.info,
       mci.vm.memory.layout,
       mci.vm.memory.pinning;

private final class WeakBox
{
    private RuntimeObject* _object;

    invariant()
    {
        assert(_object);
    }

    public this(RuntimeObject* object)
    in
    {
        assert(object);
    }
    body
    {
        _object = object;
    }

    @property public RuntimeObject* object()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _object;
    }
}

public final class DGarbageCollector : GarbageCollector
{
    private Mutex _weakRefLock;
    private PinnedObjectManager _pinManager;

    invariant()
    {
        assert(_weakRefLock);
    }

    public this()
    {
        _weakRefLock = new typeof(_weakRefLock)();
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
        auto weak = allocate(getTypeInfo(weakType, mci.core.config.is32Bit));

        if (!weak)
            return null;

        auto addr = cast(Weak!WeakBox*)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

        // Ensure that the GC doesn't pick up the weak reference.
        GC.setAttr(addr, GC.BlkAttr.NO_SCAN);

        // We currently have to box the value, since we need
        // the GC to notify us when the contained object is
        // collected.
        *addr = .weak(new WeakBox(target));

        return weak;
    }

    public override RuntimeObject* getWeakTarget(RuntimeObject* weak)
    {
        auto weakObj = cast(Weak!WeakBox*)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

        _weakRefLock.lock();

        scope (exit)
            _weakRefLock.unlock();

        auto obj = weakObj.getObject();

        return obj ? obj.object : null;
    }

    public override void setWeakTarget(RuntimeObject* weak, RuntimeObject* target)
    {
        auto addr = cast(Weak!WeakBox*)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

        _weakRefLock.lock();

        scope (exit)
            _weakRefLock.unlock();

        *addr = .weak(new WeakBox(target));
    }
}
