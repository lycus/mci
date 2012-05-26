module mci.vm.memory.prettyprint;

import std.ascii,
       std.conv,
       std.string,
       mci.core.common,
       mci.core.container,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.memory.base,
       mci.vm.memory.layout;

private final class PrettyPrinter
{
    private ulong _indent;
    private string _result;

    private string append(string s)
    in
    {
        assert(s);
    }
    body
    {
        return _result ~= s;
    }

    private string indent()
    {
        for (auto i = 0; i < _indent; i++)
            append("    ");

        return _result;
    }

    private string beginBlock()
    {
        newLine();
        append("{");
        _indent++;

        return _result;
    }

    private string endBlock()
    {
        _indent--;
        newLine();
        append("}");

        return _result;
    }

    private string newLine()
    {
        append(std.ascii.newline);
        indent();

        return _result;
    }

    private string appendLine(string s)
    in
    {
        assert(s);
    }
    body
    {
        append(s);
        newLine();

        return _result;
    }

    public string process(Type type, ubyte* mem, bool is32Bit, string instanceName)
    in
    {
        assert(type);
        assert(mem);
    }
    body
    {
        append(format("[%s] ", type.name));

        if (instanceName)
            append(instanceName ~ ": ");

        string arrayOrVector(Type type)
        in
        {
            assert(cast(ArrayType)type || cast(VectorType)type);
        }
        out (result)
        {
            assert(result);
        }
        body
        {
            auto vec = cast(VectorType)type;
            auto arr = cast(ArrayType)type;

            auto rto = *cast(RuntimeObject**)mem;

            if (!rto)
                return append(format("0x%x", cast(size_t)0));

            auto p = rto.data;

            auto elementCount = arr ? *cast(size_t*)p : vec.elements;
            auto elementType = arr ? arr.elementType : vec.elementType;
            auto elementSize = computeSize(elementType, is32Bit);

            if (arr)
                p += computeSize(NativeUIntType.instance, is32Bit);

            beginBlock();

            for (size_t i = 0; i < elementCount; i++)
            {
                newLine();
                process(elementType, p, is32Bit, to!string(i));

                p += elementSize;
            }

            return endBlock();
        }

        return match(type,
                     (Int8Type t) => append(format("%s", *cast(byte*)mem)),
                     (UInt8Type t) => append(format("%s", *cast(ubyte*)mem)),
                     (Int16Type t) => append(format("%s", *cast(short*)mem)),
                     (UInt16Type t) => append(format("%s", *cast(ushort*)mem)),
                     (Int32Type t) => append(format("%s", *cast(int*)mem)),
                     (UInt32Type t) => append(format("%s", *cast(uint*)mem)),
                     (Int64Type t) => append(format("%s", *cast(long*)mem)),
                     (UInt64Type t) => append(format("%s", *cast(ulong*)mem)),
                     (NativeIntType t) => append(format("%s", *cast(isize_t*)mem)),
                     (NativeUIntType t) => append(format("%s", *cast(size_t*)mem)),
                     (Float32Type t) => append(format("%s", *cast(float*)mem)),
                     (Float64Type t) => append(format("%s", *cast(double*)mem)),
                     (StructureType t)
                     {
                         beginBlock();

                         foreach (field; t.fields)
                         {
                             newLine();

                             auto offset = computeOffset(field.y, is32Bit);
                             process(field.y.type, mem + offset, is32Bit, field.x);
                         }

                         return endBlock();
                     },
                     (VectorType t) => arrayOrVector(t),
                     (ArrayType t) => arrayOrVector(t),
                     () => append(format("0x%x", *cast(size_t*)mem)));
    }
}

public string prettyPrint(Type type, bool is32Bit, ubyte* mem, string instanceName)
in
{
    assert(type);
    assert(mem);
}
out (result)
{
    assert(result);
}
body
{
    return (new PrettyPrinter()).process(type, mem, is32Bit, instanceName);
}
