module mci.tester.math;

import mci.core.math;

unittest
{
    for (ulong i = 1; i != 0; i *= 2)
        assert(powerOfTwo(i));
}

unittest
{
    assert(!powerOfTwo(0));
}

unittest
{
    assert(ror!ubyte(0b00001111, 4) == 0b11110000);
    assert(ror!byte(0b00001111, 4) == cast(byte)0b11110000);
}

unittest
{
    assert(rol!ubyte(0b11110000, 4) == 0b00001111);
    assert(rol!byte(cast(byte)0b11110000, 4) == 0b00001111);
}
