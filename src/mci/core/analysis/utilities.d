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
    return find(block.stream, (Instruction i) { return i.opCode is opCode; });
}

public Instruction getFirstInstruction(BasicBlock block, OperandType operandType)
in
{
    assert(block);
}
body
{
    return find(block.stream, (Instruction i) { return i.opCode.operandType == operandType; });
}

public Instruction getFirstInstruction(BasicBlock block, OpCodeType type)
in
{
    assert(block);
}
body
{
    return find(block.stream, (Instruction instr) { return instr.opCode.type == type; });
}

public bool isNullable(Type type)
in
{
    assert(type);
}
body
{
    return isType!PointerType(type) ||
           isType!FunctionPointerType(type) ||
           isType!ReferenceType(type) ||
           isType!ArrayType(type) ||
           isType!VectorType(type);
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
           opCode is opCmpLTEq ||
           opCode is opCmpGTNEq ||
           opCode is opCmpLTNEq;
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
           opCode is opArrayCmpLTEq ||
           opCode is opArrayCmpGTNEq ||
           opCode is opArrayCmpLTNEq;
}

public bool isValidInArithmetic(Type type)
in
{
    assert(type);
}
body
{
    return isType!CoreType(type);
}

public bool isValidInBitwise(Type type)
in
{
    assert(type);
}
body
{
    return isType!IntegerType(type);
}

public bool isValidInComparison(Type type)
in
{
    assert(type);
}
body
{
    return isValidInArithmetic(type) || isType!PointerType(type);
}

public bool isArrayContainerOf(Type type, Type elementType)
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

    return false;
}

public bool isArrayContainerOfT(T)(Type type)
in
{
    assert(type);
}
body
{
    if (isArrayOrVector(type))
        return isType!T(getElementType(type));

    return false;
}

public bool isContainerOf(Type type, Type elementType)
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

public bool isArrayContainerOfOrElement(Type type, Type elementType)
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

public Type getElementType(Type type)
in
{
    assert(isType!PointerType(type) || isType!ArrayType(type) || isType!VectorType(type));
}
body
{
    if (auto vec = cast(VectorType)type)
        return vec.elementType;
    else if (auto arr = cast(ArrayType)type)
        return arr.elementType;
    else
        return (cast(PointerType)type).elementType;
}

public bool isArrayOrVector(Type type)
in
{
    assert(type);
}
body
{
    return isType!ArrayType(type) ||
           isType!VectorType(type);
}

public bool isManaged(Type type)
in
{
    assert(type);
}
body
{
    return isType!ReferenceType(type) || isArrayOrVector(type);
}

public bool isTypeSpecification(Type type)
in
{
    assert(type);
}
body
{
    return isManaged(type) || isType!PointerType(type);
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

public ReadOnlyIndexable!Type getSignature(FunctionPointerType type, ref Type returnType)
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
