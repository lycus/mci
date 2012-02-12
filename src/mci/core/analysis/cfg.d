module mci.core.analysis.cfg;

import std.variant,
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
    auto term = last(block.instructions);

    if (auto bb = term.operand.peek!BasicBlock())
        return toReadOnlyIndexable(*bb);
    else if (auto tup = term.operand.peek!(Tuple!(BasicBlock, BasicBlock))())
        return toReadOnlyIndexable(tup.x, tup.y);

    return new List!BasicBlock();
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
