module mci.core.common;

import core.stdc.stdlib,
       core.stdc.string,
       std.traits,
       std.typetuple,
       std.variant,
       mci.core.config,
       mci.core.meta;

public alias Select!(is32Bit, int, long) isize_t;
public alias void function() function_t;

public U tryCast(U, T)(T obj)
    if ((is(T == class) || is(T == interface)) &&
        (is(U == class) || is(U == interface)) &&
        is(U : T))
in
{
    assert(obj);
}
body
{
    return cast(U)obj;
}

public CommonType!(staticMap!(ReturnType, F)) match(T, F ...)(T obj, scope F cases)
    if (is(T == class) || is(T == interface))
in
{
    static assert(F.length, "At least one function/delegate argument is required.");

    foreach (f; F)
    {
        alias ParameterTypeTuple!f FArgs;

        static assert(isFunctionPointer!f || isDelegate!f, "All trailing arguments must be functions or delegates.");
        static assert(FArgs.length <= 1, "All trailing functions/delegates must take zero or one parameter.");

        static if (FArgs.length)
        {
            alias FArgs[0] U;

            static assert((is(U == class) || is(U == interface)) && is(U : T));
        }
    }
}
body
{
    alias TypeTuple!F TFuncs;

    if (obj)
    {
        foreach (i, f; TFuncs)
        {
            alias ParameterTypeTuple!f FArgs;

            static if (FArgs.length)
            {
                alias FArgs[0] U;

                if (!obj && is(U == typeof(null)))
                    return cases[i](null);
                else if (auto res = tryCast!U(obj))
                    return cases[i](res);
            }
        }
    }

    static if (!is(typeof(return) == void))
        typeof(return) res;

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        // If we haven't hit any cases so far and we have cases that take no parameters, call the first one.
        static if (!FArgs.length)
        {
            static if (!is(typeof(return) == void))
                res = cases[i]();
            else
                cases[i]();

            goto exit; // Work around a DMD closure bug.
        }
    }

    assert(false);

    exit:

    static if (!is(typeof(return) == void))
        return res;
}

public CommonType!(staticMap!(ReturnType, F)) match(V, F ...)(V variant, scope F cases)
    if (is(V == struct) && __traits(identifier, V) == "VariantN") // Best we can do; ideally we'd make sure it's a VariantN of sorts...
in
{
    static assert(F.length, "At least one function/delegate argument is required.");

    foreach (f; F)
    {
        static assert(isFunctionPointer!f || isDelegate!f, "All trailing arguments must be functions or delegates.");
        static assert((ParameterTypeTuple!f).length <= 1, "All trailing functions/delegates must take zero or one parameter.");
    }
}
body
{
    alias TypeTuple!F TFuncs;

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        static if (FArgs.length)
            if (auto ptr = variant.peek!FArgs())
                return cases[i](*ptr);
    }

    static if (!is(typeof(return) == void))
        typeof(return) res;

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        // If we haven't hit any cases so far and we have cases that take no parameters, call the first one.
        static if (!FArgs.length)
        {
            static if (!is(typeof(return) == void))
                res = cases[i]();
            else
                cases[i]();

            goto exit; // Work around a DMD closure bug.
        }
    }

    assert(false);

    exit:

    static if (!is(typeof(return) == void))
        return res;
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
