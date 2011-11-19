module mci.assembler.io.writer;

import mci.core.common,
       mci.core.container,
       mci.core.io,
       mci.core.program,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.assembler.io.common;

public final class ProgramWriter
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
        _writer = new typeof(_writer)(file);
    }

    public void write(Program program)
    in
    {
        assert(program);
        assert(!_done);
    }
    body
    {
        _done = true;

        writeProgram(program);
    }

    private void writeProgram(Program program)
    in
    {
        assert(program);
    }
    body
    {
        _writer.writeArray(fileMagic);
        _writer.write(fileVersion);
        _writer.write(cast(uint)program.modules.count);

        foreach (mod; program.modules)
            writeModule(mod);

        foreach (mod; program.modules)
        {
            _writer.write(cast(uint)mod.types.count);

            foreach (type; mod.types)
                writeType(type);
        }

        foreach (mod; program.modules)
        {
            _writer.write(cast(uint)mod.functions.count);

            foreach (func; mod.functions)
                writeFunction(func);
        }

        foreach (mod; program.modules)
        {
            foreach (func; mod.functions)
            {
                foreach (block; func.blocks)
                {
                    _writer.write(cast(uint)block.instructions.count);

                    foreach (instr; block.instructions)
                        writeInstruction(instr);
                }
            }
        }
    }

    private void writeModule(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        _writer.write(cast(uint)module_.name.length);
        _writer.writeArray(module_.name);
    }

    private void writeType(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.write(cast(uint)type.name.length);
        _writer.writeArray(type.name);
        _writer.write(type.layout);

        _writer.write(cast(uint)type.fields.count);

        foreach (field; type.fields)
            writeField(field);
    }

    private void writeField(Field field)
    in
    {
        assert(field);
    }
    body
    {
        _writer.write(cast(uint)field.name.length);
        _writer.writeArray(field.name);
        _writer.write(field.attributes);
        _writer.write(field.offset.hasValue);

        if (field.offset.hasValue)
            _writer.write(field.offset.value);

        writeTypeReference(field.type);
    }

    private void writeFunction(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.write(cast(uint)function_.name.length);
        _writer.writeArray(function_.name);
        _writer.write(function_.attributes);
        _writer.write(function_.callingConvention);
        writeTypeReference(function_.returnType);
        _writer.write(cast(uint)function_.parameters.count);

        foreach (param; function_.parameters)
            writeTypeReference(param.type);

        _writer.write(cast(uint)function_.registers.count);

        foreach (register; function_.registers)
            writeRegister(register);

        _writer.write(cast(uint)function_.blocks.count);

        foreach (block; function_.blocks)
            writeBasicBlock(block);
    }

    private void writeRegister(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _writer.write(cast(uint)register.name.length);
        _writer.writeArray(register.name);
        writeTypeReference(register.type);
    }

    private void writeBasicBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _writer.write(cast(uint)block.name.length);
        _writer.writeArray(block.name);
    }

    private void writeInstruction(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
        _writer.write(instruction.opCode.code);

        if (instruction.targetRegister)
            writeRegisterReference(instruction.targetRegister);

        if (instruction.sourceRegister1)
            writeRegisterReference(instruction.sourceRegister1);

        if (instruction.sourceRegister2)
            writeRegisterReference(instruction.sourceRegister2);

        auto operand = instruction.operand;

        if (operand.hasValue)
        {
            if (auto val = operand.peek!byte())
                _writer.write(*val);
            else if (auto val = operand.peek!ubyte())
                _writer.write(*val);
            else if (auto val = operand.peek!short())
                _writer.write(*val);
            else if (auto val = operand.peek!ushort())
                _writer.write(*val);
            else if (auto val = operand.peek!int())
                _writer.write(*val);
            else if (auto val = operand.peek!uint())
                _writer.write(*val);
            else if (auto val = operand.peek!long())
                _writer.write(*val);
            else if (auto val = operand.peek!ulong())
                _writer.write(*val);
            else if (auto val = operand.peek!float())
                _writer.write(*val);
            else if (auto val = operand.peek!double())
                _writer.write(*val);
            else if (auto val = operand.peek!(Countable!ubyte)())
            {
                _writer.write(cast(uint)val.count);

                foreach (b; *val)
                    _writer.write(b);
            }
            else if (auto val = operand.peek!BasicBlock())
                writeBasicBlockReference(*val);
            else if (auto val = operand.peek!Type())
                writeTypeReference(*val);
            else if (auto val = operand.peek!StructureType())
                writeStructureTypeReference(*val);
            else if (auto val = operand.peek!Field())
                writeFieldReference(*val);
            else if (auto val = operand.peek!Function())
                writeFunctionReference(*val);
            else if (auto val = operand.peek!FunctionPointerType())
                writeFunctionPointerTypeReference(*val);
            else if (auto val = operand.peek!(Countable!Register)())
            {
                _writer.write(cast(uint)val.count);

                foreach (reg; *val)
                    writeRegisterReference(reg);
            }
        }
    }

    private void writeRegisterReference(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _writer.write(cast(uint)register.name.length);
        _writer.writeArray(register.name);
    }

    private void writeBasicBlockReference(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _writer.write(cast(uint)block.name.length);
        _writer.writeArray(block.name);
    }

    private void writeModuleReference(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        _writer.write(cast(uint)module_.name.length);
        _writer.writeArray(module_.name);
    }

    private void writeStructureTypeReference(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.write(TypeReferenceType.structure);
        writeModuleReference(type.module_);
        _writer.write(cast(uint)type.name.length);
        _writer.writeArray(type.name);
    }

    private void writeFunctionPointerTypeReference(FunctionPointerType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.write(TypeReferenceType.function_);
        writeTypeReference(type.returnType);
        _writer.write(cast(uint)type.parameterTypes.count);

        foreach (param; type.parameterTypes)
            writeTypeReference(param);
    }

    private void writeTypeReference(Type type)
    in
    {
        assert(type);
    }
    body
    {
        if (auto structType = cast(StructureType)type)
            writeStructureTypeReference(structType);
        else if (auto fpType = cast(FunctionPointerType)type)
            writeFunctionPointerTypeReference(fpType);
        else if (auto ptrType = cast(PointerType)type)
        {
            _writer.write(TypeReferenceType.pointer);
            writeTypeReference(ptrType.elementType);
        }
        else
        {
            _writer.write(TypeReferenceType.core);

            if (isType!UnitType(type))
                _writer.write(CoreTypeIdentifier.unit);
            else if (isType!Int8Type(type))
                _writer.write(CoreTypeIdentifier.int8);
            else if (isType!UInt8Type(type))
                _writer.write(CoreTypeIdentifier.uint8);
            else if (isType!Int16Type(type))
                _writer.write(CoreTypeIdentifier.int16);
            else if (isType!UInt16Type(type))
                _writer.write(CoreTypeIdentifier.uint16);
            else if (isType!Int32Type(type))
                _writer.write(CoreTypeIdentifier.int32);
            else if (isType!UInt32Type(type))
                _writer.write(CoreTypeIdentifier.uint32);
            else if (isType!Int64Type(type))
                _writer.write(CoreTypeIdentifier.int64);
            else if (isType!UInt64Type(type))
                _writer.write(CoreTypeIdentifier.uint64);
            else if (isType!NativeIntType(type))
                _writer.write(CoreTypeIdentifier.int_);
            else if (isType!NativeUIntType(type))
                _writer.write(CoreTypeIdentifier.uint_);
            else if (isType!Float32Type(type))
                _writer.write(CoreTypeIdentifier.float32);
            else
                _writer.write(CoreTypeIdentifier.float64);
        }
    }

    private void writeFieldReference(Field field)
    in
    {
        assert(field);
    }
    body
    {
        writeTypeReference(field.declaringType);
        _writer.write(cast(uint)field.name.length);
        _writer.writeArray(field.name);
    }

    private void writeFunctionReference(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        writeModuleReference(function_.module_);
        _writer.write(cast(uint)function_.name.length);
        _writer.writeArray(function_.name);
    }
}
