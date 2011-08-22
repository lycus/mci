module mci.core.nullable;

import core.exception,
       std.exception;

public struct Nullable(T)
    if (!__traits(compiles, { T t = null; }))
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
}

unittest
{
    auto x = Nullable!int();
    
    assert(!x.hasValue);
    assertThrown!AssertError(x.value);
    
    auto y = Nullable!int(0xdeadbeef);
    
    assert(y.hasValue);
    assert(y.value == 0xdeadbeef);
}
