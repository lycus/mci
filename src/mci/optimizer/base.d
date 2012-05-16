module mci.optimizer.base;

import mci.core.code.functions;

public abstract class OptimizerPass
{
    public void optimize(Function function_);
}

public enum PassType : ubyte
{
    code,
    ir,
    ssa,
}

public abstract class OptimizerDefinition
{
    @property public abstract string name() pure nothrow;

    @property public abstract string description() pure nothrow;

    @property public abstract PassType type() pure nothrow;

    @property public bool isUnsafe() pure nothrow
    {
        return false;
    }

    public abstract OptimizerPass create() pure nothrow;
}
