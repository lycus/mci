module mci.assembler.parsing.tokens;

import mci.core.container,
       mci.core.code.opcodes,
       mci.core.diagnostics.debugging;

public enum TokenType : ubyte
{
    begin = 0,
    end = 1,
    identifier = 2,
    openBrace = 3,
    closeBrace = 4,
    openParen = 5,
    closeParen = 6,
    openBracket = 7,
    closeBracket = 8,
    openAngle = 9,
    closeAngle = 10,
    colon = 11,
    semicolon = 12,
    dot = 13,
    comma = 14,
    equals = 15,
    star = 16,
    type = 17,
    value = 18,
    automatic = 19,
    sequential = 20,
    explicit = 21,
    pack = 22,
    covariant = 23,
    contravariant = 24,
    pointer = 25,
    integral = 26,
    numeric = 27,
    field = 28,
    global = 29,
    constant = 30,
    method = 31,
    queueCall = 32,
    cdecl = 33,
    stdCall = 34,
    thisCall = 35,
    fastCall = 36,
    intrinsic = 37,
    readOnly = 38,
    noOptimization = 39,
    noInlining = 40,
    noCallInlining = 41,
    unit = 42,
    int8 = 43,
    uint8 = 44,
    int16 = 45,
    uint16 = 46,
    int32 = 47,
    uint32 = 48,
    int64 = 49,
    uint64 = 50,
    nativeInt = 51,
    nativeUInt = 52,
    float32 = 53,
    float64 = 54,
    nativeFloat = 55,
    opCode = 56,
    integer = 57,
    number = 58,
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
            
        case "pack":
            return TokenType.pack;
            
        case "co":
            return TokenType.covariant;
            
        case "contra":
            return TokenType.contravariant;
            
        case "pointer":
            return TokenType.pointer;
            
        case "integral":
            return TokenType.integral;
            
        case "numeric":
            return TokenType.numeric;
            
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
            
        case "intrinsic":
            return TokenType.intrinsic;
            
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

public abstract class TokenStream
{
    @property public abstract Token current();
    
    @property public abstract Token previous();
    
    @property public abstract Token next();
    
    public abstract Token movePrevious();
    
    public abstract Token moveNext();
}

public final class MemoryTokenStream : TokenStream
{
    private NoNullList!Token _stream;
    private size_t _position;
    
    public this(NoNullList!Token stream)
    in
    {
        assert(stream);
    }
    body
    {
        _stream = stream;
    }
    
    @property public override Token current()
    {
        return _stream.get(_position);
    }
    
    @property public override Token previous()
    {
        return _stream.get(_position - 1);
    }
    
    @property public override Token next()
    {
        return _stream.get(_position + 1);
    }
    
    public override Token movePrevious()
    {
        return _stream.get(--_position);
    }
    
    public override Token moveNext()
    {
        return _stream.get(++_position);
    }
}
