module mci.vm.thread.tls;

import mci.core.common,
       mci.core.config,
       mci.core.container;

// This file contains a dirty hack to get callbacks on Windows when threads start/stop.

static if (operatingSystem == OperatingSystem.windows)
{
    import core.sys.windows.windows;

    public alias void function() WindowsThreadEventCallback;

    public final class ThreadEvent
    {
        private NoNullList!WindowsThreadEventCallback _callbacks;

        invariant()
        {
            assert(_callbacks);
        }

        private this()
        {
            _callbacks = typeof(_callbacks)();
        }

        public void add(WindowsThreadEventCallback cb)
        in
        {
            assert(cb);
        }
        body
        {
            synchronized (_callbacks)
                _callbacks.add(cb);
        }

        public void remove(WindowsThreadEventCallback cb)
        in
        {
            assert(cb);
        }
        body
        {
            synchronized (_callbacks)
                _callbacks.remove(cb);
        }

        private void invoke()
        {
            synchronized (_callbacks)
                foreach (cb; _callbacks)
                    cb();
        }
    }

    public __gshared ThreadEvent onThreadCreate;
    public __gshared ThreadEvent onThreadDestroy;

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

    private extern (C) __gshared IMAGE_TLS_DIRECTORY _tls_used =
    {
        &_tlsstart,
        &_tlsend,
        &_tls_index,
        &callbacks,
        0,
        0
    };
}
