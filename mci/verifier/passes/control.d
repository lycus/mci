module mci.verifier.passes.control;

import mci.core.container,
       mci.core.tuple,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.verifier.base;

public final class TerminatorVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto cfo = getFirstInstruction(bb.y, OpCodeType.controlFlow);

            if (!cfo)
                error(null, "All basic blocks must have a terminator.");

            if (cfo !is last(bb.y.instructions))
                error(cfo, "A terminator instruction must be the last instruction in a basic block.");
        }
    }
}

public final class JumpVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (instr.opCode.operandType == OperandType.label)
                {
                    auto target = *instr.operand.peek!BasicBlock();

                    if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target; }))
                        error(instr, "Target basic block '%s' is not within function '%s'.", target, function_);
                }
            }
        }
    }
}

public final class ReturnVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto leave = getFirstInstruction(bb.y, opLeave);

            if (leave && function_.returnType)
                    error(leave, "Function does not return 'void', so 'leave' is invalid.");

            auto ret = getFirstInstruction(bb.y, opReturn);

            if (ret && !function_.returnType)
                error(ret, "Function returns 'void', so 'return' is invalid.");
        }
    }
}

public final class FFIVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (auto inst = getFirstInstruction(function_, opFFI))
        {
            if (function_.blocks.count != 1)
                error(inst, "FFI functions may only have an 'entry' basic block.");

            auto bb = function_.blocks.get(entryBlockName);

            if (bb.instructions.count != 1 || bb.instructions[0] !is inst)
                error(inst, "FFI functions may only contain one 'ffi' instruction, terminating the 'entry' block.");
        }
    }
}

public final class RawVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (auto inst = getFirstInstruction(function_, opRaw))
        {
            if (function_.blocks.count != 1)
                error(inst, "Raw functions may only have an 'entry' basic block.");

            auto bb = function_.blocks.get(entryBlockName);

            if (bb.instructions.count != 1 || bb.instructions[0] !is inst)
                error(inst, "Raw functions may only contain one 'raw' instruction, terminating the 'entry' block.");
        }
    }
}
