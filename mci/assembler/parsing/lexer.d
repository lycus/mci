module mci.assembler.parsing.lexer;

import std.conv,
       std.file,
       std.uni,
       std.utf,
       mci.core.io,
       mci.core.container,
       mci.core.diagnostics.debugging,
       mci.assembler.exception,
       mci.assembler.parsing.tokens;

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
    
    public dchar moveNext()
    {
        if (!_position)
            _location = new SourceLocation(1, 1);
        
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
    
    public dchar next()
    {
        if (_position == _source.length)
            return dchar.init;
        
        auto index = _position;
        
        return decode(_source, index);
    }
    
    public void reset()
    {
        _position = 0;
        _current = dchar.init;
        _location = new SourceLocation(1, 1);
    }
}

private string removeByteOrderMark(string text)
{
    // Stolen from Bernard Helyer's SDC. Thanks!
    if (text.length >= 2 && text[0 .. 2] == [0xfe, 0xff] ||
        text.length >= 2 && text[0 .. 2] == [0xff, 0xfe] ||
        text.length >= 4 && text[0 .. 4] == [0x00, 0x00, 0xfe, 0xff] ||
        text.length >= 4 && text[0 .. 4] == [0xff, 0xfe, 0x00, 0x00])
        throw new AssemblerException("Only UTF-8 input is supported.");
    
    if (text.length >= 3 && text[0 .. 3] == [0xef, 0xbb, 0xbf])
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
    
    public MemoryTokenStream lex()
    {
        auto stream = new NoNullList!Token();
        
        Token tok;
        
        while ((tok = lexNext()) !is null)
            stream.add(tok);
        
        return new MemoryTokenStream(stream);
    }
    
    private static void error(T)(string expected, T got)
    {
        throw new LexerException("Expected " ~ expected ~ ", but found " ~
                                 to!string(got) ~ ".");
    }
    
    private Token lexNext()
    {
        dchar chr;
        string str;
        
        // TODO: Handle integers and floats.
        while ((chr = _source.moveNext()) != dchar.init)
        {
            // Skip any white space.
            if (isWhite(chr))
                continue;
            
            if (chr == '/')
            {
                if (_source.moveNext() == '/')
                {
                    // We have a comment, so scan to the end of the line.
                    while (_source.moveNext() != '\n')
                    {
                    }
                }
                else
                    error("'/'", chr);
            }
            
            // Simple symbols.
            switch (chr)
            {
                case '{':
                case '}':
                case '(':
                case ')':
                case '[':
                case ']':
                case '<':
                case '>':
                case ':':
                case ';':
                case '.':
                case ',':
                case '=':
                case '*':
                    return new Token(charToType(chr), chr.stringof, _source.location);
                default:
                    break;
            }
            
            if (isIdentifierChar(chr))
            {
                string id = [cast(char)chr];
                dchar idChr;
                bool hasDot;
                
                // Until we encounter white space, we construct an identifier.
                while (!isWhite(idChr = _source.moveNext()))
                {
                    auto isDot = chr == '.';
                    
                    if (isDot)
                        hasDot = true;
                    
                    if (isIdentifierChar(idChr) || isDot)
                        id ~= cast(char)idChr;
                    else
                        error("identifier character", idChr);
                }
                
                auto type = identifierToType(id);
                
                if (hasDot && type != TokenType.opCode)
                    error("opcode name", id);
                
                // This can be a keyword, an opcode, or an identifier.
                return new Token(type, id, _source.location);
            }
            
            error("any valid character", chr);
        }
        
        return null;
    }
}

private bool isIdentifierChar(dchar chr)
{
    return chr == '_' || std.ascii.isAlpha(chr);
}
