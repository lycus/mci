module mci.core.io;

import std.ascii,
       std.conv,
       std.exception,
       std.range,
       std.stdio,
       std.traits,
       mci.core.common,
       mci.core.config,
       mci.core.exception,
       mci.core.meta,
       mci.core.utilities;

/**
 * Represents a stream of bytes.
 */
public interface Stream
{
    /**
     * Gets the zero-based position in the stream.
     *
     * Returns:
     *  The zero-based position in the stream.
     *
     * Throws:
     *  $(D IOException) if this stream doesn't support
     *  querying its position.
     */
    @property public ulong position();

    /**
     * Sets the zero-based position in the stream.
     *
     * Params:
     *  position = The position to seek to.
     *
     * Throws:
     *  $(D IOException) if this stream doesn't support
     *  seeking to arbitrary positions, or if the the
     *  $(D position) value is out of range.
     */
    @property public void position(ulong position);

    /**
     * Gets the length of the stream.
     *
     * Returns:
     *  The length of the stream.
     *
     * Throws:
     *  $(D IOException) if the stream doesn't support
     *  querying its length.
     */
    @property public ulong length();

    /**
     * Sets the length of the stream.
     *
     * Params:
     *  length = The length of the stream.
     *
     * Throws:
     *  $(D IOException) if the stream doesn't support
     *  settings its length.
     */
    @property public void length(ulong length);

    /**
     * Indicates whether this stream supports reading
     * via the $(D read) method.
     *
     * This value will never change during a stream's lifetime.
     *
     * Returns:
     *  $(D true) if calling $(D read) is allowed; otherwise,
     *  $(D false).
     */
    @property public bool canRead() pure nothrow;

    /**
     * Indicates whether this stream supports writing
     * via the $(D write) method.
     *
     * This value will never change during a stream's lifetime.
     *
     * Returns:
     *  $(D true) if calling $(D write) is allowed; otherwise,
     *  $(D false).
     */
    @property public bool canWrite() pure nothrow;

    /**
     * Indicates whether this stream is closed. If the
     * stream is closed, all methods on this interface
     * except $(D isClosed), $(D canRead), and $(D canWrite)
     * will throw an $(D IOException).
     *
     * Returns:
     *  $(D true) if this stream is closed; otherwise, $(D false).
     */
    @property public bool isClosed(); // TODO: Make this pure and nothrow in 2.060.

    /**
     * Reads a byte from the stream.
     *
     * Returns:
     *  The byte read from the stream.
     *
     * Throws:
     *  $(D IOException) if the stream doesn't support reading, or
     *  if the end of the stream has been reached.
     */
    public ubyte read();

    /**
     * Writes a byte to the stream.
     *
     * Params:
     *  value = The byte to write.
     *
     * Throws:
     *  $(D IOException) if the stream doesn't support writing.
     */
    public void write(ubyte value);

    /**
     * Closes this stream, resulting in $(D isClosed) being
     * $(D true). No further operations (on this interface)
     * are allowed (they will throw an $(D IOException)).
     *
     * Closing a stream multiple times has no visible effect.
     */
    public void close();
}

/**
 * Indicates what mode a $(D FileStream) should be opened in.
 */
public enum FileMode : ubyte
{
    read, /// Opens the file for reading, and positions the cursor at the beginning.
    write, /// Opens the file for reading and writing, and positions the cursor at the end.
    truncate, /// Opens the file for reading and writing, truncates it, and positions the cursor at the beginning.
    append, /// Opens the file for reading and writing, and positions the cursor at the end.
}

private char[] modeToString(FileMode mode) pure nothrow
out (result)
{
    assert(result);
}
body
{
    final switch (mode)
    {
        case FileMode.read:
            return ['r'];
        case FileMode.write:
            return ['r', '+'];
        case FileMode.truncate:
            return ['w', '+'];
        case FileMode.append:
            return ['a', '+'];
    }
}

/**
 * Represents a stream interface to a file.
 */
public final class FileStream : Stream
{
    private FileMode _mode;
    private File _file;

    /**
     * Constructs a new $(D FileStream) instance.
     *
     * Params:
     *  fileName = The path to the file to open.
     *  mode = The mode to open the file in.
     *
     * Throws:
     *  $(D IOException) if the file could not be opened.
     */
    public this(string fileName, FileMode mode)
    in
    {
        assert(fileName);
    }
    body
    {
        try
            this(File(fileName, modeToString(mode)), mode);
        catch (ErrnoException)
            throw new IOException(format("Could not open file '%s' in %s mode.", fileName, mode));
    }

    private this(File file, FileMode mode)
    in
    {
        assert(file.isOpen);
    }
    body
    {
        _file = file;
        _mode = mode;
    }

    /**
     * Gets the mode the file was opened in.
     *
     * Does not throw an exception if the file is closed.
     *
     * Returns:
     *  The mode the file was opened in.
     */
    @property public FileMode mode()
    {
        return _mode;
    }

