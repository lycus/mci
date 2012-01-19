module mci.vm.memory.info;

import mci.core.container,
       mci.core.tuple,
       mci.core.typing.types,
       mci.vm.memory.layout;

public final class RuntimeTypeInfo
{
    private Type _type;
    private size_t _size;

    invariant()
    {
        assert(_type);
    }

    private this(Type type, size_t size)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
        _size = size;
    }

    @property public Type type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public size_t size()
    {
        return _size;
    }
}

private __gshared NoNullDictionary!(Tuple!(Type, bool), RuntimeTypeInfo, false) typeInfoCache;

shared static this()
{
    typeInfoCache = new typeof(typeInfoCache)();
}

public RuntimeTypeInfo getTypeInfo(Type type, bool is32Bit)
in
{
    assert(type);
}
body
{
    auto tup = tuple(type, is32Bit);

    if (auto info = tup in typeInfoCache)
        return *info;

    return typeInfoCache[tup] = new RuntimeTypeInfo(type, computeSize(type, is32Bit));
}
