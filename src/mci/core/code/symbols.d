module mci.core.code.symbols;

import mci.core.utilities;

/**
 * Represents the name tuple of a symbol (function, field, etc) located
 * in another module or in a native library.
 */
public final class ForeignSymbol
{
    private string _library;
    private string _symbol;

    pure nothrow invariant()
    {
        assert(_library);
        assert(_symbol);
    }

    /**
     * Constructs a new $(D ForeignSymbol) instance.
     *
     * Params:
     *  library = The library to search in.
     *  symbol = The symbol to search for.
     */
    public this(string library, string symbol) pure nothrow
    in
    {
        assert(library);
        assert(symbol);
    }
    body
    {
        _library = library;
        _symbol = symbol;
    }

    /**
     * Gets the library to search in.
     *
     * Returns:
     *  The library to search in.
     */
    @property public string library() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _library;
    }

    /**
     * Gets the symbol to search for.
     *
     * Returns:
     *  The symbol to search for.
     */
    @property public string symbol() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _symbol;
    }

    public override string toString()
    {
        return escapeIdentifier(_library) ~ ", " ~ escapeIdentifier(_symbol);
    }
}
