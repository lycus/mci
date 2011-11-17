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

public enum TypeLayout : ubyte
{
    automatic = 0,
    sequential = 1,
    explicit = 2,
}

public final class StructureType : Type
{
    private TypeLayout _layout;
    private Module _module;
    private string _name;
    private Nullable!uint _packingSize;
    private NoNullList!Field _fields;
    private bool _isClosed;

    invariant()
    {
        assert(_module);
        assert(_name);

        if (_packingSize.hasValue)
            assert(_packingSize.value);

        assert(_fields);
    }

    package this(Module module_, string name, TypeLayout layout = TypeLayout.automatic,
                 Nullable!uint packingSize = Nullable!uint())
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
        _layout = layout;
        _packingSize = packingSize;
        _fields = new typeof(_fields)();

        (cast(NoNullList!StructureType)module_.types).add(this);
    }

    @property public TypeLayout layout()
    {
        return _layout;
    }

    @property public Module module_()
    out (result)
    {
        assert(result);
    }
    body
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
    out (result)
    {
        assert(result);
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
        assert(!contains(_fields, (Field f) { return f.name == name; }));
        assert(!_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto field = new Field(this, name, type, attributes, offset);
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

    invariant()
    {
        assert(_elementType);
    }

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
    out (result)
    {
        assert(result);
    }
    body
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

    invariant()
    {
        assert(_returnType);
        assert(_parameterTypes);
    }

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
    out (result)
    {
        assert(result);
    }
    body
    {
        return _returnType;
    }

    @property public Countable!Type parameterTypes()
    out (result)
    {
        assert(result);
    }
    body
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
