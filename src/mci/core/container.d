module mci.core.container;

import core.exception,
       std.algorithm,
       std.bitmanip,
       std.exception,
       std.range,
       std.traits,
       mci.core.meta,
       mci.core.tuple;

public interface Iterable(T)
{
    public int opApply(scope int delegate(T) dg)
    in
    {
        assert(dg);
    }

    public int opApply(scope int delegate(size_t, T) dg)
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

    public T[] toArray();
}

public interface ReadOnlyCollection(T) : Countable!T
{
    public T* opBinaryRight(string op : "in")(T item)
    in
    {
        static if (isNullable!T)
            assert(item);
    }
}

public interface Collection(T) : ReadOnlyCollection!T
{
    public void add(T item);

    public void remove(T item);

    public void clear();
}

public interface ReadOnlyIndexable(T) : Countable!T
{
    public T opIndex(size_t index);

    public ReadOnlyIndexable!T opSlice(size_t x, size_t y);

    public ReadOnlyIndexable!T opSlice();

    public ReadOnlyIndexable!T opCat(T rhs);

    public ReadOnlyIndexable!T opCat(Iterable!T rhs);
}

public interface Indexable(T) : ReadOnlyIndexable!T
{
    public T opIndexAssign(T item, size_t index);

    public Indexable!T opCatAssign(T rhs);

    public Indexable!T opCatAssign(Iterable!T rhs);

    public void insert(size_t index, T item);
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

    @property public ReadOnlyCollection!K keys()
    out (result)
    {
        assert(result);
    }

    @property public ReadOnlyCollection!V values()
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

    public void clear();
}

public interface Stack(T) : ReadOnlyCollection!T
{
    public void push(T item);

    public T pop();

    public T* peek();

    public void clear();
}

public interface Set(T) : ReadOnlyCollection!T
{
    public bool add(T item)
    in
    {
        static if (isNullable!T)
            assert(item);
    }

    public void remove(T item)
    in
    {
        static if (isNullable!T)
            assert(item);
    }
}

