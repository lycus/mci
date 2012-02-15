module mci.optimizer.code.unused;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.optimizer.base;

public final class UnusedRegisterRemover : CodeOptimizer
{
    @property public string name()
    {
        return "unused-reg";
    }

    public void optimize(Function function_)
    {
        auto regs = new NoNullList!Register(function_.registers.values);

        foreach (bb; function_.blocks)
            foreach (insn; bb.y.stream)
                foreach (reg; insn.registers)
                    regs.remove(reg);

        foreach (reg; regs)
            function_.removeRegister(reg);
    }
}

public final class UnusedBasicBlockRemover : CodeOptimizer
{
    @property public string name()
    {
        return "unused-bb";
    }

    public void optimize(Function function_)
    {
        auto blocks = new NoNullList!BasicBlock(function_.blocks.values);

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
}
