module mci.core.typing.cache;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.sync,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

private __gshared NoNullDictionary!(Tuple!(CallingConvention, Type, NoNullList!Type), FunctionPointerType, false) functionPointerTypes;
private __gshared Mutex functionPointerTypesLock;

private __gshared NoNullDictionary!(Type, PointerType, false) pointerTypes;
private __gshared Mutex pointerTypesLock;

private __gshared NoNullDictionary!(StructureType, ReferenceType, false) referenceTypes;
private __gshared Mutex referenceTypesLock;

private __gshared NoNullDictionary!(Type, ArrayType, false) arrayTypes;
private __gshared Mutex arrayTypesLock;

private __gshared NoNullDictionary!(Tuple!(Type, uint), VectorType, false) vectorTypes;
private __gshared Mutex vectorTypesLock;

shared static this()
{
    functionPointerTypes = new typeof(functionPointerTypes)();
    functionPointerTypesLock = new typeof(functionPointerTypesLock)();
    pointerTypes = new typeof(pointerTypes)();
    pointerTypesLock = new typeof(pointerTypesLock)();
    referenceTypes = new typeof(referenceTypes)();
    referenceTypesLock = new typeof(referenceTypesLock)();
    arrayTypes = new typeof(arrayTypes)();
    arrayTypesLock = new typeof(arrayTypesLock)();
    vectorTypes = new typeof(vectorTypes)();
    vectorTypesLock = new typeof(vectorTypesLock)();
}

public FunctionPointerType getFunctionPointerType(CallingConvention callingConvention, Type returnType,
                                                  NoNullList!Type parameterTypes)
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
    functionPointerTypesLock.lock();

    scope (exit)
        functionPointerTypesLock.unlock();

    auto params = parameterTypes.duplicate();
    auto tup = tuple(callingConvention, returnType, params);

    if (auto fpType = tup in functionPointerTypes)
        return *fpType;

    return functionPointerTypes[tup] = new FunctionPointerType(callingConvention, returnType, params);
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
    pointerTypesLock.lock();

    scope (exit)
        pointerTypesLock.unlock();

    if (auto ptrType = elementType in pointerTypes)
        return *ptrType;

    return pointerTypes[elementType] = new PointerType(elementType);
}

public ReferenceType getReferenceType(StructureType elementType)
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
    referenceTypesLock.lock();

    scope (exit)
        referenceTypesLock.unlock();

    if (auto refType = elementType in referenceTypes)
        return *refType;

    return referenceTypes[elementType] = new ReferenceType(elementType);
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
    arrayTypesLock.lock();

    scope (exit)
        arrayTypesLock.unlock();

    if (auto arrType = elementType in arrayTypes)
        return *arrType;

    return arrayTypes[elementType] = new ArrayType(elementType);
}

public VectorType getVectorType(Type elementType, uint elements)
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
    vectorTypesLock.lock();

    scope (exit)
        vectorTypesLock.unlock();

    auto tup = tuple(elementType, elements);

    if (auto vecType = tup in vectorTypes)
        return *vecType;

    return vectorTypes[tup] = new VectorType(elementType, elements);
}
