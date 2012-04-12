module mci.core.typing.members;

import mci.core.container,
       mci.core.nullable,
       mci.core.utilities,
       mci.core.code.metadata,
       mci.core.typing.types;

public enum FieldStorage : ubyte
{
    instance = 0,
    static_ = 1,
    thread = 2,
}

public final class Field
{
    private StructureType _declaringType;
    private string _name;
    private Type _type;
    private FieldStorage _storage;
    private List!MetadataPair _metadata;

    invariant()
    {
        assert(_declaringType);
        assert(_name);
        assert(_type);
        assert(_metadata);
    }

    package this(StructureType declaringType, string name, Type type, FieldStorage storage = FieldStorage.instance)
    in
    {
        assert(declaringType);
        assert(name);
        assert(type);
    }
    body
    {
        _declaringType = declaringType;
        _name = name;
        _type = type;
        _storage = storage;
        _metadata = new typeof(_metadata)();
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

    @property public List!MetadataPair metadata()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    public override string toString()
    {
        return _declaringType.toString() ~ ":" ~ escapeIdentifier(_name);
    }
}
