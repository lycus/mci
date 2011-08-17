module mci.core.container;

import std.algorithm,
       std.range;

public interface Enumerable(T)
{
    public int opApply(int delegate(ref T) dg);
    
    public int opApply(int delegate(ref size_t, ref T) dg);
}

public interface Collection(T) : Enumerable!T
{
    @property public size_t count()
    out (result)
    {
        assert(result >= 0);
    }
    
    @property public bool empty()
    out (result)
    {
        if (count == 0)
            assert(result);
    }
    
    public void add(T item);
    
    public void remove(T item);
    
    public void clear();
}

public class Array(T) : Collection!T
{
    private T[] _array;
    
    // For compatibility with std.container and similar.
    alias _array this;
    
    public int opApply(int delegate(ref T) dg)
    {
        foreach (item; _array)
        {
            auto status = dg(item);
            
            if (status != 0)
                return status;
        }
        
        return 0;
    }
    
    public int opApply(int delegate(ref size_t, ref T) dg)
    {
        foreach (i, item; _array)
        {
            auto status = dg(i, item);
            
            if (status != 0)
                return status;
        }
        
        return 0;
    }
    
    @property public size_t count()
    {
        return _array.length;
    }
    
    @property public bool empty()
    {
        return _array.empty;
    }
    
    public void add(T item)
    {
        _array ~= item;
    }
    
    public void remove(T item)
    {
        auto index = _array.countUntil(item);
        
        if (index != -1)
            _array = _array[0 .. index] ~ _array[index + 1 .. $];
    }
    
    public void clear()
    {
        _array.clear();
    }
}
