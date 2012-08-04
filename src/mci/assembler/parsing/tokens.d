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
    openBrace, /// The opening brace character.
    closeBrace, /// The closing brace character.
    openParen, /// The opening parenthesis character.
    closeParen, /// The closing parenthesis character.
    openBracket, /// The opening bracket character.
    closeBracket, /// The closing bracket character.
    colon, /// The colon character.
    semicolon, /// The semicolon character.
    comma, /// The comma character.
    equals, /// The equals character.
    star, /// The asterisk character.
    and, /// The and character.
    slash, /// The forward slash character.
    type, /// The $(PRE type) keyword.
    align_, /// The $(PRE align) keyword.
    field, /// The $(PRE field) keyword.
    instance, /// The $(PRE instance) keyword.
    static_, /// The $(PRE static) keyword.
    thread, /// The $(PRE thread) keyword.
    function_, /// The $(PRE function) keyword.
    cdecl, /// The $(PRE cdecl) keyword.
    stdCall, /// The $(PRE stdcall) keyword.
    ssa, /// The $(PRE ssa) keyword.
    pure_, /// The $(PRE pure) keyword.
    noOptimization, /// The $(PRE nooptimize) keyword.
    noInlining, /// The $(PRE noinline) keyword.
    register, /// The $(PRE register) keyword.
    block, /// The $(PRE block) keyword.
    unwind, /// The $(PRE unwind) keyword.
    module_, /// The $(PRE module) keyword.
    entry, /// The $(PRE entry) keyword.
    exit, /// The $(PRE exit) keyword.
    void_, /// The $(PRE void) keyword.
    int8, /// The $(PRE int8) keyword.
    uint8, /// The $(PRE uint8) keyword.
    int16, /// The $(PRE int16) keyword.
    uint16, /// The $(PRE uint16) keyword.
    int32, /// The $(PRE int32) keyword.
    uint32, /// The $(PRE uint32( keyword.
    int64, /// The $(PRE int64) keyword.
    uint64, /// The $(PRE uint64) keyword.
    int_, /// The $(PRE int) keyword.
    uint_, /// The $(PRE uint) keyword.
    float32, /// The $(PRE float32) keyword.
    float64, /// The $(PRE float64) keyword.
    opCode, /// Any opcode name.
    literal, /// Any literal (integer, floating point, etc).
}

private __gshared TokenType[char] delimiters;
private __gshared TokenType[string] keywordsToTypes;

nothrow shared static this()
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

    keywordsToTypes = ["type" : TokenType.type,
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
                       "module" : TokenType.module_,
                       "entry" : TokenType.entry,
                       "exit" : TokenType.exit,
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
public Nullable!TokenType delimiterCharToType(char chr) nothrow
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

    pure nothrow invariant()
    {
        assert(_type != TokenType.begin && _type != TokenType.end ? !!_value : !_value);
    }

    //@disable this();

    /**
     * Constructs a new $(D Token).
     *
     * Params:
     *  type = The token type.
     *  value = The string value of the token.
     *  location = The location of the token in the source code.
     */
    public this(TokenType type, string value, SourceLocation location) pure nothrow
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

/**
 * Represents a linear stream of $(D Token) instances.
 */
public interface TokenStream
{
    /**
     * Gets the current token in the stream.
     *
     * Returns:
     *  The current token in the stream.
     */
    @property public Token current();

    /**
     * Gets the previous token in the stream.
     *
     * It is a logic error if the stream is in the initial state.
     *
     * Returns:
     *  The previous token in the stream.
     */
    @property public Token previous();

    /**
     * Gets the next token in the stream.
     *
     * It is a logic error if $(D done) is $(D true).
     *
     * Returns:
     *  The next token in the stream.
     */
    @property public Token next();

    /**
     * Indicates whether the end of the token stream
     * has been reached.
     *
     * Returns:
     *  $(D true) if the end of the token stream has
     *  been reached; otherwise, $(D false).
     */
    @property public bool done();

    /**
     * Moves to the previous token in the stream.
     *
     * It is a logic error if the stream is in the initial state.
     */
    public Token movePrevious();

    /**
     * Moves to the next token in the stream.
     *
     * It is a logic error if $(D done) is $(D true).
     */
    public Token moveNext();

    /**
     * Resets the stream to its initial state.
     */
    public void reset();
}

/**
 * Represents a $(D TokenStream) comprising a linear list
 * of $(D Token) instances in memory.
 */
public final class MemoryTokenStream : TokenStream
{
    private ReadOnlyIndexable!Token _stream;
    private size_t _position;

    invariant()
    {
        assert(_stream);
        assert((cast()_stream).count >= 2);
        assert((cast()_stream)[0].type == TokenType.begin);
        assert((cast()_stream)[(cast()_stream).count - 1].type == TokenType.end);
    }

    /**
     * Constructs a new $(D MemoryTokenStream) instance.
     *
     * Params:
     *  stream = The linear stream of tokens.
     */
    public this(ReadOnlyIndexable!Token stream)
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

    /**
     * Gets the backing list of tokens.
     *
     * Returns:
     *  The backing list of tokens.
     */
    @property public ReadOnlyIndexable!Token tokens()
    out (result)
    {
        assert(result);
        assert((cast()result).count >= 2);
        assert((cast()result)[0].type == TokenType.begin);
        assert((cast()result)[(cast()result).count - 1].type == TokenType.end);
    }
    body
    {
        return _stream;
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
