module mci.core.typing.members;

import mci.core.container,
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
    private StructureType _declaringType;
    private string _name;
    private Type _type;
    private Nullable!uint _offset;
    private FieldAttributes _attributes;

    invariant()
    {
        assert(_declaringType);
        assert(_name);
        assert(_type);
        assert(_declaringType.layout == TypeLayout.explicit ? _offset.hasValue : !_offset.hasValue);
    }

    package this(StructureType declaringType, string name, Type type, FieldAttributes attributes = FieldAttributes.none,
                 Nullable!uint offset = Nullable!uint())
    in
    {
        assert(declaringType);
        assert(name);
        assert(type);
        assert(declaringType.layout == TypeLayout.explicit ? offset.hasValue : !offset.hasValue);
    }
    body
    {
        _declaringType = declaringType;
        _name = name;
        _type = type;
        _attributes = attributes;
        _offset = offset;
    }

    @property public StructureType declaringType()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _declaringType;
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public Type type()
    out (result)
    {
        assert(result);
    }
    body
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
