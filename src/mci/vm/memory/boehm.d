module mci.vm.memory.boehm;

import core.stdc.stdlib,
       std.conv,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.sync,
       mci.core.tuple,
       mci.core.typing.types,
       mci.vm.execution,
       mci.vm.intrinsics.declarations,
       mci.vm.memory.base,
       mci.vm.memory.finalization,
       mci.vm.memory.info,
       mci.vm.memory.layout,
       mci.vm.memory.pinning;

static if (isPOSIX)
{
    import gc;

    private struct FinalizationRecord
    {
        private GarbageCollectorFinalizer _finalizer;
        private InteractiveGarbageCollector _gc;
        private ExecutionEngine _engine;
        public bool free;

        invariant()
        {
            assert(_finalizer);
            assert(_gc);
            assert(_engine);
        }

        //@disable this();

        public this(GarbageCollectorFinalizer finalizer, InteractiveGarbageCollector gc, ExecutionEngine engine)
        in
        {
            assert(finalizer);
            assert(gc);
            assert(engine);
        }
        body
        {
            _finalizer = finalizer;
            _gc = gc;
            _engine = engine;
        }

        @property public GarbageCollectorFinalizer finalizer() pure nothrow
        out (result)
        {
            assert(result);
        }
        body
        {
            return _finalizer;
        }

        @property public InteractiveGarbageCollector gc() pure nothrow
        out (result)
        {
            assert(result);
        }
        body
        {
            return _gc;
        }

        @property public ExecutionEngine engine() pure nothrow
        out (result)
        {
            assert(result);
        }
        body
        {
            return _engine;
        }
    }

    public final class BoehmGarbageCollector : InteractiveGarbageCollector
    {
        private __gshared Dictionary!(RuntimeTypeInfo, size_t) _registeredBitmaps;
        private __gshared Mutex _bitmapsLock;
        private __gshared List!size_t _gcs;
        private __gshared Mutex _gcLock;
        private PinnedObjectManager _pinManager;
        private NoNullList!GarbageCollectorFinalizer _allocCallbacks;
        private Mutex _allocateCallbackLock;
        private GarbageCollectorExceptionHandler _exceptionHandler;
        private FinalizerThread _finalizerThread;
        private Mutex _weakRefLock;

        invariant()
        {
            assert(_pinManager);
            assert(_allocCallbacks);
            assert(_allocateCallbackLock);
            assert(_finalizerThread);
            assert(_weakRefLock);
        }

        shared static this()
        {
            _registeredBitmaps = new typeof(_registeredBitmaps)();
            _bitmapsLock = new typeof(_bitmapsLock)();
            _gcs = new typeof(_gcs)();
            _gcLock = new typeof(_gcLock)();

            // Note that this is not necessarily sufficient. On some weird platforms, this call
            // should rather happen in the main executable due to funny issues with fetching
            // data segment bracket addresses from a shared library. However, in any case, this
            // Should Work (TM) for the platforms we support.
            GC_init();

            GC_finalize_on_demand = true; // Actually an integer, but this is prettier.
            GC_finalizer_notifier = ()
            {
                _gcLock.lock();

                scope (exit)
                    _gcLock.unlock();

                // A bit of an ugly attempt to map libgc's global design to our OO design.
                foreach (gc; _gcs)
                    (cast(BoehmGarbageCollector)cast(void*)gc)._finalizerThread.notify();
            };
        }

        public this()
        {
            _pinManager = new typeof(_pinManager)(this);
            _allocCallbacks = new typeof(_allocCallbacks)();
            _allocateCallbackLock = new typeof(_allocateCallbackLock)();
            _finalizerThread = new typeof(_finalizerThread)(this);
            _weakRefLock = new typeof(_weakRefLock)();

            _gcLock.lock();

            scope (exit)
                _gcLock.unlock();

            _gcs.add(cast(size_t)cast(void*)this);
        }

        ~this()
        {
            _gcLock.lock();

            scope (exit)
                _gcLock.unlock();

            _gcs.remove(cast(size_t)cast(void*)this);

            _finalizerThread.exit();
        }

        @property public ulong collections() nothrow
        {
            return GC_gc_no;
        }

        public RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0)
        {
            auto size = RuntimeObject.sizeof + type.size + extraSize;
            void* mem;

            if (tryCast!StructureType(type.type))
            {
                size_t descr;

                {
                    _bitmapsLock.lock();

                    scope (exit)
                        _bitmapsLock.unlock();

                    if (auto d = type in _registeredBitmaps)
                        descr = *d;
                    else
                    {
                        auto words = type.bitmap.toWordArray();

                        descr = GC_make_descriptor(words.ptr, words.length);

                        _registeredBitmaps.add(type, descr);
                    }
                }

                mem = GC_malloc_explicitly_typed(size, descr);
            }
            else
                mem = GC_malloc(size);

            if (!mem)
                return null;

            auto obj = emplace!RuntimeObject(mem[0 .. RuntimeObject.sizeof], type);

            {
                _allocateCallbackLock.lock();

                scope (exit)
                    _allocateCallbackLock.unlock();

                foreach (cb; _allocCallbacks)
                    cb(obj);
            }

            return obj;
        }

        public void free(RuntimeObject* data)
        {
            if (!data)
                return;

            FinalizationRecord* oldRecord;

            GC_register_finalizer_no_order(data, null, null, null, cast(void**)&oldRecord);

            if (oldRecord)
            {
                // Signal that we want the object freed when the finalizer has run.
                oldRecord.free = true;

                GC_register_finalizer_no_order(data, cast(gc_finalization_proc_fun)oldRecord.finalizer, oldRecord, null, null);
            }
            else
                GC_free(data);
        }

        public void addRoot(RuntimeObject** ptr)
        {
            GC_add_roots(ptr, ptr + size_t.sizeof + 1);
        }

        public void removeRoot(RuntimeObject** ptr)
        {
            GC_remove_roots(ptr, ptr + size_t.sizeof + 1);
        }

        public void addRange(RuntimeObject** ptr, size_t words)
        {
            GC_add_roots(ptr, ptr + size_t.sizeof * words + 1);
        }

        public void removeRange(RuntimeObject** ptr, size_t words)
        {
            GC_remove_roots(ptr, ptr + size_t.sizeof * words + 1);
        }

        public size_t pin(RuntimeObject* data)
        {
            return _pinManager.pin(data);
        }

        public void unpin(size_t handle)
        {
            _pinManager.unpin(handle);
        }

        public void collect()
        {
            GC_gcollect();
        }

        public void minimize()
        {
            GC_collect_a_little();
        }

        public void attach()
        {
            GC_stack_base sb;

            GC_get_stack_base(&sb);
            GC_register_my_thread(&sb);
        }

        public void detach()
        {
            GC_unregister_my_thread();
        }

        public void addPressure(size_t amount) pure nothrow
        {
            // Pressure notifications are not supported in libgc.
        }

        public void removePressure(size_t amount) pure nothrow
        {
            // Pressure notifications are not supported in libgc.
        }

        public RuntimeObject* createWeak(RuntimeObject* target)
        {
            auto weak = allocate(getTypeInfo(weakType, mci.core.config.is32Bit));

            if (!weak)
                return null;

            auto addr = cast(RuntimeObject**)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

            // This obscures the pointer so it doesn't look like a GC reference.
            *addr = cast(RuntimeObject*)hidePointer(target);
            GC_general_register_disappearing_link(cast(void**)addr, target);

            return weak;
        }

        public RuntimeObject* getWeakTarget(RuntimeObject* weak)
        {
            extern (C) static void* reveal(void* ptr)
            {
                return revealPointer(*cast(RuntimeObject**)ptr);
            }

            auto addr = cast(void*)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

            _weakRefLock.lock();

            scope (exit)
                _weakRefLock.unlock();

            return cast(RuntimeObject*)GC_call_with_alloc_lock(&reveal, addr);
        }

        public void setWeakTarget(RuntimeObject* weak, RuntimeObject* target)
        {
            auto addr = cast(RuntimeObject**)(cast(size_t)weak + computeOffset(first(weakType.fields).y, mci.core.config.is32Bit));

            _weakRefLock.lock();

            scope (exit)
                _weakRefLock.unlock();

            if (*addr)
            {
                GC_unregister_disappearing_link(cast(void**)addr);
                *addr = null;
            }

            if (target)
            {
                *addr = cast(RuntimeObject*)hidePointer(target);
                GC_general_register_disappearing_link(cast(void**)addr, target);
            }
        }

        public void addAllocateCallback(GarbageCollectorFinalizer callback)
        {
            _allocateCallbackLock.lock();

            scope (exit)
                _allocateCallbackLock.unlock();

            _allocCallbacks.add(callback);
        }

        public void removeAllocateCallback(GarbageCollectorFinalizer callback)
        {
            _allocateCallbackLock.lock();

            scope (exit)
                _allocateCallbackLock.unlock();

            _allocCallbacks.remove(callback);
        }

        private static void finalizeCallback(RuntimeObject* rto, FinalizationRecord* record)
        {
            finalize(record.gc, rto, record.finalizer, record.engine);

            if (record.free)
                GC_free(rto);

            .free(record);
        }

        public void setFreeCallback(RuntimeObject* rto, GarbageCollectorFinalizer callback, ExecutionEngine engine)
        {
            FinalizationRecord* oldRecord;

            // We shouldn't need any synchronization here, since GC_register_finalizer_no_order
            // takes care of locking internally.
            if (!callback)
                GC_register_finalizer_no_order(rto, null, null, null, cast(void**)&oldRecord);
            else
            {
                auto mem = calloc(1, FinalizationRecord.sizeof);
                auto record = emplace!FinalizationRecord(mem[0 .. FinalizationRecord.sizeof], callback, this, engine);

                GC_register_finalizer_no_order(rto, cast(gc_finalization_proc_fun)&finalizeCallback, record, null, cast(void**)&oldRecord);
            }

            // It's possible that oldRecord is null here when the method is called with a
            // null callback where no callback was installed to begin with, or when a new
            // callback is installed and none was present previously. Either way, free
            // allows null pointers, so we're good.
            .free(oldRecord);
        }

        public void invokeFreeCallbacks()
        {
            // This will of course race; it's a heuristic. When there's no work, the call
            // to GC_invoke_finalizers just does nothing.
            if (GC_should_invoke_finalizers())
                GC_invoke_finalizers();
        }

        public void waitForFreeCallbacks()
        {
            _finalizerThread.wait();
        }

        @property public GarbageCollectorExceptionHandler exceptionHandler() pure nothrow
        {
            return _exceptionHandler;
        }

        @property public void exceptionHandler(GarbageCollectorExceptionHandler exceptionHandler) pure nothrow
        {
            _exceptionHandler = exceptionHandler;
        }
    }
}
