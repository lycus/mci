module mci.core.code.functions;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.code.stream,
       mci.core.typing.types,
       mci.core.utilities;

public final class BasicBlock
{
    private Function _function;
    private string _name;
    private BasicBlock _unwindBlock;
    private InstructionStream _stream;
    private bool _isClosed;

    invariant()
    {
        assert(_function);
        assert(_name);
        // We can't assert _stream here as this would create a circular dependency.
    }

    private this(Function function_, string name)
    in
    {
        assert(function_);
        assert(name);
    }
    body
    {
        _function = function_;
        _name = name;
        _stream = new typeof(_stream)(this);
    }

    @property public Function function_()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
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

    @property public BasicBlock unwindBlock()
    in
    {
        assert(_isClosed);
    }
    body
    {
        return _unwindBlock;
    }

    @property public void unwindBlock(BasicBlock unwindBlock)
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _unwindBlock = unwindBlock;
    }

    @property public InstructionStream stream()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    @property public bool isClosed()
    {
        return _isClosed;
    }

    public void close()
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _isClosed = true;
    }

    public override string toString()
    {
        return escapeIdentifier(_name);
    }
}

public enum string entryBlockName = "entry";

public final class Parameter
{
    private Function _function;
    private Type _type;

    invariant()
    {
        assert(_function);
        assert(_type);
    }

    private this(Function function_, Type type)
    in
    {
        assert(function_);
        assert(type);
    }
    body
    {
        _function = function_;
        _type = type;
    }

    @property public Function function_()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    @property public Type type()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    public override string toString()
    {
        return _type.toString();
    }
}

public enum FunctionAttributes : ubyte
{
    none = 0x00,
    intrinsic = 0x01,
    ssa = 0x02,
    pure_ = 0x04,
    noOptimization = 0x08,
    noInlining = 0x10,
}

public final class Function
{
    private CallingConvention _callingConvention;
    private FunctionAttributes _attributes;
    private Module _module;
    private string _name;
    private NoNullList!Parameter _parameters;
    private Type _returnType;
    private NoNullDictionary!(string, BasicBlock) _blocks;
    private NoNullDictionary!(string, Register) _registers;
    private bool _isClosed;

    invariant()
    {
        assert(_module);
        assert(_name);
        assert(_parameters);
        assert(_blocks);
        assert(_registers);
    }

    public this(Module module_, string name, Type returnType, CallingConvention callingConvention = CallingConvention.standard,
                FunctionAttributes attributes = FunctionAttributes.none)
    in
    {
        assert(module_);
        assert(name);
        assert(!module_.functions.get(name));
    }
    body
    {
        _module = module_;
        _name = name;
        _returnType = returnType;
        _callingConvention = callingConvention;
        _attributes = attributes;
        _parameters = new typeof(_parameters)();
        _blocks = new typeof(_blocks)();
        _registers = new typeof(_registers)();

        (cast(Dictionary!(string, Function))module_.functions)[name] = this;
    }

    @property public Module module_()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _module;
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

    @property public Type returnType()
    {
        return _returnType;
    }

    @property public CallingConvention callingConvention()
    {
        return _callingConvention;
    }

    @property public FunctionAttributes attributes()
    {
        return _attributes;
    }

    @property public ReadOnlyIndexable!Parameter parameters()
    in
    {
        assert(_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _parameters;
    }

    @property public bool isClosed()
    {
        return _isClosed;
    }

    @property public Lookup!(string, BasicBlock) blocks()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _blocks;
    }

    @property public Lookup!(string, Register) registers()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _registers;
    }

    public override string toString()
    {
        return _module.toString() ~ "/" ~ escapeIdentifier(_name);
    }

    public Parameter createParameter(Type type)
    in
    {
        assert(type);
        assert(!_isClosed);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        // We keep the Parameter class around for now, since it may
        // come in handy later for specifying attributes.
        auto param = new Parameter(this, type);
        _parameters.add(param);

        return param;
    }

    public void close()
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _isClosed = true;
    }

    public BasicBlock createBasicBlock(string name)
    in
    {
        assert(name);
        assert(name !in _blocks);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _blocks[name] = new BasicBlock(this, name);
    }

    public void removeBasicBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _blocks.remove(block.name);
    }

    public Register createRegister(string name, Type type)
    in
    {
        assert(name);
        assert(type);
        assert(name !in _registers);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _registers[name] = new Register(this, name, type);
    }

    public void removeRegister(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _registers.remove(register.name);
    }
}

public enum CallingConvention : ubyte
{
    standard = 0,
    cdecl = 1,
    stdCall = 2,
}

public final class FFISignature
{
    private string _library;
    private string _entryPoint;

    invariant()
    {
        assert(_library);
        assert(_entryPoint);
    }

    public this(string library, string entryPoint)
    in
    {
        assert(library);
        assert(entryPoint);
    }
    body
    {
        _library = library;
        _entryPoint = entryPoint;
    }

    @property public string library()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _library;
    }

    @property public string entryPoint()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _entryPoint;
    }

    public override string toString()
    {
        return escapeIdentifier(_library) ~ ", " ~ escapeIdentifier(_entryPoint);
    }
}
