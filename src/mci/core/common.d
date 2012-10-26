module mci.core.common;

import core.exception,
       std.traits,
       std.typetuple,
       std.variant,
       mci.core.config,
       mci.core.meta;

public alias Select!(is32Bit, int, long) isize_t; /// Aliases to $(D int) on 32-bit platforms or $(D long) on 64-bit platforms.
public alias void function() function_t; /// Meant to indicate that any arbitrary function pointer is acceptable.

/**
 * Pattern matches on the type of an object. The $(D obj) parameter
 * represents the object to pattern match on. It may be $(D null).
 *
 * The cases are functions/delegates. At least one is required. Each
 * of them must have either no parameters (the case handles anything)
 * or exactly one parameter (the case handles the type specified in
 * that parameter).
 *
 * A case may take $(D typeof(null)), in which case it is invokved
 * immediately if $(D obj) is $(D null). If $(D obj) is not $(D null),
 * execution proceeds as follows.
 *
 * The function attempts to match $(D obj)'s dynamic type against the
 * types of the cases' parameters in the exact order the cases are
 * passed to this function. If $(D obj)'s type matches a case, that
 * case is called and its result (if any) is returned. If no match was
 * found and a case that takes no parameters is found, that case
 * is invoked and its value (if any) is returned.
 *
 * Note that regardless of what kind of case is involved, the first
 * case matching the conditions above will be invoked. So, if multiple
 * cases match a type, the first one encountered will be invoked, for
 * example.
 *
 * If absolutely no match is found, the result is a fatal error.
 *
 * Params:
 *  T = The type of $(D obj). Must be a class or interface.
 *  F = The types of the functions representing the patterns.
 *  obj = The object whose type to pattern match on.
 *  cases = The pattern matching case functions.
 *
 * Returns:
 *  Whatever value the matching case returned, if any (and if
 *  non-$(D void)).
 */
public CommonType!(staticMap!(ReturnType, F)) match(T, F ...)(T obj, scope F cases)
    if (is(T == class) || is(T == interface))
in
{
    static assert(F.length, "At least one function/delegate argument is required.");

    foreach (f; F)
    {
        static assert(isFunctionPointer!f || isDelegate!f, "All trailing arguments must be functions or delegates.");

        alias ParameterTypeTuple!f FArgs;

        static assert(FArgs.length <= 1, "All trailing functions/delegates must take zero or one parameter.");

        static if (FArgs.length)
        {
            alias FArgs[0] U;

            static assert((is(U == class) && is(U : T)) || is(U == interface) || is(U == typeof(null)));
        }
    }
}
body
{
    static if (!is(typeof(return) == void))
        typeof(return) res;

    alias TypeTuple!F TFuncs;

    if (!obj)
    {
        foreach (i, f; TFuncs)
        {
            static if (is(U == typeof(null)))
            {
                static if (!is(typeof(return) == void))
                    res = cases[i](null);
                else
                    cases[i](null);

                static if (!is(typeof(return) == void))
                    return res;
                else
                    return;
            }
        }
    }

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        static if (FArgs.length && !is(FArgs[0] == typeof(null)))
        {
            if (auto r = cast(FArgs[0])obj)
            {
                static if (!is(typeof(return) == void))
                    res = cases[i](r);
                else
                    cases[i](r);

                static if (!is(typeof(return) == void))
                    return res;
                else
                    return;
            }
        }
    }

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

