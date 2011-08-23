module mci.core.typing.types;

import mci.core.container,
       mci.core.typing.members;

public abstract class TypeBase
{
    private string _name;
    
    protected this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }
    
    @property public final string name()
    {
        return _name;
    }
    
    @property public final void name(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }
}

public enum TypeAttributes : ubyte
{
    none = 0x00,
    value = 0x01,
}

public enum TypeLayout : ubyte
{
    automatic = 0,
    sequential = 1,
    explicit = 2,
}

public class Type : TypeBase
{
    public TypeAttributes attributes;
    public TypeLayout layout;
    private uint _packingSize = (void*).sizeof;
    private List!Field _fields;
    
    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        super(name);
        
        _fields = new List!Field();
    }
    
    @property public final uint packingSize()
    {
        return _packingSize;
    }
    
    @property public final void packingSize(uint packingSize)
    in
    {
        assert(packingSize);
    }
    body
    {
        _packingSize = packingSize;
    }
    
    @property public List!Field fields()
    {
        return _fields;
    }
}

public abstract class TypeSpecification : TypeBase
{
    private TypeBase _elementType;
    
    invariant()
    {
        assert(_elementType);
    }
    
    public this(string name, TypeBase elementType)
    in
    {
        assert(name);
        assert(elementType);
    }
    body
    {
        super(name);
        
        _elementType = elementType;
    }
    
    @property public final TypeBase elementType()
    {
        return _elementType;
    }
    
    @property public final void elementType(TypeBase elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }
}

public nothrow pure class PointerType : TypeSpecification
{
    public this(TypeBase elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType.name ~ "*", elementType);
    }
}
