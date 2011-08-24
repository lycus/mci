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
    private Type _type;
    private Nullable!int _offset;
    public FieldAttributes attributes;
    
    public this(string name, Type type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
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
    
    @property public Type type()
    {
        return _type;
    }
    
    @property public void type(Type type)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
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
