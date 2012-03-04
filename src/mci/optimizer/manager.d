module mci.optimizer.manager;

import std.traits,
       mci.core.container,
       mci.core.code.functions,
       mci.optimizer.base,
       mci.optimizer.code.unused;

public __gshared ReadOnlyCollection!OptimizerDefinition allOptimizers;
public __gshared ReadOnlyCollection!OptimizerDefinition fastOptimizers;
public __gshared ReadOnlyCollection!OptimizerDefinition moderateOptimizers;
public __gshared ReadOnlyCollection!OptimizerDefinition slowOptimizers;
public __gshared ReadOnlyCollection!OptimizerDefinition unsafeOptimizers;

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

    allOptimizers = all;
    fastOptimizers = fast;
    moderateOptimizers = moderate;
    slowOptimizers = slow;
    unsafeOptimizers = unsafe;
}

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

    public this()
    {
        _codeOptimizers = new typeof(_codeOptimizers)();
        _irOptimizers = new typeof(_irOptimizers)();
        _ssaOptimizers = new typeof(_ssaOptimizers)();
        _definitions = new typeof(_definitions)();
    }

    @property public ReadOnlyCollection!OptimizerDefinition definitions()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _definitions;
    }

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

    public void optimize(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
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
    }
}
