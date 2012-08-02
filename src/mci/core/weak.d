module mci.core.weak;

import core.memory,
       mci.core.atomic,
       mci.core.container;

public alias void delegate(Object) FinalizeCallback; /// A delegate to call when a weak reference dies.

private extern (C) void rt_attachDisposeEvent(Object h, FinalizeCallback e);
private extern (C) void rt_detachDisposeEvent(Object h, FinalizeCallback e);

private struct SMonitor
{
    public Object.Monitor impl;
    public FinalizeCallback[] devt;
    public size_t refs;
}

/**
 * Represents a weak, GC-managed reference.
 *
 * Note that this class uses a dirty trick that exploits the internal
 * monitor field of classes. This, in short, means that you should not
 * attach dispose events to the referenced object, use it as a monitor
 * in $(D synchronized) statements, and so on.
 *
 * Params:
 *  T = Type of the object to reference.
 */
public final class Weak(T : Object)
{
    // Note: This class uses a clever trick which works fine for a conservative GC
    // that was never intended to do compaction/copying in the first place. However,
    // if compaction is ever added to D's GC, this class will break horribly. If
    // D ever gets such a GC, we should push strongly for built-in weak references.

    private Atomic!size_t _object;
    private size_t _ptr;
    private hash_t _hash;

    invariant()
    {
        assert(_ptr);
    }

    /**
     * Constructs a new weak reference referencing a given object.
     *
     * Params:
     *  object = The object to reference weakly.
     *  callbacks = Callbacks to fire when the weakly referenced
     *              object is collected. May be $(D null).
     */
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
        _object.value = ptr;

        // Only assigned once, so no atomics.
        _ptr = ptr;
        _hash = typeid(T).getHash(&object);

        FinalizeCallback dg; // Don't join the declaration with the assignment. Alters semantics.
        void* monitor;

        dg = (o)
        {
            // HACK: This is completely and utterly insane. Don't do this at home. It will
            // kill your dog and eat your laundry. This is a temporary hack to make the
            // invariant described below (before the rt_attachDisposeEvent call) hold.
            GC.removeRange(monitor);

            rt_detachDisposeEvent(o, dg);

            // This assignment is important. If we don't null _object when it is collected,
            // the check in getObject could return false positives where the GC has reused
            // the memory for a new, unrelated object.
            _object.value = 0;

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

        // HACK: See above (in dg).
        GC.addRange(monitor, mon.devt.length * FinalizeCallback.sizeof);
    }

    /**
     * Retrieves the referenced object.
     *
     * This may return $(D null) if the object has been collected.
     *
     * Returns:
     *  The referenced object, or $(D null) if it has been
     *  collected.
     */
    public T getObject() pure nothrow
    {
        auto obj = cast(T)cast(void*)_object.value;

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

    @trusted public override hash_t toHash()
    {
        auto obj = getObject();

        return obj ? typeid(T).getHash(&obj) : _hash;
    }

    public override string toString()
    {
        auto obj = getObject();

        return obj ? obj.toString() : super.toString();
    }
}

/**
 * Convenience function to construct a $(D Weak) instance from
 * a given object.
 *
 * Params:
 *  T = The type of the referenced object.
 *  object = The object to reference.
 *  callbacks = Callbacks to fire when the weakly referenced
 *              object is collected. May be $(D null).
 *
 * Returns:
 *  A weak reference referencing $(D object).
 */
public Weak!T weak(T : Object)(T object, NoNullList!FinalizeCallback callbacks = null)
in
{
    assert(object);
}
body
{
    return new Weak!T(object);
}
