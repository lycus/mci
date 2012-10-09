module mci.assembler.disassembly.modules;

import std.conv,
       mci.core.container,
       mci.core.io,
       mci.core.tuple,
       mci.core.code.data,
       mci.core.code.fields,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.typing.types,
       mci.core.utilities;

/**
 * Disassembles an in-memory IAL module into IAL source code. This
 * can be useful for round-tripping purposes.
 */
public final class ModuleDisassembler
{
    private Stream _stream;
    private TextWriter _writer;
    private bool _done;

    pure nothrow invariant()
    {
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
        assert(_writer);
    }

    /**
     * Constructs a new $(D ModuleDisassembler) instance.
     *
     * Params:
     *  stream = The stream to write to.
     */
    public this(Stream stream) pure nothrow
    in
    {
        assert(stream);
        assert((cast()stream).canWrite);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _stream = stream;
        _writer = new typeof(_writer)(stream);
    }

    /**
     * Disassembles the given module.
     *
     * Params:
     *  module_ = The module to disassemble.
     */
    public void disassemble(Module module_)
    in
    {
        assert(module_);
        assert(!_done);
    }
    body
    {
        _done = true;

        foreach (type; module_.types)
            writeType(type.y);

        foreach (field; module_.globalFields)
            writeGlobalField(field.y);

        foreach (field; module_.threadFields)
            writeThreadField(field.y);

        foreach (func; module_.functions)
            writeFunction(func.y);

        foreach (data; module_.dataBlocks)
            writeDataBlock(data.y);

        if (module_.entryPoint)
            writeEntryPoint(module_.entryPoint);

        if (module_.moduleEntryPoint)
            writeModuleEntryPoint(module_.moduleEntryPoint);

        if (module_.moduleExitPoint)
            writeModuleExitPoint(module_.moduleExitPoint);

        if (module_.threadEntryPoint)
            writeThreadEntryPoint(module_.threadEntryPoint);

        if (module_.threadExitPoint)
            writeThreadExitPoint(module_.threadExitPoint);
    }

    private void writeType(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.writef("type %s", escapeIdentifier(type.name));

        if (type.alignment)
            _writer.writef(" align %s", type.alignment);

        _writer.writeln();
        _writer.writeln("{");

        foreach (field; type.members)
            _writer.writefln("    field %s %s;", field.y.type, escapeIdentifier(field.y.name));

        _writer.writeln("}");
        _writer.writeln();
    }

    private void writeGlobalField(GlobalField field)
    in
    {
        assert(field);
    }
    body
    {
        _writer.writef("field global %s %s", field.type, escapeIdentifier(field.name));

        if (field.forwarder)
            _writer.write(" (%s, %s)", field.forwarder.library, field.forwarder.symbol);

        _writer.writeln(";");
        _writer.writeln();
    }

    private void writeThreadField(ThreadField field)
    in
    {
        assert(field);
    }
    body
    {
        _writer.writef("field thread %s %s", field.type, escapeIdentifier(field.name));

        if (field.forwarder)
            _writer.write(" (%s)", field.forwarder);

        _writer.writeln(";");
        _writer.writeln();
    }

    private void writeDataBlock(DataBlock data)
    in
    {
        assert(data);
    }
    body
    {
        string str;

        foreach (i, val; data.bytes)
        {
            str ~= to!string(val);

            if (i < data.bytes.count - 1)
                str ~= ", ";
        }

        _writer.writef("data %s (%s);", escapeIdentifier(data.name), str);
        _writer.writeln();
    }

    private void writeFunction(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.write("function ");

        if (function_.attributes & FunctionAttributes.ssa)
            _writer.write("ssa ");

        if (function_.attributes & FunctionAttributes.pure_)
            _writer.write("pure ");

        if (function_.attributes & FunctionAttributes.noOptimization)
            _writer.write("nooptimize ");

        if (function_.attributes & FunctionAttributes.noInlining)
            _writer.write("noinline ");

        if (function_.attributes & FunctionAttributes.noReturn)
            _writer.write("noreturn ");

        if (function_.attributes & FunctionAttributes.noThrow)
            _writer.write("nothrow ");

        _writer.writef("%s %s(", function_.returnType ? function_.returnType.toString() : "void", escapeIdentifier(function_.name));

        foreach (i, param; function_.parameters)
        {
            if (param.attributes & ParameterAttributes.noEscape)
                _writer.write("noescape ");

            _writer.write(param.type);

            if (i < function_.parameters.count - 1)
                _writer.write(", ");
        }

        _writer.write(")");

        final switch (function_.callingConvention)
        {
            case CallingConvention.standard:
                break;
            case CallingConvention.cdecl:
                _writer.write(" cdecl");
                break;
            case CallingConvention.stdCall:
                _writer.write(" stdcall");
                break;
        }

        _writer.writeln();
        _writer.writeln("{");

        foreach (reg; function_.registers)
            _writer.writefln("    register %s %s;", reg.y.type, reg.y);

        if (!function_.registers.empty)
            _writer.writeln();

        foreach (i, block; function_.blocks)
        {
            _writer.writef("    block %s", block.y);

            if (block.y.unwindBlock)
                _writer.writef(" unwind %s", block.y.unwindBlock);

            _writer.writeln();
            _writer.writeln("    {");

            foreach (instr; block.y.stream)
            {
                if (!instr.metadata.empty)
                {
                    _writer.write("[");

                    foreach (i, md; instr.metadata)
                    {
                        _writer.writef("'%s' : '%s'", md.key, md.value);

                        if (i != instr.metadata.count - 1)
                            _writer.writeln(",");
                    }

                    _writer.writeln("]");
                }

                _writer.write("        ");

                if (instr.attributes & InstructionAttributes.volatile_)
                    _writer.write("volatile ");

                _writer.writefln("%s;", instr);
            }

            _writer.writeln("    }");

            if (i != function_.blocks.count - 1)
                _writer.writeln();
        }

        _writer.writeln("}");
        _writer.writeln();
    }

    private void writeEntryPoint(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writefln("entry %s;", function_);
    }

    private void writeModuleEntryPoint(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writefln("module entry %s;", function_);
    }

    private void writeModuleExitPoint(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writefln("module exit %s;", function_);
    }

    private void writeThreadEntryPoint(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writefln("thread entry %s;", function_);
    }

    private void writeThreadExitPoint(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writefln("thread exit %s;", function_);
    }
}
