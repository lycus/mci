module mci.tester.io;

import mci.core.io;

unittest
{
    auto stream = new MemoryStream();

    scope (exit)
        stream.close();

    stream.write(1);
    stream.write(2);
    stream.write(3);

    stream.position = 0;

    assert(stream.read() == 1);
    assert(stream.read() == 2);
    assert(stream.read() == 3);
}

unittest
{
    auto stream = new MemoryStream();

    scope (exit)
        stream.close();

    stream.write(1);
    stream.write(2);
    stream.write(3);

    assert(stream.data == [1, 2, 3]);
}

unittest
{
    auto stream = new MemoryStream();

    stream.write(1);
    stream.write(2);
    stream.write(3);

    stream.close();

    assert(stream.isClosed);
}
