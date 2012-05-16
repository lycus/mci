module mci.tester.atomic;

import mci.core.atomic;

unittest
{
    int value;

    atomicStore(&value, 3);

    assert(atomicLoad(&value) == 3);
}

unittest
{
    auto atom = atomic(123);

    assert(atom.value == 123);

    atom.value = atom.value + 42;

    assert(atom.value == 165);
}

unittest
{
    Atomic!int atom;

    assert(atom.value == 0);
}

unittest
{
    auto atom = atomic(123);

    atom -= 100;

    assert(atom.value == 23);
}

unittest
{
    auto atom = atomic(cast(int*)0xdeadbeef);

    atom += 4;

    assert(atom.value == cast(int*)0xdeadbeff);
}

version (unittest)
{
    class A
    {
    }
}

unittest
{
    auto atom = atomic(new A());

    assert(atom.value);
}

unittest
{
    auto atom = atomic(123);

    atom.swap(123, 321);

    assert(atom.value == 321);
}
