module mci.debugger.utilities;

import std.socket,
       mci.core.io,
       mci.core.nullable,
       mci.core.tuple;

package Nullable!bool receive(Socket socket, ubyte[] buffer)
in
{
    assert(socket);
    assert(buffer);
}
body
{
    ptrdiff_t len;

    while (len < buffer.length)
    {
        auto ret = socket.receive(buffer[len .. $ - len]);

        if (ret == Socket.ERROR)
            return wouldHaveBlocked() ? nullable(false) : Nullable!bool();

        len += ret;
    }

    return nullable(true);
}

package Nullable!bool send(Socket socket, ubyte[] data)
in
{
    assert(socket);
    assert(data);
}
body
{
    ptrdiff_t len;

    while (len < data.length)
    {
        auto ret = socket.send(data[len .. $ - len]);

        if (ret == Socket.ERROR)
            return wouldHaveBlocked() ? nullable(false) : Nullable!bool();

        len += ret;
    }

    return nullable(true);
}

package Tuple!(ubyte, uint, uint) readHeader(BinaryReader reader)
in
{
    assert(reader);
}
body
{
    auto opCode = reader.read!ubyte();
    auto protoVer = reader.read!uint();
    auto length = reader.read!uint();

    return tuple(opCode, protoVer, length);
}

package void writeHeader(BinaryWriter writer, ubyte opCode, uint protocolVersion, uint length)
in
{
    assert(writer);
}
body
{
    writer.write(opCode);
    writer.write(protocolVersion);
    writer.write(length);
}
