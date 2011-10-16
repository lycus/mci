module mci.assembler.parsing.parser;

import std.conv,
       std.string,
       mci.core.container,
       mci.core.diagnostics.debugging,
       mci.core.nullable,
       mci.core.typing.types,
       mci.assembler.exception,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.tokens;

public final class CompilationUnit
{
    private NoNullList!DeclarationNode _nodes;

    public this(NoNullList!DeclarationNode nodes)
    in
    {
        assert(nodes);
    }
    body
    {
        _nodes = nodes;
    }

    @property public Countable!DeclarationNode nodes()
    {
        return _nodes;
    }
}

public final class Parser
{
    private TokenStream _stream;

    public this(TokenStream stream)
    in
    {
        assert(stream);
    }
    body
    {
        _stream = stream;
    }

    private Token peek()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        if (_stream.next.type == TokenType.end)
            errorGot("any token", _stream.current.location, "end of file");

        return _stream.next;
    }

    private Token peekEof()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        return _stream.next;
    }

    private Token next()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        auto token = _stream.moveNext();

        // EOF not allowed.
        if (token.type == TokenType.end)
            errorGot("any token", token.location, "end of file");

        return token;
    }

    private Token nextEof()
    in
    {
        assert(!_stream.done);
    }
    body
    {
        return _stream.moveNext();
    }

    private Token consume(string expect)
    in
    {
        assert(!_stream.done);
    }
    body
    {
        auto next = next();

        if (next.value != expect)
            errorGot("'" ~ expect ~ "'", next.location, next.value);

        return next;
    }

    private static void error(string error, SourceLocation location)
    {
        throw new ParserException(error ~ ".", location);
    }

    private static void errorExpected(string expected, SourceLocation location)
    {
        throw new ParserException("Expected " ~ expected ~ ".", location);
    }

    private static void errorGot(T)(string expected, SourceLocation location, T got)
    {
        throw new ParserException("Expected " ~ expected ~ ", but got '" ~ to!string(got) ~ "'.", location);
    }

    public CompilationUnit parse()
    {
        _stream.reset();
        _stream.moveNext(); // Skip begin token.

        auto ast = new NoNullList!DeclarationNode();

        Token token;

        while ((token = nextEof()).type != TokenType.end)
        {
            if (token.type == TokenType.type)
            {
            }
            else if (token.type == TokenType.method)
            {
            }
            else
                errorGot("'type' or 'function'", token.location, token.value);
        }

        return new CompilationUnit(ast);
    }
}
