module mci.tester.types;

import mci.core.container,
       mci.core.nullable,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.cache,
       mci.core.typing.types;

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "bar");
    st.close();

    auto ptr = getPointerType(st);

    assert(ptr.name == "'foo'/'bar'*");
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "foo_bar_baz");
    st.close();

    auto ptr = getPointerType(st);

    assert(ptr.name == "'foo'/'foo_bar_baz'*");
}

unittest
{
    auto mod = new Module("foo");

    auto st1 = new StructureType(mod, "bar");
    st1.close();

    auto st2 = new StructureType(mod, "baz");
    st2.close();

    auto params = new NoNullList!Type();

    params.add(st2);
    params.add(st1);

    auto fpt = getFunctionPointerType(CallingConvention.standard, st1, params);

    assert(fpt.name == "'foo'/'bar'('foo'/'baz', 'foo'/'bar')");
}

unittest
{
    auto mod = new Module("foo");

    auto st1 = new StructureType(mod, "bar");
    st1.close();

    auto params = new NoNullList!Type();
    params.add(st1);

    auto fpt = getFunctionPointerType(CallingConvention.cdecl, st1, params);

    assert(fpt.name == "'foo'/'bar'('foo'/'bar') cdecl");
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "baz");
    st.close();

    auto arr = getArrayType(st);

    assert(arr.name == "'foo'/'baz'[]");
}

unittest
{
    auto mod = new Module("foo");

    auto st = new StructureType(mod, "baz");
    st.close();

    auto vec = getVectorType(st, 3);

    assert(vec.name == "'foo'/'baz'[3]");
}
