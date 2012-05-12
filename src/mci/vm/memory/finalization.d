module mci.vm.memory.finalization;

import core.atomic,
       core.thread,
       mci.core.common,
       mci.core.container,
       mci.core.sync,
       mci.core.code.functions,
       mci.vm.exception,
       mci.vm.execution,
       mci.vm.intrinsics.declarations,
       mci.vm.memory.base;

public void finalize(InteractiveGarbageCollector gc, RuntimeObject* rto, GarbageCollectorFinalizer finalizer, ExecutionEngine engine)
in
{
    assert(gc);
    assert(rto);
    assert(finalizer);
    assert(engine);
}
body
{
    try
    {
        auto arg = new RuntimeValue(gc, objectType);

        *cast(RuntimeObject**)rto.data = rto;

        engine.execute(cast(function_t)finalizer, CallingConvention.cdecl, null, toNoNullList(arg));
    }
    catch (ExecutionException ex)
    {
        auto eh = gc.exceptionHandler;

        if (eh)
            eh(rto, finalizer, engine, ex);

        // We just silently ignore the exception if there's no handler.
    }
}

public final class FinalizerThread
{
    private InteractiveGarbageCollector _gc;
    private Mutex _finalizerMutex; // TODO: Kill these mutex variables when 2.060 is released.
    private Condition _finalizerCondition;
    private Mutex _pendingMutex;
    private Condition _pendingCondition;
    private Mutex _shutdownMutex;
    private Condition _shutdownCondition;
    private bool _running;
    private Thread _thread;

    invariant()
    {
        assert(_gc);
        assert(_finalizerMutex);
        assert(_finalizerCondition);
        assert(_pendingMutex);
        assert(_pendingCondition);
        assert(core.atomic.atomicLoad(*cast(shared)&_running) ? !!_thread : !_thread);
    }

    public this(InteractiveGarbageCollector gc)
    in
    {
        assert(gc);
    }
    body
    {
        _gc = gc;
        _finalizerMutex = new typeof(_finalizerMutex)();
        _finalizerCondition = new typeof(_finalizerCondition)(_finalizerMutex);
        _pendingMutex = new typeof(_pendingMutex)();
        _pendingCondition = new typeof(_pendingCondition)(_pendingMutex);
        _shutdownMutex = new typeof(_shutdownMutex)();
        _shutdownCondition = new typeof(_shutdownCondition)(_shutdownMutex);
    }

    @property public bool isRunning()
    {
        return core.atomic.atomicLoad(*cast(shared)&_running);
    }

    public void run()
    in
    {
        assert(!core.atomic.atomicLoad(*cast(shared)&_running));
    }
    body
    {
        core.atomic.atomicStore(*cast(shared)&_running, true);

        _thread = new Thread(&loop);
        _thread.start();
    }

    public void exit()
    in
    {
        assert(core.atomic.atomicLoad(*cast(shared)&_running));
    }
    body
    {
        core.atomic.atomicStore(*cast(shared)&_running, false);

        _shutdownMutex.lock();

        scope (exit)
            _shutdownMutex.unlock();

        while (core.atomic.atomicLoad(*cast(shared)&_running))
            _shutdownCondition.wait();
    }

    public void notify()
    in
    {
        assert(core.atomic.atomicLoad(*cast(shared)&_running));
    }
    body
    {
        _finalizerMutex.lock();

        scope (exit)
            _finalizerMutex.unlock();

        _finalizerCondition.notify();
    }

    public void wait()
    in
    {
        assert(core.atomic.atomicLoad(*cast(shared)&_running));
    }
    body
    {
        // It can happen that a finalizer calls the wait_for_free_callbacks intrinsic, which
        // would result in a deadlock here.
        if (Thread.getThis() is _thread)
            return;

        notify();

        _pendingMutex.lock();

        scope (exit)
            _pendingMutex.unlock();

        _pendingCondition.wait();
    }

    private void loop()
    {
        _shutdownMutex.lock();

        scope (exit)
            _shutdownMutex.unlock();

        while (core.atomic.atomicLoad(*cast(shared)&_running))
        {
            {
                _finalizerMutex.lock();

                scope (exit)
                    _finalizerMutex.unlock();

                _finalizerCondition.wait();
            }

            // Invoke all registered finalizers; the GC implementation takes care of this.
            _gc.invokeFreeCallbacks();

            _pendingMutex.lock();

            scope (exit)
                _pendingMutex.unlock();

            _pendingCondition.notifyAll(); // Multiple threads can be waiting on this.
        }

        _shutdownCondition.notify();
    }
}
