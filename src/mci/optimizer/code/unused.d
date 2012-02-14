module mci.optimizer.code.unused;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.optimizer.base;

public final class UnusedRegisterRemover : CodeOptimizer
{
    public override void optimize(Function function_)
    {
        auto regs = new NoNullList!Register(function_.registers.values);

        foreach (bb; function_.blocks)
        {
            foreach (insn; bb.y.stream)
            {
                if (insn.targetRegister)
                    regs.remove(insn.targetRegister);

                if (insn.sourceRegister1)
                    regs.remove(insn.sourceRegister1);

                if (insn.sourceRegister2)
                    regs.remove(insn.sourceRegister2);

                if (insn.sourceRegister3)
                    regs.remove(insn.sourceRegister3);
            }
        }

        foreach (reg; regs)
            function_.removeRegister(reg);
    }
}

public final class UnusedBasicBlockRemover : CodeOptimizer
{
    public override void optimize(Function function_)
    {
        auto blocks = new NoNullList!BasicBlock(function_.blocks.values);

        foreach (bb; function_.blocks)
        {
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
