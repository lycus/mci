module mci.core.common;

import core.exception,
       core.stdc.stdlib,
       core.stdc.string,
       std.traits,
       std.typetuple,
       std.variant,
       mci.core.config,
       mci.core.meta;

public alias Select!(is32Bit, int, long) isize_t; /// Aliases to $(D int) on 32-bit platforms or $(D long) on 64-bit platforms.
public alias void function() function_t; /// Meant to indicate that any arbitrary function pointer is acceptable.

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
                else if (auto res = cast(U)obj)
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

            static if (!is(typeof(return) == void))
                return res;
            else
                return;
        }
    }

    // DMD workaround.
    throw new AssertError("No type match found.");
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
        typeof(return)* res;

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        // If we haven't hit any cases so far and we have cases that take no parameters, call the first one.
        static if (!FArgs.length)
        {
            static if (!is(typeof(return) == void))
            {
                auto r = cases[i]();
                res = &r;
            }
            else
                cases[i]();

            static if (!is(typeof(return) == void))
                return res ? *res : typeof(return).init;
            else
                return;
        }
    }

    // DMD workaround.
    throw new AssertError("No variant match found.");
}

/**
 * Which compiler is used to build MCI.
 */
public enum Compiler : ubyte
{
    unknown = 0, /// Compiler could not be determined.
    dmd = 1, /// Digital Mars D.
    gdc = 2, /// GNU D Compiler.
    ldc = 3, /// LLVM D Compiler.
}

/**
 * Indicates what architecture MCI is compiled for.
 */
public enum Architecture : ubyte
{
    x86 = 0,
    arm = 1,
    ppc = 2,
    ia64 = 3,
    mips = 4,
}

/**
 * Indicates what endianness MCI is compiled for.
 */
public enum Endianness : ubyte
{
    littleEndian = 0,
    bigEndian = 1,
}

/**
 * Indicates what operating system MCI is compiled for.
 */
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

/**
 * Indicates what emulation layer, if any, MCI is compiled for.
 */
public enum EmulationLayer : ubyte
{
    none = 0,
    cygwin = 1,
    mingw = 2,
}
