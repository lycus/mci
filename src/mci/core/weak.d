module mci.core.weak;

import core.atomic,
       core.memory,
       mci.core.container;

public alias void delegate(Object) FinalizeCallback;

private extern (C) void rt_attachDisposeEvent(Object h, FinalizeCallback e);
private extern (C) void rt_detachDisposeEvent(Object h, FinalizeCallback e);

private struct SMonitor
{
    public Object.Monitor impl;
    public FinalizeCallback[] devt;
    public size_t refs;
}

public final class Weak(T : Object)
{
    // Note: This class uses a clever trick which works fine for a conservative GC
    // that was never intended to do compaction/copying in the first place. However,
    // if compaction is ever added to D's GC, this class will break horribly. If
    // D ever gets such a GC, we should push strongly for built-in weak references.

    private size_t _object;
    private size_t _ptr;
    private hash_t _hash;

    invariant()
    {
        assert(_ptr);
    }

    public this(T object, NoNullList!FinalizeCallback callbacks = null)
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

        FinalizeCallback dg;
        void* monitor;

        dg = (Object o)
        {
            // HACK: This is completely and utterly insane. Don't do this at home. It will
            // kill your dog, eat your laundry, and possibly assassinate your family. This
            // is a temporary hack to make the invariant described below (before the
            // rt_attachDisposeEvent call) hold.
            GC.removeRange(monitor);

            rt_detachDisposeEvent(o, dg);

            // This assignment is important. If we don't null _object when it is collected,
            // the check in object could return false positives where the GC has reused the
            // memory for a new object.
            atomicStore(*cast(shared)&_object, cast(size_t)0);

            if (callbacks)
                foreach (cb; callbacks)
                    cb(o);
        };

        // This call does more than it may seem at first. Since the second parameter
        // is a delegate, that means it has a context. In this particular case, the
        // this reference becomes the context. Now, since the delegate is attached to
        // the underlying object we're referring to, that means that as long as that
        // object is alive, so are we. In other words, we will always outlive it. Note
        // that this invariant doesn't actually hold during runtime shutdown (see the
        // note in the delegate above).
        rt_attachDisposeEvent(object, dg);

        auto mon = cast(SMonitor*)object.__monitor;
        monitor = mon.devt.ptr;

        // HACK: See above.
        GC.addRange(monitor, mon.devt.length * FinalizeCallback.sizeof);
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
