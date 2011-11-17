module mci.core.common;

alias immutable string istring;
alias immutable wstring iwstring;
alias immutable dstring idstring;

public bool isType(U, T)(T obj)
in
{
    assert(obj);
}
body
{
    return cast(U)obj !is null;
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

public enum Compiler : ubyte
{
    unknown,
    dmd,
    gdc,
    ldc,
    sdc,
}

public enum Architecture : ubyte
{
    x86,
    arm,
    ppc,
    ia64,
    mips,
    sparc,
    s390,
    hppa,
    sh,
    alpha,
}

public enum Endianness : ubyte
{
    littleEndian,
    bigEndian,
}

public enum OperatingSystem : ubyte
{
    windows,
    linux,
    osx,
    bsd,
    freebsd,
    openbsd,
    solaris,
    aix,
    skyos,
    hurd,
}

public enum EmulationLayer : ubyte
{
    none,
    cygwin,
    mingw,
}
