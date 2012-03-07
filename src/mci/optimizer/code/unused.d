module mci.optimizer.code.unused;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.optimizer.base;

public final class UnusedRegisterRemover : OptimizerDefinition
{
    @property public override string name()
    {
        return "unused-reg";
    }

    @property public override string description()
    {
        return "Eliminates unused registers.";
    }

    @property public override PassType type()
    {
        return PassType.code;
    }

    public override OptimizerPass create()
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

public final class UnusedBasicBlockRemover : OptimizerDefinition
{
    @property public override string name()
    {
        return "unused-bb";
    }

    @property public override string description()
    {
        return "Eliminates unused basic blocks.";
    }

    @property public override PassType type()
    {
        return PassType.code;
    }

    public override OptimizerPass create()
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
                        if (auto lbl = insn.operand.peek!BasicBlock())
                            blocks.remove(*lbl);
                        else if (auto branch = insn.operand.peek!(Tuple!(BasicBlock, BasicBlock))())
                        {
                            blocks.remove(branch.x);
                            blocks.remove(branch.y);
                        }
                    }
                }

                foreach (block; blocks)
                    function_.removeBasicBlock(block);
            }
        };
    }
}
