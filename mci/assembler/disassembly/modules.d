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
            writeType(type.y);

        foreach (func; module_.functions)
            writeFunction(func.y);
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

            final switch (field.y.storage)
            {
                case FieldStorage.instance:
                    write("instance");
                    break;
                case FieldStorage.static_:
                    write("static");
                    break;
            }

            writef(" %s %s", field.y.type, field.y.name);

            if (field.y.offset.hasValue)
                writef(" (%s)", field.y.offset.value);

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

        writef("%s %s (", function_.returnType ? function_.returnType.toString() : "void", function_.name);

        foreach (i, param; function_.parameters)
        {
            write(param.type);

            if (i < function_.parameters.count - 1)
                write(", ");
        }

        writeln(")");
        writeln("{");

        foreach (reg; function_.registers)
            writefln("    register %s %s;", reg.y.type, reg.y.name);

        writeln();

        foreach (block; function_.blocks)
        {
            writefln("    block %s", block.y.name);
            writeln("    {");

            foreach (instr; block.y.instructions)
            {
                write("        ");

                if (instr.targetRegister)
                    writef("%s = ", instr.targetRegister.name);

                write(instr.opCode.name);

                if (instr.sourceRegister1)
                    writef(" %s", instr.sourceRegister1.name);

                if (instr.sourceRegister2)
                    writef(", %s", instr.sourceRegister2.name);

                if (instr.sourceRegister3)
                    writef(", %s", instr.sourceRegister3.name);

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

                                if (i < bytes.count - 1)
                                    write(", ");
                            }

                            break;
                        case OperandType.selector:
                            auto regs = operand.get!(Countable!Register)();

                            foreach (i, reg; regs)
                            {
                                write(reg.name);

                                if (i < regs.count - 1)
                                    write(", ");
                            }

                            break;
                        case OperandType.ffi:
                            auto ffi = operand.get!FFISignature();

                            string callConv;

                            final switch (ffi.callingConvention)
                            {
                                case CallingConvention.cdecl:
                                    callConv = "cdecl";
                                    break;
                                case CallingConvention.stdCall:
                                    callConv = "stdcall";
                                    break;
                            }

                            writefln("%s, %s, %s", ffi.library, ffi.entryPoint, callConv);

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
