module mci.assembler.parsing.lexer;

import std.file,
       std.utf,
       mci.core.io,
       mci.core.diagnostics.debugging,
       mci.assembler.exception;

public final class Source
{
    private string _source;
    private size_t _position;
    private dchar _current;
    private SourceLocation _location;
    
    public this(string source)
    in
    {
        assert(source);
    }
    body
    {
        _source = source;
    }
    
    public this(BinaryReader reader, size_t length)
    in
    {
        assert(reader);
    }
    body
    {
        _source = removeByteOrderMark(reader.readString(length));
    }
    
    @property public dchar current()
    {
        return _current;
    }
    
    @property public SourceLocation location()
    {
        return _location;
    }
    
    public dchar next()
    {
        if (_position == _source.length)
            return _current = dchar.init;
        
        auto chr = _source[_position];
        auto line = _location.line;
        auto column = _location.column;
        
        if (chr == '\n')
        {
            line++;
            column = 0;
        }
        
        _location = new SourceLocation(line, column);
        
        return _current = decode(_source, _position);
    }
}

private string removeByteOrderMark(string text)
{
    // Stolen from Bernard Helyer's SDC. Thanks!
    if (text.length >= 2 && text[0 .. 2] == [0xFE, 0xFF] ||
        text.length >= 2 && text[0 .. 2] == [0xFF, 0xFE] ||
        text.length >= 4 && text[0 .. 4] == [0x00, 0x00, 0xFE, 0xFF] ||
        text.length >= 4 && text[0 .. 4] == [0xFF, 0xFE, 0x00, 0x00])
        throw new AssemblerException("Only UTF-8 input is supported.");
    
    if (text.length >= 3 && text[0 .. 3] == [0xEF, 0xBB, 0xBF])
        return text[3 .. $];
    
    return text;
}

public final class Lexer
{
    private Source _source;
    
    public this(Source source)
    in
    {
        assert(source);
    }
    body
    {
        _source = source;
    }
}
