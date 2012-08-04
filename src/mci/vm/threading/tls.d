module mci.vm.threading.tls;

import mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.sync;

// This file contains a dirty hack to get callbacks on Windows when threads start/stop.

static if (isWindows)
{
    import core.sys.windows.windows;

    package alias void function() WindowsThreadEventCallback;

    package final class ThreadEvent
    {
        private NoNullList!WindowsThreadEventCallback _callbacks;
        private Mutex _lock;

        pure nothrow invariant()
        {
            assert(_callbacks);
            assert(_lock);
        }

        private this()
        {
            _callbacks = new typeof(_callbacks)();
            _lock = new typeof(_lock)();
        }

        public void add(WindowsThreadEventCallback cb)
        in
        {
            assert(cb);
        }
        body
        {
            _lock.lock();

            scope (exit)
                _lock.unlock();

            _callbacks.add(cb);
        }

        public void remove(WindowsThreadEventCallback cb)
        in
        {
            assert(cb);
        }
        body
        {
            _lock.lock();

            scope (exit)
                _lock.unlock();

            _callbacks.remove(cb);
        }

        private void invoke()
        {
            _lock.lock();

            scope (exit)
                _lock.unlock();

            foreach (cb; _callbacks)
                cb();
        }
    }

    package __gshared ThreadEvent onThreadCreate;
    package __gshared ThreadEvent onThreadDestroy;

    shared static this()
    {
        onThreadCreate = new typeof(onThreadCreate)();
        onThreadDestroy = new typeof(onThreadDestroy)();
    }

    private extern (Windows) void tlsCallback(PVOID instance, DWORD reason, PVOID reserved)
    {
        switch (reason)
        {
            case DLL_THREAD_ATTACH:
                onThreadCreate.invoke();
                break;
            case DLL_THREAD_DETACH:
                onThreadDestroy.invoke();
                break;
            default:
                break;
        }
    }

    private __gshared typeof(tlsCallback)*[2] callbacks = [&tlsCallback, null];

    private extern (C) __gshared DWORD _tls_index = 0;
    private extern extern (C) __gshared DWORD _tlsstart;
    private extern extern (C) __gshared DWORD _tlsend;

    private struct IMAGE_TLS_DIRECTORY
    {
        PVOID StartAddressOfRawData;
        PVOID EndAddressOfRawData;
        PVOID AddressOfIndex;
        PVOID AddressOfCallBacks;
        DWORD SizeOfZeroFill;
        DWORD Characteristics;
    }

    private extern (C) __gshared IMAGE_TLS_DIRECTORY _tls_used = IMAGE_TLS_DIRECTORY(&_tlsstart, &_tlsend, &_tls_index, &callbacks, 0, 0);
}
