module mci.optimizer.manager;

import mci.core.container,
       mci.core.code.functions,
       mci.optimizer.base;

public final class OptimizationManager
{
    private NoNullList!TreeOptimizer _treeOptimizers;
    private NoNullList!CodeOptimizer _codeOptimizers;
    private NoNullList!IROptimizer _irOptimizers;
    private NoNullList!SSAOptimizer _ssaOptimizers;

    invariant()
    {
        assert(_treeOptimizers);
        assert(_codeOptimizers);
        assert(_irOptimizers);
        assert(_ssaOptimizers);
    }

    public this()
    {
        _treeOptimizers = new typeof(_treeOptimizers)();
        _codeOptimizers = new typeof(_codeOptimizers)();
        _irOptimizers = new typeof(_irOptimizers)();
        _ssaOptimizers = new typeof(_ssaOptimizers)();
    }

    public void addPass(OptimizerPass pass)
    in
    {
        assert(pass);
    }
    body
    {
        if (auto tree = cast(TreeOptimizer)pass)
            _treeOptimizers.add(tree);
        else if (auto ir = cast(IROptimizer)pass)
            _irOptimizers.add(ir);
        else if (auto ssa = cast(SSAOptimizer)pass)
            _ssaOptimizers.add(ssa);
        else
            _codeOptimizers.add(cast(CodeOptimizer)pass);
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
