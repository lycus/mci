module mci.core.program;

import mci.core.container,
       mci.core.code.modules,
       mci.core.typing.cache;

public final class Program
{
    private NoNullList!Module _modules;
    private TypeCache _typeCache;

    invariant()
    {
        assert(_modules);
        assert(_typeCache);
    }

    public this()
    {
        _modules = new typeof(_modules)();
        _typeCache = new TypeCache();
    }

    @property public NoNullList!Module modules()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _modules;
    }

    @property public TypeCache typeCache()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _typeCache;
    }
}
