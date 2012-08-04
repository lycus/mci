module mci.assembler.parsing.lexer;

import std.ascii,
       std.conv,
       std.utf,
       mci.core.io,
       mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.assembler.exception,
       mci.assembler.parsing.exception,
       mci.assembler.parsing.location,
       mci.assembler.parsing.tokens;

/**
 * Represents the source text input to the $(D Lexer).
 */
public final class Source
{
    private string _source;
    private size_t _position;
    private char _current;
    private SourceLocation _location;

    /**
     * Constructs a new $(D Source) instance.
     *
     * Throws:
     *  $(D AssemblerException) if the source text is not UTF-8.
     *
     * Params:
     *  source = The source text.
     */
    public this(string source)
    {
        source = removeByteOrderMark(source);
        validate(source);

        _source = source;
        _location = typeof(_location)(1, 0);
    }

    /**
     * Gets the current input character.
     *
     * Returns:
     *  The current input character. This can be $(D char.init)
     *  if this $(D Source) object is the initial state or if
     *  the end of the input has been reached.
     */
    @property public char current() pure nothrow
    {
        return _current;
    }

    /**
     * Gets the current position in the source text.
     *
     * Returns:
     *  The current position in the source text.
     */
    @property public SourceLocation location() pure nothrow
    {
        return _location;
    }

    /**
     * Moves to the next source character and returns it.
     *
     * Returns:
     *  The next source character, or $(D char.init) if the
     *  end of the input text has been reached.
     */
    public char moveNext()
    {
        if (_position == _source.length)
            return _current = char.init;

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

        _location = typeof(_location)(line, column);

        return _current = cast(char)decode(_source, _position);
    }

    /**
     * Gets the next source character.
     *
     * Returns:
     *  The next source character, or $(D char.init) if the
     *  end of the input text has been reached.
     */
    public char next()
    {
        if (_position == _source.length)
            return char.init;

        auto index = _position;

        return cast(char)decode(_source, index);
    }

    /**
     * Peeks $(D offset) characters into the input text
     * from the current position. If $(D offset) is zero,
     * just returns the current character.
     *
     * Returns:
     *  The character at the current position plus
     *  $(D offset), or $(D char.init) if the $(D Source)
     *  instance is in the initial state or the end of
     *  the input text has been reached.
     */
    public char peek(size_t offset)
    {
        if (!offset)
            return _current;

        auto idx = _position;

        for (size_t i = 0; i < offset; i++)
        {
            if (idx >= _source.length)
                return char.init;

            auto chr = cast(char)decode(_source, idx);

            if (i == offset - 1)
                return chr;
        }

        assert(false);
    }

    /**
     * Resets this $(D Source) instance to its initial state.
     */
    public void reset()
    {
        _position = 0;
        _current = char.init;
        _location = typeof(_location)(1, 1);
    }
}

private string removeByteOrderMark(string text) pure
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

/**
 * Represents the IAL (Intermediate Assembly Language) lexer.
 */
public final class Lexer
{
    private Source _source;

    pure nothrow invariant()
    {
        assert(_source);
    }

    /**
     * Constructs a new $(D Lexer).
     *
     * Params:
     *  source = The source input.
     */
    public this(Source source) pure nothrow
    in
    {
        assert(source);
    }
    body
    {
        _source = source;
    }

    /**
     * Lexes the input into a token stream.
     *
     * Throws:
     *  $(D LexerException) if lexing failed.
     *
     * Returns:
     *  The token stream resulting from the lexing.
     */
    public MemoryTokenStream lex()
    out (result)
    {
        assert(result);
    }
    body
    {
        _source.reset();

        auto stream = new List!Token();
        stream.add(Token(TokenType.begin, null, _source.location));

        auto tok = nullable(Token.init);

        while ((tok = lexNext()).hasValue)
            stream.add(tok.value);

        stream.add(Token(TokenType.end, null, _source.location));

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
    }
    body
    {
        string s;

        static if (is(T == char))
            s = got == char.init ? "end of file" : "'" ~ to!string(got) ~ "'";
        else
            s = to!string(got);

        throw new LexerException("Expected " ~ expected ~ ", but found " ~ s ~ ".", location);
    }

