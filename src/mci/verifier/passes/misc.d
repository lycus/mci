module mci.verifier.passes.misc;

import mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.verifier.base;

public final class EntryVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (!function_.blocks.get(entryBlockName))
            error(null, "Functions must have an 'entry' basic block.");
    }
}

public final class FieldStorageVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
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
