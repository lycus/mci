module mci.core.common;

import core.stdc.stdlib,
       core.stdc.string,
       std.traits,
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

alias void function() function_t;

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

public bool powerOfTwo(T)(T value)
    if (isIntegral!T)
{
    // See: http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
    return value && !(value & (value - 1));
}

public enum Compiler : ubyte
{
    unknown = 0,
    dmd = 1,
    gdc = 2,
    ldc = 3,
    sdc = 4,
}

public enum Architecture : ubyte
{
    x86 = 0,
    arm = 1,
    ppc = 2,
    ia64 = 3,
    mips = 4,
}

public enum Endianness : ubyte
{
    littleEndian = 0,
    bigEndian = 1,
}

public enum OperatingSystem : ubyte
{
    windows = 0,
    linux = 1,
    osx = 2,
    bsd = 3,
    freebsd = 4,
    openbsd = 5,
    solaris = 6,
    aix = 7,
    hurd = 8,
}

public enum EmulationLayer : ubyte
{
    none = 0,
    cygwin = 1,
    mingw = 2,
}
