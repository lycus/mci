module mci.vm.io.extended;

import mci.core.common,
       mci.core.io;

public class VMBinaryReader : BinaryReader
{
    public this(Stream file, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(file);
        assert(file.canRead);
        assert(!file.isClosed);
    }
    body
    {
        super(file, endianness);
    }

    public string readString()
    {
        auto len = read!uint();
        return readArray!string(len);
    }
}

public class VMBinaryWriter : BinaryWriter
{
    public this(Stream file, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(file);
        assert(file.canWrite);
        assert(!file.isClosed);
    }
    body
    {
        super(file, endianness);
    }

    public void writeString(string str)
    {
        write(cast(uint)str.length);
        writeArray(str);
    }
}
