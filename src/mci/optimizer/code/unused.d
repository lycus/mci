module mci.optimizer.code.unused;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.optimizer.base;

/**
 * Performs simple removal of unused registers.
 */
public final class UnusedRegisterRemover : OptimizerDefinition
{
    @property public override string name() pure nothrow
    {
        return "unused-reg";
    }

    @property public override string description() pure nothrow
    {
        return "Eliminates unused registers.";
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
                auto regs = new NoNullList!Register(function_.registers.values);

                foreach (bb; function_.blocks)
                    foreach (insn; bb.y.stream)
                        foreach (reg; insn.registers)
                            regs.remove(reg);

                foreach (reg; regs)
                    function_.removeRegister(reg);
            }
        };
    }
}

/**
 * Performs simple removal of unused basic blocks.
 */
public final class UnusedBasicBlockRemover : OptimizerDefinition
{
    @property public override string name() pure nothrow
    {
        return "unused-bb";
    }

    @property public override string description() pure nothrow
    {
        return "Eliminates unused basic blocks.";
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
                auto blocks = new NoNullList!BasicBlock(function_.blocks.values);

                blocks.remove(function_.blocks[entryBlockName]);

                foreach (bb; function_.blocks)
                {
                    if (bb.y.unwindBlock)
                        blocks.remove(bb.y.unwindBlock);

                    foreach (insn; bb.y.stream)
                    {
                        match(insn.operand,
                              (BasicBlock bb) => blocks.remove(bb),
                              (Tuple!(BasicBlock, BasicBlock) branch) => removeRange(blocks, [branch.x, branch.y]),
                              () {});
                    }
                }

                foreach (block; blocks)
                    function_.removeBasicBlock(block);
            }
        };
    }
}