public interface BitSequence : ReadOnlyIndexable!bool
{
    public size_t[] toWordArray();
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

public Queue!T asQueue(T)(Queue!T items)
{
    return items;
}

public Stack!T asStack(T)(Stack!T items)
{
    return items;
}

public Set!T asSet(T)(Set!T items)
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

public void addRange(T)(Collection!T col, T[] values ...)
in
{
    assert(col);
    assert(values);
}
body
{
    addRange(col, values);
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

public void removeRange(T)(Collection!T col, T[] values ...)
in
{
    assert(col);
    assert(values);
}
body
{
    removeRange(col, values);
}

public bool contains(T)(Iterable!T iter, T value)
in
{
    assert(iter);
}
body
{
    return contains(iter, (T x) => x == value);
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
    return findIndex(iter, (T i) => i == value);
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

public T first(T)(Iterable!T iter, lazy T defaultValue = T.init)
in
{
    assert(iter);
}
body
{
    // Just return the first item.
    foreach (item; iter)
        return item;

    return defaultValue;
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

public class List(T) : Indexable!T, Collection!T
{
    private T[] _array;
    private size_t _size;

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

    public final int opApply(scope int delegate(T) dg)
    {
        for (size_t i = 0; i < _size; i++)
        {
            auto status = dg(_array[i]);

            if (status)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, T) dg)
    {
        for (size_t i = 0; i < _size; i++)
        {
            auto status = dg(i, _array[i]);

            if (status)
                return status;
        }

        return 0;
    }

    public final T* opBinaryRight(string op : "in")(T item)
    {
        for (size_t i = 0; i < _size; i++)
            if (_array[i] == item)
                return &_array[i];

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
            _array.length = _size = index + 1;

        return _array[index] = item;
    }

    public List!T opSlice()
    {
        return duplicate();
    }

    public List!T opSlice(size_t x, size_t y)
    {
        auto list = new List!T();

        for (auto i = x; i < y; i++)
            list.add(_array[i]);

        return list;
    }

    public List!T opCat(T rhs)
    {
        auto list = duplicate();

        list.add(rhs);

        return list;
    }

    public List!T opCat(Iterable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public Indexable!T opCatAssign(T rhs)
    {
        add(rhs);

        return this;
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
        return typeid(typeof(_array)).getHash(&_array);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto list = cast(List!T)o)
            return typeid(typeof(_array)).compare(&_array, &list._array);

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

    public List!T duplicate()
    {
        auto l = new List!T();

        l._array = _array.dup;
        l._size = _size;

        return l;
    }

    public final T[] toArray()
    {
        return _array.dup;
    }

    public final void add(T item)
    {
        onAdd(item);

        auto idx = _size;

        if (_size == _array.length)
            _array.length += 1;

        _size++;
        _array[idx] = item;
    }

    public final void insert(size_t index, T item)
    {
        onAdd(item);

        if (index >= _array.length)
        {
            _array.length = _size = index + 1;
            _array[index] = item;
        }
        else
        {
            // The index lies within the managed area, so shift all elements forward.
            _array.length += 1;
            _size++;

            for (size_t i = 0; i < _size; i++)
                if (i >= index)
                    _array[i] = _array[i + 1];

            _array[index] = item;
        }
    }

    public final void remove(T item)
    {
        onRemove(item);

        size_t index;
        bool eq;

        for (size_t i = 0; i < _size; i++)
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
                _size--;

                break;
            }
        }

        if (eq)
        {
            for (size_t i = 0; i < _size; i++)
                if (i >= index)
                    _array[i] = _array[i + 1];

            // Avoid keeping dead references around.
            _array[_size] = T.init;
        }
    }

    public final void clear()
    {
        onClear();

        _array = null;
        _size = 0;
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
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public List!(ForeachType!V) toList(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new List!(ForeachType!V)();

    addRange(list, items);

    return list;
}

public Indexable!T toIndexable(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toIndexable(items);
}

public Indexable!(ForeachType!V) toIndexable(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public ReadOnlyIndexable!T toReadOnlyIndexable(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toReadOnlyIndexable(items);
}

public ReadOnlyIndexable!(ForeachType!V) toReadOnlyIndexable(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public Collection!T toCollection(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toCollection(items);
}

public Collection!(ForeachType!V) toCollection(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public ReadOnlyCollection!T toReadOnlyCollection(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toReadOnlyCollection(items);
}

public ReadOnlyCollection!(ForeachType!V) toReadOnlyCollection(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public Countable!T toCountable(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toCountable(items);
}

public Countable!(ForeachType!V) toCountable(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
}

public Iterable!T toIterable(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toIterable(items);
}

public Iterable!(ForeachType!V) toIterable(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toList(items);
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

        for (auto i = x; i < y; i++)
            list.add(_array[i]);

        return list;
    }

    public override NoNullList!T opCat(T rhs)
    {
        auto list = duplicate();

        list.add(rhs);

        return list;
    }

    public override NoNullList!T opCat(Iterable!T rhs)
    {
        auto list = duplicate();

        foreach (item; rhs)
            list.add(item);

        return list;
    }

    public override NoNullList!T opCatAssign(T rhs)
    {
        add(rhs);

        return this;
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
        l._size = _size;

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

public NoNullList!T toNoNullList(T)(T[] items ...)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    return toNoNullList(items);
}

public NoNullList!(ForeachType!V) toNoNullList(V)(V items)
    if (isIterable!V)
in
{
    assert(items);
}
out (result)
{
    assert(result);
}
body
{
    auto list = new NoNullList!(ForeachType!V)();

    addRange(list, items);

    return list;
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

    public final int opApply(scope int delegate(Tuple!(K, V)) dg)
    {
        static if (order)
        {
            foreach (tup; _list)
            {
                auto status = dg(tup);

                if (status)
                    return status;
            }
        }
        else
        {
            foreach (k, v; _aa)
            {
                auto tup = tuple(k, v);
                auto status = dg(tup);

                if (status)
                    return status;
            }
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, Tuple!(K, V)) dg)
    {
        static if (order)
        {
            foreach (i, tup; _list)
            {
                auto status = dg(i, tup);

                if (status)
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

                if (status)
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

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto dict = cast(Dictionary!(K, V, order))o)
            return _aa == dict._aa;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(typeof(_aa)).getHash(&_aa);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto dict = cast(Dictionary!(K, V, order))o)
            return typeid(typeof(_aa)).compare(&_aa, &dict._aa);

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

    public Dictionary!(K, V, order) duplicate()
    {
        auto d = new Dictionary!(K, V, order)();

        d._aa = _aa.dup;

        static if (order)
            d._list = _list.duplicate();

        return d;
    }

    public final Tuple!(K, V)[] toArray()
    {
        auto arr = new Tuple!(K, V)[_aa.length];

        static if (order)
        {
            foreach (i, tup; _list)
                arr[i] = tup;
        }
        else
        {
            size_t i = 0;

            foreach (k, v; _aa)
            {
                arr[i] = tuple(k, v);
                i++;
            }
        }

        return arr;
    }

    public final V* get(K key)
    {
        return key in _aa;
    }

    public final Tuple!(K, V)* opBinaryRight(string op : "in")(Tuple!(K, V) item)
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

    public override NoNullDictionary!(K, V, order) duplicate()
    {
        auto d = new NoNullDictionary!(K, V, order)();

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

    public final int opApply(scope int delegate(T) dg)
    {
        for (auto i = _head; i < _size; i++)
        {
            auto item = _list[i];
            auto status = dg(item);

            if (status)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, T) dg)
    {
        for (auto i = _head; i < _size; i++)
        {
            auto item = _list[i];
            auto status = dg(i, item);

            if (status)
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

            for (auto i = _head; i < _size; i++)
                if (_list[i] != q._list[i])
                    return false;

            return true;
        }

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(typeof(_list)).getHash(&_list) + typeid(typeof(_size)).getHash(&_size) +
               typeid(typeof(_head)).getHash(&_head) + typeid(typeof(_tail)).getHash(&_tail);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto q = cast(ArrayQueue!T)o)
        {
            if (!typeid(typeof(_size)).equals(&_size, &q._size))
                return typeid(typeof(_size)).compare(&_size, &q._size);

            if (!typeid(typeof(_head)).equals(&_head, &q._head))
                return typeid(typeof(_head)).compare(&_head, &q._head);

            if (!typeid(typeof(_tail)).equals(&_tail, &q._tail))
                return typeid(typeof(_tail)).compare(&_tail, &q._tail);

            return typeid(typeof(_list)).compare(&_list, &q._list);
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

    public final T[] toArray()
    {
        return _list[_head .. _size].toArray();
    }

    public final void enqueue(T item)
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

    public final T dequeue()
    {
        auto item = _list[_head];

        _list[_head] = T.init;
        _head = (_head + 1) % _list.count;
        _size--;

        return item;
    }

    public final T* peek()
    {
        if (!_size)
            return null;

        return &_list._array[_head];
    }

    public void clear()
    {
        _list.clear();
        _size = 0;
        _tail = 0;
        _head = 0;
    }
}

public class ArrayStack(T) : Stack!T
{
    private List!T _list;

    invariant()
    {
        assert(_list);
    }

    public this()
    {
        _list = new typeof(_list)();
    }

    public this(Iterable!T iter)
    in
    {
        assert(iter);
    }
    body
    {
        this();

        foreach (item; iter)
            push(item);
    }

    public final int opApply(scope int delegate(T) dg)
    {
        foreach (item; _list)
        {
            auto status = dg(item);

            if (status)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, T) dg)
    {
        foreach (i, item; _list)
        {
            auto status = dg(i, item);

            if (status)
                return status;
        }

        return 0;
    }

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto s = cast(ArrayStack!T)o)
            return _list == s._list;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(typeof(_list)).getHash(&_list);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto s = cast(ArrayStack!T)o)
            return typeid(typeof(_list)).compare(&_list, &s._list);

        return 1;
    }

    @property public final size_t count()
    {
        return _list.count;
    }

    @property public final bool empty()
    {
        return _list.empty;
    }

    public ArrayStack!T duplicate()
    {
        auto s = new ArrayStack!T();

        s._list = _list.duplicate();

        return s;
    }

    public final T[] toArray()
    {
        return _list.toArray();
    }

    public final T* opBinaryRight(string op : "in")(T item)
    {
        if (auto ptr = item in _list)
            return ptr;

        return null;
    }

    public final void push(T item)
    {
        _list.add(item);
    }

    public final T pop()
    {
        auto item = _list[_list.count - 1];

        _list.remove(item);

        return item;
    }

    public final T* peek()
    {
        return &_list._array[_list.count - 1];
    }

    public final void clear()
    {
        _list.clear();
    }
}

public final class HashSet(T) : Set!T
{
    static if (isNullable!T)
        private NoNullDictionary!(T, T, false) _dict;
    else
        private Dictionary!(T, T, false) _dict;

    invariant()
    {
        assert(_dict);
    }

    public this()
    {
        _dict = new typeof(_dict)();
    }

    public this(Iterable!T iter)
    in
    {
        assert(iter);
    }
    body
    {
        this();

        foreach (item; iter)
            add(item);
    }

    public final int opApply(scope int delegate(T) dg)
    {
        foreach (tup; _dict)
        {
            auto item = tup.x;
            auto status = dg(item);

            if (status)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, T) dg)
    {
        foreach (i, tup; _dict)
        {
            auto item = tup.x;
            auto status = dg(i, item);

            if (status)
                return status;
        }

        return 0;
    }

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto set = cast(HashSet!T)o)
            return _dict == set._dict;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(typeof(_dict)).getHash(&_dict);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto set = cast(HashSet!T)o)
            return typeid(typeof(_dict)).compare(&_dict, &set._dict);

        return 1;
    }

    @property public final size_t count()
    {
        return _dict.count;
    }

    @property public final bool empty()
    {
        return _dict.empty;
    }

    public HashSet!T duplicate()
    {
        auto set = new HashSet!T();

        set._dict = _dict.duplicate();

        return set;
    }

    public final T[] toArray()
    {
        return _dict.keys.toArray();
    }

    public final T* opBinaryRight(string op : "in")(T item)
    {
        return item in _dict;
    }

    public final bool add(T item)
    {
        if (item in _dict)
            return false;

        _dict.add(item, item);
        return true;
    }

    public final void remove(T item)
    {
        _dict.remove(item);
    }

    public final void clear()
    {
        _dict.clear();
    }
}

public class BitArray : BitSequence, Indexable!bool
{
    private std.bitmanip.BitArray _bits;

    public this()
    {
    }

    public this(Iterable!bool items)
    in
    {
        assert(items);
    }
    body
    {
        foreach (item; items)
            this ~= item;
    }

    public final int opApply(scope int delegate(bool) dg)
    {
        foreach (b; _bits)
        {
            auto status = dg(b);

            if (status)
                return status;
        }

        return 0;
    }

    public final int opApply(scope int delegate(size_t, bool) dg)
    {
        foreach (i, b; _bits)
        {
            auto status = dg(i, b);

            if (status)
                return status;
        }

        return 0;
    }

    public final bool opIndex(size_t index)
    {
        return _bits[index];
    }

    public final bool opIndexAssign(bool item, size_t index)
    {
        _bits[index] = item;

        return item;
    }

    public BitArray opSlice()
    {
        return duplicate();
    }

    public BitArray opSlice(size_t x, size_t y)
    {
        auto bits = new BitArray();

        for (auto i = x; i < y; i++)
            bits ~= _bits[i];

        return bits;
    }

    public BitArray opCat(bool rhs)
    {
        auto bits = duplicate();

        bits ~= rhs;

        return bits;
    }

    public BitArray opCat(Iterable!bool rhs)
    {
        auto bits = duplicate();

        foreach (item; rhs)
            bits ~= item;

        return bits;
    }

    public BitArray opCatAssign(bool rhs)
    {
        _bits ~= rhs;

        return this;
    }

    public BitArray opCatAssign(Iterable!bool rhs)
    {
        foreach (item; rhs)
            _bits ~= item;

        return this;
    }

    public final override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto bits = cast(BitArray)o)
            return _bits == bits._bits;

        return false;
    }

    public final override hash_t toHash()
    {
        return typeid(typeof(_bits)).getHash(&_bits);
    }

    public final override int opCmp(Object o)
    {
        if (this is o)
            return 0;

        if (auto bits = cast(BitArray)o)
            return typeid(typeof(_bits)).compare(&_bits, &bits._bits);

        return 1;
    }

    @property public final size_t count()
    {
        return _bits.length;
    }

    @property public final bool empty()
    {
        return !_bits.length;
    }

    public BitArray duplicate()
    {
        auto bits = new BitArray();

        bits._bits = _bits.dup;

        return bits;
    }

    public final bool[] toArray()
    {
        auto arr = new bool[_bits.length];

        foreach (i, b; _bits)
            arr[i] = b;

        return arr;
    }

    public final size_t[] toWordArray()
    {
        return (cast(size_t[])_bits).dup;
    }

    public final void insert(size_t index, bool item)
    {
        if (index >= _bits.length)
        {
            _bits.length = index + 1;
            _bits[index] = item;
        }
        else
        {
            assert(false); version (none) {
            // The index lies within the managed area, so shift all elements forward.
            _bits.length = _bits.length + 1;
            _size++;

            for (size_t i = 0; i < _size; i++)
                if (i >= index)
                    _bits[i] = _bits[i + 1];

            _bits[index] = item; }
        }
    }
}
