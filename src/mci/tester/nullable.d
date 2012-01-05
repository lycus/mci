module mci.tester.nullable;

import core.exception,
       std.exception,
       mci.core.nullable;

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
