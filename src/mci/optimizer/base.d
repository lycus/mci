module mci.optimizer.base;

import mci.core.code.functions;

public abstract class OptimizerPass
{
    public void optimize(Function function_);
}

public enum PassType : ubyte
{
    tree,
    code,
    ir,
    ssa,
}

public abstract class OptimizerDefinition
{
    @property public abstract string name();

    @property public abstract string description();

    @property public abstract PassType type();

    @property public bool isUnsafe()
    {
        return false;
    }

    public abstract OptimizerPass create();
}
