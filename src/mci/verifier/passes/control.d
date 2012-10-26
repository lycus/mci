module mci.verifier.passes.control;

import mci.core.container,
       mci.core.tuple,
       mci.core.analysis.cfg,
       mci.core.analysis.utilities,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.stream,
       mci.core.code.opcodes,
       mci.verifier.base;

public final class TerminatorVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto cfo = bb.y.getFirstInstruction(OpCodeType.controlFlow);

            if (!cfo)
                error(null, "All basic blocks must have a terminator.");

            if (cfo !is last(bb.y.stream))
                error(cfo, "A terminator instruction must be the last instruction in a basic block.");
        }
    }
}

public final class ReturnVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            auto leave = bb.y.getFirstInstruction(opLeave);

            if (leave && function_.returnType)
                    error(leave, "Function does not return 'void', so 'leave' is invalid.");

            auto ret = bb.y.getFirstInstruction(opReturn);

            if (ret && !function_.returnType)
                error(ret, "Function returns 'void', so 'return' is invalid.");
        }
    }
}

public final class FFIVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (auto inst = function_.getFirstInstruction(opFFI))
        {
            if (function_.blocks.count != 1)
                error(inst, "FFI functions may only have an 'entry' basic block.");

            auto bb = function_.blocks[entryBlockName];

            if (bb.stream.count != 1 || first(bb.stream) !is inst)
                error(inst, "FFI functions may only contain one 'ffi' instruction, terminating the 'entry' block.");

            if (function_.callingConvention == CallingConvention.standard)
                error(inst, "FFI functions must have either 'cdecl' or 'stdcall' calling convention.");
        }
    }
}

public final class RawVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (auto inst = function_.getFirstInstruction(opRaw))
        {
            if (function_.blocks.count != 1)
                error(inst, "Raw functions may only have an 'entry' basic block.");

            auto bb = function_.blocks[entryBlockName];

            if (bb.stream.count != 1 || first(bb.stream) !is inst)
                error(inst, "Raw functions may only contain one 'raw' instruction, terminating the 'entry' block.");

            if (function_.callingConvention == CallingConvention.standard)
                error(inst, "Raw functions must have either 'cdecl' or 'stdcall' calling convention.");
        }
    }
}

public final class ForwardVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        if (auto inst = function_.getFirstInstruction(opForward))
        {
            if (function_.blocks.count != 1)
                error(inst, "Forward functions may only have an 'entry' basic block.");

            auto bb = function_.blocks[entryBlockName];

            if (bb.stream.count != 1 || first(bb.stream) !is inst)
                error(inst, "Forward functions may only contain one 'forward' instruction, terminating the 'entry' block.");

            if (function_.callingConvention != CallingConvention.standard)
                error(inst, "Forward functions must have standard calling convention.");
        }
    }
}

public final class ExceptionContextVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
        {
            foreach (instr; bb.y.stream)
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
                        if (contains(unwindBlocks, (BasicBlock ub) => isReachableFrom(db, ub)))
                            illegalBranches.remove(db);

                    if (auto illegal = first(illegalBranches))
                        error(null, "Basic block %s branches to block %s (which uses '%s') but control does not come from any unwind block.",
                              illegal, bb.y, instr.opCode);

                    // Even if the BB contains other EH instructions, we've already done
                    // the checks that we need to do, so just break.
                    break;
                }
            }
        }
    }
}

public final class PhiRegisterVerifier : CodeVerifier
{
    public override void verify(Function function_)
    {
        foreach (bb; function_.blocks)
            foreach (instr; bb.y.stream)
                if (instr.opCode is opPhi)
                    foreach (reg; *instr.operand.peek!(ReadOnlyIndexable!Register)())
                        if (!contains(function_.registers, (Tuple!(string, Register) r) => r.y is reg))
                            error(instr, "Register %s is not within function %s.", reg, function_);
    }
}
