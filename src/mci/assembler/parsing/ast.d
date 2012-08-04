module mci.assembler.parsing.ast;

import std.conv,
       std.variant,
       mci.core.container,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.assembler.parsing.location;

private __gshared List!Node emptyNodes;

shared static this()
{
    emptyNodes = new typeof(emptyNodes)();
}

/**
 * Represents an abstract syntax tree (AST) node for IAL source code.
 */
public abstract class Node
{
    private SourceLocation _location;

    /**
     * Constructs a $(D Node) instance.
     *
     * Params:
     *  location = The location of this node in the source code.
     */
    protected this(SourceLocation location) pure nothrow
    {
        _location = location;
    }

    /**
     * Gets the most meaningful location of this AST node.
     *
     * For some constructs, this may not necessarily be the first token
     * in the source text. This value is generally most useful for error
     * reporting.
     *
     * Returns:
     *  The most meaningful location of this AST node.
     */
    @property public final SourceLocation location() pure nothrow
    {
        return _location;
    }

    /**
     * Gets the child nodes of this node, if any. If there are no
     * children, an empty container is returned.
     *
     * Returns:
     *  A container with all child nodes of this node, or an empty
     *  container if there are none.
     */
    @property public ReadOnlyIndexable!Node children()
    out (result)
    {
        assert(result);
    }
    body
    {
        return emptyNodes;
    }

    public override string toString()
    {
        return "";
    }
}

public class MetadataNode : Node
{
    private SimpleNameNode _key;
    private SimpleNameNode _value;

    pure nothrow invariant()
    {
        assert(_key);
        assert(_value);
    }

    public this(SourceLocation location, SimpleNameNode key, SimpleNameNode value) pure nothrow
    in
    {
        assert(key);
        assert(value);
    }
    body
    {
        super(location);

        _key = key;
        _value = value;
    }

    @property public final SimpleNameNode key() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _key;
    }

    @property public final SimpleNameNode value() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_key, _value);
    }
}

public class MetadataListNode : Node
{
    private NoNullList!MetadataNode _metadata;

    pure nothrow invariant()
    {
        assert(_metadata);
    }

    public this(SourceLocation location, NoNullList!MetadataNode metadata)
    in
    {
        assert(metadata);
    }
    body
    {
        super(location);

        _metadata = metadata.duplicate();
    }

    @property public final ReadOnlyIndexable!MetadataNode metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(castItems!Node(_metadata));
    }
}

public abstract class DeclarationNode : Node
{
    protected this(SourceLocation location) pure nothrow
    {
        super(location);
    }
}

public class SimpleNameNode : Node
{
    private string _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, string name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    public override string toString()
    {
        return "name: " ~ _name;
    }
}

public class ModuleReferenceNode : Node
{
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_name);
    }
}

public abstract class TypeReferenceNode : Node
{
    protected this(SourceLocation location) pure nothrow
    {
        super(location);
    }
}

public class StructureTypeReferenceNode : TypeReferenceNode
{
    private ModuleReferenceNode _moduleName;
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _moduleName = moduleName;
        _name = name;
    }

    @property public final ModuleReferenceNode moduleName() pure nothrow
    {
        return _moduleName;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_moduleName, _name);
    }
}

public class PointerTypeReferenceNode : TypeReferenceNode
{
    private TypeReferenceNode _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(SourceLocation location, TypeReferenceNode elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        super(location);

        _elementType = elementType;
    }

    @property public final TypeReferenceNode elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_elementType);
    }
}

public class ReferenceTypeReferenceNode : TypeReferenceNode
{
    private StructureTypeReferenceNode _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(SourceLocation location, StructureTypeReferenceNode elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        super(location);

        _elementType = elementType;
    }

    @property public final StructureTypeReferenceNode elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_elementType);
    }
}

public class ArrayTypeReferenceNode : TypeReferenceNode
{
    private TypeReferenceNode _elementType;

    pure nothrow invariant()
    {
        assert(_elementType);
    }

    public this(SourceLocation location, TypeReferenceNode elementType) pure nothrow
    in
    {
        assert(elementType);
    }
    body
    {
        super(location);

        _elementType = elementType;
    }

    @property public final TypeReferenceNode elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_elementType);
    }
}

public class VectorTypeReferenceNode : TypeReferenceNode
{
    private TypeReferenceNode _elementType;
    private LiteralValueNode _elements;

