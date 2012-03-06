module mci.vm.intrinsics.memory;

import mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public size_t mci_is_aligned(VirtualMachineContext context, ubyte* ptr)
    {
        return isSystemAligned(ptr);
    }

    public void mci_gc_collect(VirtualMachineContext context)
    {
        context.gc.collect();
    }

    public void mci_gc_minimize(VirtualMachineContext context)
    {
        context.gc.minimize();
    }

    public ulong mci_gc_get_collections(VirtualMachineContext context)
    {
        return context.gc.collections;
    }

    public void mci_gc_add_pressure(VirtualMachineContext context, size_t amount)
    {
        context.gc.addPressure(amount);
    }

    public void mci_gc_remove_pressure(VirtualMachineContext context, size_t amount)
    {
        context.gc.removePressure(amount);
    }

    public size_t mci_gc_is_generational(VirtualMachineContext context)
    {
        return !!cast(GenerationalGarbageCollector)context.gc;
    }

    public size_t mci_gc_get_generations(VirtualMachineContext context)
    {
        return (cast(GenerationalGarbageCollector)context.gc).generations.count;
    }

    public void mci_gc_generation_collect(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.gc).generations[id].collect();
    }

    public void mci_gc_generation_minimize(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.gc).generations[id].minimize();
    }

    public ulong mci_gc_generation_get_collections(VirtualMachineContext context, size_t id)
    {
        return (cast(GenerationalGarbageCollector)context.gc).generations[id].collections;
    }

    public size_t mci_gc_is_interactive(VirtualMachineContext context)
    {
        return !!cast(InteractiveGarbageCollector)context.gc;
    }

    public alias extern (C) void function(RuntimeObject*) GCCallbackFunction;

    public void mci_gc_add_allocate_callback(VirtualMachineContext context, GCCallbackFunction callback)
    {
        (cast(InteractiveGarbageCollector)context.gc).addAllocateCallback((RuntimeObject* rto) => callback(rto));
    }

    public void mci_gc_add_free_callback(VirtualMachineContext context, GCCallbackFunction callback)
    {
        (cast(InteractiveGarbageCollector)context.gc).addFreeCallback((RuntimeObject* rto) => callback(rto));
    }

    public size_t mci_gc_is_atomic(VirtualMachineContext context)
    {
        return !!cast(AtomicGarbageCollector)context.gc;
    }

    public ubyte mci_gc_get_barriers(VirtualMachineContext context)
    {
        return (cast(AtomicGarbageCollector)context.gc).barriers;
    }
}
