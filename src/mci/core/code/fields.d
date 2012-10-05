module mci.core.code.fields;

import mci.core.container,
       mci.core.utilities,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.code.symbols,
       mci.core.typing.types;

public abstract class Field
{
    private Module _module;
    private string _name;
    private Type _type;
    private ForeignSymbol _forwarder;
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_module);
        assert(_name);
        assert(_type);
        assert(_metadata);
    }

    private this(Module module_, string name, Type type, ForeignSymbol forwarder)
    in
    {
        assert(module_);
        assert(name);
        assert(type);
    }
    body
    {
        _module = module_;
        _name = name;
        _type = type;
        _forwarder = forwarder;
        _metadata = new typeof(_metadata)();
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

    @property public Type type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public ForeignSymbol forwarder() pure nothrow
    {
        return _forwarder;
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

public final class GlobalField : Field
{
    public this(Module module_, string name, Type type, ForeignSymbol forwarder)
    in
    {
        assert(module_);
        assert(name);
        assert(type);
        assert(!module_.globalFields.get(name));
    }
    body
    {
        super(module_, name, type, forwarder);

        (cast(NoNullDictionary!(string, GlobalField))module_.globalFields)[name] = this;
    }
}

public final class ThreadField : Field
{
    public this(Module module_, string name, Type type, ForeignSymbol forwarder)
    in
    {
        assert(module_);
        assert(name);
        assert(type);
        assert(!module_.threadFields.get(name));
    }
    body
    {
        super(module_, name, type, forwarder);

        (cast(NoNullDictionary!(string, ThreadField))module_.threadFields)[name] = this;
    }
}
