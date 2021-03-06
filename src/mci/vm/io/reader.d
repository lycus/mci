module mci.vm.io.reader;

import std.exception,
       std.file,
       std.path,
       mci.core.common,
       mci.core.container,
       mci.core.io,
       mci.core.math,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.utilities,
       mci.core.code.data,
       mci.core.code.fields,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.code.opcodes,
       mci.core.code.stream,
       mci.core.code.symbols,
       mci.core.typing.cache,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.io.common,
       mci.vm.io.exception,
       mci.vm.io.extended,
       mci.vm.io.table;

private final class TypeDescriptor
{
    private string _name;
    private uint _alignment;
    private NoNullList!MemberDescriptor _members;

    pure nothrow invariant()
    {
        assert(_name);
        assert(!_alignment || powerOfTwo(_alignment));
        assert(_members);
    }

    public this(string name, uint alignment)
    in
    {
        assert(name);
        assert(!alignment || powerOfTwo(alignment));
    }
    body
    {
        _name = name;
        _alignment = alignment;
        _members = new typeof(_members)();
    }

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public uint alignment() pure nothrow
    out (result)
    {
        assert(!result || powerOfTwo(result));
    }
    body
    {
        return _alignment;
    }

    @property public NoNullList!MemberDescriptor members() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _members;
    }
}

private final class MemberDescriptor
{
    private string _name;
    private TypeReferenceDescriptor _type;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_type);
    }

    public this(string name, TypeReferenceDescriptor type) pure nothrow
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
    }

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public TypeReferenceDescriptor type() pure nothrow
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

    pure nothrow invariant()
    {
        assert(_name);
        assert(_moduleName);
    }

    public this(string name, string moduleName) pure nothrow
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

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public string moduleName() pure nothrow
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

    pure nothrow invariant()
    {
        assert(_type);
    }

    public this(CoreType type) pure nothrow
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
    }

    @property public CoreType type() pure nothrow
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

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public TypeReferenceDescriptor elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }
}

private final class ReferenceTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private StructureTypeReferenceDescriptor _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(StructureTypeReferenceDescriptor elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public StructureTypeReferenceDescriptor elementType() pure nothrow
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

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
    }

    @property public TypeReferenceDescriptor elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }
}

private final class VectorTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private TypeReferenceDescriptor _elementType;
    private uint _elements;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType, uint elements) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
        _elements = elements;
    }

    @property public TypeReferenceDescriptor elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public uint elements() pure nothrow
    {
        return _elements;
    }
}

private final class StaticArrayTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private TypeReferenceDescriptor _elementType;
    private uint _elements;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(TypeReferenceDescriptor elementType, uint elements) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        _elementType = elementType;
        _elements = elements;
    }

    @property public TypeReferenceDescriptor elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public uint elements() pure nothrow
    {
        return _elements;
    }
}

private final class FunctionPointerTypeReferenceDescriptor : TypeReferenceDescriptor
{
    private CallingConvention _callingConvention;
    private TypeReferenceDescriptor _returnType;
    private NoNullList!TypeReferenceDescriptor _parameterTypes;

    pure nothrow invariant()
    {
        assert(_parameterTypes);
    }

    public this(CallingConvention callingConvention, TypeReferenceDescriptor returnType)
    {
        _callingConvention = callingConvention;
        _returnType = returnType;
        _parameterTypes = new typeof(_parameterTypes)();
    }

    @property public CallingConvention callingConvention() pure nothrow
    {
        return _callingConvention;
    }

    @property public TypeReferenceDescriptor returnType() pure nothrow
    {
        return _returnType;
    }

    @property public NoNullList!TypeReferenceDescriptor parameterTypes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _parameterTypes;
    }
}

public final class ModuleReader : ModuleLoader
{
    private FileStream _file;
    private ModuleManager _manager;
    private VMBinaryReader _reader;
    private bool _done;
    private NoNullDictionary!(StructureType, TypeDescriptor) _types;
    private StringTable _table;

    pure nothrow invariant()
    {
        assert(_manager);
        assert(_types);
        assert(_table);
    }

