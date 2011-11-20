module mci.core.typing.members;

import mci.core.container,
       mci.core.nullable,
       mci.core.typing.types;

public enum FieldStorage : ubyte
{
    instance = 0,
    static_ = 1,
    constant = 2,
}

public final class Field
{
    private StructureType _declaringType;
    private string _name;
    private Type _type;
    private Nullable!uint _offset;
    private FieldStorage _storage;

    invariant()
    {
        assert(_declaringType);
        assert(_name);
        assert(_type);
        assert(_declaringType.layout == TypeLayout.explicit ? _offset.hasValue : !_offset.hasValue);
    }

    package this(StructureType declaringType, string name, Type type, FieldStorage storage = FieldStorage.instance,
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
        _storage = storage;
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

    @property public FieldStorage storage()
    {
        return _storage;
    }

    @property public Nullable!uint offset()
    {
        return _offset;
    }

    public override string toString()
    {
        return _declaringType.toString() ~ ":" ~ _name;
    }
}
