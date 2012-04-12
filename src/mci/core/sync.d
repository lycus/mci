module mci.core.sync;

import core.sync.mutex;

// Ensure that calls are not virtual.
public final class Mutex : core.sync.mutex.Mutex
{
}
