module mci.core.analysis.aliasing;

import mci.core.nullable,
       mci.core.code.instructions,
       mci.core.typing.types;

public enum Aliasing : ubyte
{
    noAlias,
    mayAlias,
    partialAlias,
    mustAlias,
}

public struct MemoryLocation
{
    private Instruction _pointer;
    private Nullable!size_t _size;

    pure nothrow invariant()
    {
        assert(_pointer);
    }

    @disable this();

    public this(Instruction pointer, Nullable!size_t size = Nullable!size_t())
    in
    {
        assert(pointer);
        assert(pointer.opCode.hasTarget);
        assert(hasAliasing(pointer.targetRegister.type));
    }
    body
    {
        _pointer = pointer;
        _size = size;
    }

    @property public Instruction pointer()
    out (result)
    {
        assert(result);
        assert((cast()result).opCode.hasTarget);
        assert(hasAliasing((cast()result).targetRegister.type));
    }
    body
    {
        return _pointer;
    }

    @property public Nullable!size_t size()
    {
        return _size;
    }
}

public abstract class AliasAnalyzer
{
    public abstract Aliasing getAliasing(MemoryLocation a, MemoryLocation b);
}
