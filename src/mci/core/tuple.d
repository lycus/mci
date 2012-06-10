module mci.core.tuple;

/**
 * Represents an immutable tuple with a single element.
 *
 * Params:
 *  X = The type of the stored element.
 */
public struct Tuple(X)
{
    private X _x;

    /**
     * Constructs a tuple with a single element.
     *
     * Params:
     *  x = The stored element.
     */
    public this(X x) pure nothrow
    {
        _x = x;
    }

    /**
     * Gets the stored element.
     *
     * Returns:
     *  The stored element.
     */
    @property public X x() pure nothrow
    {
        return _x;
    }

    public equals_t opEquals(const Tuple!X rhs) const
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

    public hash_t toHash() const nothrow
    {
        return typeid(X).getHash(&_x);
    }
}

/**
 * Constructs a tuple from the given argument.
 *
 * Params:
 *  X = The type of the stored element.
 *  x = The stored element.
 *
 * Returns:
 *  The resulting tuple.
 */
public Tuple!X tuple(X)(X x) pure nothrow
{
    return Tuple!X(x);
}

/**
 * Represents an immutable tuple with two elements.
 *
 * Params:
 *  X = The type of the first element.
 *  Y = The type of the second element.
 */
public struct Tuple(X, Y)
{
    private X _x;
    private Y _y;

    /**
     * Constructs a tuple with two elements.
     *
     * Params:
     *  x = The first element.
     *  y = The second element.
     */
    public this(X x, Y y) pure nothrow
    {
        _x = x;
        _y = y;
    }

    /**
     * Gets the first element.
     *
     * Returns:
     *  The first element.
     */
    @property public X x() pure nothrow
    {
        return _x;
    }

    /**
     * Gets the second element.
     *
     * Returns:
     *  The second element.
     */
    @property public Y y() pure nothrow
    {
        return _y;
    }

    public equals_t opEquals(const Tuple!(X, Y) rhs) const
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

    public hash_t toHash() const nothrow
    {
        return typeid(X).getHash(&_x) + typeid(Y).getHash(&_y);
    }
}

/**
 * Constructs a tuple from the given arguments.
 *
 * Params:
 *  X = The type of the first element.
 *  Y = The type of the second element.
 *  x = The first element.
 *  y = The second element.
 *
 * Returns:
 *  The resulting tuple.
 */
public Tuple!(X, Y) tuple(X, Y)(X x, Y y) pure nothrow
{
    return Tuple!(X, Y)(x, y);
}

/**
 * Represents an immutable tuple with three elements.
 *
 * Params:
 *  X = The type of the first element.
 *  Y = The type of the second element.
 *  Z = The type of the third element.
 */
public struct Tuple(X, Y, Z)
{
    private X _x;
    private Y _y;
    private Z _z;

    /**
     * Constructs a tuple with two elements.
     *
     * Params:
     *  x = The first element.
     *  y = The second element.
     *  z = The third element.
     */
    public this(X x, Y y, Z z) pure nothrow
    {
        _x = x;
        _y = y;
        _z = z;
    }

    /**
     * Gets the first element.
     *
     * Returns:
     *  The first element.
     */
    @property public X x() pure nothrow
    {
        return _x;
    }

    /**
     * Gets the second element.
     *
     * Returns:
     *  The second element.
     */
    @property public Y y() pure nothrow
    {
        return _y;
    }

    /**
     * Gets the third element.
     *
     * Returns:
     *  The third element.
     */
    @property public Z z() pure nothrow
    {
        return _z;
    }

    public equals_t opEquals(const Tuple!(X, Y, Z) rhs) const
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

    public hash_t toHash() const nothrow
    {
        return typeid(X).getHash(&_x) + typeid(Y).getHash(&_y) + typeid(Z).getHash(&_z);
    }
}

/**
 * Constructs a tuple from the given arguments.
 *
 * Params:
 *  X = The type of the first element.
 *  Y = The type of the second element.
 *  Z = The type of the third element.
 *  x = The first element.
 *  y = The second element.
 *  z = The third element.
 *
 * Returns:
 *  The resulting tuple.
 */
public Tuple!(X, Y, Z) tuple(X, Y, Z)(X x, Y y, Z z) pure nothrow
{
    return Tuple!(X, Y, Z)(x, y, z);
}
