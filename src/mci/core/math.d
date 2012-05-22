module mci.core.math;

import std.traits;

public bool powerOfTwo(T)(T value) pure nothrow
    if (isIntegral!T)
{
    // See: http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
    return value && !(value & (value - 1));
}

public T rotate(string direction, T)(T value, uint amount) pure nothrow
    if (isIntegral!T)
in
{
    assert(amount < T.sizeof * 8);
}
body
{
    static if (isSigned!T)
    {
        auto x = cast(Unsigned!T)value;
        auto y = cast(Unsigned!T)amount;
    }
    else
    {
        auto x = value;
        auto y = amount;
    }

    auto z = T.sizeof * 8 - y;

    static if (direction == "left")
        return cast(T)(x << y | x >> z);
    else static if (direction == "right")
        return cast(T)(x >> y | x << z);
    else
        static assert(false, "Direction must be \"left\" or \"right\".");
}
