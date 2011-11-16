module mci.core.meta;

public template isNullable(T)
{
    public enum bool isNullable = __traits(compiles, { T t = null; });
}

public template ArrayElementType(T : T[])
{
    alias T ArrayElementType;
}
