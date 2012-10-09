module mci.core.code.data;

import mci.core.container,
       mci.core.utilities,
       mci.core.code.metadata,
       mci.core.code.modules;

public final class DataBlock
{
    private Module _module;
    private string _name;
    private List!ubyte _bytes;
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_module);
        assert(_name);
        assert(_bytes);
    }

    public this(Module module_, string name, List!ubyte bytes)
    in
    {
        assert(module_);
        assert(name);
        assert(bytes);
        assert(!module_.dataBlocks.get(name));
    }
    body
    {
        _module = module_;
        _name = name;
        _bytes = bytes;
        _metadata = new typeof(_metadata)();

        (cast(NoNullDictionary!(string, DataBlock))module_.dataBlocks)[name] = this;
    }

    @property public Module module_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _module;
    }

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public List!ubyte bytes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _bytes;
    }

    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    public override string toString()
    {
        return _module.toString() ~ "/" ~ escapeIdentifier(_name);
    }
}
