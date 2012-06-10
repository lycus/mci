module mci.core.meta;

import std.traits;

/**
 * Indicates whether a type can be atomically stored/loaded.
 *
 * Params:
 *  T = A type to test for atomicity.
 *
 * Returns:
 *  $(D true) if $(D T) is atomic; otherwise, $(D false).
 */
public template isAtomic(T)
{
    public enum bool isAtomic = isPrimitiveType!T || isPointer!T || is(T == class);
}

/**
 * Indicates whether a type can be set to $(D null).
 *
 * Params:
 *  T = The type to test for nullability.
 *
 * Returns:
 *  $(D true) if $(D T) has a $(D null) state; otherwise, $(D false).
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
 *
 * Returns:
 *  $(D true) if $(D T) is a primitive type; otherwise, $(D false).
 */
public template isPrimitiveType(T)
{
    public enum bool isPrimitiveType = is(T == enum) || is(T == bool) || isNumeric!T || isSomeChar!T;
}
