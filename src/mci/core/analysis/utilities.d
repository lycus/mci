module mci.core.analysis.utilities;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.core,
       mci.core.typing.types;

public bool isNullable(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return cast(PointerType)type ||
           cast(FunctionPointerType)type ||
           cast(ReferenceType)type ||
           cast(ArrayType)type ||
           cast(VectorType)type;
}

public bool isValidInArithmetic(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return !!cast(CoreType)type;
}

public bool isValidInBitwise(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return !!cast(IntegerType)type;
}

public bool isValidInComparison(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return isValidInArithmetic(type) || !!cast(PointerType)type;
}

public bool isArrayContainerOf(Type type, Type elementType) pure nothrow
in
{
    assert(type);
    assert(elementType);
}
body
{
    if (auto arr = cast(ArrayType)type)
        if (arr.elementType is elementType)
            return true;

    if (auto vec = cast(VectorType)type)
        if (vec.elementType is elementType)
            return true;

    if (auto sa = cast(StaticArrayType)type)
        if (sa.elementType is elementType)
            return true;

    return false;
}

public bool isArrayContainerOfT(T : Type)(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    if (isArrayOrVector(type))
        return !!cast(T)getElementType(type);

    return false;
}

public bool isContainerOf(Type type, Type elementType) pure nothrow
in
{
    assert(type);
    assert(elementType);
}
body
{
    if (auto ptr = cast(PointerType)type)
        if (ptr.elementType is elementType)
            return true;

    return isArrayContainerOf(type, elementType);
}

public bool isArrayContainerOfOrElement(Type type, Type elementType) pure nothrow
in
{
    assert(type);
    assert(elementType);
}
body
{
    if (type is elementType)
        return true;

    return isArrayContainerOf(type, elementType);
}

public Type getElementType(Type type) pure nothrow
in
{
    assert(cast(PointerType)type || cast(ArrayType)type || cast(VectorType)type || cast(StaticArrayType)type);
}
body
{
    if (auto vec = cast(VectorType)type)
        return vec.elementType;
    else if (auto arr = cast(ArrayType)type)
        return arr.elementType;
    else if (auto sa = cast(StaticArrayType)type)
        return sa.elementType;
    else
        return (cast(PointerType)type).elementType;
}

public bool isArrayOrVector(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return cast(ArrayType)type ||
           cast(VectorType)type ||
           cast(StaticArrayType)type;
}

public bool isManaged(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return cast(ReferenceType)type || isArrayOrVector(type);
}

public bool isTypeSpecification(Type type) pure nothrow
in
{
    assert(type);
}
body
{
    return isManaged(type) || cast(PointerType)type;
}

public bool isConvertibleTo(Type fromType, Type toType)
in
{
    assert(fromType);
    assert(toType);
}
body
{
    if (cast(CoreType)fromType && cast(CoreType)toType)
        return true;

    if (cast(PointerType)fromType && cast(PointerType)toType)
        return true;

    if (cast(PointerType)fromType && (toType is NativeIntType.instance || toType is NativeUIntType.instance))
        return true;

    if ((fromType is NativeIntType.instance || fromType is NativeUIntType.instance) && cast(PointerType)toType)
        return true;

    if (isManaged(fromType) && isManaged(toType))
        return true;

    if (cast(FunctionPointerType)fromType && cast(FunctionPointerType)toType)
        return true;

    if (cast(FunctionPointerType)fromType && cast(PointerType)toType)
        return true;

    if (cast(PointerType)fromType && cast(FunctionPointerType)toType)
        return true;

    return false;
}

public ReadOnlyIndexable!Type getSignature(Function function_, ref Type returnType)
{
    returnType = function_.returnType;

    auto types = new NoNullList!Type();

    foreach (param; function_.parameters)
        types.add(param.type);

    return types;
}

public ReadOnlyIndexable!Type getSignature(FunctionPointerType type, ref Type returnType) pure nothrow
{
    returnType = type.returnType;

    return type.parameterTypes;
}

public ReadOnlyIndexable!Type getSignature(Instruction callSite, ref Type returnType)
in
{
    assert(isCallSite(callSite.opCode));
}
body
{
    if (isDirectCallSite(callSite.opCode))
        return getSignature(*callSite.operand.peek!Function(), returnType);

    if (isIndirectCallSite(callSite.opCode))
        return getSignature(cast(FunctionPointerType)callSite.sourceRegister1.type, returnType);

    assert(false);
}
