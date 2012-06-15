module mci.assembler.parsing.exception;

import mci.assembler.exception,
       mci.assembler.parsing.location;

/**
 * The exception thrown by the $(D Lexer) if some input was
 * invalid or could not be lexed.
 */
public class LexerException : AssemblerException
{
    private SourceLocation _location;

    public this(string msg, SourceLocation location, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _location = location;
    }

    public this(string msg, Throwable next, SourceLocation location, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _location = location;
    }

    /**
     * Gets the location of this exception in the source text.
     *
     * Returns:
     *  The location of this exception in the source text.
     */
    @property public SourceLocation location() pure nothrow
    {
        return _location;
    }
}

/**
 * The exception thrown by the $(D Parser) if invalid source
 * code was encountered.
 */
public class ParserException : AssemblerException
{
    private SourceLocation _location;

    public this(string msg, SourceLocation location, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _location = location;
    }

    public this(string msg, Throwable next, SourceLocation location, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _location = location;
    }

    /**
     * Gets the location of this exception in the source code.
     *
     * Returns:
     *  The location of this exception in the source code.
     */
    @property public SourceLocation location() pure nothrow
    {
        return _location;
    }
}
