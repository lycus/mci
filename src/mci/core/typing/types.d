module mci.core.typing.types;

import std.conv,
       mci.core.container,
       mci.core.math,
       mci.core.nullable,
       mci.core.analysis.utilities,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.code.functions,
       mci.core.utilities;

public abstract class Type
{
    package this() pure nothrow
    {
    }

    @property public abstract string name();

    public override string toString()
    {
        return name;
    }
}

public final class StructureMember
{
    private StructureType _declaringType;
    private string _name;
    private Type _type;

    pure nothrow invariant()
    {
        assert(_declaringType);
        assert(_name);
        assert(_type);
    }

    private this(StructureType declaringType, string name, Type type)
    in
    {
        assert(declaringType);
        assert(name);
        assert(type);
    }
    body
    {
        _declaringType = declaringType;
        _name = name;
        _type = type;
    }

    @property public StructureType declaringType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _declaringType;
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

    public override string toString()
    {
        return _declaringType.toString() ~ ":" ~ escapeIdentifier(_name);
    }
}

public final class StructureType : Type
{
    private Module _module;
    private string _name;
    private uint _alignment;
    private NoNullDictionary!(string, StructureMember) _members;
    private bool _isClosed;
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_module);
        assert(_name);
        assert(!_alignment || powerOfTwo(_alignment));
        assert(_members);
        assert(_metadata);
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
        _members = new typeof(_members)();
        _metadata = new typeof(_metadata)();

        (cast(NoNullDictionary!(string, StructureType))module_.types)[name] = this;
    }

    @property public uint alignment() pure nothrow
    out (result)
    {
        assert(!result || powerOfTwo(result));
    }
    body
    {
        return _alignment;
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

    @property public Lookup!(string, StructureMember) members() pure nothrow
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
        return _members;
    }

    @property public bool isClosed() pure nothrow
    {
        return _isClosed;
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

    @property public override string name()
    {
        return _name;
    }

    public override string toString()
    {
        return _module.toString() ~ "/" ~ escapeIdentifier(_name);
    }

    public StructureMember createMember(string name, Type type)
    in
    {
        assert(name);
        assert(type);
        assert(name !in _members);

        if (auto struc = cast(StructureType)type)
            assert(!hasCycle(struc));

        assert(!_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _members[name] = new StructureMember(this, name, type);
    }

    public void close() pure nothrow
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _isClosed = true;
    }

    public bool hasCycle(StructureType memberType)
    in
    {
        assert(memberType);
    }
    body
    {
        if (memberType is this)
            return true;

        // Important that we iterate _fields and not fields.
        foreach (field; memberType._members)
            if (auto struc = cast(StructureType)field.y.type)
                if (hasCycle(struc))
                    return true;

        return false;
    }
}

public final class PointerType : Type
{
    private Type _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    package this(Type elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public Type elementType() pure nothrow
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

public final class ReferenceType : Type
{
    private StructureType _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    package this(StructureType elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public StructureType elementType() pure nothrow
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
        return elementType.toString() ~ "&";
    }
}

public final class FunctionPointerType : Type
{
    private CallingConvention _callingConvention;
    private Type _returnType;
    private NoNullList!Type _parameterTypes;

    pure nothrow invariant()
    {
        assert(_parameterTypes);
    }

    package this(CallingConvention callingConvention, Type returnType, NoNullList!Type parameterTypes)
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

    @property public CallingConvention callingConvention() pure nothrow
    {
        return _callingConvention;
    }

    @property public Type returnType() pure nothrow
    {
        return _returnType;
    }

    @property public ReadOnlyIndexable!Type parameterTypes() pure nothrow
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

        s ~= (_returnType ? _returnType.toString() : "void") ~ "(";

        foreach (i, param; _parameterTypes)
        {
            s ~= param.toString();

            if (i < _parameterTypes.count - 1)
                s ~= ", ";
        }

        s ~= ")";

        final switch (_callingConvention)
        {
            case CallingConvention.standard:
                break;
            case CallingConvention.cdecl:
                s ~= " cdecl";
                break;
            case CallingConvention.stdCall:
                s ~= " stdcall";
                break;
        }

        return s;
    }
}

public final class ArrayType : Type
{
    private Type _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    package this(Type elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public Type elementType() pure nothrow
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

public final class VectorType : Type
{
    private Type _elementType;
    private uint _elements;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    package this(Type elementType, uint elements) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
        _elements = elements;
    }

    @property public Type elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public uint elements() pure nothrow
    {
        return _elements;
    }

    @property public override string name()
    {
        return elementType.toString() ~ "[" ~ to!string(_elements) ~ "]";
    }
}

public final class StaticArrayType : Type
{
    private Type _elementType;
    private uint _elements;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    package this(Type elementType, uint elements) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
        _elements = elements;
    }

    @property public Type elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public uint elements() pure nothrow
    {
        return _elements;
    }

    @property public override string name()
    {
        return elementType.toString() ~ "{" ~ to!string(_elements) ~ "}";
    }
}

public bool hasAliasing(Type type)
in
{
    assert(type);
}
body
{
    return cast(PointerType)type ||
           cast(ReferenceType)type ||
           cast(ArrayType)type ||
           cast(VectorType)type ||
           cast(FunctionPointerType)type;
}
