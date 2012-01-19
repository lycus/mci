module mci.vm.memory.info;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.memory.layout;

public final class RuntimeTypeInfo
{
    private Type _type;
    private size_t _size;

    invariant()
    {
        assert(_type);
        assert(isType!ReferenceType(_type) || isType!ArrayType(_type) || isType!VectorType(_type));
    }

    private this(Type type, size_t size)
    in
    {
        assert(type);
        assert(isType!ReferenceType(type) || isType!ArrayType(type) || isType!VectorType(type));
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
        assert(isType!ReferenceType(result) || isType!ArrayType(result) || isType!VectorType(result));
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

private size_t computeRealSize(Type type, bool is32Bit)
in
{
    assert(type);
    assert(isType!ReferenceType(type) || isType!ArrayType(type) || isType!VectorType(type));
}
body
{
    if (auto r = cast(ReferenceType)type)
        return computeSize(r.elementType, is32Bit);
    else if (auto v = cast(VectorType)type)
        return computeSize(v.elementType, is32Bit) * v.elements;
    else // For arrays, we just compute the size of the length field.
        return computeSize(NativeUIntType.instance, is32Bit);
}

public RuntimeTypeInfo getTypeInfo(Type type, bool is32Bit)
in
{
    assert(type);
    assert(isType!ReferenceType(type) || isType!ArrayType(type) || isType!VectorType(type));
}
body
{
    synchronized (typeInfoCache)
    {
        auto tup = tuple(type, is32Bit);

        if (auto info = tup in typeInfoCache)
            return *info;

        return typeInfoCache[tup] = new RuntimeTypeInfo(type, computeRealSize(type, is32Bit));
    }
}