    private static void error(string expected, SourceLocation location)
    in
    {
        assert(expected);
    }
    body
    {
        throw new LexerException("Expected " ~ expected ~ ".", location);
    }

    private Nullable!Token lexNext()
    out (result)
    {
        if (_source.current != char.init)
            assert(*cast(Nullable!Token*)&result);
    }
    body
    {
        char chr;

        while ((chr = _source.moveNext()) != char.init)
        {
            // Skip any white space.
            if (isWhite(chr))
                continue;

            if (chr == '/' && _source.next() == '/')
            {
                _source.moveNext();
                return lexComment() ? lexNext() : Nullable!Token();
            }

            auto del = lexDelimiter(chr);

            if (del)
                return del;

            if (isIdentifierChar(chr))
                return nullable(lexIdentifier(chr));

            if (chr == '\'')
                return nullable(lexQuotedIdentifier());

            // Handle integer and float literals.
            if (isDigit(chr) || chr == '-' || chr == '+')
                return nullable(lexLiteral(chr));

            errorGot("any valid character", _source.location, chr);
        }

        // We reached EOF; stop iterating.
        return Nullable!Token();
    }

    private bool lexComment()
    {
        // We have a comment, so scan to the end of the line (or stream).
        char cmtChr;

        do
        {
            // If this happens, we've reached the end of the file.
            if ((cmtChr = _source.moveNext()) == char.init)
                return false;
        }
        while (cmtChr != '\n');

        return true;
    }

    private Nullable!Token lexDelimiter(char chr)
    {
        // Simple operators/delimiters.
        auto delim = delimiterCharToType(chr);

        if (delim.hasValue)
        {
            auto str = to!string(chr);
            return nullable(Token(delim.value, str, makeSourceLocation(str, _source.location)));
        }
        else
            return Nullable!Token();
    }

    private Token lexIdentifier(char chr)
    {
        string id = [chr];

        while (true)
        {
            auto idChr = _source.next();

            if (!isIdentifierChar(idChr) && !isDigit(idChr))
                break;

            id ~= _source.moveNext();
        }

        auto loc = makeSourceLocation(id, _source.location);

        if (id == "nan" || id == "inf")
            return Token(TokenType.literal, id, loc);

        auto type = identifierToType(id);

        // This can be a keyword, an opcode, or an identifier.
        return Token(type, id, loc);
    }

    private Token lexQuotedIdentifier()
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

        if (!id)
            errorGot("non-empty quoted identifier", loc, id);

        return Token(TokenType.identifier, id, makeSourceLocation(id, _source.location));
    }

    private Token lexLiteral(char chr)
    {
        string str = [chr];
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

            return Token(TokenType.literal, id, makeSourceLocation(id, _source.location));
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

            if (digChr == '.')
            {
                if (isHexLiteral)
                    error("base-16 digit", _source.location);
                else
                {
                    _source.moveNext();
                    return lexFloatingPoint(str ~ digChr);
                }
            }

            if (!(isHexLiteral ? isHexDigit(digChr) : isDigit(digChr)))
                break;

            str ~= _source.moveNext();
        }

        return Token(TokenType.literal, str, makeSourceLocation(str, _source.location));
    }

    private Token lexFloatingPoint(string str)
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

        if (peek == 'e')
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

        return Token(TokenType.literal, str, makeSourceLocation(str, _source.location));
    }
}

private SourceLocation makeSourceLocation(string value, SourceLocation location) pure nothrow
in
{
    assert(value);
}
body
{
    return SourceLocation(location.line, location.column - cast(uint)value.length);
}

private bool isIdentifierChar(char chr) pure nothrow
{
    return chr == '_' || chr == '.' || std.ascii.isAlpha(chr);
}
