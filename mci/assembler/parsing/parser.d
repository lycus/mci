module mci.assembler.parsing.parser;

import mci.core.container,
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
}
