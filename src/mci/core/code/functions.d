module mci.core.code.functions;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.code.metadata,
       mci.core.code.modules,
       mci.core.code.stream,
       mci.core.typing.types,
       mci.core.utilities;

/**
 * Represents a straight line of instructions that will
 * always execute fully, except when an exception is thrown
 * inside the block. All well-formed basic blocks must end
 * in a terminator instruction which performs some kind of
 * control flow (like jumping to a different basic block).
 *
 * Every function must have a basic block with the name
 * $(D entryBlockName), which is where control enters in
 * a function.
 */
public final class BasicBlock
{
    private Function _function;
    private string _name;
    private BasicBlock _unwindBlock;
    private InstructionStream _stream;
    private bool _isClosed;
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_function);
        assert(_name);
        assert(_metadata);
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
        _metadata = new typeof(_metadata)();
        _stream = new typeof(_stream)(this);
    }

    /**
     * Gets the function this basic block is in.
     *
     * Returns:
     *  The function this basic block is in.
     */
    @property public Function function_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    /**
     * Gets the name of this basic block.
     *
     * Returns:
     *  The name of this basic block.
     */
    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    /**
     * Gets the unwind basic block associated with
     * this basic block, if any.
     *
     * This function cannot be called before the
     * basic block has been closed.
     *
     * Returns:
     *  The unwind basic block associated with this
     *  basic block, or $(D null) if none.
     */
    @property public BasicBlock unwindBlock() pure nothrow
    in
    {
        assert(_isClosed);
    }
    body
    {
        return _unwindBlock;
    }

    /**
     * Sets the unwind basic block associated with
     * this basic block, if any.
     *
     * Control transfers to a basic block's unwind
     * block if some kind of operation inside the
     * basic block resulted in an exception being
     * thrown.
     *
     * Params:
     *  unwindBlock = The unwind basic block to
     *                associate with this block.
     */
    @property public void unwindBlock(BasicBlock unwindBlock) pure nothrow
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _unwindBlock = unwindBlock;
    }

    /**
     * Gets the instruction stream of this basic
     * block.
     *
     * Returns:
     *  The instruction stream of this basic block.
     */
    @property public InstructionStream stream() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _stream;
    }

    /**
     * Indicates whether this basic block is closed.
     *
     * Returns:
     *  $(D true) if this basic block is closed;
     *  otherwise, $(D false).
     */
    @property public bool isClosed() pure nothrow
    {
        return _isClosed;
    }

    /**
     * Returns the metadata list of this basic block.
     *
     * Returns:
     *  This basic block's metadata list.
     */
    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    /**
     * Closes this basic block.
     *
     * Altering the unwind block of this basic
     * block will be illegal once this function
     * has been called.
     */
    public void close() pure nothrow
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

public enum string entryBlockName = "entry"; /// The name of the entry basic block of all functions.

/**
 * Various attributes of a parameter.
 */
public enum ParameterAttributes : ubyte
{
    none = 0x00, /// No attributes.
    noEscape = 0x01, /// The parameter is guaranteed to not escape beyond the stack frame.
}

/**
 * Represents a parameter of a function.
 */
public final class Parameter
{
    private Function _function;
    private Type _type;
    private ParameterAttributes _attributes;
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_function);
        assert(_type);
        assert(_metadata);
    }

    private this(Function function_, Type type, ParameterAttributes attributes)
    in
    {
        assert(function_);
        assert(type);
    }
    body
    {
        _function = function_;
        _type = type;
        _attributes = attributes;
        _metadata = new typeof(_metadata)();
    }

    /**
     * Gets the function this parameter belongs to.
     *
     * Returns:
     *  The function this parameter belongs to.
     */
    @property public Function function_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _function;
    }

    /**
     * Gets the type of this parameter.
     *
     * Returns:
     *  The type of this parameter.
     */
    @property public Type type() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _type;
    }

    /**
     * Gets the attributes of this parameter.
     *
     * Returns:
     *  The attributes of this parameter.
     */
    @property public ParameterAttributes attributes() pure nothrow
    {
        return _attributes;
    }

    /**
     * Gets the metadata list of this parameter.
     *
     * Returns:
     *  This parameter's metadata list.
     */
    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    public override string toString()
    {
        return _type.toString();
    }
}

/**
 * Various attributes of a function.
 */
public enum FunctionAttributes : ubyte
{
    none = 0x00, /// No attributes.
    intrinsic = 0x01, /// The function is an intrinsic.
    ssa = 0x02, /// The function is in SSA form.
    pure_ = 0x04, /// The function alters no state visible outside of it and doesn't depend on any global state.
    noOptimization = 0x08, /// The function must not be optimized.
    noInlining = 0x10, /// The function must not be inlined.
    noReturn = 0x20, /// The function never returns via a terminator instruction.
    noThrow = 0x40, /// The function cannot throw any exceptions.
}

