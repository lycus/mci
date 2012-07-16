module mci.vm.io.writer;

import mci.core.common,
       mci.core.container,
       mci.core.io,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.io.common,
       mci.vm.io.extended,
       mci.vm.io.table;

public final class ModuleWriter : ModuleSaver
{
    private FileStream _file;
    private VMBinaryWriter _writer;
    private bool _done;
    private StringTable _table;

    invariant()
    {
        assert(_table);
    }

    public this()
    {
        _table = new typeof(_table)();
    }

    public void save(Module module_, string path)
    in
    {
        assert(!_done);
    }
    body
    {
        _done = true;
        _file = new typeof(_file)(path, FileMode.truncate);
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

        auto stOffset = _writer.stream.position;

        _writer.write!ulong(0); // String table offset.
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
                _writer.write(cast(uint)block.y.stream.count);

                foreach (instr; block.y.stream)
                    writeInstruction(instr);
            }
        }

        _writer.write(!!module_.entryPoint);

        if (module_.entryPoint)
            writeFunctionReference(module_.entryPoint);

        _writer.write(!!module_.moduleEntryPoint);

        if (module_.moduleEntryPoint)
            writeFunctionReference(module_.moduleEntryPoint);

        _writer.write(!!module_.moduleExitPoint);

        if (module_.moduleExitPoint)
            writeFunctionReference(module_.moduleExitPoint);

        _writer.write(!!module_.threadEntryPoint);

        if (module_.threadEntryPoint)
            writeFunctionReference(module_.threadEntryPoint);

        _writer.write(!!module_.threadExitPoint);

        if (module_.threadExitPoint)
            writeFunctionReference(module_.threadExitPoint);

        writeMetadataSegment(module_);

        auto st = _writer.stream.position;

        writeStringTable();

        // Now go back and write the start of the string table.
        _writer.stream.position = stOffset;

        _writer.write(st);
    }

    private void writeMetadataSegment(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        auto countOffset = _writer.stream.position;

        _writer.write!ulong(0); // Metadata pair count.

        ulong count;

        foreach (type; filter(module_.types, (Tuple!(string, StructureType) tup) => !tup.y.metadata.empty))
        {
            count++;

            _writer.write(MetadataType.type);
            writeStructureTypeReference(type.y);
            writeMetadata(type.y.metadata);

            foreach (field; filter(type.y.fields, (Tuple!(string, Field) tup) => !tup.y.metadata.empty))
            {
                count++;

                _writer.write(MetadataType.field);
                writeFieldReference(field.y);
                writeMetadata(field.y.metadata);
            }
        }

        foreach (func; filter(module_.functions, (Tuple!(string, Function) tup) => !tup.y.metadata.empty))
        {
            count++;

            _writer.write(MetadataType.function_);
            writeFunctionReference(func.y);
            writeMetadata(func.y.metadata);

            foreach (param; filter(func.y.parameters, (Parameter p) => !p.metadata.empty))
            {
                count++;

                _writer.write(MetadataType.parameter);
                writeFunctionReference(func.y);
                writeParameterReference(param);
                writeMetadata(param.metadata);
            }

            foreach (reg; filter(func.y.registers, (Tuple!(string, Register) tup) => !tup.y.metadata.empty))
            {
                count++;

                _writer.write(MetadataType.register);
                writeFunctionReference(func.y);
                writeRegisterReference(reg.y);
                writeMetadata(reg.y.metadata);
            }

            foreach (block; filter(func.y.blocks, (Tuple!(string, BasicBlock) tup) => !tup.y.metadata.empty))
            {
                count++;

                _writer.write(MetadataType.block);
                writeFunctionReference(func.y);
                writeBasicBlockReference(block.y);
                writeMetadata(block.y.metadata);

                foreach (insn; filter(block.y.stream, (Instruction insn) => !insn.metadata.empty))
                {
                    count++;

                    _writer.write(MetadataType.instruction);
                    writeFunctionReference(func.y);
                    writeBasicBlockReference(block.y);
                    writeInstructionReference(insn);
                    writeMetadata(insn.metadata);
                }
            }
        }

        auto pos = _writer.stream.position;

        _writer.stream.position = countOffset;

        _writer.write(count);

        _writer.stream.position = pos;
    }

    private void writeMetadata(Countable!MetadataPair metadata)
    in
    {
        assert(metadata);
    }
    body
    {
        _writer.write(cast(uint)metadata.count);

        foreach (pair; metadata)
        {
            writeString(pair.key);
            writeString(pair.value);
        }
    }

    private void writeStringTable()
    {
        _writer.write(cast(uint)_table.table.count);

        foreach (kvp; _table.table)
        {
            _writer.write(kvp.x);
            _writer.writeString(kvp.y);
        }
    }

    private void writeType(StructureType type)
    in
    {
        assert(type);
    }
    body
    {
        writeString(type.name);
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
        writeString(field.name);
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
        writeString(function_.name);
        _writer.write(function_.attributes);
        _writer.write(!!function_.returnType);

        if (function_.returnType)
            writeTypeReference(function_.returnType);

        _writer.write(function_.callingConvention);
        _writer.write(cast(uint)function_.parameters.count);

        foreach (param; function_.parameters)
            writeTypeReference(param.type);

        _writer.write(cast(uint)function_.registers.count);

        foreach (register; function_.registers)
            writeRegister(register.y);

        _writer.write(cast(uint)function_.blocks.count);

        foreach (block; function_.blocks)
            writeBasicBlock(block.y);

        foreach (block; function_.blocks)
            writeBasicBlockUnwindSpecification(block.y);
    }

    private void writeRegister(Register register)
    in
    {
        assert(register);
    }
    body
    {
        writeString(register.name);
        writeTypeReference(register.type);
    }

    private void writeBasicBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        writeString(block.name);
    }

    private void writeBasicBlockUnwindSpecification(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        writeBasicBlockReference(block);
        _writer.write(cast(bool)block.unwindBlock);

        if (block.unwindBlock)
            writeBasicBlockReference(block.unwindBlock);
    }

    private void writeInstruction(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
        _writer.write(instruction.opCode.code);

        foreach (reg; instruction.registers)
            writeRegisterReference(reg);

        auto operand = instruction.operand;

        void writeArray(T)(ReadOnlyIndexable!T values)
        {
            _writer.write(cast(uint)values.count);

            foreach (b; values)
                _writer.write(b);
        }

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
            else if (auto val = operand.peek!(ReadOnlyIndexable!byte)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!ubyte)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!short)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!ushort)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!int)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!uint)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!long)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!ulong)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!float)())
                writeArray(*val);
            else if (auto val = operand.peek!(ReadOnlyIndexable!double)())
                writeArray(*val);
            else if (auto val = operand.peek!BasicBlock())
                writeBasicBlockReference(*val);
            else if (auto val = operand.peek!(Tuple!(BasicBlock, BasicBlock))())
            {
                writeBasicBlockReference(val.x);
                writeBasicBlockReference(val.y);
            }
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
        writeString(register.name);
    }

    private void writeBasicBlockReference(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        writeString(block.name);
    }

    private void writeModuleReference(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        writeString(module_.name);
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
        writeString(type.name);
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

        _writer.write(type.callingConvention);
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
        else if (auto refType = cast(ReferenceType)type)
        {
            _writer.write(TypeReferenceType.reference);
            writeTypeReference(refType.elementType);
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
            _writer.write(match(type,
                                (Int8Type t) => CoreTypeIdentifier.int8,
                                (UInt8Type t) => CoreTypeIdentifier.uint8,
                                (Int16Type t) => CoreTypeIdentifier.int16,
                                (UInt16Type t) => CoreTypeIdentifier.uint16,
                                (Int32Type t) => CoreTypeIdentifier.int32,
                                (UInt32Type t) => CoreTypeIdentifier.uint32,
                                (Int64Type t) => CoreTypeIdentifier.int64,
                                (UInt64Type t) => CoreTypeIdentifier.uint64,
                                (NativeIntType t) => CoreTypeIdentifier.int_,
                                (NativeUIntType t) => CoreTypeIdentifier.uint_,
                                (Float32Type t) => CoreTypeIdentifier.float32,
                                (Float64Type t) => CoreTypeIdentifier.float64));
        }
    }

    private void writeFieldReference(Field field)
    in
    {
        assert(field);
    }
    body
    {
        writeStructureTypeReference(field.declaringType);
        writeString(field.name);
    }

    private void writeFunctionReference(Function function_)
    in
    {
        assert(function_);
    }
    body
    {
        writeModuleReference(function_.module_);
        writeString(function_.name);
    }

    private void writeParameterReference(Parameter parameter)
    in
    {
        assert(parameter);
    }
    body
    {
        _writer.write(cast(uint)findIndex(parameter.function_.parameters, parameter));
    }

    private void writeInstructionReference(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
        _writer.write(cast(uint)findIndex(instruction.block.stream, instruction));
    }

    private void writeFFISignature(FFISignature signature)
    in
    {
        assert(signature);
    }
    body
    {
        writeString(signature.library);
        writeString(signature.entryPoint);
    }

    private void writeString(string value)
    in
    {
        assert(value);
    }
    body
    {
        _writer.write(_table.getID(value));
    }
}
