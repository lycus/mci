module mci.core.tree.statements;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.tree.base;

public abstract class StatementNode : TreeNode
{
}

public class BlockNode : StatementNode
{
    private NoNullList!StatementNode _statements;
    
    public this()
    {
        _statements = new NoNullList!StatementNode();
    }
    
    @property public NoNullList!StatementNode statements()
    {
        return _statements;
    }
}

public class RawCodeNode : StatementNode
{
    private NoNullList!Instruction _instructions;
    
    @property public NoNullList!Instruction instructions()
    {
        return _instructions;
    }
}
