module mci.vm.intrinsics.context;

import mci.core.container,
       mci.vm.execution,
       mci.vm.memory.base;

public final class VirtualMachineState
{
    private Dictionary!(string, Object) _objects;

    invariant()
    {
        assert(_objects);
    }

    private this()
    {
        _objects = new typeof(_objects)();
    }

    @property public Dictionary!(string, Object) objects()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _objects;
    }

    @property public Object opDispatch(string s)(Object value)
    {
        mixin("return _objects[\"" ~ s ~ "\"] = value;");
    }

    @property public Object opDispatch(string s)()
    {
        mixin("return _objects[\"" ~ s ~ "\"];");
    }
}

public final class VirtualMachineContext
{
    private ExecutionEngine _engine;
    private VirtualMachineState _state;

    invariant()
    {
        assert(_engine);
        assert(_state);
    }

    public this(ExecutionEngine engine)
    in
    {
        assert(engine);
    }
    body
    {
        _engine = engine;
        _state = new typeof(_state)();
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

    @property public VirtualMachineState state()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _state;
    }
}
