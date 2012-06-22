module mci.jit.engine;

import std.socket,
       mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.types,
       mci.vm.execution,
       mci.vm.memory.base;

public final class JITEngine : ExecutionEngine
{
    protected this(GarbageCollector gc)
    in
    {
        assert(gc);
    }
    body
    {
        super(gc);
    }

    public override void terminate()
    {
        // TODO: Release all resources.
        super.terminate();
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
