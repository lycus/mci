module mci.verifier.passes.ordering;

import mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.verifier.base;

public final class CallSiteOrderVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (i, instr; bb.y.stream)
            {
                if (instr.opCode !is opArgPush)
                    continue;

                // There must be a consecutive instruction as arg.push is not terminating.
                auto next = bb.y.stream[i + 1];

                if (next.opCode is opArgPush || isCallSite(next.opCode))
                    continue;

                error(instr, "The 'arg.push' instruction is only valid just before a call site.");
            }
        }
    }
}

public final class FunctionArgumentOrderVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        auto entry = function_.blocks[entryBlockName];

        foreach (bb; function_.blocks)
        {
            if (bb.y is entry)
                continue;

            if (auto pop = getFirstInstruction(entry, opArgPop))
                error(pop, "The 'arg.pop' instruction is only valid at the beginning of the 'entry' basic block.");
        }

        auto valid = true;

        foreach (instr; entry.stream)
        {
            if (instr.opCode is opArgPop && !valid)
                error(instr, "The 'arg.pop' instruction is only valid at the beginning of the 'entry' basic block.");
            else
                valid = false;
        }
    }
}

public final class PhiOrderVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        auto entry = function_.blocks[entryBlockName];

        foreach (bb; function_.blocks)
            if (auto phi = getFirstInstruction(entry, opPhi))
                error(phi, "The 'phi' instruction is not valid in the 'entry' basic block.");

        foreach (bb; function_.blocks)
        {
            auto valid = true;

            foreach (instr; bb.y.stream)
            {
                if (instr.opCode is opPhi && !valid)
                    error(instr, "The 'phi' instruction is only valid at the beginning of a basic block.");
                else
                    valid = false;
            }
        }
    }
}

public final class TailCallReturnVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (i, instr; bb.y.stream)
            {
                if (instr.opCode is opCallTail)
                {
                    auto next = bb.y.stream[i + 1];

                    if (next.opCode !is opReturn)
                        error(instr, "The 'call.tail' instruction must be followed by a 'return' instruction.");

                    if (next.sourceRegister1 !is instr.targetRegister)
                        error(instr, "The 'return' instruction after a 'call.tail' instruction must return the resulting value from the call.");
                }
                else if (instr.opCode is opInvokeTail)
                    if (bb.y.stream[i + 1] !is opLeave)
                        error(instr, "The 'invoke.tail' instruction must be followed by a 'leave' instruction.");
            }
        }
    }
}
