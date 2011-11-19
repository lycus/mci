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
       mci.vm.io.exception;

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
    private FieldAttributes _attributes;
    private Nullable!uint _offset;
    private TypeReferenceDescriptor _type;

    invariant()
    {
        assert(_name);
        assert(_type);
    }

    public this(string name, FieldAttributes attributes, Nullable!uint offset, TypeReferenceDescriptor type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _attributes = attributes;
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

    @property public FieldAttributes attributes()
    {
        return _attributes;
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
    private BinaryReader _reader;
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
            program.modules.add(readModule(program.typeCache));

        foreach (mod; program.modules)
        {
            auto typeCount = _reader.read!uint();

            for (uint i = 0; i < typeCount; i++)
            {
                auto type = readType();
                auto structType = program.typeCache.addStructureType(mod, type.name, type.layout);

                _types[structType] = type;
            }
        }

        closeTypes(program.typeCache);

        foreach (mod; program.modules)
        {
            auto funcCount = _reader.read!uint();

            for (uint i = 0; i < funcCount; i++)
                readFunction(mod, program.typeCache);
        }

        foreach (mod; program.modules)
        {
            foreach (func; mod.functions)
            {
                foreach (block; func.blocks)
                {
                    auto instrCount = _reader.read!uint();

                    for (uint i = 0; i < instrCount; i++)
                        block.instructions.add(readInstruction(func, program));
                }
            }
        }

        return program;
    }

    private Module readModule(TypeCache cache)
    in
    {
        assert(cache);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return new Module(readString());
    }

    private void closeTypes(TypeCache cache)
    in
    {
        assert(cache);
    }
    body
    {
        foreach (tup; _types)
        {
            foreach (field; tup.y.fields)
                tup.x.createField(field.name, toType(field.type, cache), field.attributes, field.offset);

            tup.x.close();
        }
    }

    private static Type toType(TypeReferenceDescriptor descriptor, TypeCache cache)
    in
    {
        assert(descriptor);
        assert(cache);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto structType = cast(StructureTypeReferenceDescriptor)descriptor)
        {
            auto type = cache.getType(structType.moduleName, structType.name);

            if (!type)
                error("Unknown type: %s/%s", structType.moduleName, structType.name);

            return type;
        }
        else if (auto ptrType = cast(PointerTypeReferenceDescriptor)descriptor)
            return cache.getPointerType(toType(ptrType.elementType, cache));
        else if (auto fpType = cast(FunctionPointerTypeReferenceDescriptor)descriptor)
        {
            auto params = new NoNullList!Type(map(fpType.parameterTypes, (TypeReferenceDescriptor desc) { return toType(desc, cache); }));
            return cache.getFunctionPointerType(toType(fpType.returnType, cache), params);
        }
        else
            return (cast(CoreTypeReferenceDescriptor)descriptor).type;
    }

    private TypeDescriptor readType()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
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
        auto name = readString();
        auto attributes = _reader.read!FieldAttributes();
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
                auto mod = readString();
                auto type = readString();

                return new StructureTypeReferenceDescriptor(type, mod);
            case TypeReferenceType.pointer:
                auto element = readTypeReference();

                return new PointerTypeReferenceDescriptor(element);
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

    private Field readFieldReference(TypeCache cache)
    in
    {
        assert(cache);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto declType = readTypeReference();

        if (!isType!StructureTypeReferenceDescriptor(declType))
            error("Structure type expected");

        auto type = cast(StructureType)toType(declType, cache);
        auto name = readString();
        auto field = find(type.fields, (Field f) { return f.name == name; });

        if (!field)
            error("Unknown field: %s/%s:%s", type.module_.name, type.name, name);

        return field;
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
        auto moduleName = readString();
        auto mod = find(program.modules, (Module m) { return m.name == moduleName; });

        if (!mod)
            error("Unknown module: %s", moduleName);

        auto name = readString();
        auto func = find(mod.functions, (Function fn) { return fn.name == name; });

        if (!func)
            error("Unknown function: %s/%s", moduleName, name);

        return func;
    }

    private Function readFunction(Module module_, TypeCache cache)
    in
    {
        assert(module_);
        assert(cache);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto attributes = _reader.read!FunctionAttributes();
        auto callConv = _reader.read!CallingConvention();
        auto returnType = toType(readTypeReference(), cache);
        auto func = module_.createFunction(name, returnType, attributes, callConv);
        auto paramCount = _reader.read!uint();

        for (uint i = 0; i < paramCount; i++)
            func.createParameter(toType(readTypeReference(), cache));

        auto regCount = _reader.read!uint();

        for (uint j = 0; j < regCount; j++)
            readRegister(func, cache);

        auto bbCount = _reader.read!uint();

        for (uint j = 0; j < bbCount; j++)
            readBasicBlock(func);

        return func;
    }

    private Register readRegister(Function function_, TypeCache cache)
    in
    {
        assert(function_);
        assert(cache);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto type = toType(readTypeReference(), cache);

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
        return function_.createBasicBlock(readString());
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

        if (opCode.hasTarget)
            target = readRegisterReference(function_);

        if (opCode.registers >= 1)
            source1 = readRegisterReference(function_);

        if (opCode.registers >= 2)
            source2 = readRegisterReference(function_);

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
                operand = toType(readTypeReference(), program.typeCache);
                break;
            case OperandType.structure:
                auto desc = readTypeReference();

                if (!isType!StructureTypeReferenceDescriptor(desc))
                    error("Structure type expected");

                operand = cast(StructureType)toType(desc, program.typeCache);
                break;
            case OperandType.field:
                operand = readFieldReference(program.typeCache);
                break;
            case OperandType.function_:
                operand = readFunctionReference(program);
                break;
            case OperandType.signature:
                auto desc = readTypeReference();

                if (!isType!FunctionPointerTypeReferenceDescriptor(desc))
                    error("Function pointer type expected");

                operand = cast(FunctionPointerType)toType(desc, program.typeCache);
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

        return new Instruction(opCode, operand, target, source1, source2);
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
        auto name = readString();
        auto reg = find(function_.registers, (Register reg) { return reg.name == name; });

        if (!reg)
            error("Unknown register: %s", name);

        return reg;
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
        auto name = readString();
        auto block = find(function_.blocks, (BasicBlock bb) { return bb.name == name; });

        if (!block)
            error("Unknown basic block: %s", name);

        return block;
    }

    private string readString()
    {
        auto len = _reader.read!uint();
        return _reader.readArray!string(len);
    }

    private static void error(T ...)(T args)
    {
        throw new ReaderException(format(args));
    }
}
