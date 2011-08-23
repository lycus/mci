module mci.core.code.functions;

import mci.core.container,
       mci.core.code.instructions;

public final class BasicBlock
{
    private List!Instruction _instructions;
    
    public this()
    {
        _instructions = new List!Instruction();
    }
    
    @property public List!Instruction instructions()
    {
        return _instructions;
    }
}

public final class Function
{
    private List!BasicBlock _blocks;
    
    public this()
    {
        _blocks = new List!BasicBlock();
    }
    
    @property public List!BasicBlock blocks()
    {
        return _blocks;
    }
}
