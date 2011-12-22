module mci.core.analysis.utilities;

import mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
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
