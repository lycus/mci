module mci.vm.io.writer;

import mci.core.common,
       mci.core.container,
       mci.core.io,
       mci.core.visitor,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.io.common,
       mci.vm.io.extended;

public final class ModuleWriter : ModuleSaver
{
    private FileStream _file;
    private VMBinaryWriter _writer;
    private bool _done;

    public void save(Module module_, string path)
    in
    {
        assert(!_done);
    }
    body
    {
        _done = true;
        _file = new typeof(_file)(path, FileAccess.write, FileMode.truncate);
        _writer = new typeof(_writer)(_file);

        writeModule(module_);

        _file.close();
    }

    private void writeModule(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        _writer.writeArray(fileMagic);
        _writer.write(fileVersion);

        _writer.write(cast(uint)module_.types.count);

        foreach (type; module_.types)
            writeType(type.y);

        _writer.write(cast(uint)module_.functions.count);

        foreach (func; module_.functions)
            writeFunction(func.y);

        foreach (func; module_.functions)
        {
            foreach (block; func.y.blocks)
            {
                _writer.write(cast(uint)block.y.instructions.count);

                foreach (instr; block.y.instructions)
                    writeInstruction(instr);
            }
        }
    }

    private void writeType(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.writeString(type.name);
        _writer.write(type.alignment);

        _writer.write(cast(uint)type.fields.count);

        foreach (field; type.fields)
            writeField(field.y);
    }

    private void writeField(Field field)
    in
    {
        assert(field);
    }
    body
    {
        _writer.writeString(field.name);
        _writer.write(field.storage);
        writeTypeReference(field.type);
    }

    private void writeFunction(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        _writer.writeString(function_.name);
        _writer.write(function_.attributes);
        _writer.write(!!function_.returnType);

        if (function_.returnType)
            writeTypeReference(function_.returnType);

        _writer.write(cast(uint)function_.parameters.count);

        foreach (param; function_.parameters)
            writeTypeReference(param.type);

        _writer.write(cast(uint)function_.registers.count);

        foreach (register; function_.registers)
            writeRegister(register.y);

        _writer.write(cast(uint)function_.blocks.count);

        foreach (block; function_.blocks)
            writeBasicBlock(block.y);
    }

    private void writeRegister(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _writer.writeString(register.name);
        writeTypeReference(register.type);
    }

    private void writeBasicBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _writer.writeString(block.name);
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

        if (instruction.sourceRegister3)
            writeRegisterReference(instruction.sourceRegister3);

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
            else if (auto val = operand.peek!(ReadOnlyIndexable!ubyte)())
            {
                _writer.write(cast(uint)val.count);

                foreach (b; *val)
                    _writer.write(b);
            }
            else if (auto val = operand.peek!BasicBlock())
                writeBasicBlockReference(*val);
            else if (auto val = operand.peek!Type())
                writeTypeReference(*val);
            else if (auto val = operand.peek!Field())
                writeFieldReference(*val);
            else if (auto val = operand.peek!Function())
                writeFunctionReference(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!Register)())
            {
                _writer.write(cast(uint)val.count);

                foreach (reg; *val)
                    writeRegisterReference(reg);
            }
            else
                writeFFISignature(*operand.peek!FFISignature());
        }
    }

    private void writeRegisterReference(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _writer.writeString(register.name);
    }

    private void writeBasicBlockReference(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _writer.writeString(block.name);
    }

    private void writeModuleReference(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        _writer.writeString(module_.name);
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
        _writer.writeString(type.name);
    }

    private void writeFunctionPointerTypeReference(FunctionPointerType type)
    in
    {
        assert(type);
    }
    body
    {
        _writer.write(TypeReferenceType.function_);
        _writer.write(!!type.returnType);

        if (type.returnType)
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
        else if (auto arrType = cast(ArrayType)type)
        {
            _writer.write(TypeReferenceType.array);
            writeTypeReference(arrType.elementType);
        }
        else if (auto vecType = cast(VectorType)type)
        {
            _writer.write(TypeReferenceType.vector);
            writeTypeReference(vecType.elementType);
            _writer.write(vecType.elements);
        }
        else
        {
            _writer.write(TypeReferenceType.core);

            if (isType!Int8Type(type))
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
        _writer.writeString(field.name);
    }

    private void writeFunctionReference(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        writeModuleReference(function_.module_);
        _writer.writeString(function_.name);
    }

    private void writeFFISignature(FFISignature signature)
    in
    {
        assert(signature);
    }
    body
    {
        _writer.writeString(signature.library);
        _writer.writeString(signature.entryPoint);
        _writer.write(signature.callingConvention);
    }
}
