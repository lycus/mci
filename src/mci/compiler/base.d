module mci.compiler.base;

import mci.core.common,
       mci.core.code.functions,
       mci.vm.execution;

public abstract class Compiler
{
    private ExecutionEngine _engine;

    invariant()
    {
        assert(_engine);
    }

    protected this(ExecutionEngine engine)
    in
    {
        assert(engine);
    }
    body
    {
        _engine = engine;
    }

    @property public ExecutionEngine engine()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _engine;
    }

    public function_t compile(Function function_);
}
