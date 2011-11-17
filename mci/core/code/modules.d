module mci.core.code.modules;

import mci.core.common,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.types;

public final class Module
{
    private string _name;
    private NoNullList!Function _functions;
    private NoNullList!StructureType _types;

    invariant()
    {
        assert(_name);
        assert(_functions);
        assert(_types);
    }

    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _functions = new typeof(_functions)();
        _types = new typeof(_types)();
    }

    @property public istring name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public Countable!Function functions()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _functions;
    }

    @property public Countable!StructureType types()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    public Function createFunction(string name, Type returnType, FunctionAttributes attributes = FunctionAttributes.none,
                                   CallingConvention callingConvention = CallingConvention.queueCall)
    in
    {
        assert(name);
        assert(returnType);
        assert(!contains(_functions, (Function f) { return f.name == name; }));
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto func = new Function(this, name, returnType, attributes, callingConvention);
        _functions.add(func);

        return func;
    }
}

unittest
{
    auto mod = new Module("stuff");

    assert(isType!(NoNullList!StructureType)(mod.types));
}
