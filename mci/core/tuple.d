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

public Tuple!X tuple(X)(X x)
{
    return Tuple!X(x);
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

public Tuple!(X, Y) tuple(X, Y)(X x, Y y)
{
    return Tuple!(X, Y)(x, y);
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

public Tuple!(X, Y, Z) tuple(X, Y, Z)(X x, Y y, Z z)
{
    return Tuple!(X, Y, Z)(x, y, z);
}
