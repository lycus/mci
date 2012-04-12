module mci.vm.memory.libc;

import core.stdc.stdlib,
       std.conv,
       mci.core.container,
       mci.core.sync,
       mci.vm.memory.base,
       mci.vm.memory.info;

public final class LibCGarbageCollector : InteractiveGarbageCollector
{
    private NoNullList!GarbageCollectorCallbackFunction _allocCallbacks;
    private NoNullDictionary!(RuntimeObject*, NoNullList!GarbageCollectorCallbackFunction) _freeCallbacks;
    private Mutex _allocateCallbackLock;
    private Mutex _freeCallbackLock;

    public this()
    {
        _allocCallbacks = new typeof(_allocCallbacks)();
        _freeCallbacks = new typeof(_freeCallbacks)();
        _allocateCallbackLock = new typeof(_allocateCallbackLock)();
        _freeCallbackLock = new typeof(_freeCallbackLock)();
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

        {
            _freeCallbackLock.lock();

            scope (exit)
                _freeCallbackLock.unlock();

            auto callbacks = data in _freeCallbacks;

            if (callbacks)
            {
                foreach (cb; *callbacks)
                    cb(data);

                _freeCallbacks.remove(data);
            }
        }

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

    public void addAllocateCallback(GarbageCollectorCallbackFunction callback)
    {
        _allocateCallbackLock.lock();

        scope (exit)
            _allocateCallbackLock.unlock();

        _allocCallbacks.add(callback);
    }

    public void removeAllocateCallback(GarbageCollectorCallbackFunction callback)
    {
        _allocateCallbackLock.lock();

        scope (exit)
            _allocateCallbackLock.unlock();

        _allocCallbacks.remove(callback);
    }

    public void addFreeCallback(RuntimeObject* rto, GarbageCollectorCallbackFunction callback)
    {
        _freeCallbackLock.lock();

        scope (exit)
            _freeCallbackLock.unlock();

        auto cbs = rto in _freeCallbacks;
        auto callbacks = cbs ? *cbs : null;

        if (!callbacks)
        {
            callbacks = new NoNullList!GarbageCollectorCallbackFunction();
            _freeCallbacks[rto] = callbacks;
        }

        callbacks.add(callback);
    }
}
