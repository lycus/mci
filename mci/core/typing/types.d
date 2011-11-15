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
    private bool _isClosed;

    package this(Module module_, string name, TypeAttributes attributes = TypeAttributes.none,
                 TypeLayout layout = TypeLayout.automatic, Nullable!uint packingSize = Nullable!uint())
    in
    {
        assert(module_);
        assert(name);

        if (packingSize.hasValue)
            assert(packingSize.value);
    }
    body
    {
        _module = module_;
        _name = name;
        _attributes = attributes;
        _layout = layout;
        _packingSize = packingSize;
        _fields = new typeof(_fields)();

        (cast(NoNullList!StructureType)module_.types).add(this);
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

    @property public Nullable!uint packingSize()
    {
        return _packingSize;
    }

    @property public Countable!Field fields()
    in
    {
        assert(_isClosed);
    }
    body
    {
        return _fields;
    }

    @property public bool isClosed()
    {
        return _isClosed;
    }

    @property public override istring name()
    {
        return _name;
    }

    public Field createField(string name, Type type, FieldAttributes attributes = FieldAttributes.none,
                             Nullable!uint offset = Nullable!uint())
    in
    {
        assert(name);
        assert(type);
        assert(!_isClosed);
    }
    body
    {
        foreach (f; _fields)
            assert(name != f.name);

        auto field = new Field(name, type, attributes, offset);
        _fields.add(field);

        return field;
    }

    public void close()
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _isClosed = true;
    }
}

public final class PointerType : Type
{
    private Type _elementType;

    package this(Type elementType)
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

    package this(Type returnType, NoNullList!Type parameterTypes)
    in
    {
        assert(returnType);
        assert(parameterTypes);
    }
    body
    {
        _returnType = returnType;
        _parameterTypes = parameterTypes.duplicate();
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

    auto st = new StructureType(mod, "bar");
    st.close();

    auto ptr = new PointerType(st);

    assert(ptr.name == "bar*");
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "foo_bar_baz");
    st.close();

    auto ptr = new PointerType(st);

    assert(ptr.name == "foo_bar_baz*");
}

unittest
{
    auto mod = new Module("foo");

    auto st1 = new StructureType(mod, "bar");
    st1.close();

    auto st2 = new StructureType(mod, "baz");
    st2.close();

    auto params = new NoNullList!Type();
    params.add(st2);
    params.add(st1);

    auto fpt = new FunctionPointerType(st1, params);

    assert(fpt.name == "bar *(baz, bar)");
}
