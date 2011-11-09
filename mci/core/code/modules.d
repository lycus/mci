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

    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _functions = new typeof(_functions)();
        _types = new typeof(_types)();
    }

    @property public istring name()
    {
        return _name;
    }

    @property public Countable!Function functions()
    {
        return _functions;
    }

    @property public Countable!StructureType types()
    {
        return _types;
    }
}

unittest
{
    auto mod = new Module("stuff");

    assert(isType!(NoNullList!Function)(mod.functions));
    assert(isType!(NoNullList!StructureType)(mod.types));
}
