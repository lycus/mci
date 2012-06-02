module mci.core.nullable;

import std.conv,
       mci.core.meta;

/**
 * A wrapper that allows having a $(D null) state for types that
 * normally don't support this (i.e. primitives and value types).
 *
 * Params:
 *  T = The type of data to encapsulate.
 */
public struct Nullable(T)
    if (!isNullable!T)
{
    private bool _hasValue;
    private T _value;

    public this(T value) pure nothrow
    {
        _hasValue = true;
        _value = value;
    }

    /**
     * Indicates whether this wrapper holds an actual value, i.e.
     * whether it is non-null.
     *
     * Returns:
     *  $(D true) if this wrapper holds a value; otherwise, $(D false).
     */
    @property public bool hasValue() pure nothrow
    {
        return _hasValue;
    }

    /**
     * Retrieves the wrapped value. It is a logic error if no value
     * is stored in this wrapper.
     *
     * Returns:
     *  The wrapped value.
     */
    @property public T value() pure nothrow
    in
    {
        assert(_hasValue);
    }
    body
    {
        return _value;
    }

    public equals_t opEquals(Nullable!T rhs) const
    {
        return _hasValue == rhs._hasValue && typeid(T).equals(&_value, &rhs._value);
    }

    public int opCmp(ref const Nullable!T rhs) const
    {
        if (_hasValue != rhs._hasValue)
            return typeid(bool).compare(&_hasValue, &rhs._hasValue);

        if (!typeid(T).equals(&_value, &rhs._value))
            return typeid(T).compare(&_value, &rhs._value);

        return 0;
    }

    public hash_t toHash() const nothrow
    {
        if (!_hasValue)
        {
            auto def = T.init;
            return typeid(T).getHash(&def);
        }

        return typeid(T).getHash(&_value);
    }

    public string toString()
    {
        return _hasValue ? to!string(_value) : "null";
    }

    public bool opCast(T : bool)() pure nothrow
    {
        return _hasValue;
    }
}

/**
 * Constructs a nullable wrapper around a value.
 *
 * Params:
 *  T = Type of the value to wrap.
 *  value = The value to wrap.
 */
public Nullable!T nullable(T)(T value) pure nothrow
    if (!isNullable!T)
{
    return Nullable!T(value);
}
