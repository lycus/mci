module mci.vm.gc.base;

import mci.core.container,
       mci.core.typing.types;

public final class RuntimeObject
{
    private Type _type;
    private GCGeneration _generation;

    package this(Type type, GCGeneration generation)
    in
    {
        assert(type);
        assert(generation);
    }
    body
    {
        _type = type;
        _generation = generation;
    }

    @property public Type type()
    {
        return _type;
    }

    @property public GCGeneration generation()
    {
        return _generation;
    }

    @property package void generation(GCGeneration generation)
    in
    {
        assert(generation);
    }
    body
    {
        _generation = generation;
    }
}

public interface GCGeneration
{
    @property public ubyte id();

    @property public ulong collections();

    public void collect();
}

public interface GarbageCollector
{
    @property public Countable!GCGeneration generations()
    out (result)
    {
        assert(result);
    }

    public RuntimeObject allocate(Type type, size_t size)
    in
    {
        assert(type);
    }
    out (result)
    {
        assert(result);
    }

    public void free(RuntimeObject data)
    in
    {
        assert(data);
    }

    public void collect();

    public void addPressure(size_t amount);

    public void removePressure(size_t amount);
}

public interface InteractiveGarbageCollector : GarbageCollector
{
    public void addAllocateCallback(void delegate(RuntimeObject) callback)
    in
    {
        assert(callback);
    }

    public void addFreeCallback(void delegate(RuntimeObject) callback)
    in
    {
        assert(callback);
    }
}
