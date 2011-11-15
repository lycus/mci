module mci.core.io;

import std.range,
       std.stdio,
       std.traits;

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

private char[] accessAndModeToString(FileAccess access, FileMode mode)
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

    public this(string fileName, FileAccess access = FileAccess.read,
                FileMode mode = FileMode.open)
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
        return (_access & FileAccess.read) != 0;
    }

    @property public bool canWrite()
    {
        return (_access & FileAccess.write) != 0;
    }

    @property public bool isClosed()
    {
        return !_file.isOpen;
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

private template isValidType(T)
{
    public enum bool isValidType = is(T == bool) || isNumeric!T || isSomeChar!T;
}

public class BinaryReader
{
    private File _file;

    public this(File file)
    {
        _file = file;
    }

    public final T read(T)()
        if (isValidType!T)
    {
        T[1] arr;
        _file.rawRead(arr);
        return arr[0];
    }

    public final T readArray(T)(size_t length)
        if (isArray!T && isValidType!(ElementType!T))
    {
        T arr;

        for (size_t i = 0; i < length; i++)
            arr ~= read!(ElementType!T)();

        return arr;
    }
}

public class BinaryWriter
{
    private File _file;

    public this(File file)
    {
        _file = file;
    }

    public final void write(T)(T value)
        if (isValidType!T)
    {
        _file.rawWrite([value]);
    }

    public final void writeArray(T)(T value)
        if (isArray!T && isValidType!(ElementType!T))
    {
        foreach (item; value)
            write(value);
    }
}
