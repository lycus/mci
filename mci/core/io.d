module mci.core.io;

import std.stdio,
       std.traits,
       mci.core.common,
       mci.core.config,
       mci.core.meta;

public interface Stream
{
    @property public size_t position();

    @property public void position(size_t position);

    @property public size_t length();

    @property public void length(size_t length);

    @property public bool canRead();

    @property public bool canWrite();

    @property public bool isClosed();

    public ubyte read();

    public void write(ubyte value);

    public void close();
}

public enum FileAccess : ubyte
{
    write,
    read,
}

public enum FileMode : ubyte
{
    open,
    truncate,
    append,
}

public char[] accessAndModeToString(FileAccess access, FileMode mode)
out (result)
{
    assert(result);
}
body
{
    final switch (mode)
    {
        case FileMode.open:
            return access == FileAccess.write ? ['r', '+'] : ['r'];
        case FileMode.truncate:
            return access == FileAccess.read ? ['w', '+'] : ['w'];
        case FileMode.append:
            return access == FileAccess.read ? ['a', '+'] : ['a'];
    }
}

public final class FileStream : Stream
{
    private File _file;
    private FileAccess _access;

    public this(string fileName, FileAccess access = FileAccess.read, FileMode mode = FileMode.open)
    in
    {
        assert(fileName);
    }
    body
    {
        _file = File(fileName, accessAndModeToString(access, mode) ~ 'b');
        _access = access;
    }

    @property public size_t position()
    {
        return cast(size_t)_file.tell;
    }

    @property public void position(size_t position)
    {
        _file.seek(position);
    }

    @property public size_t length()
    {
        return cast(size_t)_file.size;
    }

    @property public void length(size_t length)
    {
        // We cannot just set the length of a file stream.
        assert(false);
    }

    @property public bool canRead()
    {
        return _access == FileAccess.read || _access == FileAccess.write;
    }

    @property public bool canWrite()
    {
        return _access == FileAccess.write;
    }

    @property public bool isClosed()
    {
        return !_file.isOpen;
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _file.name;
    }

    public ubyte read()
    {
        ubyte[1] b;
        _file.rawRead(b);
        return b[0];
    }

    public void write(ubyte value)
    {
        _file.rawWrite([value]);
    }

    public void close()
    {
        _file.close();
    }
}

public final class MemoryStream : Stream
{
    private ubyte[] _data;
    private bool _isClosed;
    private size_t _position;
    private bool _canWrite;

    public this(bool canWrite = true)
    {
        _canWrite = canWrite;
    }

    public this(ubyte[] data, bool canWrite = true)
    in
    {
        assert(data);
    }
    body
    {
        _data = data;
        _canWrite = canWrite;
    }

    @property public size_t position()
    {
        return _position;
    }

    @property public void position(size_t position)
    {
        _position = position;
    }

    @property public size_t length()
    {
        return _data.length;
    }

    @property public void length(size_t length)
    {
        _data.length = length;
    }

    @property public bool canRead()
    {
        return true;
    }

    @property public bool canWrite()
    {
        return _canWrite;
    }

    @property public bool isClosed()
    {
        return _isClosed;
    }

    public ubyte read()
    {
        return _data[_position++];
    }

    public void write(ubyte value)
    {
        _data[_position++] = value;
    }

    public void close()
    {
        _data = null;
        _isClosed = true;
    }
}

public class BinaryReader
{
    private FileStream _file;
    private Endianness _endianness;

    invariant()
    {
        assert(_file);
        assert(_file.canRead);
        assert(!_file.isClosed);
    }

    public this(FileStream file, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(file);
        assert(file.canRead);
        assert(!file.isClosed);
    }
    body
    {
        _file = file;
        _endianness = endianness;
    }

    public final T read(T)()
        if (isPrimitiveType!T)
    {
        T value;

        if (endianness != _endianness)
        {
            for (size_t i = T.sizeof; i > 0; i--)
                (cast(ubyte*)&value)[i] = _file.read();
        }
        else
        {
            for (size_t i = 0; i < T.sizeof; i++)
                (cast(ubyte*)&value)[i] = _file.read();
        }

        return value;
    }

    public final T readArray(T)(size_t length)
        if (isArray!T && isPrimitiveType!(ArrayElementType!T))
    {
        T arr;

        // We have to unqualify the element type, as writing elements with
        // immutable or const will fail.
        for (size_t i = 0; i < length; i++)
            arr ~= read!(Unqual!(ArrayElementType!T))();

        return arr;
    }
}

public class BinaryWriter
{
    private FileStream _file;
    private Endianness _endianness;

    invariant()
    {
        assert(_file);
        assert(_file.canWrite);
        assert(!_file.isClosed);
    }

    public this(FileStream file, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(file);
        assert(file.canWrite);
        assert(!file.isClosed);
    }
    body
    {
        _file = file;
        _endianness = endianness;
    }

    public final void write(T)(T value)
        if (isPrimitiveType!T)
    {
        if (endianness != _endianness)
        {
            for (size_t i = T.sizeof; i > 0; i--)
                _file.write((cast(ubyte*)&value)[i]);
        }
        else
        {
            for (size_t i = 0; i < T.sizeof; i++)
                _file.write((cast(ubyte*)&value)[i]);
        }
    }

    public final void writeArray(T)(T value)
        if (isArray!T && isPrimitiveType!(ArrayElementType!T))
    {
        foreach (item; value)
            write(item);
    }
}
