module mci.optimizer.ssa.dce;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.analysis.constant,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes,
       mci.core.typing.core,
       mci.optimizer.base;

/**
 * Aggressively eliminates dead code.
 *
 * This pass generally assumes that all code is dead
 * until it has proven otherwise. This is more effective
 * than traditional dead code elimination algorithms,
 * since proving the live case is easier than proving
 * the dead case.
 */
public final class DeadCodeEliminator : OptimizerDefinition
{
    @property public override string name() pure nothrow
    {
        return "dce";
    }

    @property public override string description() pure nothrow
    {
        return "Eliminates dead code aggressively.";
    }

    @property public override PassType type() pure nothrow
    {
        return PassType.ssa;
    }

    public override OptimizerPass create() pure nothrow
    {
        return new class OptimizerPass
        {
            public override void optimize(Function function_)
            {
                auto live = new HashSet!Instruction();
                auto queue = new ArrayQueue!Instruction();

                foreach (block; function_.blocks)
                {
                    foreach (insn; block.y.stream)
                    {
                        if (!insn.opCode.hasTarget || hasSideEffect(insn.opCode))
                        {
                            live.add(insn);
                            queue.enqueue(insn);
                        }
                    }
                }

                while (!queue.empty)
                {
                    auto insn = queue.dequeue();

                    foreach (reg; insn.sourceRegisters)
                    {
                        auto def = first(reg.definitions);

                        // All instructions that define a register used by a
                        // live instruction are live, too.
                        if (live.add(def))
                            queue.enqueue(def);
                    }
                }

                auto dead = new NoNullList!Instruction();

                // Collect all the dead instructions.
                foreach (block; function_.blocks)
                    foreach (insn; block.y.stream)
                        if (insn !in live)
                            dead.add(insn);

                // Finally, kill all the dead instructions.
                foreach (insn; dead)
                    insn.block.stream.remove(insn);
            }
        };
    }
}
