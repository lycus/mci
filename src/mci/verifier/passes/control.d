module mci.verifier.passes.control;

import mci.core.container,
       mci.core.tuple,
       mci.core.analysis.cfg,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
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

public final class JumpVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            if (auto instr = getFirstInstruction(bb.y, OperandType.label))
            {
                auto target = *instr.operand.peek!BasicBlock();

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target; }))
                    error(instr, "Target basic block '%s' is not within function '%s'.", target, function_);
            }
            else if (auto instr = getFirstInstruction(bb.y, OperandType.branch))
            {
                auto target = *instr.operand.peek!(Tuple!(BasicBlock, BasicBlock))();

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target.x; }))
                    error(instr, "False branch target basic block '%s' is not within function '%s'.", target.x, function_);

                if (!contains(function_.blocks, (Tuple!(string, BasicBlock) b) { return b.y is target.y; }))
                    error(instr, "True branch target basic block '%s' is not within function '%s'.", target.y, function_);
            }
        }
    }
}

public final class ReturnVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto leave = getFirstInstruction(bb.y, opLeave);

            if (leave && function_.returnType)
                    error(leave, "Function does not return 'void', so 'leave' is invalid.");

            auto ret = getFirstInstruction(bb.y, opReturn);

            if (ret && !function_.returnType)
                error(ret, "Function returns 'void', so 'return' is invalid.");
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

            auto bb = function_.blocks[entryBlockName];

            if (bb.instructions.count != 1 || bb.instructions[0] !is inst)
                error(inst, "FFI functions may only contain one 'ffi' instruction, terminating the 'entry' block.");

            if (!function_.callingConvention)
                error(inst, "FFI functions must have either 'cdecl' or 'stdcall' calling convention.");
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

            auto bb = function_.blocks[entryBlockName];

            if (bb.instructions.count != 1 || bb.instructions[0] !is inst)
                error(inst, "Raw functions may only contain one 'raw' instruction, terminating the 'entry' block.");
        }
    }
}

public final class ExceptionContextVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.instructions)
            {
                if (instr.opCode is opEHCatch || instr.opCode is opEHRethrow)
                {
                    auto directBranches = new NoNullList!BasicBlock();

                    foreach (block; function_.blocks)
                        if (isDirectlyReachableFrom(bb.y, block.y))
                            directBranches.add(block.y);

                    auto unwindBlocks = new HashSet!BasicBlock();

                    foreach (block; function_.blocks)
                    {
                        if (block.y.unwindBlock)
                        {
                            unwindBlocks.add(block.y.unwindBlock);

                            // We're not interested in unwind blocks, as those are allowed
                            // to branch directly to this BB.
                            directBranches.remove(block.y.unwindBlock);
                        }
                    }

                    auto illegalBranches = directBranches.duplicate();

                    // Remove all reachable blocks from illegalBranches such that the blocks
                    // we end up with are the ones not reachable from any unwind block.
                    foreach (db; directBranches)
                        if (contains(unwindBlocks, (BasicBlock ub) { return isReachableFrom(db, ub); }))
                            illegalBranches.remove(db);

                    if (auto illegal = first(illegalBranches))
                        error(null, "Basic block '%s' branches to block '%s' (which uses '%s') but control does not come from any unwind block.",
                              illegal.name, bb.y.name, instr.opCode.name);

                    // Even if the BB contains other EH instructions, we've already done
                    // the checks that we need to do, so just break.
                    break;
                }
            }
        }
    }
}
