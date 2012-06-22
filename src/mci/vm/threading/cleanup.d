module mci.vm.threading.cleanup;

import core.memory,
       core.thread,
       core.stdc.stdlib,
       std.conv,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.sync;

public alias void delegate() ThreadEventCallback;

static if (isWindows)
{
    import mci.vm.threading.tls;

    private __gshared NoNullDictionary!(Thread, ThreadEventCallback, false) callbacks;
    private __gshared Mutex lock;

    shared static this()
    {
        callbacks = new typeof(callbacks)();
        lock = new typeof(lock)();

        onThreadDestroy.add(&threadExit);
    }

    private void threadExit()
    in
    {
        assert(Thread.getThis());
    }
    body
    {
        ThreadEventCallback* cb;

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

        (*cb)();
    }
}
else
{
    import core.sys.posix.pthread;

    private __gshared pthread_key_t key;

    private struct CallbackData
    {
        private ThreadEventCallback _callback;

        invariant()
        {
            assert(_callback);
        }

        //@disable this();

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

    private extern (C) void threadExit(void* cd)
    in
    {
        assert(cd);
        assert(Thread.getThis());
    }
    body
    {
        pthread_setspecific(key, null);

        auto cbd = cast(CallbackData*)cd;

        cbd.callback()();

        GC.removeRange(cbd);
        free(cd);
    }
}

public void registerThreadCleanup(ThreadEventCallback cb)
in
{
    assert(Thread.getThis());
}
body
{
    static if (isWindows)
    {
        lock.lock();

        scope (exit)
            lock.unlock();

        if (cb)
            callbacks.add(Thread.getThis(), cb);
        else
            callbacks.remove(Thread.getThis());
    }
    else
    {
        CallbackData* cbd;

        if (cb)
        {
            auto mem = calloc(1, CallbackData.sizeof);
            cbd = emplace!CallbackData(mem[0 .. CallbackData.sizeof], cb);

            GC.addRange(cbd, CallbackData.sizeof); // To keep the delegate alive.
        }

        pthread_setspecific(key, cbd);
    }
}
