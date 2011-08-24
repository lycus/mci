module mci.core.typing.members;

import mci.core.nullable,
       mci.core.typing.types;

public enum FieldAttributes : ubyte
{
    none = 0x00,
    global = 0x01,
}

public class Field
{
    private string _name;
    private TypeBase _type;
    private StructureType _declaringType;
    private Nullable!int _offset;
    public FieldAttributes attributes;
    
    public this(string name, TypeBase type, StructureType declaringType)
    in
    {
        assert(name);
        assert(type);
        assert(declaringType);
    }
    body
    {
        _name = name;
        _type = type;
        _declaringType = declaringType;
    }
    
    @property public string name()
    {
        return _name;
    }
    
    @property public void name(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }
    
    @property public TypeBase type()
    {
        return _type;
    }
    
    @property public void type(TypeBase type)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
    }
    
    @property public StructureType declaringType()
    {
        return _declaringType;
    }
    
    @property public void declaringType(StructureType declaringType)
    in
    {
        assert(declaringType);
    }
    body
    {
        _declaringType = declaringType;
    }
    
    @property public Nullable!int offset()
    {
        return _offset;
    }
    
    @property public void offset(Nullable!int offset)
    in
    {
        assert(!offset.hasValue || offset.value >= 0);
    }
    body
    {
        _offset = offset;
    }
}
