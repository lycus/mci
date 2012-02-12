module mci.tester.container;

import core.exception,
       std.exception,
       mci.core.container;

unittest
{
    auto list = new List!int();

    addRange(list, [1, 2, 3]);

    assert(list[0] == 1);
    assert(list[1] == 2);
    assert(list[2] == 3);
    assert(list.count == 3);
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

unittest
{
    auto list = new List!int();

    list.add(2);

    assert(contains(list, (int x) { return x == 2; }));
    assert(!contains(list, (int x) { return x == 3; }));
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

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(findIndex(list, 1) == 0);
    assert(findIndex(list, 3) == 2);
}

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(findIndex(list, (int x) { return x == 1; }) == 0);
    assert(findIndex(list, (int x) { return x == 3; }) == 2);
}

unittest
{
    auto list = new List!int();

    debug
        assertThrown!AssertError(findIndex(list, (int x) { return x == 42; }));
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

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);

    assert(aggregate(list, (int x, int y) { return x + y; }) == 6);
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

unittest
{
    auto list = new List!int();

    list.add(1);
    list.add(2);
    list.add(3);
    list.add(4);
    list.add(5);

    assert(count(list, (int i) { return i < 3; }) == 2);
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

unittest
{
    auto list = toList(1, 2, 3);

    assert(first(list) == 1);
}

unittest
{
    auto list = new List!Object();

    assert(!first(list));
}

unittest
{
    auto list = new List!int();

    debug
        assertThrown!AssertError(last(list));
}

unittest
{
    auto list = toList(1, 2, 3);

    assert(last(list) == 3);
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

unittest
{
    auto list = toList(1, 2, 3);

    assert(list[0] == 1);
    assert(list[1] == 2);
    assert(list[2] == 3);
}

unittest
{
    auto list = toIndexable(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = toReadOnlyIndexable(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = toCollection(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = toReadOnlyCollection(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = toCountable(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = toIterable(1, 2, 3);

    assert(list);
}

unittest
{
    auto list = new NoNullList!string();

    debug
        assertThrown!AssertError(list.add(null));
}

unittest
{
    auto list = new NoNullList!string();

    debug
        assertThrown!AssertError(list.remove(null));
}

unittest
{
    auto list = new NoNullList!string();

    list.add("foo");
    list.add("bar");
    list.add("baz");
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

unittest
{
    auto st = new ArrayStack!int();

    st.push(1);
    st.push(2);
    st.push(3);

    assert(st.count == 3);
    assert(!st.empty);
}

unittest
{
    auto st = new ArrayStack!int();

    st.push(5);

    assert(*st.peek() == 5);
}

unittest
{
    auto st = new ArrayStack!int();

    st.push(1);
    st.push(2);
    st.push(3);

    st.pop();
    st.pop();
    st.pop();

    assert(st.count == 0);
    assert(st.empty);
}

unittest
{
    auto st = new ArrayStack!int();

    assert(st.empty);
}

unittest
{
    auto st = new ArrayStack!int();

    st.push(1);
    st.push(2);
    st.push(3);

    st.clear();

    assert(st.count == 0);
    assert(st.empty);
}

unittest
{
    auto set = new HashSet!int();

    set.add(1);
    set.add(2);
    set.add(3);

    assert(1 in set);
    assert(2 in set);
    assert(3 in set);
}

unittest
{
    auto set = new HashSet!string();

    debug
        assertThrown!AssertError(set.add(null));
}

unittest
{
    auto set = new HashSet!int();

    assert(set.add(1));
}

unittest
{
    auto set = new HashSet!int();

    set.add(1);

    assert(!set.add(1));
}

unittest
{
    auto set = new HashSet!int();

    assert(set.count == 0);
    assert(set.empty);
}

unittest
{
    auto set = new HashSet!int();

    set.add(1);
    set.add(2);

    assert(set.count == 2);
    assert(!set.empty);
}

unittest
{
    auto set = new HashSet!int();

    set.add(1);
    set.remove(1);

    assert(set.count == 0);
    assert(set.empty);
}

unittest
{
    auto set = new HashSet!int();

    set.add(1);
    set.add(2);
    set.add(3);

    set.clear();

    assert(set.count == 0);
    assert(set.empty);
}