    @property public ulong position()
    {
        // FIXME: This only returns a 32-bit value.
        try
            return _file.tell;
        catch (Exception) // The tell function throws Exception for some ungodly reason.
        {
            close();
            throw new IOException("The file stream is closed.");
        }
    }

    @property public void position(ulong position)
    {
        try
            _file.seek(position);
        catch (ErrnoException)
        {
            close();
            throw new IOException("The file stream is closed.");
        }
    }

    @property public ulong length()
    {
        try
            return _file.size;
        catch (ErrnoException)
        {
            close();
            throw new IOException("The file stream is closed.");
        }
    }

    @property public void length(ulong length)
    {
        try
        {
            auto pos = _file.tell;

            _file.seek(length - 1);
            _file.rawWrite!ubyte([0]);

            _file.seek(pos);
        }
        catch (ErrnoException)
        {
            close();
            throw new IOException("The file stream is closed.");
        }
    }

    @property public bool canRead()
    {
        return true;
    }

    @property public bool canWrite()
    {
        return _mode != FileMode.read;
    }

    @property public bool isClosed()
    {
        return !_file.isOpen;
    }

    /**
     * Gets the path to the file.
     *
     * Does not throw an exception if the file is closed.
     *
     * Returns:
     *  The path to the file.
     */
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

        try
            _file.rawRead(b);
        catch (ErrnoException)
        {
            scope (exit)
                close();

            if (_file.isOpen)
            {
                if (_file.eof)
                    throw new IOException("The end of the file has been reached.");
                else
                    throw new IOException("A physical I/O error occurred.");
            }
            else
                throw new IOException("The file stream is closed.");
        }

        return b[0];
    }

    public void write(ubyte value)
    {
        try
            _file.rawWrite([value]);
        catch (ErrnoException)
        {
            scope (exit)
                close();

            if (_file.isOpen)
                throw new IOException("A physical I/O error occurred.");
            else
                throw new IOException("The file stream is closed.");
        }
    }

    public void close()
    {
        try
            _file.close();
        catch (ErrnoException)
        {
            // Just ignore it. Not much we can do anyway.
        }
    }

    /**
     * Returns a temporary file created by the operating
     * system. The file is guaranteed to be empty and will
     * be opened in $(D FileMode.write) mode.
     *
     * The file will be closed automatically once the process
     * exits, but can also be closed manually. Once closed,
     * the file will be deleted.
     *
     * Returns:
     *  A temporary file stream.
     */
    public static FileStream temporary()
    {
        try
            return new FileStream(File.tmpfile(), FileMode.write);
        catch (ErrnoException)
            throw new IOException("The temporary file could not be created.");
    }
}

/**
 * Represents a stream interface to a byte buffer
 * in memory.
 */
public final class MemoryStream : Stream
{
    private ubyte[] _data;
    private bool _isClosed;
    private size_t _position;
    private bool _canWrite;

    /**
     * Constructs a new $(D MemoryStream) instance.
     *
     * This constructor always constructs a stream
     * that allows writing, since it starts out with
     * an empty buffer.
     */
    public this() pure nothrow
    {
        _canWrite = true;
    }

    /**
     * Constructs a new $(D MemoryStream) instance with
     * a given buffer.
     *
     * Params:
     *  data = The buffer to back the memory stream.
     *  canWrite = Indicates whether writing is allowed.
     */
    public this(ubyte[] data, bool canWrite = true) pure nothrow
    {
        _data = data;
        _canWrite = canWrite;
    }

    @property public ulong position()
    {
        checkOpen();

        return _position;
    }

    @property public void position(ulong position)
    {
        checkOpen();

        // This is neither nice nor safe, but there's not
        // much we can do about it.
        _position = cast(size_t)position;
    }

    @property public ulong length()
    {
        checkOpen();

        return _data.length;
    }

    @property public void length(ulong length)
    {
        checkOpen();

        // This is neither nice nor safe, but there's not
        // much we can do about it.
        _data.length = cast(size_t)length;
    }

    @property public bool canRead() pure nothrow
    {
        return true;
    }

    @property public bool canWrite() pure nothrow
    {
        return _canWrite;
    }

    @property public bool isClosed()
    {
        return _isClosed;
    }

    /**
     * Retrieves the backing buffer of the memory stream.
     *
     * Returns:
     *  The backing buffer of the memory stream.
     */
    @property public ubyte[] data() pure
    {
        checkOpen();

        return _data;
    }

    public ubyte read()
    {
        checkOpen();

        if (_position >= _data.length)
            throw new IOException("The end of the memory stream has been reached.");

        return _data[_position++];
    }

    public void write(ubyte value)
    {
        checkOpen();

        if (_position >= _data.length)
            _data.length = _position + 1;

        _data[_position++] = value;
    }

    public void close()
    {
        _data = null;
        _isClosed = true;
    }

    private void checkOpen() pure
    {
        if (_isClosed)
            throw new IOException("The memory stream is closed.");
    }
}

