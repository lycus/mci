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
        writef("type %s", type.name);

        if (type.alignment)
            writef(" (%s)", type.alignment);

        writeln();
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

            writefln(" %s %s;", field.y.type, field.y.name);
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

                    void writeArray(T)(InstructionOperand operand)
                    {
                        auto values = *operand.peek!(ReadOnlyIndexable!T)();

                        foreach (i, val; values)
                        {
                            write(val);

                            if (i < values.count - 1)
                                write(", ");
                        }
                    }

                    switch (instr.opCode.operandType)
                    {
                        case OperandType.int8Array:
                            writeArray!byte(operand);
                        case OperandType.uint8Array:
                            writeArray!ubyte(operand);
                        case OperandType.int16Array:
                            writeArray!short(operand);
                        case OperandType.uint16Array:
                            writeArray!ushort(operand);
                        case OperandType.int32Array:
                            writeArray!int(operand);
                        case OperandType.uint32Array:
                            writeArray!uint(operand);
                        case OperandType.int64Array:
                            writeArray!long(operand);
                        case OperandType.uint64Array:
                            writeArray!ulong(operand);
                        case OperandType.float32Array:
                            writeArray!float(operand);
                        case OperandType.float64Array:
                            writeArray!double(operand);
                        case OperandType.selector:
                            writeArray!Register(operand);
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
