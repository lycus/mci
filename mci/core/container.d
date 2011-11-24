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
    public T* opBinaryRight(string op : "in")(T item)
    in
    {
        assert(item);
    }

    public void add(T item);

    public void remove(T item);

    public void clear();
}

public interface Indexable(T) : Collection!T
{
    public T opIndex(size_t index);

    public T opIndexAssign(T item, size_t index);

    public Indexable!T opSlice();

    public Indexable!T opSlice(size_t x, size_t y);

    public Indexable!T opCat(Indexable!T rhs);

    public Indexable!T opCatAssign(Indexable!T rhs);
}

public interface Lookup(K, V) : Countable!(Tuple!(K, V))
{
    public V opIndex(K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    // TODO: Turn this into an opBinaryRight!"in" when the compiler is fixed.
    public V* get(K key)
    in
    {
        static if (isNullable!K)
            assert(key);
    }

    public Countable!K keys()
    out (result)
    {
        assert(result);
    }

    public Countable!V values()
    out (result)
    {
        assert(result);
    }
}

public interface Map(K, V) : Lookup!(K, V), Collection!(Tuple!(K, V))
{
    public override Tuple!(K, V)* opBinaryRight(string op : "in")(Tuple!(K, V) item)
    in
    {
        static if (isNullable!K)
            assert(item.x);
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
}

public interface Queue(T) : Countable!T
{
    public void enqueue(T item);

    public T dequeue();

