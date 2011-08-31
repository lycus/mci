module mci.assembler.parsing.tokens;

import mci.core.diagnostics.debugging;

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
}

public TokenType identifierToType(string identifier)
{
    switch (identifier)
    {
        case "{":
            return TokenType.openBrace;
            
        case "}":
            return TokenType.closeBrace;
            
        case "(":
            return TokenType.openParen;
            
        case ")":
            return TokenType.closeParen;
            
        case "[":
            return TokenType.openBracket;
            
        case "]":
            return TokenType.closeBracket;
            
        case "<":
            return TokenType.openAngle;
            
        case ">":
            return TokenType.closeAngle;
            
        case ":":
            return TokenType.colon;
            
        case ";":
            return TokenType.semicolon;
            
        case ".":
            return TokenType.dot;
            
        case ",":
            return TokenType.comma;
            
        case "=":
            return TokenType.equals;
            
        case "*":
            return TokenType.star;
            
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
            
        case "covariant":
            return TokenType.covariant;
            
        case "contravariant":
            return TokenType.contravariant;
            
        case "pointer":
            return TokenType.pointer;
            
        case "integral":
            return TokenType.integral;
            
        case "numeric":
            return TokenType.numeric;
            
        case "field":
            return TokenType.field;
            
        case "global":
            return TokenType.global;
            
        case "constant":
            return TokenType.constant;
            
        case "method":
            return TokenType.method;
            
        case "queuecall":
            return TokenType.queueCall;
            
        case "cdecl":
            return TokenType.cdecl;
            
        case "stdcall":
            return TokenType.stdCall;
            
        case "thiscall":
            return TokenType.thisCall;
            
        case "fastcall":
            return TokenType.fastCall;
            
        case "intrinsic":
            return TokenType.intrinsic;
            
        case "readonly":
            return TokenType.readOnly;
            
        case "nooptimization":
            return TokenType.noOptimization;
            
        case "noinlining":
            return TokenType.noInlining;
            
        case "noCallInlining":
            return TokenType.noCallInlining;
            
        default:
            return TokenType.identifier;
    }
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
