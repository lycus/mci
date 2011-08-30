module mci.assembler.parsing.tokens;

import mci.core.diagnostics.debugging;

public enum TokenType : ubyte
{
    Begin = 0,
    End = 1,
}

public final class Token
{
    private TokenType _type;
    private string _value;
    private SourceLocation _location;
    
    public this(TokenType type, string value, SourceLocation location)
    in
    {
        assert(value);
        assert(location);
    }
    body
    {
        _type = type;
        _value = value;
        _location = location;
    }
    
    @property public TokenType type()
    {
        return _type;
    }
    
    @property public string value()
    {
        return _value;
    }
    
    @property public SourceLocation location()
    {
        return _location;
    }
}
