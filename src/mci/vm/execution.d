module mci.vm.execution;

import core.stdc.stdlib,
       std.algorithm,
       std.socket,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.memory,
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
    private bool _terminated;

    pure nothrow invariant()
    {
        assert(_gc);
    }

    protected this(GarbageCollector gc) pure nothrow
    in
    {
        assert(gc);
    }
    body
    {
        _gc = gc;
        _context = new typeof(_context)(this);
    }

    ~this()
    {
        assert(_terminated);
    }

    public void terminate()
    {
        _terminated = true;
    }

    public abstract RuntimeValue execute(Function function_, NoNullList!RuntimeValue arguments);

    public abstract RuntimeValue execute(function_t function_, CallingConvention callingConvention, Type returnType, NoNullList!RuntimeValue arguments);

    public abstract void startDebugger(Address address);

    public abstract void stopDebugger();

    @property public final GarbageCollector gc() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _gc;
    }

    @property public final VirtualMachineContext context() pure nothrow
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

    pure nothrow invariant()
    {
        assert(_type);
        assert(_gc);
        assert(_data);
    }

    public this(GarbageCollector gc, Type type) nothrow
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
        _data = cast(ubyte*)calloc(1, max(computeSize(NativeUIntType.instance, is32Bit, simdAlignment), computeSize(type, is32Bit, simdAlignment)));
        gc.addRoot(cast(RuntimeObject**)_data);
    }

    ~this()
    {
        _gc.removeRoot(cast(RuntimeObject**)_data);
        free(_data);
    }

    @property public GarbageCollector gc() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _gc;
    }

    @property public Type type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public ubyte* data() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _data;
    }
}