    pure nothrow invariant()
    {
        assert(_elementType);
        assert(_elements);
    }

    public this(SourceLocation location, TypeReferenceNode elementType, LiteralValueNode elements) pure nothrow
    in
    {
        assert(elementType);
        assert(elements);
    }
    body
    {
        super(location);

        _elementType = elementType;
        _elements = elements;
    }

    @property public final TypeReferenceNode elementType() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elementType;
    }

    @property public final LiteralValueNode elements() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _elements;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_elementType, _elements);
    }
}

public class FunctionPointerTypeReferenceNode : TypeReferenceNode
{
    private CallingConvention _callingConvention;
    private TypeReferenceNode _returnType;
    private NoNullList!TypeReferenceNode _parameterTypes;

    pure nothrow invariant()
    {
        assert(_parameterTypes);
    }

    public this(SourceLocation location, CallingConvention callingConvention, TypeReferenceNode returnType,
                NoNullList!TypeReferenceNode parameterTypes)
    in
    {
        assert(parameterTypes);
    }
    body
    {
        super(location);

        _callingConvention = callingConvention;
        _returnType = returnType;
        _parameterTypes = parameterTypes.duplicate();
    }

    @property public final CallingConvention callingConvention() pure nothrow
    {
        return _callingConvention;
    }

    @property public final TypeReferenceNode returnType() pure nothrow
    {
        return _returnType;
    }

    @property public final ReadOnlyIndexable!TypeReferenceNode parameterTypes() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _parameterTypes;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(concat(toReadOnlyIndexable!Node(_returnType), castItems!Node(_parameterTypes)));
    }

    public override string toString()
    {
        return "calling convention: " ~ to!string(_callingConvention);
    }
}

public abstract class CoreTypeReferenceNode : TypeReferenceNode
{
    protected this(SourceLocation location) pure nothrow
    {
        super(location);
    }

    @property public abstract SimpleNameNode name() pure nothrow;
}

private mixin template DefineCoreTypeNode(string type, string name)
{
    mixin("public class " ~ type ~ "TypeReferenceNode : CoreTypeReferenceNode" ~
          "{" ~
          "    private SimpleNameNode _name;" ~
          "" ~
          "    pure nothrow invariant()" ~
          "    {" ~
          "        assert(_name);" ~
          "    }" ~
          "" ~
          "    public this(SourceLocation location) pure nothrow" ~
          "    {" ~
          "        super(location);" ~
          "" ~
          "        _name = new SimpleNameNode(location, \"" ~ name ~ "\");" ~
          "    }" ~
          "" ~
          "    @property public final override SimpleNameNode name() pure nothrow" ~
          "    {" ~
          "        return _name;" ~
          "    }" ~
          "" ~
          "    @property public override ReadOnlyIndexable!Node children()" ~
          "    {" ~
          "        return toReadOnlyIndexable!Node(_name);" ~
          "    }" ~
          "}");
}

mixin DefineCoreTypeNode!("Int8", "int8");
mixin DefineCoreTypeNode!("UInt8", "uint8");
mixin DefineCoreTypeNode!("Int16", "int16");
mixin DefineCoreTypeNode!("UInt16", "uint16");
mixin DefineCoreTypeNode!("Int32", "int32");
mixin DefineCoreTypeNode!("UInt32", "uint32");
mixin DefineCoreTypeNode!("Int64", "int64");
mixin DefineCoreTypeNode!("UInt64", "uint64");
mixin DefineCoreTypeNode!("NativeInt", "int");
mixin DefineCoreTypeNode!("NativeUInt", "uint");
mixin DefineCoreTypeNode!("Float32", "float32");
mixin DefineCoreTypeNode!("Float64", "float64");

public class FieldReferenceNode : Node
{
    private StructureTypeReferenceNode _typeName;
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_typeName);
        assert(_name);
    }

    public this(SourceLocation location, StructureTypeReferenceNode typeName, SimpleNameNode name) pure nothrow
    in
    {
        assert(typeName);
        assert(name);
    }
    body
    {
        super(location);

        _typeName = typeName;
        _name = name;
    }

    @property public final StructureTypeReferenceNode typeName() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _typeName;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_typeName, _name);
    }
}

public class FunctionReferenceNode : Node
{
    private ModuleReferenceNode _moduleName;
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _moduleName = moduleName;
        _name = name;
    }

    @property public final ModuleReferenceNode moduleName() pure nothrow
    {
        return _moduleName;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_moduleName, _name);
    }
}

