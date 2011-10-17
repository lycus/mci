module mci.core.nullable;

import core.exception,
       std.exception,
       mci.core.meta;

public struct Nullable(T)
    if (!isNullable!T)
{
    private bool _hasValue;
    private T _value = void;

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

    public T valueOrDefault(T def)
    {
        return _hasValue ? _value : def;
    }
}

unittest
{
    auto x = Nullable!int();

    assert(!x.hasValue);
    assertThrown!AssertError(x.value);
}

unittest
{
    auto x = Nullable!int(0xdeadbeef);

    assert(x.hasValue);
    assert(x.value == 0xdeadbeef);
}
