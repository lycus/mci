module mci.assembler.parsing.parser;

import std.conv,
       mci.core.container,
       mci.core.diagnostics.debugging,
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

    private Token next()
    {
        auto token = _stream.moveNext();

        // EOF not allowed.
        if (token.type == TokenType.end)
            errorGot("any token", token.location, "end of file");

        return token;
    }

    private Token nextEof()
    {
        return _stream.moveNext();
    }

    private static void error(string expected, SourceLocation location)
    {
        throw new ParserException("Expected " ~ expected ~ ".", location);
    }

    private static void errorGot(T)(string expected, SourceLocation location, T got)
    {
        throw new ParserException("Expected " ~ expected ~ ", but got " ~ to!string(got) ~ ".", location);
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
