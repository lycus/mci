module mci.core.io;

import std.stdio;

public abstract class Stream
{
    @property public abstract size_t position();
    
    @property public abstract void position(size_t position);
    
    @property public abstract size_t length();
    
    @property public abstract void length(size_t length);
    
    @property public abstract bool canRead();
    
    @property public abstract bool canWrite();
    
    @property public abstract bool isOpen();
    
    public abstract ubyte read();
    
    public abstract void write(ubyte value);
    
    public abstract void close();
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
    {
        _file = File(fileName, accessAndModeToString(access, mode) ~ 'b');
        _access = access;
    }
    
    @property public override size_t position()
    {
        return cast(size_t)_file.tell;
    }
    
    @property public override void position(size_t position)
    {
        _file.seek(position);
    }
    
    @property public override size_t length()
    {
        return cast(size_t)_file.size;
    }
    
    @property public override void length(size_t length)
    {
        // We cannot just set the length of a file stream.
        assert(false);
    }
    
    @property public override bool canRead()
    {
        return (_access & FileAccess.read) != 0;
    }
    
    @property public override bool canWrite()
    {
        return (_access & FileAccess.write) != 0;
    }
    
    @property public override bool isOpen()
    {
        return _file.isOpen;
    }
    
    public override ubyte read()
    {
        ubyte[1] b;
        _file.rawRead(b);
        return b[0];
    }
    
    public override void write(ubyte value)
    {
        auto b = [value];
        _file.rawWrite(b);
    }
    
    public override void close()
    {
        _file.close();
    }
}

public final class MemoryStream : Stream
{
    private ubyte[] _data;
    private size_t _position;
    private bool _canWrite;
    
    public this(bool canWrite = true)
    {
        _data = new ubyte[0];
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
    
    @property public override size_t position()
    {
        return _position;
    }
    
    @property public override void position(size_t position)
    {
        _position = position;
    }
    
    @property public override size_t length()
    {
        return _data.length;
    }
    
    @property public override void length(size_t length)
    {
        _data.length = length;
    }
    
    @property public override bool canRead()
    {
        return true;
    }
    
    @property public override bool canWrite()
    {
        return _canWrite;
    }
    
    @property public override bool isOpen()
    {
        return _data !is null;
    }
    
    public override ubyte read()
    {
        return _data[_position++];
    }
    
    public override void write(ubyte value)
    {
        _data[_position++] = value;
    }
    
    public override void close()
    {
        _data = null;
    }
}

public class BinaryReader
{
    private File _file;
    
    public this(File file)
    {
        _file = file;
    }
    
    private mixin template Read(string name, string type)
    {
        mixin("public final " ~ type ~ " read" ~ name ~ "()" ~
              "{" ~
              "    " ~ type ~ "[1] arr;" ~
              "    _file.rawRead(arr);" ~
              "    return arr[0];" ~
              "}");
    }
    
    mixin Read!("Boolean", "bool");
    mixin Read!("Int8", "byte");
    mixin Read!("UInt8", "ubyte");
    mixin Read!("Int16", "short");
    mixin Read!("UInt16", "ushort");
    mixin Read!("Int32", "int");
    mixin Read!("UInt32", "uint");
    mixin Read!("Int64", "long");
    mixin Read!("UInt64", "ulong");
    mixin Read!("NativeInt", "size_t");
    mixin Read!("Float32", "float");
    mixin Read!("Float64", "double");
    mixin Read!("NativeFloat", "real");
    mixin Read!("Char", "char");
    mixin Read!("WChar", "wchar");
    mixin Read!("DChar", "dchar");
    
    private mixin template ReadArray(string name, string type, string read)
    {
        mixin("public final " ~ type ~ " read" ~ name ~ "(size_t length)" ~
              "{" ~
              "    " ~ type ~ " arr;" ~
              "" ~
              "    for (size_t i = 0; i < length; i++)" ~
              "        arr ~= read" ~ read ~ "();" ~
              "" ~
              "    return arr;" ~
              "}");
    }
    
    mixin ReadArray!("Bytes", "ubyte[]", "UInt8");
    mixin ReadArray!("String", "string", "Char");
    mixin ReadArray!("WString", "wstring", "WChar");
    mixin ReadArray!("DString", "dstring", "DChar");
}

public class BinaryWriter
{
    private File _file;
    
    public this(File file)
    {
        _file = file;
    }
    
    private mixin template Write(string name, string type)
    {
        mixin("public final void write" ~ name ~ "(" ~ type ~ " value)" ~
              "{" ~
                  "auto arr = [value];" ~
                  "_file.rawWrite(arr);" ~
              "}");
    }
    
    mixin Write!("Boolean", "bool");
    mixin Write!("Int8", "byte");
    mixin Write!("UInt8", "ubyte");
    mixin Write!("Int16", "short");
    mixin Write!("UInt16", "ushort");
    mixin Write!("Int32", "int");
    mixin Write!("UInt32", "uint");
    mixin Write!("Int64", "long");
    mixin Write!("UInt64", "ulong");
    mixin Write!("NativeInt", "size_t");
    mixin Write!("Float32", "float");
    mixin Write!("Float64", "double");
    mixin Write!("NativeFloat", "real");
    mixin Write!("Char", "char");
    mixin Write!("WChar", "wchar");
    mixin Write!("DChar", "dchar");
    
    private mixin template WriteArray(string name, string type, string read)
    {
        mixin("public final void write" ~ name ~ "(" ~ type ~ " array)" ~
              "in" ~
              "{" ~
              "    assert(array);" ~
              "}" ~
              "body" ~
              "{" ~
              "    foreach (item; array)" ~
              "        write" ~ read ~ "(item);" ~
              "}");
    }
    
    mixin WriteArray!("Bytes", "ubyte[]", "UInt8");
    mixin WriteArray!("String", "string", "Char");
    mixin WriteArray!("WString", "wstring", "WChar");
    mixin WriteArray!("DString", "dstring", "DChar");
}
