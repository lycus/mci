module mci.core.typing.generics;

import std.traits,
       mci.core.container,
       mci.core.typing.core,
       mci.core.typing.types;

public enum GenericParameterVariance : ubyte
{
    none = 0,
    covariant = 1,
    contravariant = 2,
}

public enum GenericParameterConstraint : ubyte
{
    none = 0,
    value = 1,
    pointer = 2,
    integral = 3,
    numeric = 4,
}

public class GenericParameter : Type
{
    public GenericParameterVariance variance;
    public GenericParameterConstraint constraint;
    private string _name;
    
    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
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

public class GenericType : TypeSpecification
{
    private NoNullList!GenericParameter _genericParameters;
    
    public this(StructureType elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType);
        
        _genericParameters = new NoNullList!GenericParameter();
    }
    
    @property public final NoNullList!GenericParameter genericParameters()
    {
        return _genericParameters;
    }
    
    public final GenericTypeInstance construct(Countable!Type args)
    in
    {
        assert(args);
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
    private NoNullList!Type _genericArguments;
    
    public this(StructureType elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        super(elementType);
        
        _genericArguments = new NoNullList!Type();
    }
    
    @property public final NoNullList!Type genericArguments()
    {
        return _genericArguments;
    }
}

unittest
{
    auto st = new StructureType("test_struct");
    auto gt = new GenericType(st);
    
    gt.genericParameters.add(new GenericParameter("a"));
    gt.genericParameters.add(new GenericParameter("b"));
    
    auto args = new NoNullList!Type();
    
    args.add(Int32Type.instance);
    args.add(Float64Type.instance);
    
    auto gti = gt.construct(args);
    
    assert(gti);
    assert(gti.genericArguments.get(0).name == "int32");
    assert(gti.genericArguments.get(1).name == "float64");
    assert(gti.genericArguments.count == 2);
}
