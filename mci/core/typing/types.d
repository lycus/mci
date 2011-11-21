module mci.core.typing.types;

import mci.core.container,
       mci.core.nullable,
       mci.core.code.modules,
       mci.core.typing.members;

public abstract class Type
{
    @property public abstract string name();

    public override string toString()
    {
        return name;
    }
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
    private NoNullList!Field _fields;
    private bool _isClosed;

    invariant()
    {
        assert(_module);
        assert(_name);
        assert(_fields);
    }

    package this(Module module_, string name, TypeLayout layout = TypeLayout.automatic)
    in
    {
        assert(module_);
        assert(name);
    }
    body
    {
        _module = module_;
        _name = name;
        _layout = layout;
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

    @property public override string name()
    {
        return _name;
    }

    public override string toString()
    {
        return _module.toString() ~ "/" ~ _name;
    }

    public Field createField(string name, Type type, FieldStorage storage = FieldStorage.instance,
                             Nullable!uint offset = Nullable!uint())
    in
    {
        assert(name);
        assert(type);
        assert(layout == TypeLayout.explicit ? offset.hasValue : !offset.hasValue);
        assert(!contains(_fields, (Field f) { return f.name == name; }));
        assert(!_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto field = new Field(this, name, type, storage, offset);
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

    @property public override string name()
    {
        return elementType.toString() ~ "*";
    }
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "bar");
    st.close();

    auto ptr = new PointerType(st);

    assert(ptr.name == "foo/bar*");
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "foo_bar_baz");
    st.close();

    auto ptr = new PointerType(st);

    assert(ptr.name == "foo/foo_bar_baz*");
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

    @property public override string name()
    {
        auto s = _returnType.toString() ~ " (";

        foreach (i, param; _parameterTypes)
        {
            s ~= param.toString();

            if (i < _parameterTypes.count - 1)
                s ~= ", ";
        }

        return s ~ ")";
    }
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

    assert(fpt.name == "foo/bar (foo/baz, foo/bar)");
}

public final class ArrayType : Type
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

    @property public override string name()
    {
        return elementType.toString() ~ "[]";
    }
}

unittest
{
    auto mod = new Module("bar");

    auto st = new StructureType(mod, "baz");
    st.close();

    auto ptr = new ArrayType(st);

    assert(ptr.name == "bar/baz[]");
}