/**
 * Performs binary reading operations on a stream.
 */
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

    /**
     * Constructs a new $(D BinaryReader) using the
     * specified stream.
     *
     * Params:
     *  stream = The stream to use.
     *  endianness = The endianness of the stream.
     */
    public this(Stream stream, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(stream);
        assert(stream.canRead);
        assert(!stream.isClosed);
    }
    body
    {
        _stream = stream;
        _endianness = endianness;
    }

    /**
     * Retrieves the stream backing this $(D BinaryReader).
     *
     * Returns:
     *  The stream backing this $(D BinaryReader).
     */
    @property public Stream stream() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    /**
     * Gets the endianness that data is read with.
     *
     * Returns:
     *  The endianness that data is read with.
     */
    @property public Endianness endianness() pure nothrow
    {
        return _endianness;
    }

    /**
     * Reads a raw primitive value from the stream.
     *
     * If the host endianness doesn't match this instance's
     * endianness, then the value will be read in reverse
     * endianness.
     *
     * Params:
     *  T = Type of the value to read. Must be a primitive
     *      according to $(D isPrimitiveType).
     */
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
            for (size_t i = 0; i < T.sizeof; i++)
                (cast(ubyte*)&value)[i] = _stream.read();

        return value;
    }

    /**
     * Reads an array of raw primitive values from the stream.
     *
     * If the host endianness doesn't match this instance's
     * endianness, then each value will be read in reverse
     * endianness.
     *
     * Params:
     *  T = The array type. Must hold elements that are primitive
     *      according to $(D isPrimitiveValue).
     *  length = How many elements to read.
     */
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

/**
 * Performs binary writing operations on a stream.
 */
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

    /**
     * Constructs a new $(D BinaryWriter) using the
     * specified stream.
     *
     * Params:
     *  stream = The stream to use.
     *  endianness = The endianness of the stream.
     */
    public this(Stream stream, Endianness endianness = Endianness.littleEndian)
    in
    {
        assert(stream);
        assert(stream.canWrite);
        assert(!stream.isClosed);
    }
    body
    {
        _stream = stream;
        _endianness = endianness;
    }

    /**
     * Retrieves the stream backing this $(D BinaryWriter).
     *
     * Returns:
     *  The stream backing this $(D BinaryWriter).
     */
    @property public Stream stream() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    /**
     * Gets the endianness that data is written with.
     *
     * Returns:
     *  The endianness that data is written with.
     */
    @property public Endianness endianness() pure nothrow
    {
        return _endianness;
    }

    /**
     * Writes a raw primitive value to the stream.
     *
     * If the host endianness doesn't match this instance's
     * endianness, then the value will be written in reverse
     * endianness.
     *
     * Params:
     *  T = Type of $(D value). Must be a primitive according
     *      to $(D isPrimitiveType).
     *  value = The value to write.
     */
    public final void write(T)(T value)
        if (isPrimitiveType!T)
    {
        if (endianness != _endianness)
        {
            for (size_t i = T.sizeof; i > 0; i--)
                _stream.write((cast(ubyte*)&value)[i]);
        }
        else
            for (size_t i = 0; i < T.sizeof; i++)
                _stream.write((cast(ubyte*)&value)[i]);
    }

    /**
     * Writes an array of raw primitive values to the stream.
     *
     * If the host endianness doesn't match this instance's
     * endianness, then each value will be written in reverse
     * endianness.
     *
     * Params:
     *  T = The array type. Must hold elements that are primitive
     *      according to $(D isPrimitiveValue).
     *  values = The values to write.
     */
    public final void writeArray(T)(T values)
        if (isArray!T && isPrimitiveType!(ElementEncodingType!T))
    {
        foreach (item; values)
            write(item);
    }
}

/**
 * Convenience extension of $(D BinaryWriter) for
 * writing structured textual files with controlled
 * indentation.
 */
public class TextWriter : BinaryWriter
{
    private ulong _indent;

    /**
     * Constructs a new $(D TextWriter) using the
     * specified stream.
     *
     * Params:
     *  stream = The stream to use.
     *  endianness = The endianness of the stream.
     */
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

    /**
     * Increases the indentation by 4 spaces.
     */
    public void indent() pure nothrow
    {
        if (_indent != typeof(_indent).max)
            _indent++;
    }

    /**
     * Decreases the indentation by 4 spaces.
     */
    public void dedent() pure nothrow
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
    in
    {
        static assert(T.length);
    }
    body
    {
        write(format(args));
    }

    public void writefln(T ...)(T args)
    in
    {
        static assert(T.length);
    }
    body
    {
        writef(args);
        writeln();
    }

    public void writei(T ...)(T args)
    in
    {
        static assert(T.length);
    }
    body
    {
        for (auto i = 0; i < _indent; i++)
            write("    ");

        foreach (arg; args)
            write(arg);
    }

    public void writeiln(T ...)(T args)
    in
    {
        static assert(T.length);
    }
    body
    {
        writei(args);
        writeln();
    }

    public void writeif(T ...)(T args)
    in
    {
        static assert(T.length);
    }
    body
    {
        writei(format(args));
    }

    public void writeifln(T ...)(T args)
    in
    {
        static assert(T.length);
    }
    body
    {
        writeif(args);
        writeln();
    }
}
