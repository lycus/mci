module mci.core.analysis.cfg;

import std.variant,
       mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions;

public ReadOnlyIndexable!BasicBlock getBranches(BasicBlock block)
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
    auto term = last(block.stream);

    return match(term.operand,
                 (BasicBlock bb) => toReadOnlyIndexable(bb),
                 (Tuple!(BasicBlock, BasicBlock) branch) => toReadOnlyIndexable(branch.x, branch.y),
                 () => new List!BasicBlock());
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