public class TypeDeclarationNode : DeclarationNode
{
    private SimpleNameNode _name;
    private LiteralValueNode _alignment;
    private NoNullList!FieldDeclarationNode _fields;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_fields);
    }

    public this(SourceLocation location, SimpleNameNode name, LiteralValueNode alignment, NoNullList!FieldDeclarationNode fields,
                MetadataListNode metadata)
    in
    {
        assert(name);
        assert(fields);
    }
    body
    {
        super(location);

        _name = name;
        _alignment = alignment;
        _fields = fields.duplicate();
        _metadata = metadata;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public final LiteralValueNode alignment() pure nothrow
    {
        return _alignment;
    }

    @property public final ReadOnlyIndexable!FieldDeclarationNode fields() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _fields;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(concat(toReadOnlyIndexable!Node(_name, _alignment), castItems!Node(_fields), toReadOnlyIndexable!Node(_metadata)));
    }
}

public class FieldDeclarationNode : Node
{
    private TypeReferenceNode _type;
    private SimpleNameNode _name;
    private FieldStorage _storage;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_type);
        assert(_name);
    }

    public this(SourceLocation location, TypeReferenceNode type, SimpleNameNode name, FieldStorage storage,
                MetadataListNode metadata) pure nothrow
    in
    {
        assert(type);
        assert(name);
    }
    body
    {
        super(location);

        _type = type;
        _name = name;
        _storage = storage;
        _metadata = metadata;
    }

    @property public final TypeReferenceNode type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public final FieldStorage storage() pure nothrow
    {
        return _storage;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_type, _name, _metadata);
    }

    public override string toString()
    {
        return "storage: " ~ to!string(_storage);
    }
}

public class ParameterNode : Node
{
    private TypeReferenceNode _type;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_type);
    }

    public this(SourceLocation location, TypeReferenceNode type, MetadataListNode metadata) pure nothrow
    in
    {
        assert(type);
    }
    body
    {
        super(location);

        _type = type;
        _metadata = metadata;
    }

    @property public final TypeReferenceNode type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_type, _metadata);
    }
}

public class FunctionDeclarationNode : DeclarationNode
{
    private SimpleNameNode _name;
    private CallingConvention _callingConvention;
    private FunctionAttributes _attributes;
    private NoNullList!ParameterNode _parameters;
    private TypeReferenceNode _returnType;
    private NoNullList!RegisterDeclarationNode _registers;
    private NoNullList!BasicBlockDeclarationNode _blocks;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_parameters);
        assert(_registers);
        assert(_blocks);
    }

    public this(SourceLocation location, SimpleNameNode name, CallingConvention callingConvention,
                FunctionAttributes attributes, NoNullList!ParameterNode parameters, TypeReferenceNode returnType,
                NoNullList!RegisterDeclarationNode registers, NoNullList!BasicBlockDeclarationNode blocks,
                MetadataListNode metadata)
    in
    {
        assert(name);
        assert(parameters);
        assert(registers);
        assert(blocks);
    }
    body
    {
        super(location);

        _name = name;
        _callingConvention = callingConvention;
        _attributes = attributes;
        _parameters = parameters.duplicate();
        _returnType = returnType;
        _registers = registers.duplicate();
        _blocks = blocks.duplicate();
        _metadata = metadata;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public final CallingConvention callingConvention() pure nothrow
    {
        return _callingConvention;
    }

    @property public final FunctionAttributes attributes() pure nothrow
    {
        return _attributes;
    }

    @property public final ReadOnlyIndexable!ParameterNode parameters() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _parameters;
    }

    @property public final TypeReferenceNode returnType() pure nothrow
    {
        return _returnType;
    }

    @property public final ReadOnlyIndexable!RegisterDeclarationNode registers() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _registers;
    }

    @property public final ReadOnlyIndexable!BasicBlockDeclarationNode blocks() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _blocks;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        auto params = castItems!Node(_parameters);
        auto regs = castItems!Node(_registers);
        auto blocks = castItems!Node(_blocks);

        return new List!Node(concat(toReadOnlyIndexable!Node(_name, _returnType), params, regs, blocks, toReadOnlyIndexable!Node(_metadata)));
    }

    public override string toString()
    {
        return "calling convention: " ~ to!string(_callingConvention) ~ ", attributes: " ~ to!string(_attributes);
    }
}

