module mci.core.nullable;

import core.exception,
       std.conv,
       std.exception,
       mci.core.meta;

public struct Nullable(T)
    if (!isNullable!T)
{
    private bool _hasValue;
    private T _value;

    public this(T value)
    {
        _hasValue = true;
        _value = value;
    }

    @property public bool hasValue()
    {
        return _hasValue;
    }

    @property public T value()
    in
    {
        assert(_hasValue);
    }
    body
    {
        return _value;
    }

    public T valueOrDefault(lazy T def)
    {
        return _hasValue ? _value : def;
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

    public hash_t toHash() const
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

    public bool opCast(T : bool)()
    {
        return _hasValue;
    }
}

public Nullable!T nullable(T)(T value)
{
    return Nullable!T(value);
}
