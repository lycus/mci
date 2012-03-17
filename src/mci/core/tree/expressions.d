module mci.core.tree.expressions;

import mci.core.code.instructions,
       mci.core.tree.base;

public abstract class ExpressionNode : TreeNode
{
}

public class RegisterReferenceNode : ExpressionNode
{
    private Register _register;

    invariant()
    {
        assert(_register);
    }

    public this(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _register = register;
    }

    @property public final Register register()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _register;
    }

    @property public final void register(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _register = register;
    }
}

public abstract class UnaryExpressionNode : ExpressionNode
{
}

public abstract class BinaryExpressionNode : ExpressionNode
{
}
