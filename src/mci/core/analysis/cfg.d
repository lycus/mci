module mci.core.analysis.cfg;

import std.variant,
       mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes;

/**
 * Indicates the kind of control flow an instruction performs.
 */
public enum ControlFlowType : ubyte
{
    exit, /// The instruction leaves the function immediately (one way or another).
    unconditional, /// The instruction branches to another basic block unconditionally.
    conditional, /// The instruction performs a conditional branch to one of two basic blocks.
}

/**
 * Represents a control flow branch.
 *
 * This wrapper allows access to individual target basic
 * blocks, while also allowing convenient iteration.
 */
public struct ControlFlowBranch
{
    private Instruction _instruction;
    private ControlFlowType _type;
    private BasicBlock _block1;
    private BasicBlock _block2;

    pure nothrow invariant()
    {
        assert(_instruction);

        final switch (_type)
        {
            case ControlFlowType.exit:
                assert(!_block1);
                assert(!_block2);
                break;
            case ControlFlowType.unconditional:
                assert(_block1);
                assert(!_block2);
                break;
            case ControlFlowType.conditional:
                assert(_block1);
                assert(_block2);
                break;
        }
    }

    @disable this();

    private this(Instruction instruction)
    in
    {
        assert(instruction);
        assert(instruction.opCode.type == OpCodeType.controlFlow);
    }
    body
    {
        _instruction = instruction;

        match(instruction.operand,
              (BasicBlock bb)
              {
                  _type = ControlFlowType.unconditional;
                  _block1 = bb;
              },
              (Tuple!(BasicBlock, BasicBlock) branch)
              {
                  _type = ControlFlowType.conditional;
                  _block1 = branch.x;
                  _block2 = branch.y;
              },
              () => _type = ControlFlowType.exit);
    }

    public int opApply(scope int delegate(BasicBlock) dg)
    {
        if (_block1)
        {
            auto status = dg(_block1);

            if (status)
                return status;
        }

        if (_block2)
        {
            auto status = dg(_block2);

            if (status)
                return status;
        }

        return 0;
    }

    public int opApply(scope int delegate(size_t, BasicBlock) dg)
    {
        if (_block1)
        {
            auto status = dg(0, _block1);

            if (status)
                return status;
        }

        if (_block2)
        {
            auto status = dg(1, _block2);

            if (status)
                return status;
        }

        return 0;
    }

    /**
     * Gets the instruction performing the branch.
     *
     * Returns:
     *  The instruction performing the branch.
     */
    @property public Instruction instruction() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _instruction;
    }

    /**
     * Gets the kind of branch this is.
     *
     * Returns:
     *  A $(D ControlFlowType) value indicating what kind of
     *  branch this is.
     */
    @property public ControlFlowType type() pure nothrow
    {
        return _type;
    }

    /**
     * Gets the first branch target. For $(D ControlFlowType.exit),
     * this will be $(D null). For $(D ControlFlowType.conditional),
     * this will be the true branch. For $(D ControlFlowType.unconditional),
     * this will be the unconditional target of the branch.
     *
     * Returns:
     *  The first target branch.
     */
    @property public BasicBlock block1() pure nothrow
    out (result)
    {
        assert(_type == ControlFlowType.exit ? !!result : !result);
    }
    body
    {
        return _block1;
    }

    /**
     * Gets the second branch target. For $(D ControlFlowType.exit)
     * and $(D ControlFlowType.unconditional), this will be $(D null).
     * For $(D ControlFlowType.conditional), this will be the false
     * branch.
     *
     * Returns:
     *  The second target branch.
     */
    @property public BasicBlock block2() pure nothrow
    out (result)
    {
        assert(_type == ControlFlowType.conditional ? !!result : !result);
    }
    body
    {
        return _block2;
    }
}

/**
 * Gets the branch targets of the terminator instruction
 * in a basic block. Assumes the input is verified IAL.
 *
 * Params:
 *  block = The basic block to retrieve branch targets for.
 *
 * Returns:
 *  The branch targets of $(D block) as a $(D ControlFlowBranch)
 *  instance.
 */
public ControlFlowBranch getBranches(BasicBlock block)
in
{
    assert(block);
}
body
{
    return ControlFlowBranch(last(block.stream));
}

/**
 * Gets a list of all the basic blocks that can directly branch
 * to the given basic block.
 *
 * Params:
 *  block = The basic block to calculate predecessors for.
 *
 * Returns:
 *  A list of all predecessors of $(D block). Can be empty.
 */
public ReadOnlyIndexable!BasicBlock getPredecessors(BasicBlock block)
in
{
    assert(block);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new NoNullList!BasicBlock();

    foreach (bb; block.function_.blocks)
        if (isDirectlyReachableFrom(block, bb.y))
            list.add(bb.y);

    return list;
}

/**
 * Indicates whether $(D toBlock) is directly reachable by a
 * branch in $(D fromBlock).
 *
 * Params:
 *  toBlock = The basic block to check branches from $(D fromBlock) against.
 *  fromBlock = The basic block to check for branches to $(D toBlock).
 *
 * Returns:
 *  $(D true) if $(D fromBlock) can directly reach $(D toBlock);
 *  otherwise, $(D false).
 */
public bool isDirectlyReachableFrom(BasicBlock toBlock, BasicBlock fromBlock)
in
{
    assert(toBlock);
    assert(fromBlock);
}
body
{
    foreach (br; getBranches(fromBlock))
        if (br is toBlock)
            return true;

    return false;
}

/**
 * Indicates whether $(D toBlock) is directly or indirectly
 * reachable from $(D fromBlock).
 *
 * Params:
 *  toBlock = The basic block to check for reachability from $(D fromBlock).
 *  fromBlock = The basic block to check for reachability to $(D toBlock).
 *
 * Returns:
 *  $(D true) if $(D fromBlock) can directly or indirectly reach
 *  $(D toBlock); otherwise, $(D false).
 */
public bool isReachableFrom(BasicBlock toBlock, BasicBlock fromBlock)
in
{
    assert(toBlock);
    assert(fromBlock);
}
body
{
    auto queue = new ArrayQueue!BasicBlock();
    auto set = new HashSet!BasicBlock();

    queue.enqueue(fromBlock);

    BasicBlock current;

    while (!queue.empty)
    {
        current = queue.dequeue();

        foreach (br; getBranches(current))
        {
            if (br is toBlock)
                return true;

            if (set.add(br))
                queue.enqueue(br);
        }
    }

    return false;
}
