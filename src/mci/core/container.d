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

public interface ReadOnlyCollection(T) : Countable!T
{
    public T* opBinaryRight(string op : "in")(T item)
    in
    {
        assert(item);
    }
}

public interface Collection(T) : ReadOnlyCollection!T
{
    public void add(T item);

    public void remove(T item);

    public void clear();
}

public interface ReadOnlyIndexable(T) : ReadOnlyCollection!T
{
    public T opIndex(size_t index);

    public ReadOnlyIndexable!T opSlice(size_t x, size_t y);

    public ReadOnlyIndexable!T opSlice();

    public ReadOnlyIndexable!T opCat(Iterable!T rhs);
}

public interface Indexable(T) : ReadOnlyIndexable!T, Collection!T
{
    public T opIndexAssign(T item, size_t index);

    public Indexable!T opCatAssign(Iterable!T rhs);
}

public interface Lookup(K, V) : ReadOnlyCollection!(Tuple!(K, V))
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

    public ReadOnlyCollection!K keys()
    out (result)
    {
        assert(result);
    }

    public ReadOnlyCollection!V values()
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

public ReadOnlyCollection!T asReadOnlyCollection(T)(ReadOnlyCollection!T items)
{
    return items;
}

public Collection!T asCollection(T)(Collection!T items)
{
    return items;
}

public ReadOnlyIndexable!T asReadOnlyIndexable(T)(ReadOnlyIndexable!T items)
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

