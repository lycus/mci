module mci.core.tuple;

public struct Tuple(X)
{
    private X _x;

    public this(X x)
    {
        _x = x;
    }

    @property public X x()
    {
        return _x;
    }
}

public struct Tuple(X, Y)
{
    private X _x;
    private Y _y;

    public this(X x, Y y)
    {
        _x = x;
        _y = y;
    }

    @property public X x()
    {
        return _x;
    }

    @property public Y y()
    {
        return _y;
    }
}

public struct Tuple(X, Y, Z)
{
    private X _x;
    private Y _y;
    private Z _z;

    public this(X x, Y y, Z z)
    {
        _x = x;
        _y = y;
        _z = z;
    }

    @property public X x()
    {
        return _x;
    }

    @property public Y y()
    {
        return _y;
    }

    @property public Z z()
    {
        return _z;
    }
}
