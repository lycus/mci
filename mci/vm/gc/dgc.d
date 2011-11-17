module mci.vm.gc.dgc;

import core.memory,
       mci.core.container,
       mci.core.typing.types,
       mci.vm.gc.base;

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
    private DGeneration _generation;
    private NoNullList!GCGeneration _generations;

    public this()
    {
        _generation = new typeof(_generation)();
        _generations = new typeof(_generations)();

        _generations.add(_generation);
    }

    @property public Countable!GCGeneration generations()
    {
        return _generations;
    }

    public RuntimeObject allocate(Type type, size_t size)
    {
        auto mem = cast(RuntimeObject)GC.malloc(__traits(classInstanceSize, RuntimeObject) + size);
        mem.__ctor(type, _generation);

        return mem;
    }

    public void free(RuntimeObject data)
    {
        GC.free(&data);
    }

    public void collect()
    {
        _generation.collect();
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
