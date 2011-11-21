module mci.assembler.parsing.ast;

import std.variant,
       mci.core.container,
       mci.core.nullable,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.opcodes,
       mci.core.diagnostics.debugging,
       mci.core.typing.members,
       mci.core.typing.types;

public abstract class Node
{
    private SourceLocation _location;

    invariant()
    {
        assert(_location);
    }

    protected this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        _location = location;
    }

    @property public final SourceLocation location()
    {
        return _location;
    }
}

public abstract class DeclarationNode : Node
{
    protected this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        super(location);
    }
}

public class SimpleNameNode : Node
{
    private string _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, string name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final string name()
    {
        return _name;
    }
}

public class ModuleReferenceNode : Node
{
    private SimpleNameNode _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public abstract class TypeReferenceNode : Node
{
    public this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        super(location);
    }
}

public class StructureTypeReferenceNode : TypeReferenceNode
{
    private ModuleReferenceNode _moduleName;
    private SimpleNameNode _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _moduleName = moduleName;
        _name = name;
    }

    @property public final ModuleReferenceNode moduleName()
    {
        return _moduleName;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class PointerTypeReferenceNode : TypeReferenceNode
{
    private TypeReferenceNode _elementType;

    invariant()
    {
        assert(_elementType);
    }

    public this(SourceLocation location, TypeReferenceNode elementType)
    in
    {
        assert(location);
        assert(elementType);
    }
    body
    {
        super(location);

        _elementType = elementType;
    }

    @property public final TypeReferenceNode elementType()
    {
        return _elementType;
    }
}

public class FunctionPointerTypeReferenceNode : TypeReferenceNode
{
    private TypeReferenceNode _returnType;
    private NoNullList!TypeReferenceNode _parameterTypes;

    invariant()
    {
        assert(_returnType);
        assert(_parameterTypes);
    }

    public this(SourceLocation location, TypeReferenceNode returnType,
                NoNullList!TypeReferenceNode parameterTypes)
    in
    {
        assert(location);
        assert(returnType);
        assert(parameterTypes);
    }
    body
    {
        super(location);

        _returnType = returnType;
        _parameterTypes = parameterTypes.duplicate();
    }

    @property public final TypeReferenceNode returnType()
    {
        return _returnType;
    }

    @property public final Countable!TypeReferenceNode parameterTypes()
    {
        return _parameterTypes;
    }
}

public abstract class CoreTypeReferenceNode : TypeReferenceNode
{
    public this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        super(location);
    }

    @property public abstract SimpleNameNode name();
}

private mixin template DefineCoreTypeNode(string type, string name)
{
    mixin("public class " ~ type ~ "TypeReferenceNode : CoreTypeReferenceNode" ~
          "{" ~
          "    private SimpleNameNode _name;" ~
          "" ~
          "    invariant()" ~
          "    {" ~
          "        assert(_name);" ~
          "    }" ~
          "" ~
          "    public this(SourceLocation location)" ~
          "    in" ~
          "    {" ~
          "        assert(location);" ~
          "    }" ~
          "    body" ~
          "    {" ~
          "        super(location);" ~
          "" ~
          "        _name = new SimpleNameNode(location, \"" ~ name ~ "\");" ~
          "    }" ~
          "" ~
          "    @property public final override SimpleNameNode name()" ~
          "    {" ~
          "        return _name;" ~
          "    }" ~
          "}");
}

