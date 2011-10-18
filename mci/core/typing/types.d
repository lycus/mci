module mci.core.typing.types;

import mci.core.container,
       mci.core.nullable,
       mci.core.code.modules,
       mci.core.typing.members;

public abstract class Type
{
    @property public abstract string name();
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
    public TypeAttributes attributes;
    public TypeLayout layout;
    private Module _module;
    private string _name;
    private Nullable!uint _packingSize;
    private NoNullList!Field _fields;

    public this(Module module_, string name)
    in
    {
        assert(module_);
        assert(name);
    }
    body
    {
        _module = module_;
        _name = name;
        _fields = new NoNullList!Field();
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

    @property public void packingSize(Nullable!uint packingSize)
    in
    {
        assert(!packingSize.hasValue || packingSize.value);
    }
    body
    {
        _packingSize = packingSize;
    }

    @property public NoNullList!Field fields()
    {
        return _fields;
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

    @property public void elementType(Type elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public override string name()
    {
        return elementType.name ~ "*";
    }
}

public final class FunctionPointerType : Type
{
    private Type _returnType;
    private NoNullList!Type _parameterTypes;

    public this(Type returnType)
    in
    {
        assert(returnType);
    }
    body
    {
        _returnType = returnType;
        _parameterTypes = new NoNullList!Type();
    }

    @property public Type returnType()
    {
        return _returnType;
    }

    @property public void returnType(Type returnType)
    in
    {
        assert(returnType);
    }
    body
    {
        _returnType = returnType;
    }

    @property public NoNullList!Type parameterTypes()
    {
        return _parameterTypes;
    }

    @property public override string name()
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
    auto st = new StructureType(mod, "bar");
    auto ptr = new PointerType(st);

    assert(ptr.name == "bar*");
}

unittest
{
    auto mod = new Module("foo");
    auto st = new StructureType(mod, "foo_bar_baz");
    auto ptr = new PointerType(st);

    assert(ptr.name == "foo_bar_baz*");
}

unittest
{
    auto mod = new Module("foo");
    auto st1 = new StructureType(mod, "bar");
    auto st2 = new StructureType(mod, "baz");

    auto fpt = new FunctionPointerType(st1);

    fpt.parameterTypes.add(st2);
    fpt.parameterTypes.add(st1);

    assert(fpt.name == "bar *(baz, bar)");
}
