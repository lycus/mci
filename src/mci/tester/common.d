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

    assert(!tryCast!B(a));
}

unittest
{
    A b = new B();

    assert(tryCast!B(b));
}

unittest
{
    A c = new C();

    assert(tryCast!B(c));
    assert(tryCast!C(c));
}

unittest
{
    auto a = new A();

    assert(tryCast!A(a));
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
    auto b = new B();

    match(b, () => {});
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

unittest
{
    Variant v1 = 1;

    match(v1, () => {});
}

unittest
{
    for (ulong i = 1; i != 0; i *= 2)
        assert(powerOfTwo(i));
}

unittest
{
    assert(!powerOfTwo(0));
}

unittest
{
    assert(rotate!("right", ubyte)(0b00001111, 4) == 0b11110000);
    assert(rotate!("right", byte)(0b00001111, 4) == cast(byte)0b11110000);
}

unittest
{
    assert(rotate!("left", ubyte)(0b11110000, 4) == 0b00001111);
    assert(rotate!("left", byte)(cast(byte)0b11110000, 4) == 0b00001111);
}