public class EntryPointDeclarationNode : DeclarationNode
{
    private FunctionReferenceNode _function;

    pure nothrow invariant()
    {
        assert(_function);
    }

    public this(SourceLocation location, FunctionReferenceNode function_) pure nothrow
    in
    {
        assert(function_);
    }
    body
    {
        super(location);

        _function = function_;
    }

    @property public final FunctionReferenceNode function_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_function);
    }
}

public class ModuleEntryPointDeclarationNode : EntryPointDeclarationNode
{
    public this(SourceLocation location, FunctionReferenceNode function_) pure nothrow
    in
    {
        assert(function_);
    }
    body
    {
        super(location, function_);
    }
}

public class ModuleExitPointDeclarationNode : EntryPointDeclarationNode
{
    public this(SourceLocation location, FunctionReferenceNode function_) pure nothrow
    in
    {
        assert(function_);
    }
    body
    {
        super(location, function_);
    }
}

public class ThreadEntryPointDeclarationNode : EntryPointDeclarationNode
{
    public this(SourceLocation location, FunctionReferenceNode function_) pure nothrow
    in
    {
        assert(function_);
    }
    body
    {
        super(location, function_);
    }
}

public class ThreadExitPointDeclarationNode : EntryPointDeclarationNode
{
    public this(SourceLocation location, FunctionReferenceNode function_) pure nothrow
    in
    {
        assert(function_);
    }
    body
    {
        super(location, function_);
    }
}

public class RegisterDeclarationNode : Node
{
    private SimpleNameNode _name;
    private TypeReferenceNode _type;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_type);
    }

    public this(SourceLocation location, SimpleNameNode name, TypeReferenceNode type, MetadataListNode metadata) pure nothrow
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        super(location);

        _name = name;
        _type = type;
        _metadata = metadata;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public final TypeReferenceNode type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_type, _name, _metadata);
    }
}

public class BasicBlockDeclarationNode : Node
{
    private SimpleNameNode _name;
    private BasicBlockReferenceNode _unwindBlock;
    private NoNullList!InstructionNode _instructions;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_instructions);
    }

    public this(SourceLocation location, SimpleNameNode name, BasicBlockReferenceNode unwindBlock, NoNullList!InstructionNode instructions,
                MetadataListNode metadata)
    in
    {
        assert(name);
        assert(instructions);
    }
    body
    {
        super(location);

        _name = name;
        _unwindBlock = unwindBlock;
        _instructions = instructions.duplicate();
        _metadata = metadata;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public final BasicBlockReferenceNode unwindBlock() pure nothrow
    {
        return _unwindBlock;
    }

    @property public final ReadOnlyIndexable!InstructionNode instructions() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _instructions;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(concat(toReadOnlyIndexable!Node(_name, _unwindBlock), castItems!Node(_instructions), toReadOnlyIndexable!Node(_metadata)));
    }
}

public class RegisterReferenceNode : Node
{
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_name);
    }
}

public class BasicBlockReferenceNode : Node
{
    private SimpleNameNode _name;

    pure nothrow invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_name);
    }
}

public class BranchSelectorNode : Node
{
    private BasicBlockReferenceNode _trueBlock;
    private BasicBlockReferenceNode _falseBlock;

    pure nothrow invariant()
    {
        assert(_trueBlock);
        assert(_falseBlock);
    }

    public this(SourceLocation location, BasicBlockReferenceNode trueBlock, BasicBlockReferenceNode falseBlock) pure nothrow
    in
    {
        assert(trueBlock);
        assert(falseBlock);
    }
    body
    {
        super(location);

        _trueBlock = trueBlock;
        _falseBlock = falseBlock;
    }

    @property public final BasicBlockReferenceNode trueBlock() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _trueBlock;
    }

    @property public final BasicBlockReferenceNode falseBlock() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _falseBlock;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_trueBlock, _falseBlock);
    }
}

public class RegisterSelectorNode : Node
{
    private NoNullList!RegisterReferenceNode _registers;

    pure nothrow invariant()
    {
        assert(_registers);
    }

    public this(SourceLocation location, NoNullList!RegisterReferenceNode registers)
    in
    {
        assert(registers);
    }
    body
    {
        super(location);

        _registers = registers.duplicate();
    }

