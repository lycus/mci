module mci.core.code.functions;

import mci.core.container,
       mci.core.code.instructions;

public final class BasicBlock
{
    private NoNullList!Instruction _instructions;
    
    public this()
    {
        _instructions = new NoNullList!Instruction();
    }
    
    @property public NoNullList!Instruction instructions()
    {
        return _instructions;
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
}

public final class Function
{
    public FunctionAttributes attributes;
    public CallingConvention callingConvention;
    private string _name;
    private NoNullList!BasicBlock _blocks;
    
    public this(string name, BasicBlock entry)
    in
    {
        assert(name);
        assert(entry);
    }
    body
    {
        _name = name;
        _blocks = new NoNullList!BasicBlock();
        _blocks.add(entry);
    }
    
    @property public NoNullList!BasicBlock blocks()
    {
        return _blocks;
    }
    
    @property public BasicBlock entry()
    {
        return _blocks.get(0);
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
}