mixin DefineCoreTypeNode!("Unit", "unit");
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

    invariant()
    {
        assert(_typeName);
        assert(_name);
    }

    public this(SourceLocation location, StructureTypeReferenceNode typeName, SimpleNameNode name)
    in
    {
        assert(location);
        assert(typeName);
        assert(name);
    }
    body
    {
        super(location);

        _typeName = typeName;
        _name = name;
    }

    @property public final StructureTypeReferenceNode typeName()
    {
        return _typeName;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class FunctionReferenceNode : Node
{
    private ModuleReferenceNode _moduleName;
    private SimpleNameNode _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _moduleName = moduleName;
        _name = name;
    }

    @property public final ModuleReferenceNode moduleName()
    {
        return _moduleName;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class TypeDeclarationNode : DeclarationNode
{
    private SimpleNameNode _name;
    private TypeLayout _layout;
    private NoNullList!FieldDeclarationNode _fields;

    invariant()
    {
        assert(_name);
        assert(_fields);
    }

    public this(SourceLocation location, SimpleNameNode name, TypeLayout layout, NoNullList!FieldDeclarationNode fields)
    in
    {
        assert(location);
        assert(name);
        assert(fields);
    }
    body
    {
        super(location);

        _name = name;
        _layout = layout;
        _fields = fields.duplicate();
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final TypeLayout layout()
    {
        return _layout;
    }

    @property public final Countable!FieldDeclarationNode fields()
    {
        return _fields;
    }
}

public class FieldDeclarationNode : Node
{
    private TypeReferenceNode _type;
    private SimpleNameNode _name;
    private FieldStorage _storage;
    private LiteralValueNode _offset;

    invariant()
    {
        assert(_type);
        assert(_name);
    }

    public this(SourceLocation location, TypeReferenceNode type, SimpleNameNode name,
                FieldStorage storage, LiteralValueNode offset)
    in
    {
        assert(location);
        assert(type);
        assert(name);
    }
    body
    {
        super(location);

        _type = type;
        _name = name;
        _storage = storage;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final FieldStorage storage()
    {
        return _storage;
    }

    @property public final LiteralValueNode offset()
    {
        return _offset;
    }
}

public class ParameterNode : Node
{
    private TypeReferenceNode _type;

    invariant()
    {
        assert(_type);
    }

    public this(SourceLocation location, TypeReferenceNode type)
    in
    {
        assert(location);
        assert(type);
    }
    body
    {
        super(location);

        _type = type;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }
}

public class FunctionDeclarationNode : DeclarationNode
{
    private SimpleNameNode _name;
    private FunctionAttributes _attributes;
    private CallingConvention _callingConvention;
    private NoNullList!ParameterNode _parameters;
    private TypeReferenceNode _returnType;
    private NoNullList!RegisterDeclarationNode _registers;
    private NoNullList!BasicBlockDeclarationNode _blocks;

    invariant()
    {
        assert(_name);
        assert(_parameters);
        assert(_returnType);
        assert(_registers);
        assert(_blocks);
    }

    public this(SourceLocation location, SimpleNameNode name, FunctionAttributes attributes,
                CallingConvention callingConvention, NoNullList!ParameterNode parameters,
                TypeReferenceNode returnType, NoNullList!RegisterDeclarationNode registers,
                NoNullList!BasicBlockDeclarationNode blocks)
    in
    {
        assert(location);
        assert(name);
        assert(parameters);
        assert(returnType);
        assert(registers);
        assert(blocks);
    }
    body
    {
        super(location);

        _name = name;
        _attributes = attributes;
        _callingConvention = callingConvention;
        _parameters = parameters.duplicate();
        _returnType = returnType;
        _registers = registers.duplicate();
        _blocks = blocks.duplicate();
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final FunctionAttributes attributes()
    {
        return _attributes;
    }

    @property public final CallingConvention callingConvention()
    {
        return _callingConvention;
    }

    @property public final Countable!ParameterNode parameters()
    {
        return _parameters;
    }

    @property public final TypeReferenceNode returnType()
    {
        return _returnType;
    }

    @property public final Countable!RegisterDeclarationNode registers()
    {
        return _registers;
    }

    @property public final Countable!BasicBlockDeclarationNode blocks()
    {
        return _blocks;
    }
}

public class RegisterDeclarationNode : Node
{
    private SimpleNameNode _name;
    private TypeReferenceNode _type;

    invariant()
    {
        assert(_name);
        assert(_type);
    }

    public this(SourceLocation location, SimpleNameNode name, TypeReferenceNode type)
    in
    {
        assert(location);
        assert(name);
        assert(type);
    }
    body
    {
        super(location);

        _name = name;
        _type = type;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }
}

public class BasicBlockDeclarationNode : Node
{
    private SimpleNameNode _name;
    private NoNullList!InstructionNode _instructions;

    invariant()
    {
        assert(_name);
        assert(_instructions);
    }

    public this(SourceLocation location, SimpleNameNode name, NoNullList!InstructionNode instructions)
    in
    {
        assert(location);
        assert(name);
        assert(instructions);
    }
    body
    {
        super(location);

        _name = name;
        _instructions = instructions.duplicate();
    }

    @property public final Countable!InstructionNode instructions()
    {
        return _instructions;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class RegisterReferenceNode : Node
{
    private SimpleNameNode _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class BasicBlockReferenceNode : Node
{
    private SimpleNameNode _name;

    invariant()
    {
        assert(_name);
    }

    public this(SourceLocation location, SimpleNameNode name)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }
}

public class RegisterSelectorNode : Node
{
    private NoNullList!RegisterReferenceNode _registers;

    invariant()
    {
        assert(_registers);
    }

    public this(SourceLocation location, NoNullList!RegisterReferenceNode registers)
    in
    {
        assert(location);
        assert(registers);
    }
    body
    {
        super(location);

        _registers = registers.duplicate();
    }

    @property public final Countable!RegisterReferenceNode registers()
    {
        return _registers;
    }
}

public class LiteralValueNode : Node
{
    private string _value;

    invariant()
    {
        assert(_value);
    }

    public this(SourceLocation location, string value)
    in
    {
        assert(location);
        assert(value);
    }
    body
    {
        super(location);

        _value = value;
    }

    @property public final string value()
    {
        return _value;
    }
}

public class ByteArrayLiteralNode : Node
{
    private NoNullList!LiteralValueNode _values;

    invariant()
    {
        assert(_values);
    }

    public this(SourceLocation location, NoNullList!LiteralValueNode values)
    in
    {
        assert(location);
        assert(values);
    }
    body
    {
        super(location);

        _values = values.duplicate();
    }

    @property public final Countable!LiteralValueNode values()
    {
        return _values;
    }
}

alias Algebraic!(LiteralValueNode,
                 ByteArrayLiteralNode,
                 TypeReferenceNode,
                 StructureTypeReferenceNode,
                 FieldReferenceNode,
                 FunctionReferenceNode,
                 FunctionPointerTypeReferenceNode,
                 BasicBlockReferenceNode,
                 RegisterSelectorNode) InstructionOperand;

public class InstructionOperandNode : Node
{
    private InstructionOperand _operand;

    invariant()
    {
        assert(_operand.hasValue);
    }

    public this(SourceLocation location, InstructionOperand operand)
    in
    {
        assert(location);
        assert(operand.hasValue);
    }
    body
    {
        super(location);

        _operand = operand;
    }

    @property public final InstructionOperand operand()
    {
        return _operand;
    }
}

public class InstructionNode : Node
{
    private OpCode _opCode;
    private RegisterReferenceNode _target;
    private RegisterReferenceNode _source1;
    private RegisterReferenceNode _source2;
    private InstructionOperandNode _operand;

    invariant()
    {
        assert(_opCode);
    }

    public this(SourceLocation location, OpCode opCode, RegisterReferenceNode target,
                RegisterReferenceNode source1, RegisterReferenceNode source2, InstructionOperandNode operand)
    in
    {
        assert(location);
        assert(opCode);
    }
    body
    {
        super(location);

        _opCode = opCode;
        _target = target;
        _source1 = source1;
        _source2 = source2;
        _operand = operand;
    }

    @property public final OpCode opCode()
    {
        return _opCode;
    }

    @property public final RegisterReferenceNode target()
    {
        return _target;
    }

    @property public final RegisterReferenceNode source1()
    {
        return _source1;
    }

    @property public final RegisterReferenceNode source2()
    {
        return _source2;
    }

    @property public final InstructionOperandNode operand()
    {
        return _operand;
    }
}
