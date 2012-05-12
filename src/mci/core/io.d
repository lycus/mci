module mci.core.io;

import std.ascii,
       std.conv,
       std.range,
       std.stdio,
       std.string,
       std.traits,
       mci.core.common,
       mci.core.config,
       mci.core.meta;

public interface Stream
{
    @property public ulong position();

    @property public void position(ulong position);

    @property public ulong length();

    @property public void length(ulong length);

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
        _file = File(fileName, accessAndModeToString(access, mode));
        _access = access;
    }

    @property public ulong position()
    {
        return _file.tell;
    }

    @property public void position(ulong position)
    {
        _file.seek(position);
    }

    @property public ulong length()
    {
        return _file.size;
    }

    @property public void length(ulong length)
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
    in
    {
        assert(_file.isOpen);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _file.name;
    }

    @property public File handle()
    in
    {
        assert(_file.isOpen);
    }
    body
    {
        return _file;
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
    {
        _data = data;
        _canWrite = canWrite;
    }

    @property public ulong position()
    {
        return _position;
    }

    @property public void position(ulong position)
    {
        _position = cast(size_t)position;
    }

    @property public ulong length()
    {
        return _data.length;
    }

    @property public void length(ulong length)
    {
        _data.length = cast(size_t)length;
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

    @property public ubyte[] data()
    in
    {
        assert(!_isClosed);
    }
    body
    {
        return _data.dup;
    }

    public ubyte read()
    {
        return _data[_position++];
    }

    public void write(ubyte value)
    {
        if (_position >= _data.length)
            _data.length = _position + 1;

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
    private Stream _stream;
    private Endianness _endianness;

    invariant()
    {
        assert(_stream);
        assert((cast()_stream).canRead);
        assert(!(cast()_stream).isClosed);
    }

    public this(Stream stream, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(stream);
        assert((cast()stream).canRead);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _stream = stream;
        _endianness = endianness;
    }

    @property public Stream stream()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    @property public Endianness endianness()
    {
        return _endianness;
    }

    public final T read(T)()
        if (isPrimitiveType!T)
    {
        T value;

        if (endianness != _endianness)
        {
            for (size_t i = T.sizeof; i > 0; i--)
                (cast(ubyte*)&value)[i] = _stream.read();
        }
        else
        {
            for (size_t i = 0; i < T.sizeof; i++)
                (cast(ubyte*)&value)[i] = _stream.read();
        }

        return value;
    }

    public final T readArray(T)(ulong length)
        if (isArray!T && isPrimitiveType!(ElementEncodingType!T))
    {
        T arr;

        // We have to unqualify the element type, as writing elements with
        // immutable or const will fail.
        for (ulong i = 0; i < length; i++)
            arr ~= read!(Unqual!(ElementEncodingType!T))();

        return arr;
    }
}

public class BinaryWriter
{
    private Stream _stream;
    private Endianness _endianness;

    invariant()
    {
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
    }

    public this(Stream stream, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(stream);
        assert((cast()stream).canWrite);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _stream = stream;
        _endianness = endianness;
    }

    @property public Stream stream()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    @property public Endianness endianness()
    {
        return _endianness;
    }

    public final void write(T)(T value)
        if (isPrimitiveType!T)
    {
        if (endianness != _endianness)
        {
            for (size_t i = T.sizeof; i > 0; i--)
                _stream.write((cast(ubyte*)&value)[i]);
        }
        else
        {
            for (size_t i = 0; i < T.sizeof; i++)
                _stream.write((cast(ubyte*)&value)[i]);
        }
    }

    public final void writeArray(T)(T value)
        if (isArray!T && isPrimitiveType!(ElementEncodingType!T))
    {
        foreach (item; value)
            write(item);
    }
}

public class TextWriter : BinaryWriter
{
    private ulong _indent;

    public this(Stream stream, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(stream);
        assert(stream.canRead);
        assert(!stream.isClosed);
    }
    body
    {
        super(stream, endianness);
    }

    public void indent()
    {
        if (_indent != typeof(_indent).max)
            _indent++;
    }

    public void dedent()
    {
        if (_indent != typeof(_indent).min)
            _indent--;
    }

    public void write(T ...)(T args)
    {
        foreach (arg; args)
            writeArray(to!string(arg));
    }

    public void writeln(T ...)(T args)
    {
        write(args);
        write(std.ascii.newline);
    }

    public void writef(T ...)(T args)
    {
        write(format(args));
    }

    public void writefln(T ...)(T args)
    {
        writef(args);
        writeln();
    }

    public void writei(T ...)(T args)
    {
        for (auto i = 0; i < _indent; i++)
            write("    ");

        foreach (arg; args)
            write(arg);
    }

    public void writeiln(T ...)(T args)
    {
        writei(args);
        writeln();
    }

    public void writeif(T ...)(T args)
    {
        writei(format(args));
    }

    public void writeifln(T ...)(T args)
    {
        writeif(args);
        writeln();
    }
}
