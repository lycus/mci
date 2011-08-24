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

public final class Function
{
    private NoNullList!BasicBlock _blocks;
    
    public this(BasicBlock entry)
    in
    {
        assert(entry);
    }
    body
    {
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
}
