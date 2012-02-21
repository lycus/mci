module mci.tester.constant;

import core.exception,
       std.exception,
       mci.core.analysis.constant;

unittest
{
    auto a = new Constant(4UL);
    auto b = new Constant(12UL);

    assert(a + b == new Constant(16UL));
}

unittest
{
    auto a = new Constant(42UL);
    auto b = new Constant(2UL);

    assert(a * b == new Constant(84UL));
}

unittest
{
    auto a = new Constant(1.0f);

    debug
        assertThrown!AssertError(~a);
}

unittest
{
    auto a = new Constant(42UL);

    assert(a.not() == new Constant(0UL));
}

unittest
{
    auto a = new Constant(0UL);

    assert(a.not() == new Constant(1UL));
}
