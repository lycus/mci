module mci.optimizer.base;

import mci.core.code.functions;

public interface OptimizerPass
{
    @property public string name();
}

public interface TreeOptimizer : OptimizerPass
{
}

public interface CodeOptimizer : OptimizerPass
{
    public void optimize(Function function_);
}

public interface IROptimizer : CodeOptimizer
{
}

public interface SSAOptimizer : CodeOptimizer
{
}
