module mci.optimizer.manager;

import std.traits,
       mci.core.container,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.optimizer.base,
       mci.optimizer.code.unused,
       mci.optimizer.ssa.folding;

public __gshared ReadOnlyCollection!OptimizerDefinition allOptimizers; /// All included optimization passes.
public __gshared ReadOnlyCollection!OptimizerDefinition fastOptimizers; /// All fast optimization passes.
public __gshared ReadOnlyCollection!OptimizerDefinition moderateOptimizers; /// All moderate optimization passes.
public __gshared ReadOnlyCollection!OptimizerDefinition slowOptimizers; /// All slow optimization passes.
public __gshared ReadOnlyCollection!OptimizerDefinition unsafeOptimizers; /// All unsafe optimization passes (not present in the other collections).

shared static this()
{
    auto all = new NoNullList!OptimizerDefinition();
    auto fast = new NoNullList!OptimizerDefinition();
    auto moderate = new NoNullList!OptimizerDefinition();
    auto slow = new NoNullList!OptimizerDefinition();
    auto unsafe = new NoNullList!OptimizerDefinition();

    void addOptimizer(OptimizerDefinition optimizer, NoNullList!OptimizerDefinition list)
    in
    {
        assert(optimizer);
        assert(list);
        assert(list !is all);
        assert(list !is unsafe);
    }
    body
    {
        list.add(optimizer);

        if (optimizer.isUnsafe)
            unsafe.add(optimizer);

        all.add(optimizer);
    }

    addOptimizer(new UnusedBasicBlockRemover(), fast);
    addOptimizer(new UnusedRegisterRemover(), fast);
    addOptimizer(new ConstantFolder(), fast);

    allOptimizers = all;
    fastOptimizers = fast;
    moderateOptimizers = moderate;
    slowOptimizers = slow;
    unsafeOptimizers = unsafe;
}

/**
 * Manages and executes optimization passes on functions.
 */
public final class OptimizationManager
{
    private NoNullList!OptimizerPass _codeOptimizers;
    private NoNullList!OptimizerPass _irOptimizers;
    private NoNullList!OptimizerPass _ssaOptimizers;
    private NoNullList!OptimizerDefinition _definitions;

    invariant()
    {
        assert(_codeOptimizers);
        assert(_irOptimizers);
        assert(_ssaOptimizers);
        assert(_definitions);
    }

    /**
     * Constructs a new $(D OptimizationManager) instance.
     */
    public this()
    {
        _codeOptimizers = new typeof(_codeOptimizers)();
        _irOptimizers = new typeof(_irOptimizers)();
        _ssaOptimizers = new typeof(_ssaOptimizers)();
        _definitions = new typeof(_definitions)();
    }

    /**
     * Gets all registered optimizers.
     *
     * Returns:
     *  All registered optimizers.
     */
    @property public ReadOnlyCollection!OptimizerDefinition definitions() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _definitions;
    }

    /**
     * Adds an optimization pass.
     *
     * Params:
     *  pass = The optimization pass to add.
     */
    public void addPass(OptimizerDefinition pass)
    in
    {
        assert(pass);
    }
    body
    {
        auto instance = pass.create();

        final switch (pass.type)
        {
            case PassType.code:
                _codeOptimizers.add(instance);
                break;
            case PassType.ir:
                _irOptimizers.add(instance);
                break;
            case PassType.ssa:
                _ssaOptimizers.add(instance);
                break;
        }

        _definitions.add(pass);
    }

    /**
     * Runs all registered optimization passes on a function.
     *
     * First runs all optimizers that operate on any IR level. Then
     * runs all optimizers that operate on non-SSA or SSA IR depending
     * on whether the function has $(D FunctionAttributes.ssa). Finally,
     * invokes all optimizers that operate on any IR level (again).
     *
     * If the function has $(D FunctionAttributes.noOptimization), no
     * optimization will happen. Otherwise, this will very likely
     * mutate the IR of $(D function_).
     *
     * Params:
     *  function_ = The function to optimize.
     */
    public void optimize(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        if (function_.attributes & FunctionAttributes.noOptimization)
            return;

        if (first(function_.blocks[entryBlockName].stream).opCode is opRaw)
            return;

        foreach (opt; _codeOptimizers)
            opt.optimize(function_);

        if (function_.attributes & FunctionAttributes.ssa)
        {
            foreach (opt; _ssaOptimizers)
                opt.optimize(function_);
        }
        else
            foreach (opt; _irOptimizers)
                opt.optimize(function_);

        foreach (opt; _codeOptimizers)
            opt.optimize(function_);
    }
}
