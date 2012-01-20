module mci.core.meta;

import std.traits;

public template isNullable(T)
{
    public enum bool isNullable = __traits(compiles, { T t = null; });
}

public template isPrimitiveType(T)
{
    public enum bool isPrimitiveType = is(T == enum) || is(T == bool) || isNumeric!T || isSomeChar!T;
}

public template ArrayElementType(T : T[])
{
    public alias T ArrayElementType;
}
