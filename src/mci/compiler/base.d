module mci.compiler.base;

import mci.core.common,
       mci.core.code.functions,
       mci.vm.execution;

public abstract class Compiler
{
    private ExecutionEngine _engine;

    pure nothrow invariant()
    {
        assert(_engine);
    }

    protected this(ExecutionEngine engine) pure nothrow
    in
    {
        assert(engine);
    }
    body
    {
        _engine = engine;
    }

    @property public final ExecutionEngine engine() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _engine;
    }

    public abstract function_t compile(Function function_);
}
