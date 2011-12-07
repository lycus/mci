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

    public void process(Type type, bool is32Bit, void* mem, string instanceName)
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
            return append(format("%s", is32Bit ? to!string(*cast(int*)mem) : to!string(*cast(long*)mem)));

        if (isType!NativeUIntType(type))
            return append(format("%s", is32Bit ? to!string(*cast(uint*)mem) : to!string(*cast(ulong*)mem)));

        if (auto struc = cast(StructureType)type)
        {
            newLine();
            append("{");
            _indent++;

            foreach (field; struc.fields)
            {
                newLine();

                auto offset = computeOffset(field.y, is32Bit);
                process(field.y.type, is32Bit, mem + offset, field.x);
            }

            _indent--;
            newLine();
            append("}");

            return;
        }

        if (isType!PointerType(type) || isType!ArrayType(type) || isType!FunctionPointerType(type))
            return append(format("0x%s", *cast(void**)mem));

        // TODO: Support vectors.
        assert(false, "Unsupported type: " ~ type.name);
    }
}

public string prettyPrint(Type type, bool is32Bit, void* mem, string instanceName)
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
    auto ctx = new PrettyPrinter();
    ctx.process(type, is32Bit, mem, instanceName);

    return ctx.result;
}
