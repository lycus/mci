module mci.core.container;

import core.exception,
       std.algorithm,
       std.exception,
       std.range,
       std.traits,
       mci.core.tuple;

public interface Iterable(T)
{
    public int opApply(int delegate(ref T) dg);
    
    public int opApply(int delegate(ref size_t, ref T) dg);
}

public interface Countable(T) : Iterable!T
{
    @property public size_t count()
    out (result)
    {
        assert(result >= 0);
        
        if (empty)
            assert(!result);
    }
    
    @property public bool empty()
    out (result)
    {
        if (count == 0)
            assert(result);
    }
}

public interface Collection(T) : Iterable!T
{
    public void add(T item);
    
    public void remove(T item);
    
    public void clear();
}

public interface Map(K, V) : Collection!(Tuple!(K, V))
{
    public void add(K key, V value)
    in
    {
        static if (__traits(compiles, { K k = null; }))
            assert(key);
    }
    
    public void remove(K key)
    in
    {
        static if (__traits(compiles, { K k = null; }))
            assert(key);
    }
    
    public Iterable!K keys();
    
    public Iterable!V values();
}

public void addRange(T, V)(Collection!T col, V values)
    if (isIterable!V)
{
    foreach (i; values)
        col.add(i);
}

unittest
{
    auto list = new List!int();
    
    addRange(list, [1, 2, 3]);
    
    assert(list[0] == 1);
    assert(list[1] == 2);
    assert(list[2] == 3);
    assert(list.count == 3);
}

public void removeRange(T, V)(Collection!T col, V values)
    if (isIterable!V)
{
    foreach (i; values)
        col.remove(i);
}

unittest
{
    auto list = new List!int();
    
    addRange(list, [1, 2, 3, 4, 5, 6]);
    removeRange(list, [2, 3, 4, 5]);
    
    assert(list[0] == 1);
    assert(list[1] == 6);
    assert(list.count == 2);
}

public class List(T) : Collection!T
{
    private T[] _array;
    
    // For compatibility with std.container and similar.
    alias _array this;
    
    public final int opApply(int delegate(ref T) dg)
    {
        foreach (item; _array)
        {
            auto status = dg(item);
            
            if (status != 0)
                return status;
        }
        
        return 0;
    }
    
    public final int opApply(int delegate(ref size_t, ref T) dg)
    {
        foreach (i, item; _array)
        {
            auto status = dg(i, item);
            
            if (status != 0)
                return status;
        }
        
        return 0;
    }
    
    @property public final size_t count()
    {
        return _array.length;
    }
    
    @property public final bool empty()
    {
        return _array.empty;
    }
    
    public final void add(T item)
    {
        onAdd(item);
        
        _array ~= item;
    }
    
    public final void remove(T item)
    {
        onRemove(item);
        
        auto index = _array.countUntil(item);
        
        if (index != -1)
            _array = _array[0 .. index] ~ _array[index + 1 .. $];
    }
    
    public final void clear()
    {
        onClear();
        
        _array.clear();
    }
    
    protected void onAdd(T item)
    {
    }
    
    protected void onRemove(T item)
    {
    }
    
    protected void onClear()
    {
    }
}

unittest
{
    auto list = new List!int();
    
    list.add(1);
    list.add(2);
    list.add(3);
    
    assert(list.count == 3);
}

unittest
{
    auto list = new List!int();
    
    list.add(1);
    list.add(2);
    
    list.remove(2);
    
    assert(list.count == 1);
}

unittest
{
    auto list = new List!int();
    
    list.add(1);
    list.add(2);
    list.add(3);
    
    list.remove(2);
    
    assert(list[0] == 1);
    assert(list[1] == 3);
}

unittest
{
    auto list = new List!int();
    
    list.add(1);
    list.add(2);
    list.add(3);
    
    list.clear();
    
    assert(list.count == 0);
}

public class NoNullList(T) : List!T
{
    protected override void onAdd(T item)
    {
        static if (__traits(compiles, { T t = null; }))
            assert(item);
    }
    
    protected override void onRemove(T item)
    {
        static if (__traits(compiles, { T t = null; }))
            assert(item);
    }
}

unittest
{
    auto list = new NoNullList!string();
    
    assertThrown!AssertError(list.add(null));
}

unittest
{
    auto list = new NoNullList!string();
    
    assertThrown!AssertError(list.remove(null));
}

unittest
{
    auto list = new NoNullList!string();
    
    list.add("foo");
    list.add("bar");
    list.add("baz");
}

public class Dictionary(K, V) : Map!(K, V)
{
    private V[K] _aa;
    
    // For compatibility with std.container and similar.
    alias _aa this;
    
    public final int opApply(int delegate(ref Tuple!(K, V)) dg)
    {
        foreach (k, v; _aa)
        {
            auto status = dg(Tuple!(K, V)(k, v));
            
            if (status != 0)
                return status;
        }
        
        return 0;
    }
    
    public final int opApply(int delegate(ref size_t, ref Tuple!(K, V)) dg)
    {
        size_t i = 0;
        
        foreach (k, v; _aa)
        {
            auto status = dg(i, Tuple!(K, V)(k, v));
            
            if (status != 0)
                return status;
            
            i++;
        }
        
        return 0;
    }
    
    @property public final size_t count()
    {
        return _aa.length;
    }
    
    @property public final bool empty()
    {
        return _aa.length == 0;
    }
    
    public final void add(Tuple!(K, V) item)
    {
        add(item.x, item.y);
    }
    
    public final void remove(Tuple!(K, V) item)
    {
        remove(item.x);
    }
    
    public final void clear()
    {
        onClear();
        
        _aa = null;
    }
    
    public final void add(K key, V value)
    {
        onAdd(key, value);
        
        _aa[key] = value;
    }
    
    public final void remove(K key)
    {
        onRemove(key);
        
        _aa.remove(key);
    }
    
    public final Iterable!K keys()
    {
        auto arr = new List!K();
        
        foreach (k; _aa)
            arr.add(k);
        
        return arr;
    }
    
    public final Iterable!V values()
    {
        auto arr = new List!K();
        
        foreach (v; _aa.values)
            arr.add(v);
        
        return arr;
    }
    
    protected void onAdd(K key, V value)
    {
    }
    
    protected void onRemove(K key)
    {
    }
    
    protected void onClear()
    {
    }
}

unittest
{
    auto dict = new Dictionary!(int, int)();
    
    dict.add(1, 3);
    dict.add(2, 2);
    dict.add(3, 1);
    
    assert(dict.count == 3);
}

unittest
{
    auto dict = new Dictionary!(int, int)();
    
    dict.add(1, 3);
    dict.add(2, 2);
    dict.add(3, 1);
    
    dict.clear();
    
    assert(dict.count == 0);
}

unittest
{
    auto dict = new Dictionary!(int, int)();
    
    dict.add(1, 3);
    dict.add(2, 2);
    dict.add(3, 1);
    
    dict.remove(2);
    
    assert(dict[1] == 3);
    assert(dict[3] == 1);
    assert(dict.count == 2);
}
