module mci.tester.constant;

import core.exception,
       std.exception,
       mci.core.analysis.constant;

unittest
{
    auto a = Constant(4UL);
    auto b = Constant(12UL);

    assert(a + b == Constant(16UL));
}

unittest
{
    auto a = Constant(42UL);
    auto b = Constant(2UL);

    assert(a * b == Constant(84UL));
}

unittest
{
    auto a = Constant(1.0f);

    debug
        assertThrown!AssertError(~a);
}

unittest
{
    auto a = Constant(42UL);

    assert(a.not() == Constant(0UL));
}

unittest
{
    auto a = Constant(0UL);

    assert(a.not() == Constant(1UL));
}
