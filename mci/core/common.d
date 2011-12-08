module mci.core.common;

import core.stdc.stdlib,
       core.stdc.string,
       mci.core.config,
       mci.core.meta;

static if (is32Bit)
{
    alias int isize_t;
}
else
{
    alias long isize_t;
}

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

public T* copyToNative(T)(T[] arr)
    if (isPrimitiveType!T)
{
    if (!arr)
        return null;

    auto size = T.sizeof * arr.length;
    auto mem = cast(T*)malloc(size);
    memcpy(mem, arr.ptr, size);

    return mem;
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
    hurd,
}

public enum EmulationLayer : ubyte
{
    none,
    cygwin,
    mingw,
}
