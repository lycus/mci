module mci.core.typing.cache;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

public final class TypeCache
{
    private Dictionary!(Tuple!(string, string), Type) _types;
    private Dictionary!(Tuple!(Type, NoNullList!Type), FunctionPointerType) _functionPointerTypes;
    private NoNullDictionary!(Type, PointerType) _pointerTypes;

    invariant()
    {
        assert(_types);
        assert(_functionPointerTypes);
        assert(_pointerTypes);
    }

    public this()
    {
        _types = new typeof(_types)();
        _functionPointerTypes = new typeof(_functionPointerTypes)();
        _pointerTypes = new typeof(_pointerTypes)();

        void addCoreType(CoreType type)
        in
        {
            assert(type);
        }
        body
        {
            // HACK: These casts are in place to work around an incomprehensible compiler error.
            auto tup = tuple(cast(string)null, cast(string)type.name);

            if (tup !in _types)
                _types[tup] = type;
        }

        addCoreType(UnitType.instance);
        addCoreType(Int8Type.instance);
        addCoreType(UInt8Type.instance);
        addCoreType(Int16Type.instance);
        addCoreType(UInt16Type.instance);
        addCoreType(Int32Type.instance);
        addCoreType(UInt32Type.instance);
        addCoreType(Int64Type.instance);
        addCoreType(UInt64Type.instance);
        addCoreType(NativeIntType.instance);
        addCoreType(NativeUIntType.instance);
        addCoreType(Float32Type.instance);
        addCoreType(Float64Type.instance);
    }

    public Type getType(string module_, string name)
    in
    {
        assert(name);
    }
    body
    {
        if (auto type = tuple(module_, name) in _types)
            return *type;

        return null;
    }

    public StructureType addStructureType(Module module_, string name, TypeLayout layout = TypeLayout.automatic,
                                          Nullable!uint packingSize = Nullable!uint())
    in
    {
        assert(module_);
        assert(name);

        if (packingSize.hasValue)
            assert(packingSize.value);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto tup = tuple(cast(string)module_.name, name);

        assert(tup !in _types);

        auto type = new StructureType(module_, name, layout, packingSize);
        _types[tup] = type;

        return type;
    }

    public FunctionPointerType getFunctionPointerType(Type returnType, NoNullList!Type parameterTypes)
    in
    {
        assert(returnType);
        assert(parameterTypes);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto tup = tuple(returnType, parameterTypes.duplicate());

        if (auto fpType = tup in _functionPointerTypes)
            return *fpType;

        return _functionPointerTypes[tup] = new FunctionPointerType(returnType, parameterTypes);
    }

    public PointerType getPointerType(Type elementType)
    in
    {
        assert(elementType);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto ptrType = elementType in _pointerTypes)
            return *ptrType;

        return _pointerTypes[elementType] = new PointerType(elementType);
    }
}
