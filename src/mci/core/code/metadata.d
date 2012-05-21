module mci.core.code.metadata;

public struct MetadataPair
{
    private string _key;
    private string _value;

    invariant()
    {
        assert(_key);
        assert(_value);
    }

    @disable this();

    public this(string key, string value)
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

    @property public string key() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _key;
    }

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
