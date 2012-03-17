module mci.core.tree.statements;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.tree.base;

public abstract class StatementNode : TreeNode
{
}

public class BlockNode : StatementNode
{
    private ChildNodeList!StatementNode _statements;

    invariant()
    {
        assert(_statements);
    }

    public this()
    {
        _statements = new typeof(_statements)(this);
    }

    @property public final ChildNodeList!StatementNode statements()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _statements;
    }
}

public class RawCodeNode : StatementNode
{
    private NoNullList!Instruction _instructions;

    invariant()
    {
        assert(_instructions);
    }

    public this()
    {
        _instructions = new typeof(_instructions)();
    }

    @property public final NoNullList!Instruction instructions()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _instructions;
    }
}
