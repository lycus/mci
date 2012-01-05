module mci.core.tree.expressions;

import mci.core.tree.base;

public abstract class ExpressionNode : TreeNode
{
}

public abstract class UnaryExpressionNode : ExpressionNode
{
}

public abstract class BinaryExpressionNode : ExpressionNode
{
}

public abstract class TernaryExpressionNode : ExpressionNode
{
}
