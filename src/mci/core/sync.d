module mci.core.sync;

import core.sync.condition,
       core.sync.mutex;

// Ensure that calls are not virtual.
public final class Mutex : core.sync.mutex.Mutex
{
}

public final class Condition : core.sync.condition.Condition
{
    public this(Mutex mutex)
    in
    {
        assert(mutex);
    }
    body
    {
        super(mutex);
    }
}
