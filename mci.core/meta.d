module mci.core.meta;

public template isNullable(T)
{
    public immutable bool isNullable = __traits(compiles, { T t = null; });
}
