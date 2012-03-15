module mci.core.tree.base;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.typing.types;

public abstract class TreeNode
{
    @property public abstract Type type();

    @property public ReadOnlyIndexable!TreeNode children()
    out (result)
    {
        assert(result);
    }
    body
    {
        return new List!TreeNode();
    }

    public TreeNode reduce()
    {
        // No reduction possible by default.
        return null;
    }
}
