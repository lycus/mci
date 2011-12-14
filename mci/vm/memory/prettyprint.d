module mci.vm.memory.prettyprint;

import std.ascii,
       std.conv,
       std.string,
       mci.core.common,
       mci.core.container,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.memory.layout;

private class PrettyPrinter
{
    private ulong _indent;
    private string _result;
    private bool _is32Bit;

    public this(bool is32Bit)
    {
        _is32Bit = is32Bit;
    }

    @property public string result()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _result;
    }

    private void append(string s)
    in
    {
        assert(s);
    }
    body
    {
        _result = _result ~ s;
    }

    private void indent()
    {
        for (auto i = 0; i < _indent; i++)
            append("    ");
    }

    private void beginBlock()
    {
        newLine();
        append("{");
        _indent++;
    }

    private void endBlock()
    {
        _indent--;
        newLine();
        append("}");
    }

    private void newLine()
    {
        append(std.ascii.newline);
        indent();
    }

    private void appendLine(string s)
    in
    {
        assert(s);
    }
    body
    {
        append(s);
        newLine();
    }

    public void process(Type type, ubyte* mem, string instanceName)
    in
    {
        assert(type);
        assert(mem);
    }
    body
    {
        append(format("[%s] ", type.name));

        if (instanceName.length)
            append(instanceName ~ ": ");

        if (isType!Int8Type(type))
            return append(format("%s", *cast(byte*)mem));

        if (isType!UInt8Type(type))
            return append(format("%s", *cast(ubyte*)mem));

        if (isType!Int16Type(type))
            return append(format("%s", *cast(short*)mem));

        if (isType!UInt16Type(type))
            return append(format("%s", *cast(ushort*)mem));

        if (isType!Int32Type(type))
            return append(format("%s", *cast(int*)mem));

        if (isType!UInt32Type(type))
            return append(format("%s", *cast(uint*)mem));

        if (isType!Int64Type(type))
            return append(format("%s", *cast(long*)mem));

        if (isType!UInt64Type(type))
            return append(format("%s", *cast(ulong*)mem));

        if (isType!Float32Type(type))
            return append(format("%s", *cast(float*)mem));

        if (isType!Float64Type(type))
            return append(format("%s", *cast(double*)mem));

        if (isType!NativeIntType(type))
            return append(format("%s", *cast(isize_t*)mem));

        if (isType!NativeUIntType(type))
            return append(format("%s", *cast(size_t*)mem));

        if (auto struc = cast(StructureType)type)
        {
            beginBlock();

            foreach (field; struc.fields)
            {
                newLine();

                auto offset = computeOffset(field.y, _is32Bit);
                process(field.y.type, mem + offset, field.x);
            }

            endBlock();

            return;
        }

        if (auto vect = cast(VectorType)type)
        {
            auto elementSize = computeSize(vect.elementType, _is32Bit);
            auto p = *cast(ubyte**)mem;

            beginBlock();

            for (auto i = 0; i < vect.elements; i++)
            {
                newLine();
                process(vect.elementType, p, to!string(i));

                p += elementSize;
            }

            endBlock();
        }

        // FIXME: FunctionPointerType does not imply a low-level function pointer at the memory location.
        if (isType!PointerType(type) || isType!ArrayType(type) || isType!FunctionPointerType(type))
            return append(format("0x%s", *cast(void**)mem));
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
    auto ctx = new PrettyPrinter(is32Bit);
    ctx.process(type, mem, instanceName);

    return ctx.result;
}
