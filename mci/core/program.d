module mci.core.program;

import mci.core.container,
       mci.core.code.modules;

public final class Program
{
    private NoNullDictionary!(string, Module) _modules;

    invariant()
    {
        assert(_modules);
    }

    public this()
    {
        _modules = new typeof(_modules)();
    }

    @property public Lookup!(string, Module) modules()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _modules;
    }
}
