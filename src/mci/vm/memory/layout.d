module mci.vm.memory.layout;

import mci.core.common,
       mci.core.container,
       mci.core.memory,
       mci.core.tuple,
       mci.core.analysis.utilities,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

public size_t computeSize(Type type, bool is32Bit, size_t simdAlignment)
in
{
    assert(type);
}
body
{
    if (type is Int8Type.instance || type is UInt8Type.instance)
        return 1;

    if (type is Int16Type.instance || type is UInt16Type.instance)
        return 2;

    if (type is Int32Type.instance || type is UInt32Type.instance || type is Float32Type.instance)
        return 4;

    if (type is Int64Type.instance || type is UInt64Type.instance || type is Float64Type.instance)
        return 8;

    if (type is NativeIntType.instance || type is NativeUIntType.instance)
        return is32Bit ? 4 : 8;

    if (cast(PointerType)type || cast(ReferenceType)type ||
        cast(ArrayType)type || cast(VectorType)type ||
        cast(FunctionPointerType)type)
        return is32Bit ? 4 : 8;

    if (auto sa = cast(StaticArrayType)type)
        return computeSize(sa.elementType, is32Bit, simdAlignment) * sa.elements;

    auto structType = cast(StructureType)type;

    size_t size;

    foreach (field; structType.fields)
    {
        if (field.y.storage != FieldStorage.instance)
            continue;

        auto al = structType.alignment ? structType.alignment : computeAlignment(field.y.type, is32Bit, simdAlignment);

        size = alignTo(size, al);
        size += computeSize(field.y.type, is32Bit, simdAlignment);
    }

    return size;
}

public size_t computeOffset(Field field, bool is32Bit, size_t simdAlignment)
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

        auto al = alignment ? alignment : computeAlignment(fld.y.type, is32Bit, simdAlignment);

        offset = alignTo(offset, al);

        if (fld.y is field)
            break;

        offset += computeSize(fld.y.type, is32Bit, simdAlignment);
    }

    return offset;
}

public size_t computeAlignment(Type type, bool is32Bit, size_t simdAlignment)
{
    if (auto struc = cast(StructureType)type)
    {
        if (struc.alignment)
            return struc.alignment;

        if (struc.fields.empty)
            return 1;

        return computeSize(NativeUIntType.instance, is32Bit, simdAlignment);
    }

    if (auto sa = cast(StaticArrayType)type)
    {
        if (!sa.elements)
            return 1;

        return simdAlignment;
    }

    return computeSize(type, is32Bit, simdAlignment);
}

public BitArray computeBitmap(StructureType type, bool is32Bit, size_t simdAlignment)
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

    auto wordSize = computeSize(NativeUIntType.instance, is32Bit, simdAlignment);

    void innerCompute(StructureType type, size_t baseOffset)
    in
    {
        assert(type);
    }
    body
    {
        foreach (field; type.fields)
        {
            auto offset = baseOffset + computeOffset(field.y, is32Bit, simdAlignment);

            if (auto structType = cast(StructureType)field.y.type)
                innerCompute(structType, offset);
            else if (isAligned(offset))
                bits ~= isManaged(field.y.type);
        }
    }

    innerCompute(type, 0);

    return bits;
}
