module mci.tester.common;

import core.exception,
       std.exception,
       std.variant,
       mci.core.common;

version (unittest)
{
    private class A
    {
    }

    private class B : A
    {
    }

    private class C : B
    {
    }

    private class D
    {
    }
}

unittest
{
    auto b = new B();

    assert(isType!A(b));
}

unittest
{
    auto c = new C();

    assert(isType!A(c));
    assert(isType!B(c));
}

unittest
{
    auto a = new A();

    assert(!isType!B(a));
}

unittest
{
    auto a = new A();

    assert(isType!A(a));
}

unittest
{
    auto d = new D();

    assert(!isType!A(d));
}

unittest
{
    Variant v = 1;

    assertThrown!AssertError(match(v, (ubyte f) => {}));
}

unittest
{
    Variant v1 = 1;
    Variant v2;

    match(v1,
          (string s) => v2 = "foo",
          (int i) => v2 = i);

    assert(v2.get!int() == 1);
}

unittest
{
    Variant v1 = "foo";
    Variant v2;

    match(v1,
          (string s) => v2 = s,
          (int i) => v2 = i);

    assert(v2.get!string() == "foo");
}
