module mci.vm.memory.base;

import mci.core.config,
       mci.core.container,
       mci.core.memory,
       mci.core.code.fields,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.vm.execution,
       mci.vm.exception,
       mci.vm.memory.info,
       mci.vm.memory.layout;

public struct RuntimeObject
{
    // Remember to keep this in sync with mci.vm.memory.layout.computeBitmap.

    private RuntimeTypeInfo _typeInfo;
    public GarbageCollectorHeader header;
    public RuntimeObject* userData;

    pure nothrow invariant()
    {
        assert(_typeInfo);
    }

    public this(RuntimeTypeInfo typeInfo) pure nothrow
    in
    {
        assert(typeInfo);
    }
    body
    {
        _typeInfo = typeInfo;
    }

    @property public RuntimeTypeInfo typeInfo() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _typeInfo;
    }

    @property public ubyte* data() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return cast(ubyte*)&this + RuntimeObject.sizeof;
    }

    public static RuntimeObject* fromData(ubyte* data) pure nothrow
    in
    {
        assert(data);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return cast(RuntimeObject*)(data - RuntimeObject.sizeof);
    }
}

public union GarbageCollectorHeader
{
    // Temporary padding until we make use of this union.
    public size_t bits;
}

public abstract class GarbageCollector
{
    private bool _terminated;

    ~this()
    {
        assert(_terminated);
    }

    public void terminate()
    {
        _terminated = true;
    }

    @property public abstract ulong collections() nothrow;

    public abstract RuntimeObject* allocate(RuntimeTypeInfo type, size_t extraSize = 0);

    public abstract void free(RuntimeObject* data);

    public abstract void addRange(RuntimeObject** ptr, size_t words);

    public abstract void removeRange(RuntimeObject** ptr, size_t words);

    public abstract size_t pin(RuntimeObject* data);

    public abstract void unpin(size_t handle);

    public abstract void collect();

    public abstract void minimize();

    public abstract void attach();

    public abstract void detach();

    @property public abstract bool isAttached();

    public abstract void addPressure(size_t amount) pure nothrow;

    public abstract void removePressure(size_t amount) pure nothrow;

    public abstract RuntimeObject* createWeak(RuntimeObject* target);

    public abstract RuntimeObject* getWeakTarget(RuntimeObject* weak);

    public abstract void setWeakTarget(RuntimeObject* weak, RuntimeObject* target);
}

public interface GarbageCollectorGeneration
{
    @property public size_t id() pure nothrow;

    @property public ulong collections() nothrow;

    public void collect();

    public void minimize();
}

public interface GenerationalGarbageCollector
{
    @property public ReadOnlyIndexable!GarbageCollectorGeneration generations() pure nothrow
    out (result)
    {
        assert(result);
    }
}

public alias extern (C) void function(RuntimeObject*) GarbageCollectorFinalizer;

public alias void delegate(RuntimeObject*, GarbageCollectorFinalizer, ExecutionEngine, ExecutionException) GarbageCollectorExceptionHandler;

public interface InteractiveGarbageCollector
{
    public void addAllocateCallback(GarbageCollectorFinalizer callback)
    in
    {
        assert(callback);
    }

    public void removeAllocateCallback(GarbageCollectorFinalizer callback)
    in
    {
        assert(callback);
    }

    public void setFreeCallback(RuntimeObject* rto, GarbageCollectorFinalizer callback, ExecutionEngine engine)
    in
    {
        assert(rto);
        assert(isAligned(rto));
        assert(engine);
    }

    public void invokeFreeCallbacks();

    public void waitForFreeCallbacks();

    @property public GarbageCollectorExceptionHandler exceptionHandler() pure nothrow;

    @property public void exceptionHandler(GarbageCollectorExceptionHandler exceptionHandler) pure nothrow;
}

public interface MovingGarbageCollector
{
    @property public bool canMove() pure nothrow;

    public void enableMoving() pure nothrow;

    public void disableMoving() pure nothrow;
}

public enum BarrierFlags : ubyte
{
    none = 0x0,
    memoryGet = 0x1,
    memorySet = 0x2,
}

public interface AtomicGarbageCollector
{
    @property public BarrierFlags barriers() pure nothrow;

    public void memoryGetBarrier(RuntimeObject** source, RuntimeObject** destination)
    in
    {
        assert(source);
        assert(destination);
    }

    public void memorySetBarrier(RuntimeObject** destination, RuntimeObject** source)
    in
    {
        assert(destination);
        assert(source);
    }
}
