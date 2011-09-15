module mci.assembler.parsing.ast;

import std.variant,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.diagnostics.debugging,
       mci.core.typing.generics,
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

public class TypeReferenceNode : Node
{
    private ModuleReferenceNode _moduleName;
    private SimpleNameNode _name;

    public this(SourceLocation location, ModuleReferenceNode moduleName, SimpleNameNode name)
    in
    {
        assert(location);
        assert(moduleName);
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

public class FieldReferenceNode : Node
{
    private TypeReferenceNode _typeName;
    private SimpleNameNode _name;

    public this(SourceLocation location, TypeReferenceNode typeName, SimpleNameNode name)
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

    @property public final TypeReferenceNode typeName()
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
        assert(moduleName);
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
    private string _name;
    private TypeAttributes _attributes;
    private TypeLayout _layout;
    private uint _packingSize;
    private NoNullList!GenericParameterNode _genericParameters;
    private NoNullList!FieldDeclarationNode _fields;

    public this(SourceLocation location, string name, TypeAttributes attributes,
                TypeLayout layout, uint packingSize,
                NoNullList!GenericParameterNode genericParameters,
                NoNullList!FieldDeclarationNode fields)
    in
    {
        assert(location);
        assert(name);
        assert(packingSize);
        assert(genericParameters);
        assert(fields);
    }
    body
    {
        super(location);

        _name = name;
        _attributes = attributes;
        _layout = layout;
        _packingSize = packingSize;
        _genericParameters = genericParameters;
        _fields = fields;
    }

    @property public final string name()
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

    @property public final uint packingSize()
    {
        return _packingSize;
    }

    @property public final Countable!GenericParameterNode genericParameters()
    {
        return _genericParameters;
    }

    @property public final Countable!FieldDeclarationNode fields()
    {
        return _fields;
    }
}

public class GenericParameterNode : Node
{
    private string _name;
    private GenericParameterVariance _variance;
    private GenericParameterConstraint _constraint;

    public this(SourceLocation location, string name, GenericParameterVariance variance,
                GenericParameterConstraint constraint)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
        _variance = variance;
        _constraint = constraint;
    }

    @property public final string name()
    {
        return _name;
    }

    @property public final GenericParameterVariance variance()
    {
        return _variance;
    }

    @property public final GenericParameterConstraint constraint()
    {
        return _constraint;
    }
}

public class FieldDeclarationNode : Node
{
    private string _name;
    private FieldAttributes _attributes;

    public this(SourceLocation location, string name, FieldAttributes attributes)
    in
    {
        assert(location);
        assert(name);
    }
    body
    {
        super(location);

        _name = name;
        _attributes = attributes;
    }

    @property public final string name()
    {
        return _name;
    }

    @property public final FieldAttributes attributes()
    {
        return _attributes;
    }
}

public class ParameterNode : Node
{
    private string _name;
    private TypeReferenceNode _type;

    public this(SourceLocation location, string name, TypeReferenceNode type)
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

    @property public final string name()
    {
        return _name;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }
}

public class FunctionDeclarationNode : DeclarationNode
{
    private string _name;
    private FunctionAttributes _attributes;
    private CallingConvention _callingConvention;
    private NoNullList!ParameterNode _parameters;
    private TypeReferenceNode _returnType;
    private NoNullList!RegisterDeclarationNode _registers;
    private NoNullList!BasicBlockNode _blocks;

    public this(SourceLocation location, string name, FunctionAttributes attributes,
                CallingConvention callingConvention, NoNullList!ParameterNode parameters,
                TypeReferenceNode returnType, NoNullList!RegisterDeclarationNode registers,
                NoNullList!BasicBlockNode blocks)
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

    @property public final string name()
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

    @property public final Countable!BasicBlockNode blocks()
    {
        return _blocks;
    }
}

public class RegisterDeclarationNode : Node
{
    private string _name;
    private TypeReferenceNode _type;

    public this(SourceLocation location, string name, TypeReferenceNode type)
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

    @property public final string name()
    {
        return _name;
    }

    @property public final TypeReferenceNode type()
    {
        return _type;
    }
}

public class BasicBlockNode : Node
{
    private string _name;
    private NoNullList!InstructionNode _instructions;

    public this(SourceLocation location, string name, NoNullList!InstructionNode instructions)
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

    @property public final string name()
    {
        return _name;
    }
}

public class RegisterReferenceNode : Node
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
}

public class BasicBlockReferenceNode : Node
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
}

alias Algebraic!(TypeReferenceNode,
                 FieldReferenceNode,
                 FunctionReferenceNode,
                 LiteralValueNode,
                 BasicBlockReferenceNode,
                 Countable!(Tuple!(BasicBlockReferenceNode, RegisterReferenceNode))) InstructionOperandNode;

public class InstructionNode : Node
{
    private RegisterReferenceNode _target;
    private RegisterReferenceNode _source1;
    private RegisterReferenceNode _source2;
    private InstructionOperandNode _operand;

    public this(SourceLocation location, RegisterReferenceNode target, RegisterReferenceNode source1,
                RegisterReferenceNode source2, InstructionOperandNode operand)
    in
    {
        assert(location);
    }
    body
    {
        super(location);

        _operand = operand;
    }
}
