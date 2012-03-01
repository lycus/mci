module mci.vm.memory.dgc;

import core.exception,
       core.memory,
       core.thread,
       std.conv,
       mci.core.container,
       mci.vm.memory.base,
       mci.vm.memory.info;

public final class DGarbageCollector : GarbageCollector
{
    @property public ulong collections()
    {
        // We can't query D's GC about this.
        return 0;
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
        {
            return null;
        }
    }

    public void free(RuntimeObject* data)
    {
        if (data)
            GC.free(data);
    }

    public void addRoot(ubyte* ptr)
    {
        GC.addRoot(ptr);
    }

    public void removeRoot(ubyte* ptr)
    {
        GC.removeRoot(ptr);
    }

    public void addRange(ubyte* ptr, size_t words)
    {
        GC.addRange(ptr, words * size_t.sizeof);
    }

    public void removeRange(ubyte* ptr, size_t words)
    {
        GC.removeRange(ptr);
    }

    public size_t pin(RuntimeObject* data)
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
        GC.collect();
    }

    public void minimize()
    {
        GC.minimize();
    }

    public void attach()
    {
    }

    public void detach()
    {
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
