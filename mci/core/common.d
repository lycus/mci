module mci.core.common;

public bool isType(T)(Object obj)
{
    return cast(T)obj !is null;
}

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
