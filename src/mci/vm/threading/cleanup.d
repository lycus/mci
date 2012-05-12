module mci.vm.threading.cleanup;

import core.thread,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.sync;

public alias void delegate() ThreadEventCallback;

static if (isWindows)
{
    import mci.vm.threading.tls;

    private __gshared NoNullDictionary!(Thread, ThreadEventCallback) callbacks;
    private __gshared Mutex lock;

    shared static this()
    {
        callbacks = new typeof(callbacks)();
        lock = new typeof(lock)();

        onThreadDestroy.add(&threadExit);
    }

    private static void threadExit()
    in
    {
        assert(Thread.getThis());
    }
    body
    {
        ThreadEventCallback cb;

        {
            lock.lock();

            scope (exit)
                lock.unlock();

            auto key = Thread.getThis();
            cb = key in callbacks;

            if (!cb)
                return;

            callbacks.remove(key);
        }

        cb();
    }

    public void registerThreadCleanup(ThreadEventCallback cb)
    in
    {
        assert(Thread.getThis());
    }
    body
    {
        lock.lock();

        scope (exit)
            lock.unlock();

        if (cb)
            callbacks.add(Thread.getThis(), cb);
        else
            callbacks.remove(Thread.getThis());
    }
}
else
{
    import core.sys.posix.pthread;

    private __gshared pthread_key_t key;

    private final class CallbackData
    {
        private ThreadEventCallback _callback;

        invariant()
        {
            assert(_callback);
        }

        public this(ThreadEventCallback callback)
        in
        {
            assert(callback);
        }
        body
        {
            _callback = callback;
        }

        @property public ThreadEventCallback callback()
        out (result)
        {
            assert(result);
        }
        body
        {
            return _callback;
        }
    }

    shared static this()
    {
        pthread_key_create(&key, &threadExit);
    }

    private static extern (C) void threadExit(void *cd)
    {
        pthread_setspecific(key, null);

        (cast(CallbackData)cd).callback()();
    }

    public void registerThreadCleanup(ThreadEventCallback cb)
    in
    {
        assert(Thread.getThis());
    }
    body
    {
        pthread_setspecific(key, cb ? cast(void*)new CallbackData(cb) : null);
    }
}

