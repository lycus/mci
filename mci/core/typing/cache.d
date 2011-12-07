module mci.core.typing.cache;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

private NoNullDictionary!(Tuple!(Type, NoNullList!Type), FunctionPointerType) functionPointerTypes;
private NoNullDictionary!(Type, PointerType) pointerTypes;
private NoNullDictionary!(Type, ArrayType) arrayTypes;
private NoNullDictionary!(Tuple!(Type, uint), VectorType) vectorTypes;

static this()
{
    functionPointerTypes = new typeof(functionPointerTypes)();
    pointerTypes = new typeof(pointerTypes)();
    arrayTypes = new typeof(arrayTypes)();
    vectorTypes = new typeof(vectorTypes)();
}

public FunctionPointerType getFunctionPointerType(Type returnType, NoNullList!Type parameterTypes)
in
{
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

public VectorType getVectorType(Type elementType, uint elements)
in
{
    assert(elementType);
    assert(elements);
}
out (result)
{
    assert(result);
}
body
{
    auto tup = tuple(elementType, elements);

    if (auto vecType = tup in vectorTypes)
        return *vecType;

    return vectorTypes[tup] = new VectorType(elementType, elements);
}
