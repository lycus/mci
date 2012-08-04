module mci.vm.memory.finalization;

import core.thread,
       mci.core.atomic,
       mci.core.common,
       mci.core.container,
       mci.core.sync,
       mci.core.code.functions,
       mci.vm.exception,
       mci.vm.execution,
       mci.vm.intrinsics.declarations,
       mci.vm.memory.base;

public void finalize(GarbageCollector gc, RuntimeObject* rto, GarbageCollectorFinalizer finalizer, ExecutionEngine engine)
in
{
    assert(gc);
    assert(cast(InteractiveGarbageCollector)gc);
    assert(rto);
    assert(finalizer);
    assert(engine);
}
body
{
    try
    {
        auto arg = new RuntimeValue(gc, objectType);

        *cast(RuntimeObject**)arg.data = rto;

        engine.execute(cast(function_t)finalizer, CallingConvention.cdecl, null, toNoNullList(arg));
    }
    catch (ExecutionException ex)
    {
        auto eh = (cast(InteractiveGarbageCollector)gc).exceptionHandler;

        if (eh)
            eh(rto, finalizer, engine, ex);

        // We just silently ignore the exception if there's no handler.
    }
}

public final class FinalizerThread
{
    private GarbageCollector _gc;
    private InteractiveGarbageCollector _igc;
    private Mutex _finalizerMutex;
    private Condition _finalizerCondition;
    private Mutex _pendingMutex;
    private Condition _pendingCondition;
    private Atomic!bool _finalizeDone;
    private Atomic!bool _notified;
    private Atomic!bool _running;
    private Atomic!Thread _thread;

    pure nothrow invariant()
    {
        assert(_gc);
        assert(cast(InteractiveGarbageCollector)_gc);
        assert(_igc);
        assert(cast(InteractiveGarbageCollector)_gc is _igc);
        assert(_finalizerMutex);
        assert(_finalizerCondition);
        assert(_pendingMutex);
        assert(_pendingCondition);
        assert((cast()_running).value ? !!(cast()_thread).value : !(cast()_thread).value);
    }

    public this(GarbageCollector gc)
    in
    {
        assert(gc);
        assert(cast(InteractiveGarbageCollector)gc);
    }
    body
    {
        _gc = gc;
        _igc = cast(InteractiveGarbageCollector)gc;
        _finalizerMutex = new typeof(_finalizerMutex)();
        _finalizerCondition = new typeof(_finalizerCondition)(_finalizerMutex);
        _pendingMutex = new typeof(_pendingMutex)();
        _pendingCondition = new typeof(_pendingCondition)(_pendingMutex);
    }

    @property public bool running() pure nothrow
    {
        return _running.value;
    }

    public void start()
    in
    {
        assert(!_running.value);
    }
    body
    {
        _running.value = true;
        _thread.value = new Thread(&loop);

        _thread.value.start();
    }

    public void stop()
    in
    {
        assert(_running.value);
    }
    body
    {
        _running.value = false;

        internalNotify();

        _thread.value.join();
        _thread.value = null;
    }

    private void internalNotify()
    {
        _finalizerMutex.lock();

        scope (exit)
            _finalizerMutex.unlock();

        _notified.value = true;

        _finalizerCondition.notify();
    }

    public void notify()
    in
    {
        assert(_running.value);
    }
    body
    {
        internalNotify();
    }

    public void wait()
    in
    {
        assert(_running.value);
    }
    body
    {
        // It can happen that a finalizer calls the wait_for_free_callbacks intrinsic, which
        // would result in a deadlock here.
        if (Thread.getThis() is _thread.value)
            return;

        _finalizeDone.value = false;

        notify();

        _pendingMutex.lock();

        scope (exit)
            _pendingMutex.unlock();

        while (!_finalizeDone.value)
            _pendingCondition.wait();
    }

    private void loop()
    {
        _gc.attach();

        while (_running.value)
        {
            {
                _finalizerMutex.lock();

                scope (exit)
                    _finalizerMutex.unlock();

                while (!_notified.value)
                    _finalizerCondition.wait();

                _notified.value = false;
            }

            // Invoke all registered finalizers; the GC implementation takes care of this.
            _igc.invokeFreeCallbacks();

            _pendingMutex.lock();

            scope (exit)
                _pendingMutex.unlock();

            _finalizeDone.value = true;

            _pendingCondition.notifyAll(); // Multiple threads can be waiting on this.
        }

        _gc.detach();
    }
}
