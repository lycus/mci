module mci.vm.intrinsics.memory;

import mci.core.memory,
       mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public void mci_gc_collect(VirtualMachineContext context)
    {
        context.engine.gc.collect();
    }

    public void mci_gc_minimize(VirtualMachineContext context)
    {
        context.engine.gc.minimize();
    }

    public ulong mci_gc_get_collections(VirtualMachineContext context)
    {
        return context.engine.gc.collections;
    }

    public void mci_gc_add_pressure(VirtualMachineContext context, size_t amount)
    {
        context.engine.gc.addPressure(amount);
    }

    public void mci_gc_remove_pressure(VirtualMachineContext context, size_t amount)
    {
        context.engine.gc.removePressure(amount);
    }

    public size_t mci_gc_is_generational(VirtualMachineContext context)
    {
        return !!cast(GenerationalGarbageCollector)context.engine.gc;
    }

    public size_t mci_gc_get_generations(VirtualMachineContext context)
    {
        return (cast(GenerationalGarbageCollector)context.engine.gc).generations.count;
    }

    public void mci_gc_generation_collect(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].collect();
    }

    public void mci_gc_generation_minimize(VirtualMachineContext context, size_t id)
    {
        (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].minimize();
    }

    public ulong mci_gc_generation_get_collections(VirtualMachineContext context, size_t id)
    {
        return (cast(GenerationalGarbageCollector)context.engine.gc).generations[id].collections;
    }

    public size_t mci_gc_is_interactive(VirtualMachineContext context)
    {
        return !!cast(InteractiveGarbageCollector)context.engine.gc;
    }

    public void mci_gc_add_allocate_callback(VirtualMachineContext context, GarbageCollectorFinalizer callback)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).addAllocateCallback(callback);
    }

    public void mci_gc_remove_allocate_callback(VirtualMachineContext context, GarbageCollectorFinalizer callback)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).removeAllocateCallback(callback);
    }

    public void mci_gc_set_free_callback(VirtualMachineContext context, RuntimeObject* rto, GarbageCollectorFinalizer callback)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).setFreeCallback(rto, callback, context.engine);
    }

    public void mci_gc_wait_for_free_callbacks(VirtualMachineContext context)
    {
        (cast(InteractiveGarbageCollector)context.engine.gc).waitForFreeCallbacks();
    }

    public size_t mci_gc_is_atomic(VirtualMachineContext context)
    {
        return !!cast(AtomicGarbageCollector)context.engine.gc;
    }

    public ushort mci_gc_get_barriers(VirtualMachineContext context)
    {
        return (cast(AtomicGarbageCollector)context.engine.gc).barriers;
    }
}
