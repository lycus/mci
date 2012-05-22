module mci.vm.memory.layout;

import mci.core.common,
       mci.core.container,
       mci.core.memory,
       mci.core.tuple,
       mci.core.analysis.utilities,
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
    if (tryCast!Int8Type(type) || tryCast!UInt8Type(type))
        return 1;

    if (tryCast!Int16Type(type) || tryCast!UInt16Type(type))
        return 2;

    if (tryCast!Int32Type(type) || tryCast!UInt32Type(type) || tryCast!Float32Type(type))
        return 4;

    if (tryCast!Int64Type(type) || tryCast!UInt64Type(type) || tryCast!Float64Type(type))
        return 8;

    if (tryCast!NativeIntType(type) || tryCast!NativeUIntType(type))
        return is32Bit ? 4 : 8;

    if (tryCast!PointerType(type) || tryCast!ReferenceType(type) ||
        tryCast!ArrayType(type) || tryCast!VectorType(type) ||
        tryCast!FunctionPointerType(type))
        return is32Bit ? 4 : 8;

    auto structType = cast(StructureType)type;

    size_t size;

    foreach (field; structType.fields)
    {
        if (field.y.storage != FieldStorage.instance)
            continue;

        auto al = structType.alignment ? structType.alignment : computeAlignment(field.y.type, is32Bit);

        size = alignTo(size, al);
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

        auto al = alignment ? alignment : computeAlignment(fld.y.type, is32Bit);

        offset = alignTo(offset, al);

        if (fld.y is field)
            break;

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

        return computeSize(NativeUIntType.instance, is32Bit);
    }

    return computeSize(type, is32Bit);
}

public BitArray computeBitmap(StructureType type, bool is32Bit)
in
{
    assert(type);
}
body
{
    auto bits = new BitArray();

    bits ~= false; // The runtime type info.
    bits ~= false; // The GC header.
    bits ~= true; // The user data field.

    auto wordSize = computeSize(NativeUIntType.instance, is32Bit);

    void innerCompute(StructureType type, size_t baseOffset)
    in
    {
        assert(type);
    }
    body
    {
        foreach (field; type.fields)
        {
            auto offset = baseOffset + computeOffset(field.y, is32Bit);

            if (auto structType = tryCast!StructureType(field.y.type))
                innerCompute(structType, offset);
            else if (!(offset % wordSize))
                bits ~= isManaged(field.y.type);
        }
    }

    innerCompute(type, 0);

    return bits;
}
