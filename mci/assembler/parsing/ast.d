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
    private Dictionary!(string, Object) _tags;

    protected this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        _location = location;
        _tags = new Dictionary!(string, Object)();
    }

    @property public final SourceLocation location()
    {
        return _location;
    }

    @property public final Dictionary!(string, Object) tags()
    {
        return _tags;
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

    @property public string name()
    {
        return _name;
    }
}

public class ModuleReferenceNode : Node
{
    private SimpleNameNode _name;

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
        _parameterTypes = parameterTypes;
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

private mixin template CoreTypeReferenceNode(string type)
{
    mixin("public class " ~ type ~ "TypeReferenceNode : TypeReferenceNode" ~
          "{" ~
          "    public this(SourceLocation location)" ~
          "    in" ~
          "    {" ~
          "        assert(location);" ~
          "    }" ~
          "    body" ~
          "    {" ~
          "        super(location);" ~
          "    }" ~
          "}");
}

mixin CoreTypeReferenceNode!("Unit");
mixin CoreTypeReferenceNode!("Int8");
mixin CoreTypeReferenceNode!("UInt8");
mixin CoreTypeReferenceNode!("Int16");
mixin CoreTypeReferenceNode!("UInt16");
mixin CoreTypeReferenceNode!("Int32");
mixin CoreTypeReferenceNode!("UInt32");
mixin CoreTypeReferenceNode!("Int64");
mixin CoreTypeReferenceNode!("UInt64");
mixin CoreTypeReferenceNode!("NativeInt");
mixin CoreTypeReferenceNode!("NativeUInt");
mixin CoreTypeReferenceNode!("Float32");
mixin CoreTypeReferenceNode!("Float64");
mixin CoreTypeReferenceNode!("NativeFloat");

public class FieldReferenceNode : Node
{
    private StructureTypeReferenceNode _typeName;
    private SimpleNameNode _name;

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
    private TypeReferenceNode _returnType;
    private NoNullList!TypeReferenceNode _parameterTypes;

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name,
                TypeReferenceNode returnType, NoNullList!TypeReferenceNode parameterTypes)
    in
    {
        assert(location);
        assert(name);
        assert(returnType);
        assert(parameterTypes);
    }
    body
    {
        super(location);

        _moduleName = moduleName;
        _name = name;
        _returnType = returnType;
        _parameterTypes = parameterTypes;
    }

    @property public final ModuleReferenceNode moduleName()
    {
        return _moduleName;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public TypeReferenceNode returnType()
    {
        return _returnType;
    }

    @property public Countable!TypeReferenceNode parameterTypes()
    {
        return _parameterTypes;
    }
}

public class TypeDeclarationNode : DeclarationNode
{
    private SimpleNameNode _name;
    private TypeAttributes _attributes;
    private TypeLayout _layout;
    private LiteralValueNode _packingSize;
    private NoNullList!FieldDeclarationNode _fields;

    public this(SourceLocation location, SimpleNameNode name, TypeAttributes attributes,
                TypeLayout layout, LiteralValueNode packingSize, NoNullList!FieldDeclarationNode fields)
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
        _attributes = attributes;
        _layout = layout;
        _packingSize = packingSize;
        _fields = fields;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final TypeAttributes attributes()
    {
        return _attributes;
    }

    @property public final TypeLayout layout()
    {
        return _layout;
    }

    @property public final LiteralValueNode packingSize()
    {
        return _packingSize;
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
    private FieldAttributes _attributes;
    private LiteralValueNode _value;

    public this(SourceLocation location, TypeReferenceNode type, SimpleNameNode name,
                FieldAttributes attributes, LiteralValueNode value)
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
        _attributes = attributes;
        _value = value;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
    }

    @property public final FieldAttributes attributes()
    {
        return _attributes;
    }

    @property public final LiteralValueNode value()
    {
        return _value;
    }
}

public class ParameterNode : Node
{
    private TypeReferenceNode _type;
    private SimpleNameNode _name;

    public this(SourceLocation location, TypeReferenceNode type, SimpleNameNode name)
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
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }

    @property public final SimpleNameNode name()
    {
        return _name;
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
        _parameters = parameters;
        _returnType = returnType;
        _registers = registers;
        _blocks = blocks;
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
        _instructions = instructions;
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

public class RegisterListNode : Node
{
    private NoNullList!(Tuple!(BasicBlockReferenceNode, RegisterReferenceNode)) _registers;

    public this(SourceLocation location,
                NoNullList!(Tuple!(BasicBlockReferenceNode, RegisterReferenceNode)) registers)
    in
    {
        assert(location);
        assert(registers);
    }
    body
    {
        super(location);

        _registers = registers;
    }

    @property public final Countable!(Tuple!(BasicBlockReferenceNode, RegisterReferenceNode)) registers()
    {
        return _registers;
    }
}

public class LiteralValueNode : Node
{
    private string _value;

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

    public this(SourceLocation location, NoNullList!LiteralValueNode values)
    in
    {
        assert(location);
        assert(values);
    }
    body
    {
        super(location);

        _values = values;
    }

    @property public final NoNullList!LiteralValueNode values()
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
                 RegisterListNode) InstructionOperand;

public class InstructionOperandNode : Node
{
    private InstructionOperand _operand;

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
        _operand = operand;
    }
}
