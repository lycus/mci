module mci.optimizer.base;

import mci.core.code.functions;

public abstract class OptimizerPass
{
    @property public abstract string name();

    @property public bool isUnsafe()
    {
        return false;
    }
}

public abstract class TreeOptimizer : OptimizerPass
{
}

public abstract class CodeOptimizer : OptimizerPass
{
    public void optimize(Function function_);
}

public abstract class IROptimizer : CodeOptimizer
{
}

public abstract class SSAOptimizer : CodeOptimizer
{
}
