module mci.assembler.parsing.lexer;

import std.ascii,
       std.conv,
       std.uni,
       std.utf,
       mci.core.io,
       mci.core.common,
       mci.core.container,
       mci.core.diagnostics.debugging,
       mci.assembler.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.tokens;

public final class Source
{
    private string _source;
    private size_t _position;
    private dchar _current;
    private SourceLocation _location;

    invariant()
    {
        assert(_location);
    }

    public this(string source)
    {
        initialize(source);
    }

    public this(BinaryReader reader, ulong length)
    in
    {
        assert(reader);
    }
    body
    {
        initialize(reader.readArray!string(length));
    }

    private void initialize(string source)
    {
        source = removeByteOrderMark(source);
        validate(source);

        _source = source;
        _location = new typeof(_location)(1, 0);
    }

    @property public dchar current()
    {
        return _current;
    }

    @property public SourceLocation location()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _location;
    }

    public dchar moveNext()
    {
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

        _location = new typeof(_location)(line, column);

        return _current = decode(_source, _position);
    }

    public dchar next()
    {
        if (_position == _source.length)
            return dchar.init;

        auto index = _position;

        return decode(_source, index);
    }

    public dchar peek(size_t offset)
    {
        if (!offset)
            return _current;

        auto idx = _position;

        for (size_t i = 0; i < offset; i++)
        {
            if (idx >= _source.length)
                return dchar.init;

            auto chr = decode(_source, idx);

            if (i == offset - 1)
                return chr;
        }

        assert(false);
    }

    public void reset()
    {
        _position = 0;
        _current = dchar.init;
        _location = new typeof(_location)(1, 1);
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

    invariant()
    {
        assert(_source);
    }

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
    out (result)
    {
        assert(result);
    }
    body
    {
        _source.reset();

        auto stream = new NoNullList!Token();
        stream.add(new Token(TokenType.begin, null, _source.location));

        Token tok;

        while ((tok = lexNext()) !is null)
            stream.add(tok);

        stream.add(new Token(TokenType.end, null, _source.location));

        return new MemoryTokenStream(stream);
    }

    private string expect(string expected)
    in
    {
        assert(expected);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        string id;
        auto loc = _source.location;

        foreach (chr; expected)
        {
            auto next = _source.moveNext();
            id ~= next;

            if (next != chr)
                errorGot(expected, loc, id);
        }

        return expected;
    }

    private static void errorGot(T)(string expected, SourceLocation location, T got)
    in
    {
        assert(expected);
        assert(location);
    }
    body
    {
        string s;

        static if (is(T == dchar))
            s = got == dchar.init ? "end of file" : "'" ~ to!string(got) ~ "'";
        else
            s = to!string(got);

        throw new LexerException("Expected " ~ expected ~ ", but found " ~ s ~ ".", location);
    }

    private static void error(string expected, SourceLocation location)
    in
    {
        assert(expected);
        assert(location);
    }
    body
    {
        throw new LexerException("Expected " ~ expected ~ ".", location);
    }

    private Token lexNext()
    out (result)
    {
        if (_source.current != dchar.init)
            assert(result);
    }
    body
    {
        dchar chr;

        while ((chr = _source.moveNext()) != dchar.init)
        {
            // Skip any white space.
            if (std.uni.isWhite(chr))
                continue;

            if (chr == '/' && _source.next() == '/')
            {
                _source.moveNext();
                return lexComment() ? lexNext() : null;
            }

            auto del = lexDelimiter(chr);

            if (del)
                return del;

            if (isIdentifierChar(chr))
                return lexIdentifier(chr);

            if (chr == '\'')
                return lexQuotedIdentifier();

            // Handle integer and float literals.
            if (isDigit(chr) || chr == '-' || chr == '+')
                return lexLiteral(chr);

            // Handle string literals.
            if (chr == '"')
                return lexString();

            errorGot("any valid character", _source.location, chr);
        }

        // We reached EOF; stop iterating.
        return null;
    }

    private bool lexComment()
    {
        // We have a comment, so scan to the end of the line (or stream).
        dchar cmtChr;

        do
        {
            // If this happens, we've reached the end of the file.
            if ((cmtChr = _source.moveNext()) == dchar.init)
                return false;
        }
        while (cmtChr != '\n');

        return true;
    }

    private Token lexDelimiter(dchar chr)
    {
        // Simple operators/delimiters.
        auto delim = delimiterCharToType(cast(char)chr);

        if (delim.hasValue)
        {
            auto str = to!string(chr);
            return new Token(delim.value, str, makeSourceLocation(str, _source.location));
        }
         else
            return null;
    }

    private Token lexIdentifier(dchar chr)
    out (result)
    {
        assert(result);
    }
    body
    {
        string id = [cast(char)chr];

        while (true)
        {
            auto idChr = _source.next();

            if (!isIdentifierChar(idChr) && !isDigit(idChr))
                break;

            id ~= _source.moveNext();
        }

        auto loc = makeSourceLocation(id, _source.location);

        if (id == "nan" || id == "inf")
            return new Token(TokenType.literal, id, loc);

        auto type = identifierToType(id);

        // This can be a keyword, an opcode, or an identifier.
        return new Token(type, id, loc);
    }

    private Token lexQuotedIdentifier()
    out (result)
    {
        assert(result);
    }
    body
    {
        string id;
        auto loc = _source.location;

        while (true)
        {
            auto idChr = _source.next();

            if (idChr == '\'')
            {
                _source.moveNext();
                break;
            }

            if (idChr == '\\')
            {
                _source.moveNext();

                if (_source.next() == '\'')
                    idChr = _source.moveNext();
            }
            else
                _source.moveNext();

            id ~= idChr;
        }

        if (!id.length)
            errorGot("non-empty quoted identifier", loc, id);

        return new Token(TokenType.identifier, id, makeSourceLocation(id, _source.location));
    }

    private Token lexLiteral(dchar chr)
    out (result)
    {
        assert(result);
    }
    body
    {
        string str = [cast(char)chr];
        auto peek = _source.next();
        auto isN = peek == 'n';
        auto isI = peek == 'i';

        if (!isDigit(chr) && (isN || isI))
        {
            string id;

            if (isN)
                id = expect("nan");
            else
                id = expect("inf");

            return new Token(TokenType.literal, id, makeSourceLocation(id, _source.location));
        }

        bool isHexLiteral;

        // To support hex literals.
        if (chr == '0' && _source.next() == 'x')
        {
            isHexLiteral = true;
            str ~= _source.moveNext();
        }

        while (true)
        {
            auto digChr = _source.next();
            auto isDot = digChr == '.';

            if (isDot)
            {
                if (isHexLiteral)
                    error("base-16 digit", _source.location);
                else
                {
                    _source.moveNext();
                    return lexFloatingPoint(str ~ '.');
                }
            }

            if (!(isHexLiteral ? isHexDigit(digChr) : isDigit(digChr)))
                break;

            str ~= _source.moveNext();
        }

        return new Token(TokenType.literal, str, makeSourceLocation(str, _source.location));
    }

    private Token lexFloatingPoint(string str)
    out (result)
    {
        assert(result);
    }
    body
    {
        bool hasTrailingDigit;

        while (true)
        {
            auto digChr = _source.next();

            if (!isDigit(digChr))
                break;

            hasTrailingDigit = true;
            str ~= _source.moveNext();
        }

        if (!hasTrailingDigit)
            error("base-10 digit", _source.location);

        auto peek = _source.next();

        if (peek == 'e' || peek == 'E')
        {
            str ~= _source.moveNext();

            auto sign = _source.next();

            if (sign == '-' || sign == '+')
                str ~= _source.moveNext();

            while (true)
            {
                auto digChr = _source.next();

                if (!isDigit(digChr))
                    break;

                str ~= _source.moveNext();
            }
        }

        return new Token(TokenType.literal, str, makeSourceLocation(str, _source.location));
    }

    private Token lexString()
    out (result)
    {
        assert(result);
    }
    body
    {
        string str;

        while (true)
        {
            auto chr = _source.next();

            if (chr == '"')
            {
                _source.moveNext();
                break;
            }

            if (chr == '\\')
            {
                _source.moveNext();

                if (_source.next() == '"')
                    chr = _source.moveNext();
            }
            else
                _source.moveNext();

            str ~= chr;
        }

        return new Token(TokenType.string, str, makeSourceLocation(str, _source.location));
    }
}

private SourceLocation makeSourceLocation(string value, SourceLocation location)
in
{
    assert(value);
    assert(location);
}
body
{
    return new SourceLocation(location.line, location.column - cast(uint)value.length);
}

private bool isIdentifierChar(dchar chr)
{
    return chr == '_' || chr == '.' || std.ascii.isAlpha(chr);
}
