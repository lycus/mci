module mci.vm.memory.layout;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

public size_t computeSize(Type type, bool is32Bit)
in
{
    assert(type);
}
body
{
    if (isType!Int8Type(type) || isType!UInt8Type(type))
        return 1;

    if (isType!Int16Type(type) || isType!UInt16Type(type))
        return 2;

    if (isType!Int32Type(type) || isType!UInt32Type(type) || isType!Float32Type(type))
        return 4;

    if (isType!Int64Type(type) || isType!UInt64Type(type) || isType!Float64Type(type))
        return 8;

    if (isType!NativeIntType(type) || isType!NativeUIntType(type))
        return is32Bit ? 4 : 8;

    if (isType!PointerType(type) || isType!ReferenceType(type) ||
        isType!ArrayType(type) || isType!VectorType(type) ||
        isType!FunctionPointerType(type))
        return is32Bit ? 4 : 8;

    auto structType = cast(StructureType)type;

    size_t size;

    foreach (field; structType.fields)
    {
        if (field.y.storage != FieldStorage.instance)
            continue;

        auto al = structType.alignment ? structType.alignment : computeAlignment(field.y.type, is32Bit);

        if (size % al)
            size += al - size % al;

        size += computeSize(field.y.type, is32Bit);
    }

    return size;
}

public size_t computeOffset(Field field, bool is32Bit)
in
{
    assert(field);
    assert(field.storage == FieldStorage.instance);
}
body
{
    auto alignment = field.declaringType.alignment;
    size_t offset;

    foreach (fld; field.declaringType.fields)
    {
        if (fld.y.storage != FieldStorage.instance)
            continue;

        if (fld.y is field)
            break;

        auto al = alignment ? alignment : computeAlignment(fld.y.type, is32Bit);

        if (offset % al)
            offset += al - offset % al;

        offset += computeSize(fld.y.type, is32Bit);
    }

    return offset;
}

public size_t computeAlignment(Type type, bool is32Bit)
{
    if (auto struc = cast(StructureType)type)
    {
        if (struc.alignment)
            return struc.alignment;

        if (struc.fields.empty)
            return 1;

        return computeAlignment(first(struc.fields).y.type, is32Bit);
    }

    return computeSize(type, is32Bit);
}
