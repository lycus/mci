module mci.vm.threading.cleanup;

import core.memory,
       core.thread,
       core.stdc.stdlib,
       core.sys.posix.pthread,
       std.conv,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.sync,
       mci.vm.threading.tls;

public alias void delegate() ThreadEventCallback;

static if (isWindows)
{
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
    private __gshared pthread_key_t key;

    private struct CallbackData
    {
        private ThreadEventCallback _callback;
        private Thread _thisThread;

        pure nothrow invariant()
        {
            assert(_callback);
            assert(_thisThread);
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
            _thisThread = Thread.getThis();
        }

        @property public ThreadEventCallback callback() pure nothrow
        out (result)
        {
            assert(result);
        }
        body
        {
            return _callback;
        }

        @property public Thread thread() pure nothrow
        out (result)
        {
            assert(result);
        }
        body
        {
            return _thisThread;
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
    }
    body
    {
        pthread_setspecific(key, null);
        auto cbd = cast(CallbackData*)cd;

        thread_setThis(cbd.thread);
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
