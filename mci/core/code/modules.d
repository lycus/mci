module mci.core.code.modules;

import mci.core.common,
       mci.core.container,
       mci.core.program,
       mci.core.code.functions,
       mci.core.typing.types;

public final class Module
{
    private Program _program;
    private string _name;
    private NoNullDictionary!(string, Function) _functions;
    private NoNullDictionary!(string, StructureType) _types;

    invariant()
    {
        assert(_program);
        assert(_name);
        assert(_functions);
        assert(_types);
    }

    public this(Program program, string name)
    in
    {
        assert(program);
        assert(name);
        assert(!program.modules.get(name));
    }
    body
    {
        _program = program;
        _name = name;
        _functions = new typeof(_functions)();
        _types = new typeof(_types)();

        (cast(Dictionary!(string, Module))program.modules)[name] = this;
    }

    @property public Program program()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _program;
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

    @property public Lookup!(string, Function) functions()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _functions;
    }

    @property public Lookup!(string, StructureType) types()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    public override string toString()
    {
        return _name;
    }
}