/**
 * Pattern matches on the type stored in a $(D VariantN) value (which
 * is really a discriminated union).
 *
 * The cases are functions/delegates. At least one is required. Each
 * of them must have either no parameters (the case handles anything)
 * or exactly one parameter (the case handles the type specified in
 * that parameter).
 *
 * A case may take $(D typeof(null)), in which case it is invokved
 * immediately if $(D variant) holds no value. If $(D variant) does
 * hold a value, execution proceeds as follows.
 *
 * The function attempts to match $(D variant)'s runtime type against
 * the types of the cases' parameters in the exact order the cases are
 * passed to this function. If $(D variant)'s type matches a case, that
 * case is called and its result (if any) is returned. If no match was
 * found and a case that takes no parameters is found, that case
 * is invoked and its value (if any) is returned.
 *
 * Note that regardless of what kind of case is involved, the first
 * case matching the conditions above will be invoked. So, if multiple
 * cases match a type, the first one encountered will be invoked, for
 * example.
 *
 * If absolutely no match is found, the result is a fatal error.
 *
 * Params:
 *  V = The type of $(D variant). Should be a $(D VariantN) instantiation.
 *  F = The types of the functions representing the patterns.
 *  variant = The variant whose type to pattern match on.
 *  cases = The pattern matching case functions.
 *
 * Returns:
 *  Whatever value the matching case returned, if any (and if
 *  non-$(D void)).
 */
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
    static if (!is(typeof(return) == void))
        typeof(return)* res;

    alias TypeTuple!F TFuncs;

    if (!variant.hasValue)
    {
        foreach (i, f; TFuncs)
        {
            static if (is(U == typeof(null)))
            {
                static if (!is(typeof(return) == void))
                {
                    auto r = cases[i](null);
                    res = &r;
                }
                else
                    cases[i](null);

                static if (!is(typeof(return) == void))
                    return res ? *res : typeof(return).init;
                else
                    return;
            }
        }
    }

    foreach (i, f; TFuncs)
    {
        alias ParameterTypeTuple!f FArgs;

        static if (FArgs.length && !is(FArgs[0] == typeof(null)))
        {
            if (auto ptr = variant.peek!(FArgs[0])())
            {
                static if (!is(typeof(return) == void))
                {
                    auto r = cases[i](*ptr);
                    res = &r;
                }
                else
                    cases[i](*ptr);

                static if (!is(typeof(return) == void))
                    return res ? *res : typeof(return).init;
                else
                    return;
            }
        }
    }

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
 * Which compiler is used to build the MCI.
 */
public enum Compiler : ubyte
{
    unknown = 0, /// Compiler could not be determined.
    dmd = 1, /// Digital Mars D.
    gdc = 2, /// GNU D Compiler.
    ldc = 3, /// LLVM D Compiler.
}

/**
 * Indicates what architecture the MCI is compiled for.
 */
public enum Architecture : ubyte
{
    x86 = 0, /// The x86 architecture (32-bit and 64-bit).
    arm = 1, /// The ARM architecture (32-bit).
    ppc = 2, /// The PowerPC architecture (32-bit and 64-bit).
    ia64 = 3, /// The Itanium architecture (64-bit).
    mips = 4, /// The MIPS architecture (32-bit and 64-bit).
}

/**
 * Indicates what endianness the MCI is compiled for.
 */
public enum Endianness : ubyte
{
    littleEndian = 0, /// Least significant byte first.
    bigEndian = 1, /// Most significant byte first.
}

/**
 * Indicates what operating system the MCI is compiled for.
 */
public enum OperatingSystem : ubyte
{
    windows = 0, /// The Windows operating system (Windows 7 and up).
    linux = 1, /// The Linux kernel (2.6 and up).
    osx = 2, /// Mac OS X (Leopard and up).
    freebsd = 3, /// The FreeBSD operating system (9.0 and up).
    solaris = 4, /// All Solaris variants.
    aix = 5, /// IBM's AIX operating system.
}

/**
 * Indicates what emulation layer, if any, the MCI is compiled for.
 */
public enum EmulationLayer : ubyte
{
    none = 0, /// No emulation layer was used.
    cygwin = 1, /// The MCI was compiled under Cygwin (tends to imply GDC or LDC).
    mingw = 2, /// The MCI was compiled under MinGW (tends to imply GDC or LDC).
}

/**
 * Indicates the kind of inline assembly provided by a compiler.
 */
public enum InlineAssembly : ubyte
{
    dmd32, // DMD-style inline assembly for x86 (32-bit).
    dmd64, // DMD-style inline assembly for x86 (64-bit).
    gnu, // GNU-style inline assembly.
    llvm, // LLVM-style inline assembly (import the $(D ldc.llvmasm) module). Implies $(D dmd32) and $(D dmd64).
}

/**
 * Indicates which method is used to execute floating-point operations.
 */
public enum FloatingPointMethod : ubyte
{
    soft, /// Floating-point operations are done in software.
    hard, /// Floating-point operations are done in hardware.
}
