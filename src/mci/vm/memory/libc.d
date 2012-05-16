module mci.vm.memory.libc;

import core.stdc.stdlib,
       std.conv,
       mci.core.container,
       mci.core.sync,
       mci.core.tuple,
       mci.vm.execution,
       mci.vm.intrinsics.declarations,
       mci.vm.memory.base,
       mci.vm.memory.finalization,
       mci.vm.memory.info,
       mci.vm.memory.layout;

public final class LibCGarbageCollector : InteractiveGarbageCollector
{
    private NoNullList!GarbageCollectorFinalizer _allocCallbacks;
    private Dictionary!(RuntimeObject*, Tuple!(GarbageCollectorFinalizer, ExecutionEngine)) _freeCallbacks;
    private ArrayQueue!(Tuple!(RuntimeObject*, GarbageCollectorFinalizer, ExecutionEngine)) _finalizables;
    private Mutex _allocateCallbackLock;
    private Mutex _freeCallbackLock;
    private Mutex _finalizableLock;
    private GarbageCollectorExceptionHandler _exceptionHandler;
    private FinalizerThread _finalizerThread;

    invariant()
    {
        assert(_allocCallbacks);
        assert(_freeCallbacks);
        assert(_finalizables);
        assert(_allocateCallbackLock);
        assert(_freeCallbackLock);
        assert(_finalizableLock);
    }

    public this()
    {
        _allocCallbacks = new typeof(_allocCallbacks)();
        _freeCallbacks = new typeof(_freeCallbacks)();
        _finalizables = new typeof(_finalizables)();
        _allocateCallbackLock = new typeof(_allocateCallbackLock)();
        _freeCallbackLock = new typeof(_freeCallbackLock)();
        _finalizableLock = new typeof(_finalizableLock)();
        _finalizerThread = new typeof(_finalizerThread)(this);
    }

    ~this()
    {
        _finalizerThread.exit();
    }

    @property public ulong collections() nothrow
    {
        return 0;
    }

    public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
    {
        auto mem = calloc(1, RuntimeObject.sizeof + type.size + extraSize);

        if (!mem)
            return null;

        auto obj = emplace!RuntimeObject(mem[0 .. RuntimeObject.sizeof], type);

        {
            _allocateCallbackLock.lock();

            scope (exit)
                _allocateCallbackLock.unlock();

            foreach (cb; _allocCallbacks)
                cb(obj);
        }

        return obj;
    }

    public void free(RuntimeObject* data)
    {
        if (!data)
            return;

        bool finalizable;

        {
            _freeCallbackLock.lock();

            scope (exit)
                _freeCallbackLock.unlock();

            if (auto cb = data in _freeCallbacks)
            {
                finalizable = true;

                _freeCallbacks.remove(data);

                _finalizableLock.lock();

                scope (exit)
                    _finalizableLock.unlock();

                _finalizables.enqueue(tuple(data, cb.x, cb.y));

                _finalizerThread.notify();
            }
        }

        if (!finalizable)
            .free(data);
    }

    public void addRoot(RuntimeObject** ptr)
    {
    }

    public void removeRoot(RuntimeObject** ptr)
    {
    }

    public void addRange(RuntimeObject** ptr, size_t words)
    {
    }

    public void removeRange(RuntimeObject** ptr, size_t words)
    {
    }

    public size_t pin(RuntimeObject* data)
    {
        // Pinning is not actually necessary since we don't reclaim objects automatically.
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

    public void addPressure(size_t amount) pure nothrow
    {
    }

    public void removePressure(size_t amount) pure nothrow
    {
    }

    public RuntimeObject* createWeak(RuntimeObject* target)
    {
        auto weak = allocate(getTypeInfo(weakType, mci.core.config.is32Bit));

        if (!weak)
            return null;

        *cast(RuntimeObject**)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit)) = target;

        return weak;
    }

    public RuntimeObject* getWeakTarget(RuntimeObject* weak)
    {
        return *cast(RuntimeObject**)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));
    }

    public void setWeakTarget(RuntimeObject* weak, RuntimeObject* target)
    {
        *cast(RuntimeObject**)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit)) = target;
    }

    public void addAllocateCallback(GarbageCollectorFinalizer callback)
    {
        _allocateCallbackLock.lock();

        scope (exit)
            _allocateCallbackLock.unlock();

        _allocCallbacks.add(callback);
    }

    public void removeAllocateCallback(GarbageCollectorFinalizer callback)
    {
        _allocateCallbackLock.lock();

        scope (exit)
            _allocateCallbackLock.unlock();

        _allocCallbacks.remove(callback);
    }

    public void setFreeCallback(RuntimeObject* rto, GarbageCollectorFinalizer callback, ExecutionEngine engine)
    {
        _freeCallbackLock.lock();

        scope (exit)
            _freeCallbackLock.unlock();

        if (!callback)
        {
            _freeCallbacks.remove(rto);
            return;
        }

        _freeCallbacks[rto] = tuple(callback, engine);
    }

    public void invokeFreeCallbacks()
    {
        _finalizableLock.lock();

        scope (exit)
            _finalizableLock.unlock();

        while (!_finalizables.empty)
        {
            auto finalizable = _finalizables.dequeue();

            finalize(this, finalizable.x, finalizable.y, finalizable.z);

            // Actually free the object; this isn't done the normal way for finalizables.
            .free(finalizable.x);
        }
    }

    public void waitForFreeCallbacks()
    {
        _finalizerThread.wait();
    }

    @property public GarbageCollectorExceptionHandler exceptionHandler() pure nothrow
    {
        return _exceptionHandler;
    }

    @property public void exceptionHandler(GarbageCollectorExceptionHandler exceptionHandler) pure nothrow
    {
        _exceptionHandler = exceptionHandler;
    }
}
