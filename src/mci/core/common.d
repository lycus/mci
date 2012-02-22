module mci.core.common;

import core.stdc.stdlib,
       core.stdc.string,
       std.traits,
       mci.core.config,
       mci.core.meta;

public alias Select!(is32Bit, int, long) isize_t;
public alias void function() function_t;

public bool isType(U, T)(T obj)
in
{
    assert(obj);
}
body
{
    return cast(U)obj !is null;
}

public bool powerOfTwo(T)(T value)
    if (isIntegral!T)
{
    // See: http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
    return value && !(value & (value - 1));
}

public T rotate(string direction, T)(T value, T amount)
    if (isIntegral!T)
in
{
    assert(amount < T.sizeof * 8);
}
body
{
    static if (isSigned!T)
    {
        auto x = cast(Unsigned!T)value;
        auto y = cast(Unsigned!T)amount;
    }
    else
    {
        auto x = value;
        auto y = amount;
    }

    auto z = T.sizeof * 8 - y;

    static if (direction == "left")
        return cast(T)(x << y | x >> z);
    else static if (direction == "right")
        return cast(T)(x >> y | x << z);
    else
        static assert(false, "Direction must be \"left\" or \"right\".");
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
