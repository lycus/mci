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
    return find(block.instructions, (Instruction i) { return i.opCode is opCode; });
}

public Instruction getFirstInstruction(BasicBlock block, OperandType operandType)
in
{
    assert(block);
}
body
{
    return find(block.instructions, (Instruction i) { return i.opCode.operandType == operandType; });
}

public Instruction getFirstInstruction(BasicBlock block, OpCodeType type)
in
{
    assert(block);
}
body
{
    return find(block.instructions, (Instruction instr) { return instr.opCode.type == type; });
}

public bool isNullable(Type type)
in
{
    assert(type);
}
body
{
    return isType!PointerType(type) || isType!FunctionPointerType(type) || isType!ArrayType(type) || isType!VectorType(type);
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
           opCode is opArrayAddr;
}

public bool isValidInArithmetic(Type type)
in
{
    assert(type);
}
body
{
    if (isType!CoreType(type) || isType!PointerType(type))
        return true;

    if (auto vec = cast(VectorType)type)
        if (isType!CoreType(vec.elementType) || isType!PointerType(vec.elementType))
            return true;

    return false;
}

public bool isValidInBitwise(Type type)
in
{
    assert(type);
}
body
{
    if (isType!IntegerType(type) || isType!PointerType(type))
        return true;

    if (auto vec = cast(VectorType)type)
        if (isType!IntegerType(vec.elementType) || isType!PointerType(vec.elementType))
            return true;

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

    if (auto arr = cast(ArrayType)type)
        if (arr.elementType is elementType)
            return true;

    if (auto vec = cast(VectorType)type)
        if (vec.elementType is elementType)
            return true;

    return false;
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

public bool isTypeSpecification(Type type)
in
{
    assert(type);
}
body
{
    return isType!PointerType(type) ||
           isType!ReferenceType(type) ||
           isType!ArrayType(type) ||
           isType!VectorType(type);
}
