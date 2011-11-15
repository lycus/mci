module mci.core.container;

import core.exception,
       std.algorithm,
       std.exception,
       std.range,
       std.traits,
       mci.core.meta,
       mci.core.tuple;

public interface Iterable(T)
{
    public int opApply(scope int delegate(ref T) dg)
    in
    {
        assert(dg);
    }

    public int opApply(scope int delegate(ref size_t, ref T) dg)
    in
    {
        assert(dg);
    }
}

public interface Countable(T) : Iterable!T
{
    @property public size_t count();

    @property public bool empty();

    public Countable!T duplicate();
}

public interface Collection(T) : Countable!T
{
    public T* opBinaryRight(string op : "in")(T item);

    public void add(T item);

    public void remove(T item);

    public void clear();
}

public interface Indexable(T) : Collection!T
{
    public T opIndex(size_t index);

    public T opIndexAssign(T item, size_t index);
}

public interface Map(K, V) : Collection!(Tuple!(K, V))
{
    public V* opBinaryRight(string op : "in")(K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public V opIndex(K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public V opIndexAssign(V value, K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public override void add(Tuple!(K, V) item)
    in
    {
        static if (isNullable!K)
            assert(item.x);
    }

    public override void remove(Tuple!(K, V) item)
    in
    {
        static if (isNullable!K)
            assert(item.x);
    }

    public void add(K key, V value)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public void remove(K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public Countable!K keys();

    public Countable!V values();
}

public void addRange(T, V)(Collection!T col, V values)
    if (isIterable!V)
in
{
    assert(col);
    assert(values);
}
body
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
in
{
    assert(col);
    assert(values);
}
body
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

public bool contains(T)(Iterable!T iter, T value)
in
{
    assert(iter);
}
body
{
    foreach (item; iter)
        if (item == value)
            return true;

    return false;
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(contains(list, 1));
    assert(contains(list, 2));
    assert(contains(list, 3));
}

unittest
{
    auto list = new List!int();

    assert(!contains(list, 1));
}

public class List(T) : Indexable!T
{
    private T[] _array;

    public final int opApply(scope int delegate(ref T) dg)
    {
        foreach (item; _array)
        {
            auto status = dg(item);

            if (status != 0)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(ref size_t, ref T) dg)
    {
        foreach (i, item; _array)
        {
            auto status = dg(i, item);

            if (status != 0)
                return status;
        }

        return 0;
    }

    public final T* opBinaryRight(string op : "in")(T item)
    {
        foreach (obj; _array)
            if (obj == item)
                return &obj;

        return null;
    }

    public final T opIndex(size_t index)
    {
        return _array[index];
    }

    public final T opIndexAssign(T item, size_t index)
    {
        onAdd(item);

        return _array[index] = item;
    }

    public final override bool opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto list = cast(List!T)o)
            return _array == list._array;

        return false;
    }

    @property public final size_t count()
    {
        return _array.length;
    }

    @property public final bool empty()
    {
        return _array.empty;
    }

    public List!T duplicate()
    {
        auto l = new List!T();
        l._array = _array.dup;

        return l;
    }

    public final void add(T item)
    {
        onAdd(item);

        _array ~= item;
    }

    public final void remove(T item)
    {
        onRemove(item);

        size_t index;

        for (size_t i = 0; i < _array.length; i++)
        {
            bool eq;

            // Here's an ugly hack for interfaces because, for whatever reason, one cannot
            // compare interface instances without casting them to a concrete type.
            static if (is(T == interface))
                eq = cast(Object)_array[i] == cast(Object)item;
            else
                eq = _array[i] == item;

            if (eq)
            {
                index = i;
                break;
            }
        }

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

    assert(list.empty);
}

public List!T toList(T)(T[] items ...)
{
    auto list = new List!T();

    foreach (item; items)
        list.add(item);

    return list;
}

unittest
{
    auto list = toList(1, 2, 3);

    assert(list[0] == 1);
    assert(list[1] == 2);
    assert(list[2] == 3);
}

public Countable!T toCountable(T)(T[] items ...)
{
    return toList(items);
}

public Countable!T asCountable(T)(Countable!T items)
{
    return items;
}

unittest
{
    auto list = toCountable(1, 2, 3);

    assert(list);
}

public Iterable!T toIterable(T)(T[] items ...)
{
    return toCountable(items);
}

unittest
{
    auto list = toIterable(1, 2, 3);

    assert(list);
}

public class NoNullList(T) : List!T
{
    public override NoNullList!T duplicate()
    {
        auto l = new NoNullList!T();
        l._array = _array;

        return l;
    }

    protected override void onAdd(T item)
    {
        static if (isNullable!T)
            assert(item);
    }

    protected override void onRemove(T item)
    {
        static if (isNullable!T)
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

public NoNullList!T toNoNullList(T)(Iterable!T iter)
{
    auto l = new NoNullList!T();

    foreach (obj; iter)
        l.add(obj);

    return l;
}

public NoNullList!T toNoNullList(T)(T[] items ...)
{
    auto list = new NoNullList!T();

    foreach (item; items)
        list.add(item);

    return list;
}

public class Dictionary(K, V) : Map!(K, V)
{
    private V[K] _aa;

    public final int opApply(scope int delegate(ref Tuple!(K, V)) dg)
    {
        foreach (k, v; _aa)
        {
            auto tup = tuple(k, v);
            auto status = dg(tup);

            if (status != 0)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(ref size_t, ref Tuple!(K, V)) dg)
    {
        size_t i = 0;

        foreach (k, v; _aa)
        {
            auto tup = tuple(k, v);
            auto status = dg(i, tup);

            if (status != 0)
                return status;

            i++;
        }

        return 0;
    }

    public V opIndex(K key)
    {
        return _aa[key];
    }

    public V opIndexAssign(V value, K key)
    {
        onAdd(key, value);

        return _aa[key] = value;
    }

    public override bool opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto dict = cast(Dictionary!(K, V))o)
            return _aa == dict._aa;

        return false;
    }

    public final V* opBinaryRight(string op : "in")(K key)
    {
        return key in _aa;
    }

    @property public final size_t count()
    {
        return _aa.length;
    }

    @property public final bool empty()
    {
        return _aa.length == 0;
    }

    public Dictionary!(K, V) duplicate()
    {
        auto d = new Dictionary!(K, V)();
        d._aa = _aa.dup;

        return d;
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

    public final Countable!K keys()
    {
        auto arr = new List!K();

        foreach (k; _aa.keys)
            arr.add(k);

        return arr;
    }

    public final Countable!V values()
    {
        auto arr = new List!V();

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
    auto dict = new Dictionary!(int, string)();

    dict.add(1, "a");
    dict.add(2, "b");
    dict.add(3, "c");

    dict.remove(2);

    assert(dict[1] == "a");
    assert(dict[3] == "c");
    assert(dict.count == 2);
}

public class NoNullDictionary(K, V) : Dictionary!(K, V)
{
    public override NoNullDictionary!(K, V) duplicate()
    {
        auto d = new NoNullDictionary!(K, V)();
        d._aa = _aa.dup;

        return d;
    }

    protected override void onAdd(K key, V value)
    {
        static if (isNullable!V)
            assert(value);
    }
}
