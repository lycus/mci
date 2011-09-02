module mci.assembler.parsing.lexer;

import std.ascii,
       std.conv,
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
            column = 1;
        }
        else
            column++;
        
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
    
    private static void errorGot(T)(string expected, SourceLocation location, T got)
    {
        string s;
        
        static if (is(T == dchar))
            s = got == dchar.init ? "end of file" : got.stringof;
        else
            s = to!string(got);
        
        throw new LexerException("Expected " ~ expected ~ ", but found " ~ s ~ ".", location);
    }
    
    private static void error(string expected, SourceLocation location)
    {
        throw new LexerException("Expected " ~ expected ~ ".", location);
    }
    
    private Token lexNext()
    {
        dchar chr;
        
        while ((chr = _source.moveNext()) != dchar.init)
        {
            // Skip any white space.
            if (std.uni.isWhite(chr))
                continue;
            
            if (chr == '/')
            {
                if (_source.moveNext() != '/')
                    errorGot("/", _source.location, chr);
                
                // We have a comment, so scan to the end of the line (or stream).
                dchar cmtChr;
                
                do
                {
                    // If this happens, we've reached the end of the file, and we
                    // just return null.
                    if ((cmtChr = _source.moveNext()) == dchar.init)
                        return null;
                }
                while (cmtChr != '\n');
                
                // Comment skipped; continue the outer loop and look for the next
                // token, if any.
                continue;
            }
            
            // Simple operators/delimiters.
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
                auto idLoc = _source.location;
                string id = [cast(char)chr];
                bool hasDot;
                
                // Until we encounter white space, we construct an identifier.
                while (true)
                {
                    auto idChr = _source.moveNext();
                    
                    if (std.uni.isWhite(idChr))
                        break;
                    
                    auto isDot = idChr == '.';
                    
                    if (idChr == dchar.init || (!isIdentifierChar(idChr) && !isDot))
                        errorGot("identifier character (a-z, A-Z, _)", _source.location, idChr);
                    
                    if (isDot)
                        hasDot = true;
                    
                    id ~= idChr;
                }
                
                auto type = identifierToType(id);
                
                if (hasDot && type != TokenType.opCode)
                    errorGot("opcode name", idLoc, id);
                
                // This can be a keyword, an opcode, or an identifier.
                return new Token(type, id, _source.location);
            }
            
            // Handle integer and float literals.
            if (isDigit(chr))
            {
                string str = [cast(char)chr];
                bool hasDot;
                bool hasDecimal;
                
                while (true)
                {
                    auto digChr = _source.moveNext();
                    
                    if (std.uni.isWhite(digChr))
                    {
                        // Don't allow a decimal point with no trailing digit.
                        if (hasDot && !hasDecimal)
                            error("base-10 digit", _source.location);
                        
                        break;
                    }
                    
                    if (digChr == '.')
                        hasDot = true;
                    else
                    {
                        if (digChr == dchar.init || !isDigit(digChr))
                            errorGot("base-10 digit" ~ (!hasDot ? "or decimal point" : ""),
                                     _source.location, digChr);
                        
                        if (hasDot)
                            hasDecimal = true;
                    }
                    
                    str ~= digChr;
                }
                
                return new Token(TokenType.literal, str, _source.location);
            }
            
            errorGot("any valid character", _source.location, chr);
        }
        
        // We reached EOF; stop iterating.
        return null;
    }
}

private bool isIdentifierChar(dchar chr)
{
    return chr == '_' || std.ascii.isAlpha(chr);
}