/**
 * Represents an IAL function.
 */
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
    private List!MetadataPair _metadata;

    pure nothrow invariant()
    {
        assert(_module);
        assert(_name);
        assert(_parameters);
        assert(_blocks);
        assert(_registers);
        assert(_metadata);
    }

    /**
     * Constructs a new $(D Function) instance.
     *
     * It is a logic error if a function named $(D name)
     * already exists in $(D module_).
     *
     * Params:
     *  module_ = The module this function belongs to.
     *  name = The name of this function.
     *  returnType = The return type of this function. May
     *               be $(D null) if $(PRE void).
     *  callingConvention = The ABI to use when invoking
     *                      this function.
     *  attributes = Attributes of the function.
     */
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
        _metadata = new typeof(_metadata)();

        (cast(NoNullDictionary!(string, Function))module_.functions)[name] = this;
    }

    /**
     * Gets the module that this function belongs to.
     *
     * Returns:
     *  The module that this function belongs to.
     */
    @property public Module module_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _module;
    }

    /**
     * Gets the unique name of this function.
     *
     * Returns:
     *  The unique name of this function.
     */
    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    /**
     * Gets the return type of this function.
     *
     * Returns:
     *  The return type of this function, or $(D null)
     *  if the return type is $(PRE void).
     */
    @property public Type returnType() pure nothrow
    {
        return _returnType;
    }

    /**
     * Gets the ABI to use when invoking this function.
     *
     * Returns:
     *  The ABI to use when invoking this function.
     */
    @property public CallingConvention callingConvention() pure nothrow
    {
        return _callingConvention;
    }

    /**
     * Gets the attributes of this function.
     *
     * Returns:
     *  The attributes of this function.
     */
    @property public FunctionAttributes attributes() pure nothrow
    {
        return _attributes;
    }

    /**
     * Gets the parameters of this function.
     *
     * This function cannot be called before the
     * function instance has been closed.
     *
     * Returns:
     *  The parameters of this function.
     */
    @property public ReadOnlyIndexable!Parameter parameters() pure nothrow
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

    /**
     * Indicates whether this function is closed.
     *
     * Returns:
     *  $(D true) if this function is closed; otherwise,
     *  $(D false).
     */
    @property public bool isClosed() pure nothrow
    {
        return _isClosed;
    }

    /**
     * Retrieves all basic blocks in this function.
     *
     * Returns:
     *  All basic blocks in this function.
     */
    @property public Lookup!(string, BasicBlock) blocks() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _blocks;
    }

    /**
     * Retrieves all registers in this function.
     *
     * Returns:
     *  All registers in this function.
     */
    @property public Lookup!(string, Register) registers() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _registers;
    }

    /**
     * Gets the metadata list of this function.
     *
     * Returns:
     *  This function's metadata list.
     */
    @property public List!MetadataPair metadata() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _metadata;
    }

    /**
     * Creates a new parameter in the function.
     *
     * The parameter is appended to the existing
     * parameter list.
     *
     * Params:
     *  type = The type of the parameter.
     *  attributes = Attributes of the parameter.
     *
     * Returns:
     *  The newly created parameter.
     */
    public Parameter createParameter(Type type, ParameterAttributes attributes)
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
        auto param = new Parameter(this, type, attributes);

        _parameters.add(param);

        return param;
    }

    /**
     * Closes this function.
     *
     * Once the function is closed, no further
     * changes can be made to its parameters.
     */
    public void close() pure nothrow
    in
    {
        assert(!_isClosed);
    }
    body
    {
        _isClosed = true;
    }

    /**
     * Creates a new basic block in this function.
     *
     * The name of the basic block must be unique
     * within this function.
     *
     * Params:
     *  name = The name of the basic block.
     *
     * Returns:
     *  The newly created basic block.
     */
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

    /**
     * Removes the given basic block from the function.
     *
     * If $(D block) is not inside this function, no
     * action is taken.
     *
     * Params:
     *  block = The basic block to remove.
     */
    public void removeBasicBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _blocks.remove(block.name);
    }

    /**
     * Creates a register in this function.
     *
     * The name of the register must be unique within
     * this function.
     *
     * Params:
     *  name = The name of the register.
     *  type = The type of the register.
     *
     * Returns:
     *  The newly created register.
     */
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

    /**
     * Removes a register from this function.
     *
     * If $(D register) is not within this function,
     * no action is taken.
     *
     * Params:
     *  register = The register to remove.
     */
    public void removeRegister(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _registers.remove(register.name);
    }

    public override string toString()
    {
        return _module.toString() ~ "/" ~ escapeIdentifier(_name);
    }
}

/**
 * Represents the calling convention of
 * a function.
 */
public enum CallingConvention : ubyte
{
    standard = 0, /// The MCI ABI. Not valid on FFI functions.
    cdecl = 1, /// The platform's native C ABI.
    stdCall = 2, /// The $(PRE stdcall) convention on Windows.
}

/**
 * Represents the signature of an FFI invocation.
 */
public final class FFISignature
{
    private string _library;
    private string _entryPoint;

    pure nothrow invariant()
    {
        assert(_library);
        assert(_entryPoint);
    }

    /**
     * Constructs a new $(D FFISignature) instance.
     *
     * Params:
     *  library = The library to search in.
     *  entryPoint = The procedure to search for.
     */
    public this(string library, string entryPoint) pure nothrow
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

    /**
     * Gets the library to search in.
     *
     * Returns:
     *  The library to search in.
     */
    @property public string library() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _library;
    }

    /**
     * Gets the procedure to search for.
     *
     * Returns:
     *  The procedure to search for.
     */
    @property public string entryPoint() pure nothrow
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
