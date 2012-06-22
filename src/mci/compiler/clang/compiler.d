module mci.compiler.clang.compiler;

import mci.compiler.base,
       mci.core.common,
       mci.core.code.functions,
       mci.vm.execution;

public final class ClangCompiler : mci.compiler.base.Compiler
{
    public this(ExecutionEngine engine)
    in
    {
        assert(engine);
    }
    body
    {
        super(engine);
    }

    public override function_t compile(Function function_)
    {
        assert(false);
    }
}
