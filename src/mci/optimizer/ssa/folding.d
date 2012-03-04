module mci.optimizer.ssa.folding;

import mci.core.common,
       mci.core.container,
       mci.core.analysis.constant,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.core,
       mci.optimizer.base;

private OpCode typeToConstantLoadOpCode(CoreType type)
in
{
    assert(type);
}
out (result)
{
    assert(result);
}
body
{
    if (isType!Int8Type(type))
        return opLoadI8;
    else if (isType!UInt8Type(type))
        return opLoadUI8;
    else if (isType!Int16Type(type))
        return opLoadI16;
    else if (isType!UInt16Type(type))
        return opLoadUI16;
    else if (isType!Int32Type(type))
        return opLoadI32;
    else if (isType!UInt32Type(type))
        return opLoadUI32;
    else if (isType!Int64Type(type))
        return opLoadI64;
    else if (isType!UInt64Type(type))
        return opLoadUI64;
    else if (isType!Float32Type(type))
        return opLoadF32;
    else
        return opLoadF64;
}

private Constant operandToConstant(InstructionOperand operand)
in
{
    assert(operand.hasValue);
}
out (result)
{
    assert(result);
}
body
{
    if (auto val = operand.peek!byte())
        return new Constant(cast(long)*val);
    else if (auto val = operand.peek!ubyte())
        return new Constant(cast(ulong)*val);
    else if (auto val = operand.peek!short())
        return new Constant(cast(long)*val);
    else if (auto val = operand.peek!ushort())
        return new Constant(cast(ulong)*val);
    else if (auto val = operand.peek!int())
        return new Constant(cast(long)*val);
    else if (auto val = operand.peek!uint())
        return new Constant(cast(ulong)*val);
    else if (auto val = operand.peek!long())
        return new Constant(cast(long)*val);
    else if (auto val = operand.peek!ulong())
        return new Constant(cast(ulong)*val);
    else if (auto val = operand.peek!float())
        return new Constant(*val);
    else
        return new Constant(*operand.peek!double());
}

private InstructionOperand constantToOperand(Constant constant, CoreType type)
in
{
    assert(type);
}
out (result)
{
    assert(result.hasValue);
}
body
{
    InstructionOperand operand;

    if (isType!Int8Type(type))
        operand = constant.castTo!byte();
    else if (isType!UInt8Type(type))
        operand = constant.castTo!ubyte();
    else if (isType!Int16Type(type))
        operand = constant.castTo!short();
    else if (isType!UInt16Type(type))
        operand = constant.castTo!ushort();
    else if (isType!Int32Type(type))
        operand = constant.castTo!int();
    else if (isType!UInt32Type(type))
        operand = constant.castTo!uint();
    else if (isType!Int64Type(type))
        operand = constant.castTo!long();
    else if (isType!UInt64Type(type))
        operand = constant.castTo!ulong();
    else if (isType!Float32Type(type))
        operand = constant.castTo!float();
    else
        operand = constant.castTo!double();

    return operand;
}

private bool isFoldable(OpCode opCode)
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
           opCode is opAriNeg ||
           opCode is opBitAnd ||
           opCode is opBitOr ||
           opCode is opBitXOr ||
           opCode is opBitNeg ||
           opCode is opNot;
}

public final class ConstantFolder : OptimizerDefinition
{
    @property public override string name()
    {
        return "const-fold";
    }

    @property public override string description()
    {
        return "Folds constant computations.";
    }

    @property public override PassType type()
    {
        return PassType.ssa;
    }

    public override OptimizerPass create()
    {
        return new class OptimizerPass
        {
            public override void optimize(Function function_)
            {
                auto constantInsns = true;

                while (constantInsns)
                {
                    auto constantLoads = new NoNullList!Instruction();

                    foreach (bb; function_.blocks)
                        addRange(constantLoads, filter(bb.y.stream, (Instruction i) => isConstantLoad(i.opCode)));

                    auto constantOps = new NoNullList!Instruction();

                    foreach (bb; function_.blocks)
                        foreach (instr; bb.y.stream)
                            if (isFoldable(instr.opCode) && !instr.sourceRegisters.empty &&
                                all(instr.sourceRegisters, (Register r) => first(r.definitions) && isConstantLoad(first(r.definitions).opCode)))
                                constantOps.add(instr);

                    foreach (instr; constantOps)
                    {
                        Constant result;
                        auto r1 = operandToConstant(first(instr.sourceRegister1.definitions).operand);
                        Constant r2;
                        Constant r3;

                        if (instr.sourceRegister2)
                            r2 = operandToConstant(first(instr.sourceRegister2.definitions).operand);

                        if (instr.sourceRegister3)
                            r3 = operandToConstant(first(instr.sourceRegister3.definitions).operand);

                        if (instr.opCode is opAriAdd)
                            result = r1 + r2;
                        else if (instr.opCode is opAriSub)
                            result = r1 - r2;
                        else if (instr.opCode is opAriMul)
                            result = r1 * r2;
                        else if (instr.opCode is opAriDiv)
                        {
                            // Division by zero is undefined behavior, so we treat it as a no-op here.
                            if (isType!IntegerType(instr.targetRegister.type) && r2.castTo!ulong() == 0)
                                result = r1;
                            else
                                result = r1 / r2;
                        }
                        else if (instr.opCode is opAriRem)
                        {
                            // Division by zero is undefined behavior, so we treat it as a no-op here.
                            if (isType!IntegerType(instr.targetRegister.type) && r2.castTo!ulong() == 0)
                                result = r1;
                            else
                                result = r1 % r2;
                        }
                        else if (instr.opCode is opAriNeg)
                            result = -r1;
                        else if (instr.opCode is opBitAnd)
                            result = r1 & r2;
                        else if (instr.opCode is opBitOr)
                            result = r1 | r2;
                        else if (instr.opCode is opBitXOr)
                            result = r1 ^ r2;
                        else if (instr.opCode is opBitNeg)
                            result = ~r1;
                        else if (instr.opCode is opNot)
                            result = r1.not();

                        instr.block.stream.replace(instr, typeToConstantLoadOpCode(cast(CoreType)instr.targetRegister.type),
                                                   constantToOperand(result, cast(CoreType)instr.targetRegister.type),
                                                   instr.targetRegister, null, null, null);
                    }

                    // Kill constant loads that are no longer used. This includes those
                    // that were never used to begin with and those that are now rendered
                    // useless due to constant folding.
                    foreach (instr; constantLoads)
                        if (instr.targetRegister.uses.empty)
                            instr.block.stream.remove(instr);

                    constantInsns = !constantOps.empty;
                }
            }
        };
    }
}
