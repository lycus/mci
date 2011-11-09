module mci.core.typing.types;

import mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.modules,
       mci.core.typing.members;

public abstract class Type
{
    @property public abstract istring name();
}

public enum TypeAttributes : ubyte
{
    none = 0x00,
    value = 0x01,
}

public enum TypeLayout : ubyte
{
    automatic = 0,
    sequential = 1,
    explicit = 2,
}

public final class StructureType : Type
{
    private TypeAttributes _attributes;
    private TypeLayout _layout;
    private Module _module;
    private string _name;
    private Nullable!uint _packingSize;
    private NoNullList!Field _fields;

    public this(Module module_, string name, NoNullList!Field fields, TypeAttributes attributes = TypeAttributes.none,
                TypeLayout layout = TypeLayout.automatic, Nullable!uint packingSize = Nullable!uint())
    in
    {
        assert(module_);
        assert(name);
        assert(fields);

        if (packingSize.hasValue)
            assert(packingSize.value);
    }
    body
    {
        module_ = module_;
        _name = name;
        _attributes = attributes;
        _layout = layout;
        _fields = fields;
        _packingSize = packingSize;
    }

    @property public TypeAttributes attributes()
    {
        return _attributes;
    }

    @property public TypeLayout layout()
    {
        return _layout;
    }

    @property public Module module_()
    {
        return _module;
    }

    @property package void module_(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        if (module_ !is _module)
        {
            (cast(NoNullList!StructureType)_module.types).remove(this);
            (cast(NoNullList!StructureType)module_.types).add(this);
        }

        _module = module_;
    }

    @property public Nullable!uint packingSize()
    {
        return _packingSize;
    }

    @property public Countable!Field fields()
    {
        return _fields;
    }

    @property public override istring name()
    {
        return _name;
    }
}

public final class PointerType : Type
{
    private Type _elementType;

    public this(Type elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public Type elementType()
    {
        return _elementType;
    }

    @property public override istring name()
    {
        return elementType.name ~ "*";
    }
}

public final class FunctionPointerType : Type
{
    private Type _returnType;
    private NoNullList!Type _parameterTypes;

    public this(Type returnType, NoNullList!Type parameterTypes)
    in
    {
        assert(returnType);
        assert(parameterTypes);
    }
    body
    {
        _returnType = returnType;
        _parameterTypes = parameterTypes;
    }

    @property public Type returnType()
    {
        return _returnType;
    }

    @property public Countable!Type parameterTypes()
    {
        return _parameterTypes;
    }

    @property public override istring name()
    {
        auto s = _returnType.name ~ " *(";

        foreach (i, param; _parameterTypes)
        {
            s ~= param.name;

            if (i != _parameterTypes.count - 1)
                s ~= ", ";
        }

        return s ~ ")";
    }
}

unittest
{
    auto mod = new Module("foo");
    auto st = new StructureType(mod, "bar", new NoNullList!Field());
    auto ptr = new PointerType(st);

    assert(ptr.name == "bar*");
}

unittest
{
    auto mod = new Module("foo");
    auto st = new StructureType(mod, "foo_bar_baz", new NoNullList!Field());
    auto ptr = new PointerType(st);

    assert(ptr.name == "foo_bar_baz*");
}

unittest
{
    auto mod = new Module("foo");
    auto st1 = new StructureType(mod, "bar", new NoNullList!Field());
    auto st2 = new StructureType(mod, "baz", new NoNullList!Field());

    auto params = new NoNullList!Type();
    params.add(st2);
    params.add(st1);

    auto fpt = new FunctionPointerType(st1, params);

    assert(fpt.name == "bar *(baz, bar)");
}
