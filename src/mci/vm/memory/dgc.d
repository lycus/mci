module mci.vm.memory.dgc;

import core.memory,
       core.thread,
       std.conv,
       mci.core.container,
       mci.core.typing.types,
       mci.vm.memory.base;

public final class DGeneration : GCGeneration
{
    @property public ubyte id()
    {
        return 0;
    }

    @property public ulong collections()
    {
        // There's currently no reliable way to get this from the D GC.
        return 0;
    }

    public void collect()
    {
        return GC.collect();
    }
}

public final class DGarbageCollector : GarbageCollector
{
    private static bool _isThisThreadAttached;
    private Object _attachmentSync;
    private DGeneration _generation;
    private NoNullList!GCGeneration _generations;

    public this()
    {
        _attachmentSync = new typeof(_attachmentSync)();
        _generation = new typeof(_generation)();
        _generations = new typeof(_generations)();

        _generations.add(_generation);
    }

    @property public ReadOnlyIndexable!GCGeneration generations()
    {
        return _generations;
    }

    public RuntimeObject allocate(Type type, size_t size)
    {
        auto length = __traits(classInstanceSize, RuntimeObject);
        auto mem = GC.calloc(length + size);

        if (!mem)
            return null;

        auto obj = emplace!RuntimeObject(mem[0 .. length], type, _generation);

        return obj;
    }

    public void free(RuntimeObject data)
    {
        if (data)
            GC.free(&data);
    }

    public size_t pin(RuntimeObject data)
    {
        // This is not a compacting GC.
        return 0;
    }

    public void unpin(size_t handle)
    {
        // This is not a compacting GC.
    }

    public void collect()
    {
        _generation.collect();
    }

    public void attach()
    {
        synchronized (_attachmentSync)
        {
            if (!_isThisThreadAttached)
            {
                thread_attachThis();
                _isThisThreadAttached = true;
            }
        }
    }

    public void detach()
    {
        synchronized (_attachmentSync)
        {
            if (_isThisThreadAttached)
            {
                thread_detachThis();
                _isThisThreadAttached = false;
            }
        }
    }

    public void addPressure(size_t amount)
    {
        // D's GC doesn't support pressure notifications.
    }

    public void removePressure(size_t amount)
    {
        // D's GC doesn't support pressure notifications.
    }
}
