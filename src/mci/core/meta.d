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
    public enum bool isAtomic = isScalarType!T || isPointer!T || is(Unqual!T == class);
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
 * Indicates whether a type is serializable. All scalar types except $(D real)
 * are considered serializable.
 *
 * Params:
 *  T = The type to test.
 *
 * Returns:
 *  $(D true) if $(D T) is a serializable type; otherwise, $(D false).
 */
public template isSerializable(T)
{
    public enum bool isSerializable = (isScalarType!T || is(Unqual!T == enum)) && !is(Unqual!T == real);
}
