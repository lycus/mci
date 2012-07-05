module mci.optimizer.code.noop;

import mci.core.container,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.optimizer.base;

/**
 * Removes all $(PRE nop) instructions in a function.
 */
public final class NopRemover : OptimizerDefinition
{
    @property public override string name() pure nothrow
    {
        return "nop-rem";
    }

    @property public override string description() pure nothrow
    {
        return "Removes nop instructions.";
    }

    @property public override PassType type() pure nothrow
    {
        return PassType.code;
    }

    public override OptimizerPass create() pure nothrow
    {
        return new class OptimizerPass
        {
            public override void optimize(Function function_)
            {
                auto insns = new NoNullList!Instruction();

                foreach (block; function_.blocks)
                    foreach (insn; block.y.stream)
                        if (insn.opCode is opNop)
                            insns.add(insn);

                foreach (insn; insns)
                    insn.block.stream.remove(insn);
            }
        };
    }
}

/**
 * Removes all $(PRE comment) instructions in a function.
 */
public final class CommentRemover : OptimizerDefinition
{
    @property public override string name() pure nothrow
    {
        return "comm-rem";
    }

    @property public override string description() pure nothrow
    {
        return "Removes comment instructions.";
    }

    @property public override PassType type() pure nothrow
    {
        return PassType.code;
    }

    public override OptimizerPass create() pure nothrow
    {
        return new class OptimizerPass
        {
            public override void optimize(Function function_)
            {
                auto insns = new NoNullList!Instruction();

                foreach (block; function_.blocks)
                    foreach (insn; block.y.stream)
                        if (insn.opCode is opComment)
                            insns.add(insn);

                foreach (insn; insns)
                    insn.block.stream.remove(insn);
            }
        };
    }
}
