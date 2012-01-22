module mci.vm.thread.thread;

import core.thread,
       mci.core.common,
       mci.core.config,
       mci.core.container;

alias void delegate() ThreadEventCallback;

static if (operatingSystem == OperatingSystem.windows)
{
    import mci.vm.thread.tls;

    private __gshared NoNullDictionary!(Thread, ThreadEventCallback) callbacks;

    shared static this()
    {
        callbacks = new typeof(callbacks)();

        onThreadDestroy.add(&threadExit);
    }

    private static void threadExit()
    {
        ThreadEventCallback* cb;

        synchronized (callbacks)
        {
            auto key = Thread.getThis();

            if (!(cb = callbacks.get(key)))
                return;

            callbacks.remove(key);
        }

        (*cb)();
    }

    public void registerThreadCleanup(ThreadCallback cb)
    in
    {
        assert(cb);
        assert(Thread.getThis());
    }
    body
    {
        synchronized (callbacks)
            callbacks.add(Thread.getThis(), cb);
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
        (cast(CallbackData)cd).callback()();

        pthread_setspecific(key, null);
    }

    public void registerThreadCleanup(ThreadEventCallback cb)
    in
    {
        assert(cb);
        assert(Thread.getThis());
        assert(!pthread_getspecific(key));
    }
    body
    {
        pthread_setspecific(key, cast(void*)new CallbackData(cb));
    }
}

