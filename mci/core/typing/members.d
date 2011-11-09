module mci.core.typing.members;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.typing.types;

public enum FieldAttributes : ubyte
{
    none = 0x00,
    static_ = 0x01,
    constant = 0x02,
}

public final class Field
{
    private string _name;
    private Type _type;
    private Nullable!uint _offset;
    private FieldAttributes _attributes;

    public this(string name, Type type, FieldAttributes attributes = FieldAttributes.none,
                Nullable!uint offset = Nullable!uint())
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
        _attributes = attributes;
        _offset = offset;
    }

    @property public istring name()
    {
        return _name;
    }

    @property public Type type()
    {
        return _type;
    }

    @property public FieldAttributes attributes()
    {
        return _attributes;
    }

    @property public Nullable!uint offset()
    {
        return _offset;
    }
}
