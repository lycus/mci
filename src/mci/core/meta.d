module mci.core.meta;

import std.traits;

/**
 * Indicates whether a type can be set to $(D null).
 *
 * Params:
 *  T = The type to test for nullability.
 */
public template isNullable(T)
{
    public enum bool isNullable = __traits(compiles, { T t = null; });
}

/**
 * Indicates whether a type is primitive. That is, whether it is an integral,
 * floating point, character, or $(D enum) type.
 *
 * Params:
 *  T = The type to test.
 */
public template isPrimitiveType(T)
{
    public enum bool isPrimitiveType = is(T == enum) || is(T == bool) || isNumeric!T || isSomeChar!T;
}
