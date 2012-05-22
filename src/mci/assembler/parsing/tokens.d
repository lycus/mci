module mci.assembler.parsing.tokens;

import mci.core.container,
       mci.core.nullable,
       mci.core.code.opcodes,
       mci.assembler.parsing.location;

/**
 * Represents the various tokens that can appear in IAL source code.
 */
public enum TokenType : ubyte
{
    begin, /// Indicates the beginning of a token stream.
    end, /// Indicates the end of a token stream.
    identifier, /// Any alphanumeric identifier (may also include underscores and dots).
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
    and,
    slash,
    type,
    align_,
    field,
    instance,
    static_,
    thread,
    function_,
    cdecl,
    stdCall,
    ssa,
    pure_,
    noOptimization,
    noInlining,
    register,
    block,
    unwind,
    entry,
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
    literal, /// Any literal (integer, floating point, etc).
}

private __gshared TokenType[char] delimiters;

shared static this()
{
    delimiters = ['{' : TokenType.openBrace,
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
                  '&' : TokenType.and,
                  '/' : TokenType.slash];
}

/**
 * Maps a character to a delimiter, if possible.
 *
 * Params:
 *  The character to map to a delimiter.
 *
 * Returns:
 *  A non-null token type for the character if it could be mapped
 *  to a delimiter; otherwise, a null value.
 */
public Nullable!TokenType delimiterCharToType(char chr)
{
    if (auto type = chr in delimiters)
        return nullable(*type);

    return Nullable!TokenType();
}

/**
 * Maps an identifier to a token type.
 *
 * This first attempts to match the identifier against keywords and
 * opcode names. If this fails, $(D TokenType.identifier) is returned.
 *
 * Params:
 *  The identifier to map to a token type.
 *
 * Returns:
 *  A token type indicating the keyword or opcode that $(D identifier)
 *  represents, if any; otherwise, $(D TokenType.identifier).
 */
public TokenType identifierToType(string identifier)
in
{
    assert(identifier);
}
body
{
    auto keywordsToTypes = ["type" : TokenType.type,
                            "align" : TokenType.align_,
                            "field" : TokenType.field,
                            "instance" : TokenType.instance,
                            "static" : TokenType.static_,
                            "thread" : TokenType.thread,
                            "function" : TokenType.function_,
                            "cdecl" : TokenType.cdecl,
                            "stdcall" : TokenType.stdCall,
                            "ssa" : TokenType.ssa,
                            "pure" : TokenType.pure_,
                            "nooptimize" : TokenType.noOptimization,
                            "noinline" : TokenType.noInlining,
                            "register" : TokenType.register,
                            "block" : TokenType.block,
                            "unwind" : TokenType.unwind,
                            "entry" : TokenType.entry,
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

/**
 * Represents a token in IAL source code.
 */
public struct Token
{
    private TokenType _type;
    private string _value;
    private SourceLocation _location;

    invariant()
    {
        assert(_type != TokenType.begin && _type != TokenType.end ? !!_value : !_value);
    }

    //@disable this();

    public this(TokenType type, string value, SourceLocation location)
    in
    {
        assert(type != TokenType.begin && type != TokenType.end ? !!value : !value);
    }
    body
    {
        _type = type;
        _value = value;
        _location = location;
    }

    /**
     * Gets the type of this token.
     *
     * Returns:
     *  The type of this token.
     */
    @property public TokenType type() pure nothrow
    {
        return _type;
    }

    /**
     * Gets the value associated with this token.
     *
     * Returns:
     *  The value of this token. This may be $(D null) if the token
     *  is of type $(D TokenType.begin) or $(D TokenType.end).
     */
    @property public string value() pure nothrow
    out (result)
    {
        assert(_type != TokenType.begin && _type != TokenType.end ? !!result : !result);
    }
    body
    {
        return _value;
    }

    /**
     * Gets the location of this token in the source text.
     *
     * Returns:
     *  The location of this token in the source text.
     */
    @property public SourceLocation location() pure nothrow
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

    public void reset() pure nothrow;
}

public final class MemoryTokenStream : TokenStream
{
    private List!Token _stream;
    private size_t _position;

    invariant()
    {
        assert(_stream);
        assert((cast()_stream).count >= 2);
        assert((cast()_stream)[0].type == TokenType.begin);
        assert((cast()_stream)[(cast()_stream).count - 1].type == TokenType.end);
    }

    public this(List!Token stream)
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

    public void reset() pure nothrow
    {
        _position = 0;
    }
}
