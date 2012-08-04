module mci.vm.intrinsics.context;

import mci.core.container,
       mci.vm.execution,
       mci.vm.memory.base;

/**
 * Represents the internal state of the virtual
 * machine during an intrinsic function invocation.
 */
public final class VirtualMachineState
{
    private Dictionary!(string, Object, false) _objects;

    pure nothrow invariant()
    {
        assert(_objects);
    }

    private this()
    {
        _objects = new typeof(_objects)();
    }

    /**
     * Gets the dictionary used to store the internal state.
     *
     * Returns:
     *  The dictionary used to store the internal state.
     */
    @property public Dictionary!(string, Object, false) objects() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _objects;
    }

    /**
     * Sets a key to a given object.
     *
     * Params:
     *  key = The key.
     *  value = The value.
     *
     * Returns:
     *  The $(D value).
     */
    @property public Object opDispatch(string key)(Object value)
    {
        mixin("return _objects[\"" ~ key ~ "\"] = value;");
    }

    /**
     * Gets an object by a given key.
     *
     * Params:
     *  key = The key.
     *
     * Returns:
     *  The object associated with $(D key).
     */
    @property public Object opDispatch(string key)()
    {
        mixin("return _objects[\"" ~ key ~ "\"];");
    }
}

/**
 * Represents the virtual machine that an intrinsic
 * function is operating on.
 */
public final class VirtualMachineContext
{
    private ExecutionEngine _engine;
    private VirtualMachineState _state;

    pure nothrow invariant()
    {
        assert(_engine);
        assert(_state);
    }

    /**
     * Constructs a new $(D VirtualMachineContext)
     * instance.
     *
     * Params:
     *  engine = The execution engine.
     */
    public this(ExecutionEngine engine) pure nothrow
    in
    {
        assert(engine);
    }
    body
    {
        _engine = engine;
        _state = new typeof(_state)();
    }

    /**
     * Gets the execution engine being used to
     * invoke the current intrinsic function.
     *
     * Returns:
     *  The current execution engine.
     */
    @property public ExecutionEngine engine() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _engine;
    }

    /**
     * Gets the internal state of the virtual machine.
     *
     * Returns:
     *  The internal state of the virtual machine.
     */
    @property public VirtualMachineState state() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _state;
    }
}
