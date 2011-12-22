module mci.verifier.passes.control;

import mci.core.container,
       mci.core.analysis.utilities,
       mci.core.code.functions,
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
