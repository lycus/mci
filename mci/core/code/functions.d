module mci.core.code.functions;

import mci.core.container,
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
        _instructions = new NoNullList!Instruction();
    }

    @property public string name()
    {
        return _name;
    }

    @property public void name(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }

    @property public NoNullList!Instruction instructions()
    {
        return _instructions;
    }
}

public enum string entryBlockName = "entry";

public class Parameter
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

    @property public final Register register()
    {
        return _register;
    }

    @property public final void register(Register register)
    in
    {
        assert(register);
    }
    body
    {
        _register = register;
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

public class Function
{
    public FunctionAttributes attributes;
    public CallingConvention callingConvention;
    private Module _module;
    private string _name;
    private NoNullList!Parameter _parameters;
    private Type _returnType;
    private NoNullList!BasicBlock _blocks;
    private NoNullList!Register _registers;

    protected this(Module module_, string name, Type returnType)
    in
    {
        assert(module_);
        assert(name);
        assert(returnType);
    }
    body
    {
        _module = module_;
        _name = name;
        _returnType = returnType;
        _parameters = new NoNullList!Parameter();
        _blocks = new NoNullList!BasicBlock();
        _registers = new NoNullList!Register();
    }

    @property public final Module module_()
    {
        return _module;
    }

    @property package final void module_(Module module_)
    in
    {
        assert(module_);
    }
    body
    {
        if (module_ !is _module)
        {
            (cast(NoNullList!Function)_module.functions).remove(this);
            (cast(NoNullList!Function)module_.functions).add(this);
        }

        _module = module_;
    }

    @property public final string name()
    {
        return _name;
    }

    @property public final void name(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }

    @property public final NoNullList!Parameter parameters()
    {
        return _parameters;
    }

    @property public final NoNullList!BasicBlock blocks()
    {
        return _blocks;
    }

    @property public final NoNullList!Register registers()
    {
        return _registers;
    }
}
