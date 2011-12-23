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
    colon,
    semicolon,
    comma,
    equals,
    star,
    slash,
    type,
    field,
    instance,
    static_,
    constant,
    function_,
    cdecl,
    stdCall,
    pure_,
    noOptimization,
    noInlining,
    noCallInlining,
    register,
    block,
    void_,
    int8,
    uint8,
    int16,
    uint16,
    int32,
    uint32,
    int64,
    uint64,
    int_,
    uint_,
    float32,
    float64,
    opCode,
    literal,
    string,
}

public TokenType charToType(dchar chr)
{
    return ['{' : TokenType.openBrace,
            '}' : TokenType.closeBrace,
            '(' : TokenType.openParen,
            ')' : TokenType.closeParen,
            '[' : TokenType.openBracket,
            ']' : TokenType.closeBracket,
            ':' : TokenType.colon,
            ';' : TokenType.semicolon,
            ',' : TokenType.comma,
            '=' : TokenType.equals,
            '*' : TokenType.star,
            '/' : TokenType.slash][cast(char)chr];
}

public TokenType identifierToType(string identifier)
in
{
    assert(identifier);
}
body
{
    auto keywordsToTypes = ["type" : TokenType.type,
                            "field" : TokenType.field,
                            "instance" : TokenType.instance,
                            "static" : TokenType.static_,
                            "function" : TokenType.function_,
                            "cdecl" : TokenType.cdecl,
                            "stdcall" : TokenType.stdCall,
                            "pure" : TokenType.pure_,
                            "nooptimize" : TokenType.noOptimization,
                            "noinline" : TokenType.noInlining,
                            "nocallinline" : TokenType.noCallInlining,
                            "register" : TokenType.register,
                            "block" : TokenType.block,
                            "void" : TokenType.void_,
                            "int8" : TokenType.int8,
                            "uint8" : TokenType.uint8,
                            "int16" : TokenType.int16,
                            "uint16" : TokenType.uint16,
                            "int32" : TokenType.int32,
                            "uint32" : TokenType.uint32,
                            "int64" : TokenType.int64,
                            "uint64" : TokenType.uint64,
                            "int" : TokenType.int_,
                            "uint" : TokenType.uint_,
                            "float32" : TokenType.float32,
                            "float64" : TokenType.float64];

    if (auto type = identifier in keywordsToTypes)
        return *type;

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

    invariant()
    {
        assert(_type != TokenType.begin && _type != TokenType.end ? !!_value : !_value);
        assert(_location);
    }

    public this(TokenType type, string value, SourceLocation location)
    in
    {
        assert(type != TokenType.begin && type != TokenType.end ? !!value : !value);
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
    out (result)
    {
        assert(_type != TokenType.begin && _type != TokenType.end ? !!result : !result);
    }
    body
    {
        return _value;
    }

    @property public SourceLocation location()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _location;
    }
}

public interface TokenStream
{
    @property public Token current()
    out (result)
    {
        assert(result);
    }

    @property public Token previous()
    out (result)
    {
        assert(result);
    }

    @property public Token next()
    out (result)
    {
        assert(result);
    }

    @property public bool done();

    public Token movePrevious()
    out (result)
    {
        assert(result);
    }

    public Token moveNext()
    out (result)
    {
        assert(result);
    }

    public void reset();
}

public final class MemoryTokenStream : TokenStream
{
    private NoNullList!Token _stream;
    private size_t _position;

    invariant()
    {
        assert(_stream);
        assert(_stream.count >= 2);
        assert(_stream[0].type == TokenType.begin);
        assert(_stream[_stream.count - 1].type == TokenType.end);
    }

    public this(NoNullList!Token stream)
    in
    {
        assert(stream);
        assert(stream.count >= 2);
        assert(stream[0].type == TokenType.begin);
        assert(stream[stream.count - 1].type == TokenType.end);
    }
    body
    {
        _stream = stream.duplicate();
    }

    @property public Token current()
    {
        return _stream[_position];
    }

    @property public Token previous()
    {
        return _stream[_position - 1];
    }

    @property public Token next()
    {
        return _stream[_position + 1];
    }

    @property public bool done()
    {
        return _position == _stream.count - 1;
    }

    public Token movePrevious()
    {
        return _stream[--_position];
    }

    public Token moveNext()
    {
        return _stream[++_position];
    }

    public void reset()
    {
        _position = 0;
    }
}

unittest
{
    auto list = new NoNullList!Token();

    list.add(new Token(TokenType.begin, null, new SourceLocation(1, 1)));
    list.add(new Token(TokenType.void_, "void", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.constant, "const", new SourceLocation(1, 1)));
    list.add(new Token(TokenType.end, null, new SourceLocation(1, 1)));

    auto stream = new MemoryTokenStream(list);

    assert(stream.current.type == TokenType.begin);
    assert(stream.next.type == TokenType.void_);

    auto next = stream.moveNext();

    assert(next.type == TokenType.void_);
    assert(stream.previous.type == TokenType.begin);
    assert(stream.current.type == TokenType.void_);
    assert(stream.next.type == TokenType.constant);

    auto next2 = stream.moveNext();

    assert(next2.type == TokenType.constant);
    assert(stream.next.type == TokenType.end);
}