    public T* peek();
}

public Iterable!T asIterable(T)(Iterable!T items)
{
    return items;
}

public Countable!T asCountable(T)(Countable!T items)
{
    return items;
}

public Collection!T asCollection(T)(Collection!T items)
{
    return items;
}

public Indexable!T asIndexable(T)(Indexable!T items)
{
    return items;
}

public Lookup!(K, V) asLookup(K, V)(Lookup!(K, V) items)
{
    return items;
}

public Map!(K, V) asMap(K, V)(Map!(K, V) items)
{
    return items;
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

public bool contains(T)(Iterable!T iter, scope bool delegate(T) criteria)
in
{
    assert(iter);
    assert(criteria);
}
body
{
    foreach (item; iter)
        if (criteria(item))
            return true;

    return false;
}

unittest
{
    auto list = new List!int();

    list.add(2);

    assert(contains(list, (int x) { return x == 2; }));
    assert(!contains(list, (int x) { return x == 3; }));
}

public bool all(T)(Iterable!T iter, scope bool delegate(T) criteria)
in
{
    assert(iter);
    assert(criteria);
}
body
{
    foreach (item; iter)
        if (!criteria(item))
            return false;

    return true;
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(all(list, (int x) { return x != 0; }));
    assert(!all(list, (int x) { return x == 2; }));
}

public T find(T)(Iterable!T iter, scope bool delegate(T) criteria, lazy T defaultValue = T.init)
in
{
    assert(iter);
    assert(criteria);
}
body
{
    foreach (item; iter)
        if (criteria(item))
            return item;

    return defaultValue;
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(find(list, (int x) { return x == 1; }) == 1);
    assert(find(list, (int x) { return x == 2; }) == 2);
    assert(find(list, (int x) { return x == 3; }) == 3);
    assert(find(list, (int x) { return x == 4; }) == int.init);
    assert(find(list, (int x) { return x == 5; }, 6) == 6);
}

public Iterable!R map(T, R)(Iterable!T iter, scope R delegate(T) selector)
in
{
    assert(iter);
    assert(selector);
}
out (result)
{
    assert(result);
}
body
{
    auto results = new List!R();

    foreach (item; iter)
        results.add(selector(item));

    return results;
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    auto list2 = new List!int((map(list, (int x) { return x * x; })));

    assert(list2[0] == 1);
    assert(list2[1] == 4);
    assert(list2[2] == 9);
}

public R aggregate(T, R)(Iterable!T iter, scope R delegate(R, T) selector, R seed = R.init)
in
{
    assert(iter);
    assert(selector);
}
out (result)
{
    assert(result);
}
body
{
    auto result = seed;

    foreach (item; iter)
        result = selector(result, item);

    return result;
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(aggregate(list, (int x, int y) { return x + y; }) == 6);
}

public Iterable!T concat(T)(Iterable!T iter, Iterable!T other)
in
{
    assert(iter);
    assert(other);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new List!T();

    foreach (item; iter)
        list.add(item);

    foreach (item; other)
        list.add(item);

    return list;
}

unittest
{
    auto list1 = new List!int();

    list1.add(1);
    list1.add(2);
    list1.add(3);

    auto list2 = new List!int();

    list2.add(4);
    list2.add(5);

    auto list3 = new List!int(concat(list1, list2));

    assert(list3[0] == 1);
    assert(list3[1] == 2);
    assert(list3[2] == 3);
    assert(list3[3] == 4);
    assert(list3[4] == 5);
}

public Iterable!T filter(T)(Iterable!T iter, scope bool delegate(T) filter)
in
{
    assert(iter);
    assert(filter);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new List!T();

    foreach (item; iter)
        if (filter(item))
            list.add(item);

    return list;
}

unittest
{
    auto list = new List!string();

    list.add("foo");
    list.add(null);
    list.add("bar");
    list.add("baz");
    list.add(null);

    auto list2 = filter(list, (string s) { return s != null; });

    assert(all(list2, (string s) { return s != null; }));
}

public bool isEmpty(T)(Iterable!T iter)
in
{
    assert(iter);
}
body
{
    foreach (item; iter)
        return false;

    return true;
}

unittest
{
    auto list1 = new List!int();

    assert(isEmpty(list1));
}

unittest
{
    auto list2 = new List!int();

    list2.add(2);
    list2.add(5);

    assert(!isEmpty(list2));
}

public size_t count(T)(Iterable!T iter)
in
{
    assert(iter);
}
body
{
    size_t count;

    foreach (item; iter)
        count++;

    return count;
}

unittest
{
    auto list1 = new List!int();

    assert(count(list1) == 0);
}

unittest
{
    auto list2 = new List!int();

    list2.add(1);
    list2.add(2);
    list2.add(3);

    assert(count(list2) == 3);
}

public Iterable!R castItems(R, T)(Iterable!T iter)
in
{
    assert(iter);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new List!R();

    foreach (item; iter)
        list.add(cast(R)item);

    return list;
}

public Iterable!R ofType(R, T)(Iterable!T iter)
in
{
    assert(iter);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new List!R();

    foreach (item; iter)
        if (auto casted = cast(R)item)
            list.add(casted);

    return list;
}

public bool equal(T)(Iterable!T iter, Iterable!T other)
in
{
    assert(iter);
    assert(other);
}
body
{
    auto list1 = new List!T(iter);
    auto list2 = new List!T(other);

    if (list1.count != list2.count)
        return false;

    for (size_t i = 0; i < list1.count; i++)
        if (list1[i] != list2[i])
            return false;

    return true;
}

unittest
{
    auto list1 = toList(1, 2, 3);
    auto list2 = toList(1, 2, 3);

    assert(equal(list1, list2));
}

unittest
{
    auto list1 = toList(1, 2, 3);
    auto list2 = toList(4, 5, 6);

    assert(!equal(list1, list2));
}

unittest
{
    auto list1 = toList(1, 2, 3);
    auto list2 = toList(4, 5);

    assert(!equal(list1, list2));
}

public class List(T) : Indexable!T
{
    private T[] _array;

    public this()
    {
    }

    public this(Iterable!T items)
    in
    {
        assert(items);
    }
    body
    {
        foreach (item; items)
            add(item);
    }

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

        if (index >= _array.length)
            _array.length = index + 1;

        return _array[index] = item;
    }

    public List!T opSlice()
    {
        return duplicate();
    }

    public List!T opSlice(size_t x, size_t y)
    {
        auto list = new List!T();

        for (size_t i = x; i < y; i++)
            list.add(this[i]);

        return list;
    }

    public List!T opCat(Indexable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public List!T opCatAssign(Indexable!T rhs)
    {
        foreach (item; rhs)
            add(item);

        return this;
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
out (result)
{
    assert(result);
}
body
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
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

unittest
{
    auto list = toCountable(1, 2, 3);

    assert(list);
}

public Iterable!T toIterable(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toCountable(items);
}

unittest
{
    auto list = toIterable(1, 2, 3);

    assert(list);
}

public class NoNullList(T)
    if (isNullable!T) : List!T
{
    public this()
    {
    }

    public this(Iterable!T items)
    in
    {
        assert(items);
    }
    body
    {
        foreach (item; items)
            add(item);
    }

    public override NoNullList!T opSlice()
    {
        return duplicate();
    }

    public override NoNullList!T opSlice(size_t x, size_t y)
    {
        auto list = new NoNullList!T();

        for (size_t i = x; i < y; i++)
            list.add(this[i]);

        return list;
    }

    public override NoNullList!T opCat(Indexable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public override NoNullList!T opCatAssign(Indexable!T rhs)
    {
        foreach (item; rhs)
            add(item);

        return this;
    }

    public override NoNullList!T duplicate()
    {
        auto l = new NoNullList!T();
        l._array = _array.dup;

        return l;
    }

    protected override void onAdd(T item)
    {
        assert(item);
    }

    protected override void onRemove(T item)
    {
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
in
{
    assert(iter);
}
out (result)
{
    assert(result);
}
body
{
    auto l = new NoNullList!T();

    foreach (obj; iter)
        l.add(obj);

    return l;
}

public class Dictionary(K, V) : Map!(K, V)
{
    private V[K] _aa;

    public this()
    {
    }

    public this(Map!(K, V) items)
    in
    {
        assert(items);
    }
    body
    {
        foreach (item; items)
            add(item);
    }

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

    public final V opIndex(K key)
    {
        return _aa[key];
    }

    public final V opIndexAssign(V value, K key)
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

    public V* get(K key)
    {
        return key in _aa;
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

public class NoNullDictionary(K, V)
    if (isNullable!V) : Dictionary!(K, V)
{
    public this()
    {
    }

    public this(Map!(K, V) items)
    in
    {
        assert(items);
    }
    body
    {
        foreach (item; items)
            add(item);
    }

    public override NoNullDictionary!(K, V) duplicate()
    {
        auto d = new NoNullDictionary!(K, V)();
        d._aa = _aa.dup;

        return d;
    }

    protected override void onAdd(K key, V value)
    {
        assert(value);
    }
}

public NoNullDictionary!(K, V) toNullDictionary(K, V)(Iterable!(Tuple!(K, V)) iter)
in
{
    assert(iter);
}
out (result)
{
    assert(result);
}
body
{
    auto d = new NoNullDictionary!(K, V)();

    foreach (item; iter)
        d.add(item);

    return d;
}

public class ArrayQueue(T) : Queue!T
{
    private List!T _list;
    private size_t _size;
    private size_t _tail;
    private size_t _head;

    public this()
    {
        _list = new typeof(_list);
    }

    public this(Iterable!T items)
    in
    {
        assert(items);
    }
    body
    {
        this();

        foreach (item; items)
            enqueue(item);
    }

    public final int opApply(scope int delegate(ref T) dg)
    {
        for (size_t i = _head; i < _size; i++)
        {
            auto item = _list[i];
            auto status = dg(item);

            if (status != 0)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(ref size_t, ref T) dg)
    {
        for (size_t i = _head; i < _size; i++)
        {
            auto item = _list[i];
            auto status = dg(i, item);

            if (status != 0)
                return status;
        }

        return 0;
    }

    public final override bool opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto q = cast(ArrayQueue!T)o)
        {
            if (_size != q._size || _head != q._head || _tail != q._tail)
                return false;

            for (size_t i = _head; i < _size; i++)
                if (_list[i] != q._list[i])
                    return false;

            return true;
        }

        return false;
    }

    @property public final size_t count()
    {
        return _size;
    }

    @property public final bool empty()
    {
        return !_size;
    }

    public ArrayQueue!T duplicate()
    {
        auto q = new ArrayQueue!T();

        q._list = _list.duplicate();
        q._size = _size;
        q._tail = _tail;
        q._head = _head;

        return q;
    }

    public void enqueue(T item)
    {
        if (_size == _list.count)
        {
            _list.add(T.init);
            _head = 0;
            _tail = _size == _list.count ? 0 : _size;
        }

        _list[_tail] = item;
        _tail = (_tail + 1) % _list.count;
        _size++;
    }

    public T dequeue()
    {
        auto item = _list[_head];

        _list[_head] = T.init;
        _head = (_head + 1) % _list.count;
        _size--;

        return item;
    }

    public T* peek()
    {
        if (!_size)
            return null;

        return &_list._array[_head];
    }
}

unittest
{
    auto q = new ArrayQueue!int();

    q.enqueue(1);
    q.enqueue(2);
    q.enqueue(3);

    assert(q.dequeue() == 1);
    assert(q.dequeue() == 2);
    assert(q.dequeue() == 3);
}

unittest
{
    auto q = new ArrayQueue!int();

    assert(q.empty);
    assert(!q.count);
}

unittest
{
    auto q = new ArrayQueue!int();

    q.enqueue(1);

    assert(!q.empty);
    assert(q.count == 1);
}

unittest
{
    auto q = new ArrayQueue!int();

    assert(!q.peek());
}

unittest
{
    auto q = new ArrayQueue!int();

    q.enqueue(1);

    assert(*q.peek() == 1);
}

unittest
{
    auto q1 = new ArrayQueue!int();
    auto q2 = new ArrayQueue!int();

    q1.enqueue(1);
    q1.enqueue(2);

    q2.enqueue(1);
    q2.enqueue(2);

    assert(q1 == q2);
}

unittest
{
    auto q1 = new ArrayQueue!int();
    auto q2 = new ArrayQueue!int();

    q1.enqueue(1);
    q1.enqueue(2);

    q2.enqueue(3);
    q2.enqueue(4);

    assert(q1 != q2);
}

unittest
{
    auto q1 = new ArrayQueue!int();
    auto q2 = new ArrayQueue!int();

    q1.enqueue(1);
    q1.enqueue(2);

    q2.enqueue(3);
    q2.enqueue(4);
    q2.enqueue(5);

    assert(q1 != q2);
}
