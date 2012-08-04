module mci.core.sync;

import core.sync.condition,
       core.sync.mutex;

/**
 * A $(D final) version of $(D core.sync.mutex.Mutex). Its only purpose is
 * to devirtualize all calls for performance.
 */
public final class Mutex : core.sync.mutex.Mutex
{
    public this() nothrow
    {
        super();
    }
}

/**
 * A $(D final) version of $(D core.sync.condition.Condition). Its only
 * purpose is to devirtualize all calls for performance.
 */
public final class Condition : core.sync.condition.Condition
{
    /**
     * Constructs a new condition variable.
     *
     * Params:
     *  mutex = The mutex to use for synchronization.
     */
    public this(Mutex mutex) nothrow
    in
    {
        assert(mutex);
    }
    body
    {
        super(mutex);
    }
}
