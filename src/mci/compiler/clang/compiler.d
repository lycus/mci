module mci.compiler.clang.compiler;

import mci.compiler.base,
       mci.compiler.clang.generator,
       mci.core.common,
       mci.core.io,
       mci.core.code.functions,
       mci.vm.execution;

public final class ClangCompiler : mci.compiler.base.Compiler
{
    public this(ExecutionEngine engine) nothrow
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
        auto generator = new ClangCGenerator(this, FileStream.temporary());
        auto functionNames = generator.write(function_);

        assert(false);
    }
}
