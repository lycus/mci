module mci.jit.engine;

import std.socket,
       mci.compiler.base,
       mci.compiler.clang.compiler,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.types,
       mci.vm.execution,
       mci.vm.memory.base;

public enum JITBackEnd : ubyte
{
    native,
    clang,
}

public final class JITEngine : ExecutionEngine
{
    private JITBackEnd _backEnd;
    private mci.compiler.base.Compiler _compiler;

    public this(JITBackEnd backEnd, GarbageCollector gc)
    in
    {
        assert(gc);
    }
    body
    {
        super(gc);

        _backEnd = backEnd;

        final switch (backEnd)
        {
            case JITBackEnd.native:
                static if (architecture == Architecture.x86)
                    assert(false);
                else static if (architecture == Architecture.arm)
                    assert(false);
                else static if (architecture == Architecture.ppc)
                    assert(false);
                else static if (architecture == Architecture.ia64)
                    assert(false);
                else
                    assert(false);
            case JITBackEnd.clang:
                _compiler = new ClangCompiler(this);
                break;
        }
    }

    @property public JITBackEnd backEnd() pure nothrow
    {
        return _backEnd;
    }

    @property public mci.compiler.base.Compiler compiler() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _compiler;
    }

    public override RuntimeValue execute(Function function_, NoNullList!RuntimeValue arguments)
    {
        // TODO: Implement.
        assert(false);
    }

    public override RuntimeValue execute(function_t function_, CallingConvention callingConvention, Type returnType, NoNullList!RuntimeValue arguments)
    {
        assert(false);
    }

    public override void startDebugger(Address address)
    {
        // FIXME: Implement debugging.
        assert(false);
    }

    public override void stopDebugger()
    {
        assert(false);
    }
}