public bool contains(T)(Iterable!T iter, T value)
in
{
    assert(iter);
}
body
{
    return contains(iter, (T item) { return item == value; });
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

public size_t findIndex(T)(Iterable!T iter, T value)
in
{
    assert(iter);
}
body
{
    return findIndex(iter, (T item) { return item == value; });
}

public size_t findIndex(T)(Iterable!T iter, scope bool delegate(T) criteria)
in
{
    assert(iter);
    assert(criteria);
}
body
{
    foreach (i, item; iter)
        if (criteria(item))
            return i;

    assert(false);
}

public Iterable!R map(R, T)(Iterable!T iter, scope R delegate(T) selector)
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

public R aggregate(T, R)(Iterable!T iter, scope R delegate(R, T) selector, R seed = R.init)
in
{
    assert(iter);
    assert(selector);
}
body
{
    auto result = seed;

    foreach (item; iter)
        result = selector(result, item);

    return result;
}

public Iterable!T concat(T)(Iterable!T iter, Iterable!T[] others ...)
in
{
    assert(iter);
    assert(others);
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

    foreach (other; others)
        foreach (item; other)
            list.add(item);

    return list;
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

public size_t count(T)(Iterable!T iter, scope bool delegate(T) predicate)
in
{
    assert(iter);
    assert(predicate);
}
body
{
    size_t count;

    foreach (item; iter)
        if (predicate(item))
            count++;

    return count;
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

public T first(T)(Iterable!T iter)
in
{
    assert(iter);
}
body
{
    // Just return the first item.
    foreach (item; iter)
        return item;

    assert(false);
}

public T last(T)(Iterable!T iter)
in
{
    assert(iter);
    assert(!isEmpty(iter));
}
body
{
    T item;

    foreach (i; iter)
        item = i;

    return item;
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

    public List!T opCat(Iterable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public List!T opCatAssign(Iterable!T rhs)
    {
        foreach (item; rhs)
            add(item);

        return this;
    }

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto list = cast(List!T)o)
            return _array == list._array;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(T[]).getHash(&_array);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto list = cast(List!T)o)
            return typeid(T[]).compare(&_array, &list._array);

        return 1;
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
        bool eq;

        for (size_t i = 0; i < _array.length; i++)
        {
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

        if (eq)
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

public Indexable!T toIndexable(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public ReadOnlyIndexable!T toReadOnlyIndexable(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public Collection!T toCollection(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public ReadOnlyCollection!T toReadOnlyCollection(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toList(items);
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

public Iterable!T toIterable(T)(T[] items ...)
out (result)
{
    assert(result);
}
body
{
    return toCountable(items);
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

    public override NoNullList!T opCat(Iterable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public override NoNullList!T opCatAssign(Iterable!T rhs)
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

public class Dictionary(K, V, bool order = true) : Map!(K, V)
{
    private V[K] _aa;

    static if (order)
        private List!(Tuple!(K, V)) _list;

    public this()
    {
        static if (order)
            _list = new typeof(_list)();
    }

    public this(Map!(K, V) items)
    in
    {
        assert(items);
    }
    body
    {
        this();

        foreach (item; items)
            add(item);
    }

    public final int opApply(scope int delegate(ref Tuple!(K, V)) dg)
    {
        static if (order)
        {
            foreach (tup; _list)
            {
                auto status = dg(tup);

                if (status != 0)
                    return status;
            }
        }
        else
        {
            foreach (k, v; _aa)
            {
                auto tup = tuple(k, v);
                auto status = dg(tup);

                if (status != 0)
                    return status;
            }
        }

        return 0;
    }

    public final int opApply(scope int delegate(ref size_t, ref Tuple!(K, V)) dg)
    {
        static if (order)
        {
            foreach (i, tup; _list)
            {
                auto status = dg(i, tup);

                if (status != 0)
                    return status;
            }
        }
        else
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

        _aa[key] = value;

        static if (order)
        {
            foreach (i, tup; _list)
            {
                if (tup.x == key)
                {
                    _list[i] = tuple(key, value);
                    return value;
                }
            }

            _list.add(tuple(key, value));
        }

        return value;
    }

    public override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto dict = cast(Dictionary!(K, V))o)
            return _aa == dict._aa;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(V[K]).getHash(&_aa);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto dict = cast(Dictionary!(K, V))o)
            return typeid(V[K]).compare(&_aa, &dict._aa);

        return 1;
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

        static if (order)
            d._list = _list.duplicate();

        return d;
    }

    public final V* get(K key)
    {
        return key in _aa;
    }

    public Tuple!(K, V)* opBinaryRight(string op : "in")(Tuple!(K, V) item)
    {
        static if (order)
        {
            foreach (tup; _list)
                if (tup == item)
                    return &tup;
        }
        else
        {
            foreach (k, v; _aa)
                if (tuple(k, v) == item)
                    return new Tuple!(K, V)(k, v);
        }

        return null;
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

        static if (order)
            _list.clear();
    }

    public final void add(K key, V value)
    {
        onAdd(key, value);

        _aa[key] = value;

        static if (order)
            _list.add(tuple(key, value));
    }

    public final void remove(K key)
    {
        onRemove(key);

        static if (order)
            _list.remove(tuple(key, _aa[key]));

        _aa.remove(key);
    }

    @property public final ReadOnlyCollection!K keys()
    {
        auto arr = new List!K();

        static if (order)
        {
            foreach (tup; _list)
                arr.add(tup.x);
        }
        else
        {
            foreach (k, v; _aa)
                arr.add(k);
        }

        return arr;
    }

    @property public final ReadOnlyCollection!V values()
    {
        auto arr = new List!V();

        static if (order)
        {
            foreach (tup; _list)
                arr.add(tup.y);
        }
        else
        {
            foreach (k, v; _aa)
                arr.add(v);
        }

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

public class NoNullDictionary(K, V, bool order = true)
    if (isNullable!V) : Dictionary!(K, V, order)
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

        static if (order)
            d._list = _list.duplicate();

        return d;
    }

    protected override void onAdd(K key, V value)
    {
        assert(value);
    }
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

    public final override equals_t opEquals(Object o)
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

    public final override hash_t toHash()
    {
        return typeid(List!T).getHash(&_list) + typeid(size_t).getHash(&_size) +
               typeid(size_t).getHash(&_head) + typeid(size_t).getHash(&_tail);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto q = cast(ArrayQueue!T)o)
        {
            if (!typeid(size_t).equals(&_size, &q._size))
                return typeid(size_t).compare(&_size, &q._size);

            if (!typeid(size_t).equals(&_head, &q._head))
                return typeid(size_t).compare(&_head, &q._head);

            if (!typeid(size_t).equals(&_tail, &q._tail))
                return typeid(size_t).compare(&_tail, &q._tail);

            return typeid(List!T).compare(&_list, &q._list);
        }

        return 1;
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
