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

    public equals_t opEquals(ref const Tuple!X rhs) const
    {
        return typeid(X).equals(&_x, &rhs._x);
    }

    public int opCmp(ref const Tuple!X rhs) const
    {
        // There is no doubt that this could be sanitized, but it seems to be the best
        // generic way to call these built-in functions.
        if (!typeid(X).equals(&_x, &rhs._x))
            return typeid(X).compare(&_x, &rhs._x);

        return 0;
    }

    public hash_t toHash() const
    {
        return typeid(X).getHash(&_x);
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

    public equals_t opEquals(ref const Tuple!(X, Y) rhs) const
    {
        return typeid(X).equals(&_x, &rhs._x) && typeid(Y).equals(&_y, &rhs._y);
    }

    public int opCmp(ref const Tuple!(X, Y) rhs) const
    {
        if (!typeid(X).equals(&_x, &rhs._x))
            return typeid(X).compare(&_x, &rhs._x);

        if (!typeid(Y).equals(&_y, &rhs._y))
            return typeid(Y).compare(&_y, &rhs._y);

        return 0;
    }

    public hash_t toHash() const
    {
        return typeid(X).getHash(&_x) + typeid(Y).getHash(&_y);
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

    public equals_t opEquals(ref const Tuple!(X, Y, Z) rhs) const
    {
        return typeid(X).equals(&_x, &rhs._x) && typeid(Y).equals(&_y, &rhs._y) && typeid(Z).equals(&_z, &rhs._z);
    }

    public int opCmp(ref const Tuple!(X, Y, Z) rhs) const
    {
        if (!typeid(X).equals(&_x, &rhs._x))
            return typeid(X).compare(&_x, &rhs._x);

        if (!typeid(Y).equals(&_y, &rhs._y))
            return typeid(Y).compare(&_y, &rhs._y);

        if (!typeid(Z).equals(&_z, &rhs._z))
            return typeid(Z).compare(&_z, &rhs._z);

        return 0;
    }

    public hash_t toHash() const
    {
        return typeid(X).getHash(&_x) + typeid(Y).getHash(&_y) + typeid(Z).getHash(&_z);
    }
}

public Tuple!(X, Y, Z) tuple(X, Y, Z)(X x, Y y, Z z)
{
    return Tuple!(X, Y, Z)(x, y, z);
}
