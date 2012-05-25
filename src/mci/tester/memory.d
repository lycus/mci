module mci.tester.memory;

import mci.core.common,
       mci.core.memory;

unittest
{
    assert(alignTo(size_t.sizeof) == size_t.sizeof);
}

unittest
{
    assert(!alignTo(0));
}

unittest
{
    assert(alignTo(1) == size_t.sizeof);
    assert(alignTo(2) == size_t.sizeof);
    assert(alignTo(3) == size_t.sizeof);
}

unittest
{
    assert(isAligned(size_t.sizeof));
    assert(isAligned(isize_t.sizeof));
}

unittest
{
    assert(isAligned(0));
}

unittest
{
    for (size_t i = size_t.sizeof; i != 0; i *= size_t.sizeof)
        assert(isAligned(i));
}

unittest
{
    assert(alignmentPadding(1) == size_t.sizeof - 1);
    assert(alignmentPadding(2) == size_t.sizeof - 2);
    assert(alignmentPadding(3) == size_t.sizeof - 3);
}

unittest
{
    assert(!alignmentPadding(0));
}

unittest
{
    assert(!alignmentPadding(size_t.sizeof));
}
