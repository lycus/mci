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
}

unittest
{
    auto a = new A();

    assert(!isType!B(a));
}

unittest
{
    A b = new B();

    assert(isType!B(b));
}

unittest
{
    A c = new C();

    assert(isType!B(c));
    assert(isType!C(c));
}

unittest
{
    auto a = new A();

    assert(isType!A(a));
}

unittest
{
    auto b = new B();
    bool isB;

    match(b, (B b) => isB = true);

    assert(isB);
}

unittest
{
    A c = new C();
    bool isB;
    bool isC;

    match(c,
          (B b) => isB = true,
          (C c) => isC = false);

    assert(isB);
    assert(!isC);
}

unittest
{
    Variant v = 1;

    assertThrown!AssertError(match(v, (ubyte b) => {}));
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
