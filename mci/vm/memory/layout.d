module mci.vm.memory.layout;

import mci.core.common,
       mci.core.container,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types;

public uint computeSize(Type type, bool is64Bit)
in
{
    assert(type);
}
body
{
    if (isType!UnitType(type))
        return 0;

    if (isType!Int8Type(type) || isType!UInt8Type(type))
        return 1;

    if (isType!Int16Type(type) || isType!UInt16Type(type))
        return 2;

    if (isType!Int32Type(type) || isType!UInt32Type(type) || isType!Float32Type(type))
        return 4;

    if (isType!Int64Type(type) || isType!UInt64Type(type) || isType!Float64Type(type))
        return 8;

    if (isType!NativeIntType(type) || isType!NativeUIntType(type))
        return is64Bit ? 8 : 4;

    if (isType!PointerType(type) || isType!ArrayType(type) || isType!FunctionPointerType(type))
        return is64Bit ? 8 : 4;

    auto structType = cast(StructureType)type;

    final switch (structType.layout)
    {
        case TypeLayout.explicit:
            uint size;

            foreach (f; structType.fields)
                if (f.offset.value > size)
                    size = f.offset.value;

            return size;
        case TypeLayout.sequential:
            return aggregate(structType.fields, (uint x, Field f) { return x + computeSize(f.type, is64Bit); });
        case TypeLayout.automatic:
            uint size;

            foreach (field; structType.fields)
            {
                auto al = computeAlignment(field.type, is64Bit);

                if (size % al)
                    size += al - size % al;

                size += computeSize(field.type, is64Bit);
            }

            return size;
    }
}

public uint computeOffset(Field field, bool is64Bit)
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
                if (f !is field)
                    break;

                ofs += computeSize(f.type, is64Bit);
            }

            return ofs;
        case TypeLayout.automatic:
            uint offset;

            foreach (fld; field.declaringType.fields)
            {
                if (fld is field)
                    break;

                auto al = computeAlignment(fld.type, is64Bit);

                if (offset % al)
                    offset += al - offset % al;

                offset += computeSize(fld.type, is64Bit);
            }

            return offset;
    }
}

private uint computeAlignment(Type type, bool is64Bit)
{
    if (auto struc = cast(StructureType)type)
    {
        final switch (struc.layout)
        {
            case TypeLayout.explicit:
                auto maxAlign = 0;

                foreach (fld; struc.fields)
                {
                    if (fld.offset.value == 0)
                    {
                        auto al = computeAlignment(fld.type, is64Bit);

                        if (al > maxAlign)
                            al = maxAlign;
                    }
                }

                return maxAlign; 
            case TypeLayout.sequential:
                return 1;
            case TypeLayout.automatic:
                // TODO: Write a first() function for iterables.
                foreach (field; struc.fields)
                    return computeAlignment(field.type, is64Bit);

                assert(false);
        }
    } 
    else
        return computeSize(type, is64Bit);
}
