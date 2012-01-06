module mci.core.code.metadata;

public final class MetadataPair
{
    private string _key;
    private string _value;

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

    @property public string key()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _key;
    }

    @property public string value()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }
}