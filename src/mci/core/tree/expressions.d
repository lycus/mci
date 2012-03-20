module mci.core.tree.expressions;

import mci.core.code.instructions,
       mci.core.tree.base,
       mci.core.typing.types;

public abstract class ExpressionNode : TreeNode
{
}

public abstract class TargetExpressionNode : ExpressionNode
{
}

public class RegisterReferenceNode : TargetExpressionNode
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

    @property public override Type type()
    {
        return _register.type;
    }
}

public abstract class UnaryExpressionNode : ExpressionNode
{
    private ExpressionNode _operand;

    invariant()
    {
        assert(_operand);
    }

    protected this(ExpressionNode operand)
    in
    {
        assert(operand);
    }
    body
    {
        _operand = operand;
    }

    @property public final ExpressionNode operand()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _operand;
    }

    @property public final void operand(ExpressionNode operand)
    in
    {
        assert(operand);
    }
    body
    {
        _operand = operand;
    }

    @property public override Type type()
    {
        return _operand.type;
    }
}

public abstract class BinaryExpressionNode : ExpressionNode
{
    private ExpressionNode _leftOperand;
    private ExpressionNode _rightOperand;

    invariant()
    {
        assert(_leftOperand);
        assert(_rightOperand);
        assert((cast()_leftOperand).type == (cast()_rightOperand).type);
    }

    protected this(ExpressionNode leftOperand, ExpressionNode rightOperand)
    in
    {
        assert(leftOperand);
        assert(rightOperand);
        assert(_leftOperand.type == _rightOperand.type);
    }
    body
    {
        _leftOperand = leftOperand;
        _rightOperand = rightOperand;
    }

    @property public final ExpressionNode leftOperand()
    out (result)
    {
        assert(result);
        assert((cast()result).type == (cast()_rightOperand).type);
    }
    body
    {
        return _leftOperand;
    }

    @property public final void leftOperand(ExpressionNode leftOperand)
    in
    {
        assert(leftOperand);
        assert(leftOperand.type == _rightOperand.type);
    }
    body
    {
        _leftOperand = leftOperand;
    }

    @property public final ExpressionNode rightOperand()
    out (result)
    {
        assert(result);
        assert((cast()result).type == (cast()_leftOperand).type);
    }
    body
    {
        return _rightOperand;
    }

    @property public final void rightOperand(ExpressionNode rightOperand)
    in
    {
        assert(rightOperand);
        assert(rightOperand.type == _leftOperand.type);
    }
    body
    {
        _rightOperand = rightOperand;
    }

    @property public override Type type()
    {
        return _leftOperand.type;
    }
}
