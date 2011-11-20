module mci.assembler.disassembly.modules;

import std.conv,
       std.stdio,
       std.string,
       mci.core.container,
       mci.core.io,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types;

public final class ModuleDisassembler
{
    private FileStream _file;
    private BinaryWriter _writer;
    private bool _done;

    invariant()
    {
        assert(_file);
        assert(_file.canWrite);
        assert(!_file.isClosed);
        assert(_writer);
    }

    public this(FileStream file)
    in
    {
        assert(file);
        assert(file.canWrite);
        assert(!file.isClosed);
    }
    body
    {
        _file = file;
        _writer = new BinaryWriter(file);
    }

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
            writeType(type);

        foreach (func; module_.functions)
            writeFunction(func);
    }

    private void writeType(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        write("type ");

        final switch (type.layout)
        {
            case TypeLayout.automatic:
                write("automatic");
                break;
            case TypeLayout.sequential:
                write("sequential");
                break;
            case TypeLayout.explicit:
                write("explicit");
                break;
        }

        writefln(" %s", type.name);
        writeln("{");

        foreach (field; type.fields)
        {
            write("    field ");

            final switch (field.storage)
            {
                case FieldStorage.instance:
                    write("instance");
                    break;
                case FieldStorage.static_:
                    write("static");
                    break;
                case FieldStorage.constant:
                    write("const");
                    break;
            }

            writef(" %s %s", field.type, field.name);

            if (field.offset.hasValue)
                writef(" (%s)", field.offset.value);

            writeln(";");
        }

        writeln("}");
        writeln();
    }

    private void writeFunction(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        write("function ");

        if (function_.attributes & FunctionAttributes.pure_)
            write("pure ");

        if (function_.attributes & FunctionAttributes.noOptimization)
            write("nooptimize ");

        if (function_.attributes & FunctionAttributes.noInlining)
            write("noinline ");

        if (function_.attributes & FunctionAttributes.noCallInlining)
            write("nocallinline ");

        final switch (function_.callingConvention)
        {
            case CallingConvention.queueCall:
                write("qcall ");
                break;
            case CallingConvention.cdecl:
                write("ccall ");
                break;
            case CallingConvention.stdCall:
                write("scall ");
                break;
            case CallingConvention.thisCall:
                write("tcall ");
                break;
            case CallingConvention.fastCall:
                write("fcall ");
                break;
        }

        writef("%s %s(", function_.returnType, function_.name);

        foreach (i, param; function_.parameters)
        {
            write(param.type);

            if (i < function_.parameters.count)
                write(", ");
        }

        writeln(")");
        writeln("{");

        foreach (reg; function_.registers)
            writef("    register %s %s;", reg.type, reg.name);

        writeln();

        foreach (block; function_.blocks)
        {
            writefln("    block %s", block.name);
            writeln("    {");

            foreach (instr; block.instructions)
            {
                write("        ");

                if (instr.targetRegister)
                    writef("%s = ", instr.targetRegister.name);

                write(instr.opCode.name);

                if (instr.sourceRegister1)
                    writef(" %s", instr.sourceRegister1.name);

                if (instr.sourceRegister2)
                    writef(", %s", instr.sourceRegister2.name);

                auto operand = instr.operand;

                if (operand.hasValue)
                {
                    write(" (");

                    switch (instr.opCode.operandType)
                    {
                        case OperandType.bytes:
                            auto bytes = operand.get!(Countable!ubyte)();

                            foreach (i, b; bytes)
                            {
                                write(b);

                                if (i < bytes.count)
                                    write(", ");
                            }

                            break;
                        case OperandType.selector:
                            auto regs = operand.get!(Countable!Register)();

                            foreach (i, reg; regs)
                            {
                                write(reg.name);

                                if (i < regs.count)
                                    write(", ");
                            }

                            break;
                        default:
                            write(operand);
                    }

                    write(")");
                }

                writeln(";");
            }

            writeln("    }");
            writeln();
        }

        writeln("}");
        writeln();
    }

    private void write(T ...)(T args)
    {
        foreach (arg; args)
            _writer.writeArray(to!string(arg));
    }

    private void writeln(T ...)(T args)
    {
        write(args);
        write(newline);
    }

    private void writef(T ...)(T args)
    {
        write(format(args));
    }

    private void writefln(T ...)(T args)
    {
        writef(args);
        writeln();
    }
}
