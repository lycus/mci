module mci.vm.execution;

import core.stdc.stdlib,
       std.algorithm,
       std.socket,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.intrinsics.context,
       mci.vm.memory.base,
       mci.vm.memory.layout;

public abstract class ExecutionEngine
{
    private GarbageCollector _gc;
    private VirtualMachineContext _context;

    invariant()
    {
        assert(_gc);
    }

    protected this(GarbageCollector gc)
    in
    {
        assert(gc);
    }
    body
    {
        _gc = gc;
        _context = new typeof(_context)(this);
    }

    public abstract RuntimeValue execute(Function function_, NoNullList!RuntimeValue arguments);

    public abstract RuntimeValue execute(function_t function_, CallingConvention callingConvention, Type returnType, NoNullList!RuntimeValue arguments);

    public abstract void startDebugger(Address address);

    public abstract void stopDebugger();

    @property public final GarbageCollector gc()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _gc;
    }

    @property public final VirtualMachineContext context()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _context;
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
        gc.addRoot(cast(RuntimeObject**)_data);
    }

    ~this()
    {
        _gc.removeRoot(cast(RuntimeObject**)_data);
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
