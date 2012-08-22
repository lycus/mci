module mci.core.analysis.utilities;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.core,
       mci.core.typing.types;

public Instruction getFirstInstruction(Function function_, OpCode opCode)
in
{
    assert(function_);
    assert(opCode);
}
body
{
    foreach (bb; function_.blocks)
        if (auto instr = getFirstInstruction(bb.y, opCode))
            return instr;

    return null;
}

public Instruction getFirstInstruction(BasicBlock block, OpCode opCode)
in
{
    assert(block);
    assert(opCode);
}
body
{
    return find(block.stream, (Instruction i) => i.opCode is opCode);
}

public Instruction getFirstInstruction(BasicBlock block, OperandType operandType)
in
{
    assert(block);
}
body
{
    return find(block.stream, (Instruction i) => i.opCode.operandType == operandType);
}

public Instruction getFirstInstruction(BasicBlock block, OpCodeType type)
in
{
    assert(block);
}
body
{
    return find(block.stream, (Instruction instr) => instr.opCode.type == type);
}

public bool isArithmetic(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opAriAdd ||
           opCode is opAriSub ||
           opCode is opAriMul ||
           opCode is opAriDiv ||
           opCode is opAriRem ||
           opCode is opAriNeg;
}

public bool isBitwise(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opBitAnd ||
           opCode is opBitOr ||
           opCode is opBitXOr ||
           opCode is opBitNeg;
}

public bool isShift(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opShL ||
           opCode is opShR;
}

public bool isRotate(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opRoL ||
           opCode is opRoR;
}

public bool isBitShift(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return isShift(opCode) || isRotate(opCode);
}

public bool isComparison(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opCmpEq ||
           opCode is opCmpNEq ||
           opCode is opCmpGT ||
           opCode is opCmpLT ||
           opCode is opCmpGTEq ||
           opCode is opCmpLTEq;
}

public bool isArray(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayGet ||
           opCode is opArraySet ||
           opCode is opArrayAddr ||
           opCode is opArrayLen;
}

public bool isArrayArithmetic(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayAriAdd ||
           opCode is opArrayAriSub ||
           opCode is opArrayAriMul ||
           opCode is opArrayAriDiv ||
           opCode is opArrayAriRem ||
           opCode is opArrayAriNeg;
}

public bool isArrayBitwise(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayBitAnd ||
           opCode is opArrayBitOr ||
           opCode is opArrayBitXOr ||
           opCode is opArrayBitNeg;
}

public bool isArrayShift(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayShL ||
           opCode is opArrayShR;
}

public bool isArrayRotate(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayRoL ||
           opCode is opArrayRoR;
}

public bool isArrayBitShift(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return isArrayShift(opCode) || isArrayRotate(opCode);
}

public bool isArrayComparison(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opArrayCmpEq ||
           opCode is opArrayCmpNEq ||
           opCode is opArrayCmpGT ||
           opCode is opArrayCmpLT ||
           opCode is opArrayCmpGTEq ||
           opCode is opArrayCmpLTEq;
}

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

public bool isFloatingPointConstantLoad(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opLoadF32 ||
           opCode is opLoadF64;
}

public bool isIntegralConstantLoad(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opLoadI8 ||
           opCode is opLoadUI8 ||
           opCode is opLoadI16 ||
           opCode is opLoadUI16 ||
           opCode is opLoadI32 ||
           opCode is opLoadUI32 ||
           opCode is opLoadI64 ||
           opCode is opLoadUI64;
}

public bool isConstantLoad(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return isIntegralConstantLoad(opCode) || isFloatingPointConstantLoad(opCode);
}

public bool isDirectCallSite(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opCall ||
           opCode is opCallTail ||
           opCode is opInvoke ||
           opCode is opInvokeTail;
}

public bool isIndirectCallSite(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return opCode is opCallIndirect ||
           opCode is opInvokeIndirect;
}

public bool isCallSite(OpCode opCode)
in
{
    assert(opCode);
}
body
{
    return isDirectCallSite(opCode) ||
           isIndirectCallSite(opCode);
}

public bool hasSideEffect(OpCode opCode)
in
{
    assert(opCode);
    assert(opCode.hasTarget);
}
body
{
    return opCode is opLoadI8A ||
           opCode is opLoadUI8A ||
           opCode is opLoadI16A ||
           opCode is opLoadUI16A ||
           opCode is opLoadI32A ||
           opCode is opLoadUI32A ||
           opCode is opLoadI64A ||
           opCode is opLoadUI64A ||
           opCode is opLoadF32A ||
           opCode is opLoadF64A ||
           opCode is opMemAlloc ||
           opCode is opMemNew ||
           opCode is opMemSAlloc ||
           opCode is opMemSNew ||
           opCode is opMemPin ||
           opCode is opMemAddr ||
           opCode is opArrayAddr ||
           opCode is opFieldAddr ||
           opCode is opFieldUserAddr ||
           opCode is opArgPop ||
           opCode is opCall ||
           opCode is opCallTail ||
           opCode is opCallIndirect ||
           opCode is opPhi ||
           opCode is opEHCatch ||
           opCode is opTramp;
}

public bool containsManagedCode(BasicBlock block)
{
    return !getFirstInstruction(block, opFFI) && !getFirstInstruction(block, opRaw);
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