    public this(ModuleManager manager)
    in
    {
        assert(manager);
    }
    body
    {
        _manager = manager;
        _types = new typeof(_types)();
        _table = new typeof(_table)();
    }

    public Module load(string path)
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
        _file = new typeof(_file)(path, FileMode.read);
        _reader = new typeof(_reader)(_file);

        auto mod = readModule();

        _file.close();

        return mod;
    }

    private Module readModule()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto magic = _reader.readArray!string(fileMagic.length);

        if (magic != fileMagic)
            error("File magic '%s' doesn't match expected '%s'.", magic, fileMagic);

        auto ver = _reader.read!uint();

        if (ver != fileVersion)
            error("Cannot handle file format version %s.", ver);

        auto stOffset = _reader.read!ulong();

        auto pos = _reader.stream.position;

        _reader.stream.position = stOffset;

        readStringTable();

        _reader.stream.position = pos;

        auto mod = _manager.attach(new Module(baseName(_file.name, moduleFileExtension)));

        auto typeCount = _reader.read!uint();

        for (uint i = 0; i < typeCount; i++)
        {
            auto type = readType();
            auto structType = new StructureType(mod, type.name, type.alignment);

            _types[structType] = type;
        }

        foreach (tup; _types)
        {
            foreach (field; tup.y.members)
            {
                auto fieldType = toType(field.type);

                if (auto struc = cast(StructureType)fieldType)
                    if (tup.x.hasCycle(struc))
                        error("Cyclic member %s:'%s' detected.", tup.x, field.name);

                tup.x.createMember(field.name, fieldType);
            }

            tup.x.close();
        }

        auto gfCount = _reader.read!uint();

        for (uint i = 0; i < gfCount; i++)
            readGlobalField(mod);

        auto tfCount = _reader.read!uint();

        for (uint i = 0; i < tfCount; i++)
            readThreadField(mod);

        auto dbCount = _reader.read!uint();

        for (uint i = 0; i < dbCount; i++)
            readDataBlock(mod);

        auto funcCount = _reader.read!uint();

        for (uint i = 0; i < funcCount; i++)
            readFunction(mod);

        foreach (func; mod.functions)
        {
            foreach (block; func.y.blocks)
            {
                auto instrCount = _reader.read!uint();

                for (uint i = 0; i < instrCount; i++)
                    readInstruction(block.y.stream, func.y);
            }
        }

        if (_reader.read!bool())
            mod.entryPoint = readEntryPointFunctionReference(mod, Int32Type.instance);

        if (_reader.read!bool())
            mod.moduleEntryPoint = readEntryPointFunctionReference(mod, null);

        if (_reader.read!bool())
            mod.moduleExitPoint = readEntryPointFunctionReference(mod, null);

        if (_reader.read!bool())
            mod.threadEntryPoint = readEntryPointFunctionReference(mod, null);

        if (_reader.read!bool())
            mod.threadExitPoint = readEntryPointFunctionReference(mod, null);

        readMetadataSegment();

        return mod;
    }

    private void readMetadataSegment()
    {
        auto count = _reader.read!ulong();

        for (ulong i = 0; i < count; i++)
        {
            auto mdType = _reader.read!MetadataType();

            switch (mdType)
            {
                case MetadataType.type:
                    auto type = toType(readTypeReference());

                    if (auto struc = cast(StructureType)type)
                        readMetadata(struc.metadata);
                    else
                        error("Structure type expected.");

                    break;
                case MetadataType.globalField:
                    readMetadata(readGlobalFieldReference().metadata);
                    break;
                case MetadataType.threadField:
                    readMetadata(readThreadFieldReference().metadata);
                    break;
                case MetadataType.function_:
                    readMetadata(readFunctionReference().metadata);
                    break;
                case MetadataType.parameter:
                    readMetadata(readParameterReference(readFunctionReference()).metadata);
                    break;
                case MetadataType.register:
                    readMetadata(readRegisterReference(readFunctionReference()).metadata);
                    break;
                case MetadataType.block:
                    readMetadata(readBasicBlockReference(readFunctionReference()).metadata);
                    break;
                case MetadataType.instruction:
                    readMetadata(readInstructionReference(readBasicBlockReference(readFunctionReference())).metadata);
                    break;
                case MetadataType.dataBlock:
                    readMetadata(readDataBlockReference().metadata);
                    break;
                default:
                    error("Unknown metadata type '%s'.", mdType);
            }
        }
    }

    private void readMetadata(List!MetadataPair metadata)
    in
    {
        assert(metadata);
    }
    body
    {
        auto count = _reader.read!uint();

        for (uint i = 0; i < count; i++)
            metadata.add(MetadataPair(readString(), readString()));
    }

    private void readStringTable()
    {
        auto count = _reader.read!uint();

        for (uint i = 0; i < count; i++)
            _table.addPair(_reader.read!uint(), _reader.readString());
    }

    private Type toType(TypeReferenceDescriptor descriptor)
    in
    {
        assert(descriptor);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto structType = cast(StructureTypeReferenceDescriptor)descriptor)
        {
            if (auto type = toModule(structType.moduleName).types.get(structType.name))
                return *type;

            error("Unknown type '%s'/'%s'.", structType.moduleName, structType.name);
            assert(false);
        }
        else if (auto ptrType = cast(PointerTypeReferenceDescriptor)descriptor)
            return getPointerType(toType(ptrType.elementType));
        else if (auto refType = cast(ReferenceTypeReferenceDescriptor)descriptor)
             return getReferenceType(cast(StructureType)toType(refType.elementType));
        else if (auto arrType = cast(ArrayTypeReferenceDescriptor)descriptor)
            return getArrayType(toType(arrType.elementType));
        else if (auto vecType = cast(VectorTypeReferenceDescriptor)descriptor)
            return getVectorType(toType(vecType.elementType), vecType.elements);
        else if (auto saType = cast(StaticArrayTypeReferenceDescriptor)descriptor)
            return getStaticArrayType(toType(saType.elementType), saType.elements);
        else if (auto fpType = cast(FunctionPointerTypeReferenceDescriptor)descriptor)
        {
            auto params = new NoNullList!Type(map(fpType.parameterTypes, (TypeReferenceDescriptor desc) => toType(desc)));
            return getFunctionPointerType(fpType.callingConvention, fpType.returnType ? toType(fpType.returnType) : null, params);
        }
        else
            return (cast(CoreTypeReferenceDescriptor)descriptor).type;
    }

    private Module toModule(string name)
    in
    {
        assert(name);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto mod = _manager.load(this, name))
            return mod;

        error("Could not locate module '%s'.", name);
        assert(false);
    }

    private TypeDescriptor readType()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto alignment = _reader.read!uint();

        if (alignment && !powerOfTwo(alignment))
            error("Alignment %s is not a power of two.", alignment);

        auto type = new TypeDescriptor(name, alignment);
        auto memberCount = _reader.read!uint();

        for (uint i = 0; i < memberCount; i++)
            type.members.add(readMember());

        return type;
    }

    private MemberDescriptor readMember()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto type = readTypeReference();

        return new MemberDescriptor(name, type);
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
                        error("Unknown core type identifier '%s'.", id);
                        assert(false);
                }
            case TypeReferenceType.structure:
                auto mod = readString();
                auto type = readString();

                return new StructureTypeReferenceDescriptor(type, mod);
            case TypeReferenceType.pointer:
                auto element = readTypeReference();

                return new PointerTypeReferenceDescriptor(element);
            case TypeReferenceType.reference:
                auto element = readTypeReference();

                if (auto struc = cast(StructureTypeReferenceDescriptor)element)
                    return new ReferenceTypeReferenceDescriptor(struc);

                error("Structure type expected.");
                assert(false);
            case TypeReferenceType.array:
                auto element = readTypeReference();

                return new ArrayTypeReferenceDescriptor(element);
            case TypeReferenceType.vector:
                auto element = readTypeReference();
                auto elements = _reader.read!uint();

                return new VectorTypeReferenceDescriptor(element, elements);
            case TypeReferenceType.staticArray:
                auto element = readTypeReference();
                auto elements = _reader.read!uint();

                return new StaticArrayTypeReferenceDescriptor(element, elements);
            case TypeReferenceType.function_:
                TypeReferenceDescriptor returnType;

                if (_reader.read!bool())
                    returnType = readTypeReference();

                auto cc = _reader.read!CallingConvention();
                auto fpType = new FunctionPointerTypeReferenceDescriptor(cc, returnType);
                auto paramCount = _reader.read!uint();

                for (uint i = 0; i < paramCount; i++)
                    fpType.parameterTypes.add(readTypeReference());

                return fpType;
            default:
                error("Unknown type reference type '%s'.", t);
                assert(false);
        }
    }

    private StructureMember readMemberReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto declType = readTypeReference();

        if (!cast(StructureTypeReferenceDescriptor)declType)
            error("Structure type expected.");

        auto type = cast(StructureType)toType(declType);
        auto name = readString();

        if (auto field = type.members.get(name))
            return *field;

        error("Unknown member '%s'/'%s':'%s'.", type.module_.name, type.name, name);
        assert(false);
    }

    private GlobalField readGlobalFieldReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto mod = toModule(readString());
        auto name = readString();

        if (auto field = mod.globalFields.get(name))
            return *field;

        error("Unknown global field '%s':'%s'.", mod.name, name);
        assert(false);
    }

    private ThreadField readThreadFieldReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto mod = toModule(readString());
        auto name = readString();

        if (auto field = mod.threadFields.get(name))
            return *field;

        error("Unknown thread field '%s':'%s'.", mod.name, name);
        assert(false);
    }

    private Function readFunctionReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto mod = toModule(readString());
        auto name = readString();

        if (auto func = mod.functions.get(name))
            return *func;

        error("Unknown function '%s'/'%s'.", mod.name, name);
        assert(false);
    }

    private DataBlock readDataBlockReference()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto mod = toModule(readString());
        auto name = readString();

        if (auto data = mod.dataBlocks.get(name))
            return *data;

        error("Unknown data block '%s'/'%s'.", mod.name, name);
        assert(false);
    }

    private Function readEntryPointFunctionReference(Module module_, Type returnType)
    in
    {
        assert(module_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto func = readFunctionReference();

        if (func.module_ !is module_)
            error("Function %s is not within module %s.", func, module_);

        if (func.callingConvention != CallingConvention.standard)
            error("Function %s does not have standard calling convention.", func);

        if (func.returnType !is returnType)
            error("Function %s does not have return type %s.", func, returnType ? returnType.toString() : "void");

        if (!func.parameters.empty)
            error("Function %s does not have an empty parameter list.");

        return func;
    }

    private GlobalField readGlobalField(Module module_)
    in
    {
        assert(module_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto type = toType(readTypeReference());
        ForeignSymbol forwarder;

        if (_reader.read!bool())
            forwarder = readForeignSymbol();

        return new GlobalField(module_, name, type, forwarder);
    }

    private ThreadField readThreadField(Module module_)
    in
    {
        assert(module_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto type = toType(readTypeReference());
        ForeignSymbol forwarder;

        if (_reader.read!bool())
            forwarder = readForeignSymbol();

        return new ThreadField(module_, name, type, forwarder);
    }

    private DataBlock readDataBlock(Module module_)
    in
    {
        assert(module_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto count = _reader.read!uint();
        auto bytes = toList(_reader.readArray!(ubyte[])(count));

        return new DataBlock(module_, name, bytes);
    }

    private Function readFunction(Module module_)
    in
    {
        assert(module_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto name = readString();
        auto attributes = _reader.read!FunctionAttributes();

        TypeReferenceDescriptor retType;

        if (_reader.read!bool())
            retType = readTypeReference();

        auto returnType = retType ? toType(retType) : null;
        auto cc = _reader.read!CallingConvention();
        auto func = new Function(module_, name, returnType, cc, attributes);
        auto paramCount = _reader.read!uint();

        for (uint i = 0; i < paramCount; i++)
            readParameter(func);

        func.close();

        auto regCount = _reader.read!uint();

        for (uint i = 0; i < regCount; i++)
            readRegister(func);

        auto bbCount = _reader.read!uint();

        for (uint i = 0; i < bbCount; i++)
            readBasicBlock(func);

        for (uint i = 0; i < bbCount; i++)
            readBasicBlockUnwindSpecification(func).close();

        return func;
    }

    private Parameter readParameter(Function function_)
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
        auto type = toType(readTypeReference());
        auto attr = _reader.read!ParameterAttributes();

        return function_.createParameter(type, attr);
    }

    private Register readRegister(Function function_)
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
        auto type = toType(readTypeReference());

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

    private BasicBlock readBasicBlockUnwindSpecification(Function function_)
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
        auto bb = readBasicBlockReference(function_);

        if (_reader.read!bool())
            bb.unwindBlock = readBasicBlockReference(function_);

        return bb;
    }

    private Instruction readInstruction(InstructionStream stream, Function function_)
    in
    {
        assert(stream);
        assert(function_);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto code = _reader.read!OperationCode();
        auto attributes = _reader.read!InstructionAttributes();
        auto opCode = find(allOpCodes, (OpCode op) => op.code == code);

        if (!opCode)
            error("Unknown opcode %s.", cast(ubyte)code);

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

        ReadOnlyIndexable!T readArray(T)()
        {
            auto count = _reader.read!uint();
            auto values = toList(_reader.readArray!(T[])(count));

            return values;
        }

        switch (opCode.operandType)
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
            case OperandType.int8Array:
                operand = readArray!byte();
                break;
            case OperandType.uint8Array:
                operand = readArray!ubyte();
                break;
            case OperandType.int16Array:
                operand = readArray!short();
                break;
            case OperandType.uint16Array:
                operand = readArray!ushort();
                break;
            case OperandType.int32Array:
                operand = readArray!int();
                break;
            case OperandType.uint32Array:
                operand = readArray!uint();
                break;
            case OperandType.int64Array:
                operand = readArray!long();
                break;
            case OperandType.uint64Array:
                operand = readArray!ulong();
                break;
            case OperandType.float32Array:
                operand = readArray!float();
                break;
            case OperandType.float64Array:
                operand = readArray!double();
                break;
            case OperandType.type:
                operand = toType(readTypeReference());
                break;
            case OperandType.member:
                operand = readMemberReference();
                break;
            case OperandType.globalField:
                operand = readGlobalFieldReference();
                break;
            case OperandType.threadField:
                operand = readThreadFieldReference();
                break;
            case OperandType.function_:
                operand = readFunctionReference();
                break;
            case OperandType.label:
                operand = readBasicBlockReference(function_);
                break;
            case OperandType.branch:
                auto trueBB = readBasicBlockReference(function_);
                auto falseBB = readBasicBlockReference(function_);
                operand = tuple(trueBB, falseBB);
                break;
            case OperandType.selector:
                auto count = _reader.read!uint();
                auto regs = new NoNullList!Register();

                for (uint i = 0; i < count; i++)
                    regs.add(readRegisterReference(function_));

                operand = asReadOnlyIndexable(regs);
                break;
            case OperandType.foreignSymbol:
                operand = readForeignSymbol();
                break;
            case OperandType.dataBlock:
                operand = readDataBlockReference();
                break;
            default:
                error("Unknown opcode operand type '%s'.", opCode.operandType);
        }

        return stream.append(opCode, attributes, operand, target, source1, source2, source3);
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

        if (auto reg = function_.registers.get(name))
            return *reg;

        error("Unknown register '%s'.", name);
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
        auto name = readString();

        if (auto block = function_.blocks.get(name))
            return *block;

        error("Unknown basic block '%s'.", name);
        assert(false);
    }

    private Instruction readInstructionReference(BasicBlock block)
    in
    {
        assert(block);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        auto i = _reader.read!uint();

        if (i >= block.stream.count)
            error("Unknown instruction %s.", i);

        return block.stream[i];
    }

    private Parameter readParameterReference(Function function_)
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
        auto i = _reader.read!uint();

        if (i >= function_.parameters.count)
            error("Unknown parameter %s.", i);

        return function_.parameters[i];
    }

    private ForeignSymbol readForeignSymbol()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto library = readString();
        auto ep = readString();

        return new ForeignSymbol(library, ep);
    }

    private string readString()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _table.getString(_reader.read!uint());
    }

    private static void error(T ...)(T args)
    {
        throw new ReaderException(format(args));
    }
}
