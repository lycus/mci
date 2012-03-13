module mci.vm.execution;

import core.stdc.stdlib,
       std.algorithm,
       std.socket,
       mci.core.config,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.intrinsics.context,
       mci.vm.memory.base,
       mci.vm.memory.layout;

public interface ExecutionEngine
{
    public RuntimeValue execute(Function function_, NoNullList!RuntimeValue arguments)
    in
    {
        assert(function_);
        assert(arguments);
        assert(arguments.count == function_.parameters.count);

        foreach (i, arg; arguments)
            assert(arg is function_.parameters[i].type);
    }
    out (result)
    {
        assert(function_.returnType ? !!result : !result);
    }

    public void startDebugger(Address address)
    in
    {
        assert(address);
    }

    public void stopDebugger();

    @property public GarbageCollector gc()
    out (result)
    {
        assert(result);
    }

    @property public VirtualMachineContext context()
    out (result)
    {
        assert(result);
    }
}

public final class RuntimeValue
{
    private Type _type;
    private GarbageCollector _gc;
    private ubyte* _data;

    invariant()
    {
        assert(_type);
        assert(_gc);
        assert(_data);
    }

    public this(GarbageCollector gc, Type type)
    in
    {
        assert(gc);
        assert(type);
    }
    body
    {
        _gc = gc;
        _type = type;

        // GC roots must be at least one machine word long.
        _data = cast(ubyte*)calloc(1, max(computeSize(NativeUIntType.instance, is32Bit), computeSize(type, is32Bit)));
        gc.addRoot(_data);
    }

    ~this()
    {
        _gc.removeRoot(_data);
        free(_data);
    }

    @property public GarbageCollector gc()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _gc;
    }

    @property public Type type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public ubyte* data()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _data;
    }
}
