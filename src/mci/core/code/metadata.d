module mci.core.code.metadata;

/**
 * Represents a metadata pair.
 */
public struct MetadataPair
{
    private string _key;
    private string _value;

    pure nothrow invariant()
    {
        assert(_key);
        assert(_value);
    }

    @disable this();

    /**
     * Constructs a new $(D MetadataPair) instance.
     *
     * Params:
     *  key = The key.
     *  value = The value.
     */
    public this(string key, string value) pure nothrow
    in
    {
        assert(key);
        assert(value);
    }
    body
    {
        _key = key;
        _value = value;
    }

    /**
     * Gets the key of this metadata pair.
     *
     * Returns:
     *  The key of this metadata pair.
     */
    @property public string key() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _key;
    }

    /**
     * Gets the value of this metadata pair.
     *
     * Returns:
     *  The value of this metadata pair.
     */
    @property public string value() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }
}
