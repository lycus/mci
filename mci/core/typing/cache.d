module mci.core.typing.cache;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

private NoNullDictionary!(string, Type) types;
private NoNullDictionary!(Tuple!(Type, NoNullList!Type), FunctionPointerType) functionPointerTypes;
private NoNullDictionary!(Type, PointerType) pointerTypes;
private NoNullDictionary!(Type, ArrayType) arrayTypes;

static this()
{
    types = new typeof(types)();
    functionPointerTypes = new typeof(functionPointerTypes)();
    pointerTypes = new typeof(pointerTypes)();
    arrayTypes = new typeof(arrayTypes)();

    void addCoreType(CoreType type)
    in
    {
        assert(type);
        assert(type.name !in types);
    }
    body
    {
        types[type.name] = type;
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

public Type getType(string name)
in
{
    assert(name);
}
body
{
    if (auto type = name in types)
        return *type;

    return null;
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

    if (auto fpType = tup in functionPointerTypes)
        return *fpType;

    return functionPointerTypes[tup] = new FunctionPointerType(returnType, parameterTypes);
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
    if (auto ptrType = elementType in pointerTypes)
        return *ptrType;

    return pointerTypes[elementType] = new PointerType(elementType);
}

public ArrayType getArrayType(Type elementType)
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
    if (auto arrType = elementType in arrayTypes)
        return *arrType;

    return arrayTypes[elementType] = new ArrayType(elementType);
}
