module mci.vm.io.reader;

import std.string,
       mci.core.common,
       mci.core.container,
       mci.core.io,
       mci.core.nullable,
       mci.core.program,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.io.common,
       mci.vm.io.exception,
       mci.vm.io.extended;

private final class TypeDescriptor
{
    private string _name;
    private TypeLayout _layout;
    private NoNullList!FieldDescriptor _fields;

    invariant()
    {
        assert(_name);
        assert(_fields);
    }

    public this(string name, TypeLayout layout)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _layout = layout;
        _fields = new typeof(_fields)();
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public TypeLayout layout()
    {
        return _layout;
    }

    @property public NoNullList!FieldDescriptor fields()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _fields;
    }
}

private final class FieldDescriptor
{
    private string _name;
    private FieldStorage _storage;
    private Nullable!uint _offset;
    private TypeReferenceDescriptor _type;

    invariant()
    {
        assert(_name);
        assert(_type);
    }

    public this(string name, FieldStorage storage, Nullable!uint offset, TypeReferenceDescriptor type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _storage = storage;
        _offset = offset;
        _type = type;
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public FieldStorage storage()
    {
        return _storage;
    }

    @property public Nullable!uint offset()
    {
        return _offset;
    }

    @property public TypeReferenceDescriptor type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }
}

private abstract class TypeReferenceDescriptor
{
}

private final class StructureTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private string _name;
    private string _moduleName;

    invariant()
    {
        assert(_name);
        assert(_moduleName);
    }

    public this(string name, string moduleName)
    in
    {
        assert(name);
        assert(moduleName);
    }
    body
    {
        _name = name;
        _moduleName = moduleName;
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public string moduleName()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _moduleName;
    }
}

private final class CoreTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private CoreType _type;

    invariant()
    {
        assert(_type);
    }

    public this(CoreType type)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
    }

    @property public CoreType type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }
}

private final class PointerTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private TypeReferenceDescriptor _elementType;

    invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public TypeReferenceDescriptor elementType()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }
}

private final class ArrayTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private TypeReferenceDescriptor _elementType;

    invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType)
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public TypeReferenceDescriptor elementType()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }
}

private final class FunctionPointerTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private TypeReferenceDescriptor _returnType;
    private NoNullList!TypeReferenceDescriptor _parameterTypes;

    invariant()
    {
        assert(_returnType);
        assert(_parameterTypes);
    }

    public this(TypeReferenceDescriptor returnType)
    in
    {
        assert(returnType);
    }
    body
    {
        _returnType = returnType;
        _parameterTypes = new typeof(_parameterTypes)();
    }

    @property public TypeReferenceDescriptor returnType()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _returnType;
    }

    @property public NoNullList!TypeReferenceDescriptor parameterTypes()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _parameterTypes;
    }
}

public final class ProgramReader
{
    private FileStream _file;
    private VMBinaryReader _reader;
    private bool _done;
    private NoNullDictionary!(StructureType, TypeDescriptor) _types;

    invariant()
    {
        assert(_file);
        assert(_file.canRead);
        assert(!_file.isClosed);
        assert(_reader);
        assert(_types);
    }

    public this(FileStream file)
    in
    {
        assert(file);
        assert(file.canRead);
        assert(!file.isClosed);
    }
    body
    {
        _file = file;
        _reader = new typeof(_reader)(file);
        _types = new typeof(_types)();
    }

    public Program read()
    in
    {
        assert(!_done);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        _done = true;

        return readProgram();
    }

    private Program readProgram()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto magic = _reader.readArray!string(fileMagic.length);

        if (magic != fileMagic)
            error("File magic %s doesn't match expected %s.", magic, fileMagic);

        auto ver = _reader.read!uint();
        auto modCount = _reader.read!uint();
        auto program = new Program();

        for (uint i = 0; i < modCount; i++)
            readModule(program);

        foreach (mod; program.modules)
        {
            auto typeCount = _reader.read!uint();

            for (uint i = 0; i < typeCount; i++)
            {
                auto type = readType();
                auto structType = new StructureType(mod.y, type.name, type.layout);

                _types[structType] = type;
            }
        }

        closeTypes(program);

        foreach (mod; program.modules)
        {
            auto funcCount = _reader.read!uint();

            for (uint i = 0; i < funcCount; i++)
                readFunction(mod.y, program);
        }

        foreach (mod; program.modules)
        {
            foreach (func; mod.y.functions)
            {
                foreach (block; func.y.blocks)
                {
                    auto instrCount = _reader.read!uint();

                    for (uint i = 0; i < instrCount; i++)
                        block.y.instructions.add(readInstruction(func.y, program));
                }
            }
        }

