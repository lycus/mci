module mci.vm.intrinsics.memory;

import mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public size_t is_aligned(VirtualMachineContext context, ubyte* ptr)
    {
        return isSystemAligned(ptr);
    }

    public void gc_collect(VirtualMachineContext context)
    {
        context.engine.gc.collect();
    }

    public void gc_minimize(VirtualMachineContext context)
    {
        context.engine.gc.minimize();
    }

    public ulong gc_get_collections(VirtualMachineContext context)
    {
        return context.engine.gc.collections;
    }

    public void gc_add_pressure(VirtualMachineContext context, size_t amount)
    {
        context.engine.gc.addPressure(amount);
    }

    public void gc_remove_pressure(VirtualMachineContext context, size_t amount)
    {
        context.engine.gc.removePressure(amount);
    }

    public size_t gc_is_generational(VirtualMachineContext context)
    {
        return !!cast(GenerationalGarbageCollector)context.engine.gc;
    }

    public size_t gc_get_generations(VirtualMachineContext context)
    {
        return (cast(GenerationalGarbageCollector)context.engine.gc).generations.count;
    }

    public void gc_generation_collect(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].collect();
    }

    public void gc_generation_minimize(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].minimize();
    }

    public ulong gc_generation_get_collections(VirtualMachineContext context, size_t id)
    {
        return (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].collections;
    }

    public size_t gc_is_interactive(VirtualMachineContext context)
    {
        return !!cast(InteractiveGarbageCollector)context.engine.gc;
    }

    public alias extern (C) void function(RuntimeObject*) GCCallbackFunction;

    public void gc_add_allocate_callback(VirtualMachineContext context, GCCallbackFunction callback)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).addAllocateCallback((RuntimeObject* rto) => callback(rto));
    }

    public void gc_add_free_callback(VirtualMachineContext context, GCCallbackFunction callback)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).addFreeCallback((RuntimeObject* rto) => callback(rto));
    }

    public size_t gc_is_atomic(VirtualMachineContext context)
    {
        return !!cast(AtomicGarbageCollector)context.engine.gc;
    }

    public ubyte gc_get_barriers(VirtualMachineContext context)
    {
        return (cast(AtomicGarbageCollector)context.engine.gc).barriers;
    }
}
