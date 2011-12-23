module mci.core.typing.types;

import std.conv,
       mci.core.common,
       mci.core.container,
       mci.core.nullable,
       mci.core.code.modules,
       mci.core.code.functions,
       mci.core.typing.members;

public abstract class Type
{
    @property public abstract string name();

    public override string toString()
    {
        return name;
    }
}

public final class StructureType : Type
{
    private Module _module;
    private string _name;
    private uint _alignment;
    private NoNullDictionary!(string, Field) _fields;
    private bool _isClosed;

    invariant()
    {
        assert(_module);
        assert(_name);
        assert(!_alignment || powerOfTwo(_alignment));
        assert(_fields);
    }

    public this(Module module_, string name, uint alignment = 0)
    in
    {
        assert(module_);
        assert(name);
        assert(!alignment || powerOfTwo(alignment));
        assert(!module_.types.get(name));
    }
    body
    {
        _module = module_;
        _name = name;
        _alignment = alignment;
        _fields = new typeof(_fields)();

        (cast(Dictionary!(string, StructureType))module_.types)[name] = this;
    }

    @property public uint alignment()
    {
        return _alignment;
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

    @property public Lookup!(string, Field) fields()
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

    public Field createField(string name, Type type, FieldStorage storage = FieldStorage.instance)
    in
    {
        assert(name);
        assert(type);
        assert(name !in _fields);
        assert(!_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _fields[name] = new Field(this, name, type, storage);
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
    private Nullable!CallingConvention _callingConvention;
    private Type _returnType;
    private NoNullList!Type _parameterTypes;

    invariant()
    {
        assert(_parameterTypes);
    }

    package this(Nullable!CallingConvention callingConvention, Type returnType, NoNullList!Type parameterTypes)
    in
    {
        assert(parameterTypes);
    }
    body
    {
        _callingConvention = callingConvention;
        _returnType = returnType;
        _parameterTypes = parameterTypes.duplicate();
    }

    @property public Nullable!CallingConvention callingConvention()
    {
        return _callingConvention;
    }

    @property public Type returnType()
    {
        return _returnType;
    }

    @property public ReadOnlyIndexable!Type parameterTypes()
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
        string s;

        if (_callingConvention.hasValue)
        {
            final switch (_callingConvention.value)
            {
                case CallingConvention.cdecl:
                    s ~= "cdecl ";
                    break;
                case CallingConvention.stdCall:
                    s ~= "stdcall ";
                    break;
            }
        }

        s ~= (_returnType ? _returnType.toString() : "void") ~ " (";

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

    auto fpt = new FunctionPointerType(Nullable!CallingConvention(), st1, params);

    assert(fpt.name == "foo/bar (foo/baz, foo/bar)");
}

unittest
{
    auto mod = new Module("foo");

    auto st1 = new StructureType(mod, "bar");
    st1.close();

    auto params = new NoNullList!Type();
    params.add(st1);

    auto fpt = new FunctionPointerType(nullable(CallingConvention.cdecl), st1, params);

    assert(fpt.name == "cdecl foo/bar (foo/bar)");
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
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "baz");
    st.close();

    auto ptr = new ArrayType(st);

    assert(ptr.name == "foo/baz[]");
}

public final class VectorType : Type
{
    private Type _elementType;
    private uint _elements;

    invariant()
    {
        assert(_elementType);
        assert(_elements);
    }

    package this(Type elementType, uint elements)
    in
    {
        assert(elementType);
        assert(elements);
    }
    body
    {
        _elementType = elementType;
        _elements = elements;
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

    @property public uint elements()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elements;
    }

    @property public override string name()
    {
        return elementType.toString() ~ "[" ~ to!string(_elements) ~ "]";
    }
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "baz");
    st.close();

    auto ptr = new VectorType(st, 3);

    assert(ptr.name == "foo/baz[3]");
}
