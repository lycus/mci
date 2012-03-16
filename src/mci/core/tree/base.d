module mci.core.tree.base;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.typing.types;

private __gshared List!TreeNode _emptyNodes;

shared static this()
{
    _emptyNodes = new typeof(_emptyNodes)();
}

public abstract class TreeNode
{
    private TreeNode _parent;

    @property public abstract Type type();

    @property public final TreeNode parent()
    {
        return _parent;
    }

    @property private final void parent(TreeNode parent)
    {
        _parent = parent;
    }

    @property public ReadOnlyIndexable!TreeNode children()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _emptyNodes;
    }

    public TreeNode reduce()
    {
        // No reduction possible by default.
        return null;
    }
}

public final class ChildNodeContainer(T : TreeNode) : NoNullList!T
{
    private TreeNode _node;

    invariant()
    {
        assert(_node);
    }

    public this(TreeNode node)
    in
    {
        assert(node);
    }
    body
    {
        _node = node;
    }

    public override ChildNodeContainer!T opSlice()
    {
        return duplicate();
    }

    public override ChildNodeContainer!T opSlice(size_t x, size_t y)
    {
        auto list = new ChildNodeContainer!T(_node);

        for (auto i = x; i < y; i++)
            list.add(this[i]);

        return list;
    }

    public override ChildNodeContainer!T opCat(Iterable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public override ChildNodeContainer!T opCatAssign(Iterable!T rhs)
    {
        foreach (item; rhs)
            add(item);

        return this;
    }

    public override ChildNodeContainer!T duplicate()
    {
        auto l = new ChildNodeContainer!T(_node);

        foreach (item; this)
            l.add(item);

        return l;
    }

    protected override void onAdd(T item)
    {
        super.onAdd(item);

        item.parent = _node;
    }

    protected override void onRemove(T item)
    {
        super.onRemove(item);

        item.parent = null;
    }

    protected override void onClear()
    {
        foreach (item; this)
            item.parent = null;
    }
}
