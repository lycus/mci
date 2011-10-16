module mci.assembler.parsing.tokens;

import mci.core.container,
       mci.core.code.opcodes,
       mci.core.diagnostics.debugging;

public enum TokenType : ubyte
{
    begin,
    end,
    identifier,
    openBrace,
    closeBrace,
    openParen,
    closeParen,
    openBracket,
    closeBracket,
    openAngle,
    closeAngle,
    colon,
    semicolon,
    dot,
    comma,
    equals,
    star,
    type,
    value,
    automatic,
    sequential,
    explicit,
    field,
    global,
    constant,
    method,
    queueCall,
    cdecl,
    stdCall,
    thisCall,
    fastCall,
    readOnly,
    noOptimization,
    noInlining,
    noCallInlining,
    unit,
    int8,
    uint8,
    int16,
    uint16,
    int32,
    uint32,
    int64,
    uint64,
    nativeInt,
    nativeUInt,
    float32,
    float64,
    nativeFloat,
    opCode,
    literal,
}

public TokenType charToType(dchar chr)
{
    switch (chr)
    {
        case '{':
            return TokenType.openBrace;
        case '}':
            return TokenType.closeBrace;
        case '(':
            return TokenType.openParen;
        case ')':
            return TokenType.closeParen;
        case '[':
            return TokenType.openBracket;
        case ']':
            return TokenType.closeBracket;
        case '<':
            return TokenType.openAngle;
        case '>':
            return TokenType.closeAngle;
        case ':':
            return TokenType.colon;
        case ';':
            return TokenType.semicolon;
        case '.':
            return TokenType.dot;
        case ',':
            return TokenType.comma;
        case '=':
            return TokenType.equals;
        case '*':
            return TokenType.star;
        default:
            assert(false);
    }
}

public TokenType identifierToType(string identifier)
in
{
    assert(identifier);
}
body
{
    switch (identifier)
    {
        case "type":
            return TokenType.type;
        case "value":
            return TokenType.value;
        case "automatic":
            return TokenType.automatic;
        case "sequential":
            return TokenType.sequential;
        case "explicit":
            return TokenType.explicit;
        case "field":
            return TokenType.field;
        case "static":
            return TokenType.global;
        case "const":
            return TokenType.constant;
        case "function":
            return TokenType.method;
        case "qcall":
            return TokenType.queueCall;
        case "ccall":
            return TokenType.cdecl;
        case "scall":
            return TokenType.stdCall;
        case "tcall":
            return TokenType.thisCall;
        case "fcall":
            return TokenType.fastCall;
        case "pure":
            return TokenType.readOnly;
        case "noopt":
            return TokenType.noOptimization;
        case "noinl":
            return TokenType.noInlining;
        case "nocinl":
            return TokenType.noCallInlining;
        case "unit":
            return TokenType.unit;
        case "int8":
            return TokenType.int8;
        case "uint8":
            return TokenType.uint8;
        case "int16":
            return TokenType.int16;
        case "uint16":
            return TokenType.uint16;
        case "int32":
            return TokenType.int32;
        case "uint32":
            return TokenType.uint32;
        case "int64":
            return TokenType.int64;
        case "uint64":
            return TokenType.uint64;
        case "int":
            return TokenType.nativeInt;
        case "uint":
            return TokenType.nativeUInt;
        case "float32":
            return TokenType.float32;
        case "float64":
            return TokenType.float64;
        case "float":
            return TokenType.nativeFloat;
        default:
            break;
    }
    
    foreach (opCode; allOpCodes)
        if (identifier == opCode.name)
            return TokenType.opCode;
    
    return TokenType.identifier;
}

public final class Token
{
    private TokenType _type;
    private string _value;
    private SourceLocation _location;
    
    public this(TokenType type, string value, SourceLocation location)
    in
    {
        if (type == TokenType.begin || type == TokenType.end)
        {
            assert(!value);
            assert(!location);
        }
        else
        {
            assert(value);
            assert(location);
        }
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

public interface TokenStream
{
    @property public Token current();
    
    @property public Token previous();
    
    @property public Token next();

    @property public bool done();
    
    public Token movePrevious();
    
    public Token moveNext();

    public void reset();
}

public final class MemoryTokenStream : TokenStream
{
    private NoNullList!Token _stream;
    private size_t _position;
    
    public this(NoNullList!Token stream)
    in
    {
        assert(stream);
        assert(stream.count >= 2);
        assert(stream.get(0).type == TokenType.begin);
        assert(stream.get(stream.count - 1).type == TokenType.end);
    }
    body
    {
        _stream = stream;
    }
    
    @property public Token current()
    {
        return _stream.get(_position);
    }
    
    @property public Token previous()
    {
        return _stream.get(_position - 1);
    }
    
    @property public Token next()
    {
        return _stream.get(_position + 1);
    }

    @property public bool done()
    {
        return _position == _stream.count - 1;
    }
    
    public Token movePrevious()
    {
        return _stream.get(--_position);
    }
    
    public Token moveNext()
    {
        return _stream.get(++_position);
    }

    public void reset()
    {
        _position = 0;
    }
}

unittest
{
    auto list = new NoNullList!Token();

    list.add(new Token(TokenType.begin, null, null));
    list.add(new Token(TokenType.unit, "unit", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.constant, "const", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.end, null, null));

    auto stream = new MemoryTokenStream(list);

    assert(stream.current.type == TokenType.begin);
    assert(stream.next.type == TokenType.unit);

    auto next = stream.moveNext();

    assert(next.type == TokenType.unit);
    assert(stream.previous.type == TokenType.begin);
    assert(stream.current.type == TokenType.unit);
    assert(stream.next.type == TokenType.constant);

    auto next2 = stream.moveNext();

    assert(next2.type == TokenType.constant);
    assert(stream.next.type == TokenType.end);
}
