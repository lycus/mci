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
            foreach (i, instr; bb.y.instructions)
            {
                if (instr.opCode !is opArgPush)
                    continue;

                // There must be a consecutive instruction as arg.push is not terminating.
                auto next = bb.y.instructions[i + 1];

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

        foreach (instr; entry.instructions)
        {
            if (instr.opCode is opArgPop && !valid)
                error(instr, "The 'arg.pop' instruction is only valid at the beginning of the 'entry' basic block.");
            else
                valid = false;
        }
    }
}
