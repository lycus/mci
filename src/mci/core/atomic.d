module mci.core.atomic;

import core.atomic,
       std.traits,
       mci.core.meta;

template isAtomic(T)
{
    public enum bool isAtomic = isPrimitiveType!T || isPointer!T || is(T == class);
}

public T atomicLoad(T)(T* pointer) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    return cast(T)core.atomic.atomicLoad(*cast(shared)pointer);
}

public void atomicStore(T)(T* pointer, T value) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    core.atomic.atomicStore(*cast(shared)pointer, cast(shared)value);
}

public bool atomicSwap(T)(T* pointer, T condition, T value) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    return cas(cast(shared)pointer, cast(shared)condition, cast(shared)value);
}

public T atomicOp(string op, T)(T* pointer, T operand) pure // TODO: Make this nothrow in 2.060.
    if (!isPointer!T && !is(T == class))
{
    return core.atomic.atomicOp!op(*cast(shared)pointer, operand);
}

public T atomicOp(string op, T, U)(T* pointer, U operand) pure // TODO: Make this nothrow in 2.060.
    if (isPointer!T && isIntegral!U)
{
    return cast(T)core.atomic.atomicOp!op(*cast(shared)pointer, operand);
}

public struct Atomic(T)
    if (isAtomic!T)
{
    private T _value;

    public this(T value) pure nothrow
    {
        atomicStore(&_value, value);
    }

    @property public T value() pure // TODO: Make this nothrow in 2.060.
    {
        return cast(T)atomicLoad(&_value);
    }

    @property public void value(T value) pure // TODO: Make this nothrow in 2.060.
    {
        atomicStore(&_value, value);
    }

    @property public T* pointer() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return &_value;
    }

    public bool swap(T condition, T value) pure // TODO: Make this nothrow in 2.060.
    {
        return atomicSwap(&_value, condition, value);
    }

    public Atomic!T opOpAssign(string op)(T rhs) pure // TODO: Make this nothrow in 2.060.
        if (!isPointer!T && !is(T == class))
    {
        atomicOp!(op ~ '=')(&_value, rhs);

        return this;
    }

    public Atomic!T opOpAssign(string op, U)(U rhs) pure // TODO: Make this nothrow in 2.060.
        if (isPointer!T && isIntegral!U)
    {
        atomicOp!(op ~ '=')(&_value, rhs);

        return this;
    }
}

public Atomic!T atomic(T)(T value) pure nothrow
{
    return Atomic!T(value);
}
