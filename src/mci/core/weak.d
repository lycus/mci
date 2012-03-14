module mci.core.weak;

import core.atomic,
       core.memory;

private alias void delegate(Object) DEvent;
private extern (C) void rt_attachDisposeEvent(Object h, DEvent e);
private extern (C) void rt_detachDisposeEvent(Object h, DEvent e);

public final class Weak(T : Object)
{
    // Note: This class uses a clever trick which works fine for a conservative GC
    // that was never intended to do compaction/copying in the first place. However,
    // if compaction is ever added to D's GC, this class will break horribly. If
    // D ever gets such a GC, we should push strongly for built-in weak references.
    private size_t _object;
    private size_t _ptr;
    private hash_t _hash;

    public this(T object)
    in
    {
        assert(object);
    }
    body
    {
        auto ptr = cast(size_t)cast(void*)object;

        // We use atomics because not all architectures may guarantee atomic store
        // and load of these values.
        atomicStore(*cast(shared)&_object, ptr);

        // Only assigned once, so no atomics.
        _ptr = ptr;
        _hash = typeid(T).getHash(&object);

        rt_attachDisposeEvent(object, &unhook);
        GC.setAttr(cast(void*)this, GC.BlkAttr.NO_SCAN);
    }

    @property public T object()
    {
        auto obj = cast(T)cast(void*)atomicLoad(*cast(shared)&_object);

        // We've moved it into the GC-scanned stack space, so it's now safe to ask
        // the GC whether the object is still alive. Note that even if the cast and
        // assignment of the obj local doesn't put the object on the stack, this
        // call will. So, either way, this is safe.
        if (GC.addrOf(cast(void*)obj))
            return obj;

        return null;
    }

    private void unhook(Object object)
    {
        rt_detachDisposeEvent(object, &unhook);

        // This assignment is important. If we don't null _object when it is collected,
        // the check in object could return false positives where the GC has reused the
        // memory for a new object.
        atomicStore(*cast(shared)&_object, cast(size_t)0);
    }

    public override equals_t opEquals(Object o)
    {
        if (this is o)
            return true;

        if (auto weak = cast(Weak!T)o)
            return _ptr == weak._ptr;

        return false;
    }

    public override int opCmp(Object o)
    {
        if (auto weak = cast(Weak!T)o)
            return _ptr > weak._ptr;

        return 1;
    }

    public override hash_t toHash()
    {
        auto obj = object;

        return obj ? typeid(T).getHash(&obj) : _hash;
    }

    public override string toString()
    {
        auto obj = object;

        return obj ? obj.toString() : toString();
    }
}

public Weak!T weak(T)(T object)
in
{
    assert(object);
}
body
{
    return new Weak!T(object);
}