        return program;
    }

    private Module readModule(Program program)
    in
    {
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return new Module(program, _reader.readString());
    }

    private void closeTypes(Program program)
    in
    {
        assert(program);
    }
    body
    {
        foreach (tup; _types)
        {
            foreach (field; tup.y.fields)
                tup.x.createField(field.name, toType(field.type, program), field.storage, field.offset);

            tup.x.close();
        }
    }

    private static Type toType(TypeReferenceDescriptor descriptor, Program program)
    in
    {
        assert(descriptor);
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto structType = cast(StructureTypeReferenceDescriptor)descriptor)
        {
            if (auto type = toModule(structType.moduleName, program).types.get(structType.name))
                return *type;

            error("Unknown type: %s/%s", structType.moduleName, structType.name);
            assert(false);
        }
        else if (auto ptrType = cast(PointerTypeReferenceDescriptor)descriptor)
            return getPointerType(toType(ptrType.elementType, program));
        else if (auto arrType = cast(ArrayTypeReferenceDescriptor)descriptor)
            return getArrayType(toType(arrType.elementType, program));
        else if (auto fpType = cast(FunctionPointerTypeReferenceDescriptor)descriptor)
        {
            auto params = new NoNullList!Type(map(fpType.parameterTypes, (TypeReferenceDescriptor desc) { return toType(desc, program); }));
            return getFunctionPointerType(toType(fpType.returnType, program), params);
        }
        else
            return (cast(CoreTypeReferenceDescriptor)descriptor).type;
    }

    private static Module toModule(string name, Program program)
    in
    {
        assert(name);
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto mod = program.modules.get(name))
            return *mod;

        error("Unknown module: %s", name);
        assert(false);
    }

    private TypeDescriptor readType()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();
        auto layout = _reader.read!TypeLayout();
        auto type = new TypeDescriptor(name, layout);
        auto fieldCount = _reader.read!uint();

        for (uint i = 0; i < fieldCount; i++)
            type.fields.add(readField());

        return type;
    }

    private FieldDescriptor readField()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();
        auto attributes = _reader.read!FieldStorage();
        auto offset = _reader.read!bool() ? Nullable!uint(_reader.read!uint()) : Nullable!uint();
        auto type = readTypeReference();

        return new FieldDescriptor(name, attributes, offset, type);
    }

    private TypeReferenceDescriptor readTypeReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto t = _reader.read!TypeReferenceType();

        switch (t)
        {
            case TypeReferenceType.core:
                auto id = _reader.read!CoreTypeIdentifier();

                switch (id)
                {
                    case CoreTypeIdentifier.unit:
                        return new CoreTypeReferenceDescriptor(UnitType.instance);
                    case CoreTypeIdentifier.int8:
                        return new CoreTypeReferenceDescriptor(Int8Type.instance);
                    case CoreTypeIdentifier.uint8:
                        return new CoreTypeReferenceDescriptor(UInt8Type.instance);
                    case CoreTypeIdentifier.int16:
                        return new CoreTypeReferenceDescriptor(Int16Type.instance);
                    case CoreTypeIdentifier.uint16:
                        return new CoreTypeReferenceDescriptor(UInt16Type.instance);
                    case CoreTypeIdentifier.int32:
                        return new CoreTypeReferenceDescriptor(Int32Type.instance);
                    case CoreTypeIdentifier.uint32:
                        return new CoreTypeReferenceDescriptor(UInt32Type.instance);
                    case CoreTypeIdentifier.int64:
                        return new CoreTypeReferenceDescriptor(Int64Type.instance);
                    case CoreTypeIdentifier.uint64:
                        return new CoreTypeReferenceDescriptor(UInt64Type.instance);
                    case CoreTypeIdentifier.int_:
                        return new CoreTypeReferenceDescriptor(NativeIntType.instance);
                    case CoreTypeIdentifier.uint_:
                        return new CoreTypeReferenceDescriptor(NativeUIntType.instance);
                    case CoreTypeIdentifier.float32:
                        return new CoreTypeReferenceDescriptor(Float32Type.instance);
                    case CoreTypeIdentifier.float64:
                        return new CoreTypeReferenceDescriptor(Float64Type.instance);
                    default:
                        error("Unknown core type identifier: %s", id);
                }

                assert(false);
            case TypeReferenceType.structure:
                auto mod = _reader.readString();
                auto type = _reader.readString();

                return new StructureTypeReferenceDescriptor(type, mod);
            case TypeReferenceType.pointer:
                auto element = readTypeReference();

                return new PointerTypeReferenceDescriptor(element);
            case TypeReferenceType.array:
                auto element = readTypeReference();

                return new ArrayTypeReferenceDescriptor(element);
            case TypeReferenceType.function_:
                auto returnType = readTypeReference();
                auto fpType = new FunctionPointerTypeReferenceDescriptor(returnType);
                auto paramCount = _reader.read!uint();

                for (uint i = 0; i < paramCount; i++)
                    fpType.parameterTypes.add(readTypeReference());

                return fpType;
            default:
                error("Unknown type reference type: %s", t);
        }

        assert(false);
    }

    private Field readFieldReference(Program program)
    out (result)
    {
        assert(result);
        assert(program);
    }
    body
    {
        auto declType = readTypeReference();

        if (!isType!StructureTypeReferenceDescriptor(declType))
            error("Structure type expected");

        auto type = cast(StructureType)toType(declType, program);
        auto name = _reader.readString();

        if (auto field = type.fields.get(name))
            return *field;

        error("Unknown field: %s/%s:%s", type.module_.name, type.name, name);
        assert(false);
    }

    private Function readFunctionReference(Program program)
    in
    {
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto mod = toModule(_reader.readString(), program);
        auto name = _reader.readString();

        if (auto func = mod.functions.get(name))
            return *func;

        error("Unknown function: %s/%s", mod.name, name);
        assert(false);
    }

    private Function readFunction(Module module_, Program program)
    in
    {
        assert(module_);
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();
        auto attributes = _reader.read!FunctionAttributes();
        auto callConv = _reader.read!CallingConvention();
        auto returnType = toType(readTypeReference(), program);
        auto func = new Function(module_, name, returnType, attributes, callConv);
        auto paramCount = _reader.read!uint();

        for (uint i = 0; i < paramCount; i++)
            func.createParameter(toType(readTypeReference(), program));

        func.close();

        auto regCount = _reader.read!uint();

        for (uint j = 0; j < regCount; j++)
            readRegister(func, program);

        auto bbCount = _reader.read!uint();

        for (uint j = 0; j < bbCount; j++)
            readBasicBlock(func);

        return func;
    }

    private Register readRegister(Function function_, Program program)
    in
    {
        assert(function_);
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();
        auto type = toType(readTypeReference(), program);

        return function_.createRegister(name, type);
    }

    private BasicBlock readBasicBlock(Function function_)
    in
    {
        assert(function_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return function_.createBasicBlock(_reader.readString());
    }

    private Instruction readInstruction(Function function_, Program program)
    in
    {
        assert(function_);
        assert(program);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto code = _reader.read!OperationCode();
        auto opCode = find(allOpCodes, (OpCode op) { return op.code == code; });

        if (!opCode)
            error("Unknown opcode: %s", code);

        Register target;
        Register source1;
        Register source2;
        Register source3;

        if (opCode.hasTarget)
            target = readRegisterReference(function_);

        if (opCode.registers >= 1)
            source1 = readRegisterReference(function_);

        if (opCode.registers >= 2)
            source2 = readRegisterReference(function_);

        if (opCode.registers >= 3)
            source3 = readRegisterReference(function_);

        InstructionOperand operand;

        final switch (opCode.operandType)
        {
            case OperandType.none:
                break;
            case OperandType.int8:
                operand = _reader.read!byte();
                break;
            case OperandType.uint8:
                operand = _reader.read!ubyte();
                break;
            case OperandType.int16:
                operand = _reader.read!short();
                break;
            case OperandType.uint16:
                operand = _reader.read!ushort();
                break;
            case OperandType.int32:
                operand = _reader.read!int();
                break;
            case OperandType.uint32:
                operand = _reader.read!uint();
                break;
            case OperandType.int64:
                operand = _reader.read!long();
                break;
            case OperandType.uint64:
                operand = _reader.read!ulong();
                break;
            case OperandType.float32:
                operand = _reader.read!float();
                break;
            case OperandType.float64:
                operand = _reader.read!double();
                break;
            case OperandType.bytes:
                auto count = _reader.read!uint();
                auto bytes = new List!ubyte();

                for (uint i = 0; i < count; i++)
                    bytes.add(_reader.read!ubyte());

                operand = asCountable(bytes);
                break;
            case OperandType.type:
                operand = toType(readTypeReference(), program);
                break;
            case OperandType.structure:
                auto desc = readTypeReference();

                if (!isType!StructureTypeReferenceDescriptor(desc))
                    error("Structure type expected");

                operand = cast(StructureType)toType(desc, program);
                break;
            case OperandType.field:
                operand = readFieldReference(program);
                break;
            case OperandType.function_:
                operand = readFunctionReference(program);
                break;
            case OperandType.signature:
                auto desc = readTypeReference();

                if (!isType!FunctionPointerTypeReferenceDescriptor(desc))
                    error("Function pointer type expected");

                operand = cast(FunctionPointerType)toType(desc, program);
                break;
            case OperandType.label:
                operand = readBasicBlockReference(function_);
                break;
            case OperandType.selector:
                auto count = _reader.read!uint();
                auto regs = new NoNullList!Register();

                for (uint i = 0; i < count; i++)
                    regs.add(readRegisterReference(function_));

                operand = asCountable(regs);
                break;
        }

        return new Instruction(opCode, operand, target, source1, source2, source3);
    }

    private Register readRegisterReference(Function function_)
    in
    {
        assert(function_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();

        if (auto reg = function_.registers.get(name))
            return *reg;

        error("Unknown register: %s", name);
        assert(false);
    }

    private BasicBlock readBasicBlockReference(Function function_)
    in
    {
        assert(function_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = _reader.readString();

        if (auto block = function_.blocks.get(name))
            return *block;

        error("Unknown basic block: %s", name);
        assert(false);
    }

    private static void error(T ...)(T args)
    {
        throw new ReaderException(format(args));
    }
}
