module mci.core.code.functions;

import mci.core.common,
       mci.core.container,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.tree.statements,
       mci.core.typing.types;

public final class BasicBlock
{
    private string _name;
    private NoNullList!Instruction _instructions;

    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _instructions = new typeof(_instructions)();
    }

    @property public istring name()
    {
        return _name;
    }

    @property public NoNullList!Instruction instructions()
    {
        return _instructions;
    }
}

public enum string entryBlockName = "entry";

public final class Parameter
{
    private Register _register;

    public this(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _register = register;
    }

    @property public Register register()
    {
        return _register;
    }
}

public enum CallingConvention : ubyte
{
    queueCall = 0,
    cdecl = 1,
    stdCall = 2,
    thisCall = 3,
    fastCall = 4,
}

public enum FunctionAttributes : ubyte
{
    none = 0x00,
    intrinsic = 0x01,
    readOnly = 0x02,
    noOptimization = 0x04,
    noInlining = 0x08,
    noCallInlining = 0x10,
}

public final class Function
{
    private FunctionAttributes _attributes;
    private CallingConvention _callingConvention;
    private Module _module;
    private string _name;
    private NoNullList!Parameter _parameters;
    private Type _returnType;
    private NoNullList!BasicBlock _blocks;
    private NoNullList!Register _registers;

    protected this(Module module_, string name, Type returnType, NoNullList!Parameter parameters,
                   FunctionAttributes attributes = FunctionAttributes.none,
                   CallingConvention callingConvention = CallingConvention.queueCall)
    in
    {
        assert(module_);
        assert(name);
        assert(returnType);
        assert(parameters);
    }
    body
    {
        _module = module_;
        _name = name;
        _returnType = returnType;
        _parameters = parameters.duplicate();
        _attributes = attributes;
        _callingConvention = callingConvention;
        _blocks = new typeof(_blocks)();
        _registers = new typeof(_registers)();

        (cast(NoNullList!Function)module_.functions).add(this);
    }

    @property public Module module_()
    {
        return _module;
    }

    @property public istring name()
    {
        return _name;
    }

    @property public Type returnType()
    {
        return _returnType;
    }

    @property public FunctionAttributes attributes()
    {
        return _attributes;
    }

    @property public CallingConvention callingConvention()
    {
        return _callingConvention;
    }

    @property public Countable!Parameter parameters()
    {
        return _parameters;
    }

    @property public NoNullList!BasicBlock blocks()
    {
        return _blocks;
    }

    @property public NoNullList!Register registers()
    {
        return _registers;
    }
}
