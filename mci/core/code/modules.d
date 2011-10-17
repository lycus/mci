module mci.core.code.modules;

import mci.core.container,
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
        _functions = new NoNullList!Function();
        _types = new NoNullList!StructureType();
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

    @property public Countable!Function functions()
    {
        return _functions;
    }

    @property public Countable!StructureType types()
    {
        return _types;
    }
}
