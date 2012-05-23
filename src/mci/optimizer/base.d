module mci.optimizer.base;

import mci.core.code.functions;

/**
 * Represents an instance of an optimization pass.
 */
public abstract class OptimizerPass
{
    /**
     * Performs optimization on the given function. What kind of
     * optimization is done is specific to the pass.
     *
     * Params:
     *  function_ = The function to optimize.
     */
    public void optimize(Function function_);
}

/**
 * Indicates what level of the IR an optimizer operates on.
 */
public enum PassType : ubyte
{
    code, /// Any level; the optimizer will be invoked before and after $(D ir) and $(D ssa) passes.
    ir, /// Non-SSA; the optimizer will only be invoked on non-SSA functions.
    ssa, /// SSA (static single assignment form); the optimizer will only be invoked on SSA functions.
}

public abstract class OptimizerDefinition
{
    /**
     * Gets the name of this optimizer. This is what will be used
     * to invoke the optimizer from the command line.
     *
     * Returns:
     *  The name of this optimizer.
     */
    @property public abstract string name() pure nothrow;

    /**
     * Retrieves a description of this optimization pass.
     *
     * Returns:
     *  A human-friendly description of this optimization pass.
     */
    @property public abstract string description() pure nothrow;

    /**
     * Indicates what code this optimization pass is interested in.
     *
     * Returns:
     *  A $(D PassType) value indicating what code this pass is
     *  interested in.
     */
    @property public abstract PassType type() pure nothrow;

    /**
     * Indicates whether the optimization this pass performs is
     * considered unsafe. An unsafe optimization is one that can
     * change the original meaning or semantics of code in any way.
     *
     * Returns:
     *  $(D true) if this optimizer is unsafe; otherwise, $(D false).
     */
    @property public bool isUnsafe() pure nothrow
    {
        return false;
    }

    /**
     * Creates an instance of this optimization pass.
     *
     * Returns:
     *  An instance of this optimization pass.
     */
    public abstract OptimizerPass create() pure nothrow;
}
