module mci.core.typing.generics;

import std.traits,
       mci.core.container,
       mci.core.typing.core,
       mci.core.typing.types;

public class GenericType : TypeSpecification
{
    private NoNullList!string _genericParameters;
    
    public this(StructureType elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType);
        
        _genericParameters = new NoNullList!string();
    }
    
    @property public final NoNullList!string genericParameters()
    {
        return _genericParameters;
    }
    
    public final GenericTypeInstance construct(Countable!TypeBase args)
    in
    {
        assert(args.count == genericParameters.count);
    }
    body
    {
        auto instance = new GenericTypeInstance(cast(StructureType)elementType);
        
        foreach (gp; genericParameters)
            instance.genericParameters.add(gp);
        
        foreach (ga; args)
            instance.genericArguments.add(ga);
        
        return instance;
    }
}

public class GenericTypeInstance : GenericType
{
    private NoNullList!TypeBase _genericArguments;
    
    public this(StructureType elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType);
    }
    
    @property public final NoNullList!TypeBase genericArguments()
    {
        return _genericArguments;
    }
}

unittest
{
    auto st = new StructureType("test_struct");
    auto gt = new GenericType(st);
    
    gt.genericParameters.add("a");
    gt.genericParameters.add("b");
    
    auto args = new NoNullList!TypeBase();
    
    args.add(new Int32Type());
    args.add(new Float64Type());
    
    auto gti = gt.construct(args);
    
    assert(gti);
    assert(gti.genericArguments.get(0).name == "int32");
    assert(gti.genericArguments.get(1).name == "float64");
    assert(gti.genericArguments.count == 2);
}
