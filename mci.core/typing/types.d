module mci.core.typing.types;

import mci.core.container,
       mci.core.typing.members;

public abstract class TypeBase
{
    @property public abstract string name();
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

public class StructureType : TypeBase
{
    public TypeAttributes attributes;
    public TypeLayout layout;
    private string _name;
    private uint _packingSize = (void*).sizeof;
    private NoNullList!Field _fields;
    
    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _fields = new NoNullList!Field();
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
    
    @property public final NoNullList!Field fields()
    {
        return _fields;
    }
    
    @property public override string name()
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
}

public abstract class TypeSpecification : TypeBase
{
    private TypeBase _elementType;
    
    public this(TypeBase elementType)
    in
    {
        assert(elementType);
    }
    body
    {
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
    
    @property public override string name()
    {
        return elementType.name;
    }
}

public class PointerType : TypeSpecification
{
    public this(TypeBase elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType);
    }
    
    @property public override string name()
    {
        return elementType.name ~ "*";
    }
}
