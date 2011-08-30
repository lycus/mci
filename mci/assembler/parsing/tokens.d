module mci.assembler.parsing.tokens;

public enum TokenType : ubyte
{
    Begin = 0,
    End = 1,
}

public final class Token
{
    private TokenType _type;
    private string _value;
    
    public this(TokenType type, string value)
    in
    {
        assert(value);
    }
    body
    {
        _type = type;
        _value = value;
    }
    
    @property public TokenType type()
    {
        return _type;
    }
    
    @property public string value()
    {
        return _value;
    }
}
