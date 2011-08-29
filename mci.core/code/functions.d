module mci.core.code.functions;

import mci.core.container,
       mci.core.code.instructions,
       mci.core.tree.statements,
       mci.core.typing.types;

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

public class Parameter
{
    private string _name;
    private Type _type;
    
    public this(string name, Type type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
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
    
    @property public final Type type()
    {
        return _type;
    }
    
    @property public final void type(Type type)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
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

public abstract class Function
{
    public FunctionAttributes attributes;
    public CallingConvention callingConvention;
    private string _name;
    private NoNullList!Parameter _parameters;
    private Type _returnType;
    
    protected this(string name, Type returnType)
    in
    {
        assert(name);
        assert(returnType);
    }
    body
    {
        _name = name;
        _returnType = returnType;
        _parameters = new NoNullList!Parameter();
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
    
    @property public final NoNullList!Parameter parameters()
    {
        return _parameters;
    }
}

public class CodeFunction : Function
{
    private NoNullList!BasicBlock _blocks;
    
    public this(string name, Type returnType)
    in
    {
        assert(name);
        assert(returnType);
    }
    body
    {
        super(name, returnType);
        
        _blocks = new NoNullList!BasicBlock();
    }
    
    @property public final NoNullList!BasicBlock blocks()
    {
        return _blocks;
    }
}

public class TreeFunction : Function
{
    private BlockNode _tree;
    
    public this(string name, Type returnType, BlockNode tree)
    in
    {
        assert(name);
        assert(returnType);
        assert(tree);
    }
    body
    {
        super(name, returnType);
    }
    
    @property public final BlockNode tree()
    {
        return _tree;
    }
    
    @property public void tree(BlockNode tree)
    in
    {
        assert(tree);
    }
    body
    {
        _tree = tree;
    }
}
