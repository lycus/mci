module mci.vm.memory.layout;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

public uint computeSize(Type type, bool is32Bit)
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

    if (isType!PointerType(type) || isType!ArrayType(type) || isType!VectorType(type) || isType!FunctionPointerType(type))
        return is32Bit ? 4 : 8;

    auto structType = cast(StructureType)type;

    final switch (structType.layout)
    {
        case TypeLayout.explicit:
            uint size;

            foreach (f; structType.fields)
                if (f.y.storage == FieldStorage.instance && f.y.offset.value > size)
                    size = f.y.offset.value;

            return size;
        case TypeLayout.sequential:
            return aggregate(filter(structType.fields, (Tuple!(string, Field) f) { return f.y.storage == FieldStorage.instance; }),
                             (uint x, Tuple!(string, Field) f) { return x + computeSize(f.y.type, is32Bit); });
        case TypeLayout.automatic:
            uint size;

            foreach (field; structType.fields)
            {
                if (field.y.storage != FieldStorage.instance)
                    continue;

                auto al = computeAlignment(field.y.type, is32Bit);

                if (size % al)
                    size += al - size % al;

                size += computeSize(field.y.type, is32Bit);
            }

            return size;
    }
}

public uint computeOffset(Field field, bool is32Bit)
in
{
    assert(field);
}
body
{
    final switch (field.declaringType.layout)
    {
        case TypeLayout.explicit:
            return field.offset.value;
        case TypeLayout.sequential:
            uint ofs;

            foreach (f; field.declaringType.fields)
            {
                if (f.y.storage != FieldStorage.instance)
                    continue;

                if (f.y !is field)
                    break;

                ofs += computeSize(f.y.type, is32Bit);
            }

            return ofs;
        case TypeLayout.automatic:
            uint offset;

            foreach (fld; field.declaringType.fields)
            {
                if (fld.y.storage != FieldStorage.instance)
                    continue;

                if (fld.y is field)
                    break;

                auto al = computeAlignment(fld.y.type, is32Bit);

                if (offset % al)
                    offset += al - offset % al;

                offset += computeSize(fld.y.type, is32Bit);
            }

            return offset;
    }
}

private uint computeAlignment(Type type, bool is32Bit)
{
    if (auto struc = cast(StructureType)type)
    {
        final switch (struc.layout)
        {
            case TypeLayout.explicit:
                auto maxAlign = 0;

                foreach (fld; struc.fields)
                {
                    if (fld.y.storage != FieldStorage.instance)
                        continue;

                    if (fld.y.offset.value == 0)
                    {
                        auto al = computeAlignment(fld.y.type, is32Bit);

                        if (al > maxAlign)
                            al = maxAlign;
                    }
                }

                return maxAlign; 
            case TypeLayout.sequential:
                return 1;
            case TypeLayout.automatic:
                if (struc.fields.empty)
                    return 1;

                return computeAlignment(first(struc.fields).y.type, is32Bit);
        }
    }
    else
        return computeSize(type, is32Bit);
}
