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
    return match(type,
                 (Int8Type t) => opLoadI8,
                 (UInt8Type t) => opLoadUI8,
                 (Int16Type t) => opLoadI16,
                 (UInt16Type t) => opLoadUI16,
                 (Int32Type t) => opLoadI32,
                 (UInt32Type t) => opLoadUI32,
                 (Int64Type t) => opLoadI64,
                 (UInt64Type t) => opLoadUI64,
                 (Float32Type t) => opLoadF32,
                 (Float64Type t) => opLoadF64);
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
    return match(operand,
                 (byte v) => new Constant(cast(long)v),
                 (ubyte v) => new Constant(cast(ulong)v),
                 (short v) => new Constant(cast(long)v),
                 (ushort v) => new Constant(cast(ulong)v),
                 (int v) => new Constant(cast(long)v),
                 (uint v) => new Constant(cast(ulong)v),
                 (long v) => new Constant(v),
                 (ulong v) => new Constant(v),
                 (float v) => new Constant(v),
                 (double v) => new Constant(v));
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

    match(type,
          (Int8Type t) => operand = constant.castTo!byte(),
          (UInt8Type t) => operand = constant.castTo!ubyte(),
          (Int16Type t) => operand = constant.castTo!short(),
          (UInt16Type t) => operand = constant.castTo!ushort(),
          (Int32Type t) => operand = constant.castTo!int(),
          (UInt32Type t) => operand = constant.castTo!uint(),
          (Int64Type t) => operand = constant.castTo!long(),
          (UInt64Type t) => operand = constant.castTo!ulong(),
          (Float32Type t) => operand = constant.castTo!float(),
          (Float64Type t) => operand = constant.castTo!double());

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

                    auto insns = constantOps.duplicate();

                    foreach (instr; insns)
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
                            // We can't handle division by zero in any sane fashion, so we simply stop folding.
                            if (tryCast!IntegerType(instr.targetRegister.type) && r2.castTo!ulong() == 0)
                                constantOps.remove(instr);
                            else
                                result = r1 / r2;
                        }
                        else if (instr.opCode is opAriRem)
                        {
                            // We can't handle division by zero in any sane fashion, so we simply stop folding.
                            if (tryCast!IntegerType(instr.targetRegister.type) && r2.castTo!ulong() == 0)
                                constantOps.remove(instr);
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

                        if (result)
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
