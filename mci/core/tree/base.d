module mci.core.tree.base;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.diagnostics.debugging,
       mci.core.typing.types;

public abstract class TreeNode
{
    private DebuggingInfo _debugInfo;

    @property public abstract Type type();

    @property public Countable!TreeNode children()
    {
        return new List!TreeNode();
    }

    @property public final DebuggingInfo debugInfo()
    {
        return _debugInfo;
    }

    @property public final void debugInfo(DebuggingInfo debugInfo)
    {
        _debugInfo = debugInfo;
    }

    @property public bool isReducible()
    {
        return false;
    }

    public TreeNode reduce()
    in
    {
        assert(isReducible);
    }
    body
    {
        assert(false);
    }

    public Countable!Instruction generateCode()
    {
        return new List!Instruction();
    }
}
