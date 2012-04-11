module mci.core.analysis.cfg;

import std.variant,
       mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.opcodes;

public enum ControlFlowType : ubyte
{
    exit,
    unconditional,
    conditional,
}

public struct ControlFlowBranch
{
    private BasicBlock _block;
    private ControlFlowType _type;
    private BasicBlock _block1;
    private BasicBlock _block2;

    invariant()
    {
        assert(_block);

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

    private this(BasicBlock block, Instruction instruction)
    in
    {
        assert(block);
        assert(instruction);
        assert(instruction.opCode.type == OpCodeType.controlFlow);
    }
    body
    {
        _block = block;

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

    @property public BasicBlock block()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _block;
    }

    @property public ControlFlowType type()
    {
        return _type;
    }

    @property public BasicBlock block1()
    out (result)
    {
        assert(_type == ControlFlowType.exit ? !!result : !result);
    }
    body
    {
        return _block1;
    }

    @property public BasicBlock block2()
    out (result)
    {
        assert(_type == ControlFlowType.conditional ? !!result : !result);
    }
    body
    {
        return _block2;
    }
}

public ControlFlowBranch getBranches(BasicBlock block)
in
{
    assert(block);
}
body
{
    return ControlFlowBranch(block, last(block.stream));
}

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

            if (!set.add(br))
                continue;

            queue.enqueue(br);
        }
    }

    return false;
}
