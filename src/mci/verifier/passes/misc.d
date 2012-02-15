module mci.verifier.passes.misc;

import mci.core.container,
       mci.core.tuple,
       mci.core.analysis.cfg,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.stream,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.verifier.base;

public final class EntryVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (!function_.blocks.get(entryBlockName))
            error(null, "Functions must have an 'entry' basic block.");
    }
}

public final class UnwindVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            if (bb.y.unwindBlock && !contains(function_.blocks, (Tuple!(string, BasicBlock) t) { return t.y is bb.y; }))
                error(null, "Unwind basic block '%s' is not within function '%s'.", bb, function_);
    }
}

public final class RegisterVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (insn; bb.y.stream)
            {
                if (insn.targetRegister && !contains(function_.registers, (Tuple!(string, Register) t) { return t.y is insn.targetRegister; }))
                    error(insn, "Target register '%s' is not within function '%s'.", insn.targetRegister, function_);

                if (insn.sourceRegister1 && !contains(function_.registers, (Tuple!(string, Register) t) { return t.y is insn.sourceRegister1; }))
                    error(insn, "Source register '%s' is not within function '%s'.", insn.sourceRegister1, function_);

                if (insn.sourceRegister2 && !contains(function_.registers, (Tuple!(string, Register) t) { return t.y is insn.sourceRegister2; }))
                    error(insn, "Source register '%s' is not within function '%s'.", insn.sourceRegister2, function_);

                if (insn.sourceRegister3 && !contains(function_.registers, (Tuple!(string, Register) t) { return t.y is insn.sourceRegister3; }))
                    error(insn, "Source register '%s' is not within function '%s'.", insn.sourceRegister3, function_);
            }
        }
    }
}

public final class JumpVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            if (auto instr = getFirstInstruction(bb.y, OperandType.label))
            {
                auto target = *instr.operand.peek!BasicBlock();

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target; }))
                    error(instr, "Target basic block '%s' is not within function '%s'.", target, function_);
            }
            else if (auto instr = getFirstInstruction(bb.y, OperandType.branch))
            {
                auto target = *instr.operand.peek!(Tuple!(BasicBlock, BasicBlock))();

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target.x; }))
                    error(instr, "False branch target basic block '%s' is not within function '%s'.", target.x, function_);

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target.y; }))
                    error(instr, "True branch target basic block '%s' is not within function '%s'.", target.y, function_);
            }
        }
    }
}

public final class FieldStorageVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (auto field = instr.operand.peek!Field())
                {
                    if (instr.opCode is opLoadOffset || instr.opCode is opFieldGet ||
                        instr.opCode is opFieldSet || instr.opCode is opFieldAddr)
                    {
                        if (field.storage != FieldStorage.instance)
                            error(instr, "Field reference must have instance storage.");
                    }
                    else if (instr.opCode is opFieldGGet || instr.opCode is opFieldGSet ||
                             instr.opCode is opFieldGAddr)
                    {
                        if (field.storage == FieldStorage.instance)
                            error(instr, "Field reference must have static storage.");
                    }
                }
            }
        }
    }
}

public final class CallSiteCountVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            size_t pushCount;
            size_t required;

            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opArgPush)
                {
                    pushCount++;
                    continue;
                }
                else if (isDirectCallSite(instr.opCode))
                    required = (*instr.operand.peek!Function()).parameters.count;
                else if (isIndirectCallSite(instr.opCode))
                    required = (cast(FunctionPointerType)instr.sourceRegister1.type).parameterTypes.count;
                else
                    continue;

                if (pushCount != required)
                    error(instr, "Insufficient 'arg.push' instructions.");

                pushCount = 0;
                required = 0;
            }
        }
    }
}

public final class FunctionArgumentCountVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        auto entry = function_.blocks[entryBlockName];

        if (!containsManagedCode(entry))
            return;

        for (size_t i = 0; i < function_.parameters.count; i++)
        {
            auto instr = entry.stream[i];

            if (instr.opCode !is opArgPop)
                error(instr, "Insufficient 'arg.pop' instructions.");
        }

        auto instr = entry.stream[function_.parameters.count];

        if (instr.opCode is opArgPop)
            error(instr, "Insufficient 'arg.pop' instructions.");
    }
}

public final class PhiRegisterCountVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            foreach (instr; bb.y.stream)
                if (instr.opCode is opPhi && !instr.operand.peek!(ReadOnlyIndexable!Register)().count)
                    error(instr, "The 'phi' instruction requires one or more registers.");
    }
}

public final class PhiPredecessorVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opPhi)
                {
                    auto predecessors = getPredecessors(bb.y);
                    auto registers = *instr.operand.peek!(ReadOnlyIndexable!Register)();

                    if (registers.count != predecessors.count)
                        error(instr, "The 'phi' instruction must have as many registers in the selector as its basic block has predecessors.");

                    auto predSet = new HashSet!BasicBlock();

                    foreach (reg; registers)
                    {
                        auto def = first(reg.definitions);

                        if (!def || !contains(predecessors, def.block))
                            error(instr, "Register '%s' is not defined in any predecessors.", reg);

                        if (!predSet.add(def.block))
                            error(instr, "Register '%s' defined in multiple predecessor basic blocks.", reg);
                    }
                }
            }
        }
    }
}

public final class SSAFormVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (function_.attributes & FunctionAttributes.ssa)
        {
            foreach (reg; function_.registers)
                if (reg.y.definitions.count > 1)
                    error(null, "Register '%s' assigned multiple times; invalid SSA form.", reg.y);
        }
        else
            if (auto phi = getFirstInstruction(function_, opPhi))
                error(phi, "The 'phi' instruction is not valid in non-SSA functions.");
    }
}
