module mci.core.atomic;

import core.atomic,
       std.traits,
       mci.core.meta;

/**
 * Indicates whether a type can be atomically stored/loaded using the functions
 * in this module.
 *
 * Params:
 *  T = A type to test for atomicity.
 *
 * Returns:
 *  A Boolean value indicating whether $(D T) is atomic.
 */
template isAtomic(T)
{
    public enum bool isAtomic = isPrimitiveType!T || isPointer!T || is(T == class);
}

/**
 * Atomically loads a value from the given memory location (that is, with full
 * memory barriers).
 *
 * Params:
 *  T = The type of the data at $(D pointer).
 *  pointer = The location to load from atomically.
 *
 * Returns:
 *  The value loaded from the location pointed to by $(D pointer).
 */
public T atomicLoad(T)(T* pointer) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    return cast(T)core.atomic.atomicLoad(*cast(shared)pointer);
}

/**
 * Atomically stores a value to a given memory location (that is, with full
 * memory barriers).
 *
 * Params:
 *  T = The type of the data at $(D pointer).
 *  pointer = The location to write to atomically.
 *  value = The value to write to the location pointed to by $(D pointer).
 */
public void atomicStore(T)(T* pointer, T value) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    core.atomic.atomicStore(*cast(shared)pointer, cast(shared)value);
}

/**
 * Atomically swaps the value at a memory location with a given value if the
 * value at the memory location equals another given value.
 *
 * Params:
 *  T = The type of the data at $(D pointer).
 *  pointer = The memory location to attempt an atomic swap at.
 *  condition = The value pointed to by $(D pointer) must be equal to this
 *              value for the swap to occur.
 *  value = The value to insert at $(D pointer) if the existing value equals
 *          $(D condition).
 *
 * Returns:
 *  $(D true) if the swap happened; otherwise, $(D false).
 */
public bool atomicSwap(T)(T* pointer, T condition, T value) pure // TODO: Make this nothrow in 2.060.
    if (isAtomic!T)
{
    return cas(cast(shared)pointer, cast(shared)condition, cast(shared)value);
}

/**
 * Atomically performs a binary operation on a value at a given memory location.
 *
 * Params:
 *  op = The binary operation to apply.
 *  T = The type of the data at $(D pointer). Must not be a pointer or a class.
 *  pointer = The memory location to perform the atomic operation at.
 *  operand = The operand to the atomic binary operation.
 *
 * Returns:
 *  The result of applying the binary operation atomically.
 */
public T atomicOp(string op, T)(T* pointer, T operand) pure // TODO: Make this nothrow in 2.060.
    if (!isPointer!T && !is(T == class))
{
    return core.atomic.atomicOp!op(*cast(shared)pointer, operand);
}

/**
 * Atomically performs a binary operation on a value at a given memory location.
 *
 * Params:
 *  op = The binary operation to apply.
 *  T = The type of the data at $(D pointer). Must be a pointer itself.
 *  U = The type of the operand of the binary operation. Must be an integral.
 *  pointer = The memory location to perform the atomic operation at.
 *  operand = The operand to the atomic binary operation.
 *
 * Returns:
 *  The result of applying the binary operation atomically.
 */
public T atomicOp(string op, T, U)(T* pointer, U operand) pure // TODO: Make this nothrow in 2.060.
    if (isPointer!T && isIntegral!U)
{
    return cast(T)core.atomic.atomicOp!op(*cast(shared)pointer, operand);
}

/**
 * Encapsulates atomic operations on a value.
 *
 * Params:
 *  T = The type of the encapsulated value. Must be atomic.
 */
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