    @property public final ReadOnlyIndexable!RegisterReferenceNode registers() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _registers;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(castItems!Node(_registers));
    }
}

public class LiteralValueNode : Node
{
    private string _value;

    pure nothrow invariant()
    {
        assert(_value);
    }

    public this(SourceLocation location, string value) pure nothrow
    in
    {
        assert(value);
    }
    body
    {
        super(location);

        _value = value;
    }

    @property public final string value() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }

    public override string toString()
    {
        return "value: " ~ value;
    }
}

public class ArrayLiteralNode : Node
{
    private NoNullList!LiteralValueNode _values;

    pure nothrow invariant()
    {
        assert(_values);
    }

    public this(SourceLocation location, NoNullList!LiteralValueNode values)
    in
    {
        assert(values);
    }
    body
    {
        super(location);

        _values = values.duplicate();
    }

    @property public final ReadOnlyIndexable!LiteralValueNode values() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _values;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return new List!Node(castItems!Node(_values));
    }
}

public class FFISignatureNode : Node
{
    private SimpleNameNode _library;
    private SimpleNameNode _entryPoint;

    pure nothrow invariant()
    {
        assert(_library);
        assert(_entryPoint);
    }

    public this(SourceLocation location, SimpleNameNode library, SimpleNameNode entryPoint) pure nothrow
    in
    {
        assert(library);
        assert(entryPoint);
    }
    body
    {
        super(location);

        _library = library;
        _entryPoint = entryPoint;
    }

    @property public final SimpleNameNode library() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _library;
    }

    @property public final SimpleNameNode entryPoint() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _entryPoint;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_library, _entryPoint);
    }
}

public alias Algebraic!(LiteralValueNode,
                        ArrayLiteralNode,
                        TypeReferenceNode,
                        FieldReferenceNode,
                        FunctionReferenceNode,
                        BasicBlockReferenceNode,
                        BranchSelectorNode,
                        RegisterSelectorNode,
                        FFISignatureNode) InstructionOperand;

public class InstructionOperandNode : Node
{
    private InstructionOperand _operand;

    pure nothrow invariant()
    {
        assert(_operand.hasValue);
    }

    public this(SourceLocation location, InstructionOperand operand)
    in
    {
        assert(operand.hasValue);
    }
    body
    {
        super(location);

        _operand = operand;
    }

    @property public final InstructionOperand operand() pure nothrow
    out (result)
    {
        assert(result.hasValue);
    }
    body
    {
        return _operand;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_operand.coerce!Node());
    }
}

public class InstructionNode : Node
{
    private OpCode _opCode;
    private RegisterReferenceNode _target;
    private RegisterReferenceNode _source1;
    private RegisterReferenceNode _source2;
    private RegisterReferenceNode _source3;
    private InstructionOperandNode _operand;
    private MetadataListNode _metadata;

    pure nothrow invariant()
    {
        assert(_opCode);
    }

    public this(SourceLocation location, OpCode opCode, RegisterReferenceNode target,
                RegisterReferenceNode source1, RegisterReferenceNode source2, RegisterReferenceNode source3,
                InstructionOperandNode operand, MetadataListNode metadata) pure nothrow
    in
    {
        assert(opCode);
    }
    body
    {
        super(location);

        _opCode = opCode;
        _target = target;
        _source1 = source1;
        _source2 = source2;
        _source3 = source3;
        _operand = operand;
        _metadata = metadata;
    }

    @property public final OpCode opCode() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _opCode;
    }

    @property public final RegisterReferenceNode target() pure nothrow
    {
        return _target;
    }

    @property public final RegisterReferenceNode source1() pure nothrow
    {
        return _source1;
    }

    @property public final RegisterReferenceNode source2() pure nothrow
    {
        return _source2;
    }

    @property public final RegisterReferenceNode source3() pure nothrow
    {
        return _source3;
    }

    @property public final InstructionOperandNode operand() pure nothrow
    {
        return _operand;
    }

    @property public final MetadataListNode metadata() pure nothrow
    {
        return _metadata;
    }

    @property public override ReadOnlyIndexable!Node children()
    {
        return toReadOnlyIndexable!Node(_target, _source1, _source2, _source3, _operand, _metadata);
    }

    public override string toString()
    {
        return "opcode: " ~ _opCode.name ~ "/" ~ to!string(_opCode.code);
    }
}
