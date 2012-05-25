module mci.vm.intrinsics.weak;

import mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public RuntimeObject* mci_create_weak(VirtualMachineContext context, RuntimeObject* target)
    {
        return context.engine.gc.createWeak(target);
    }

    public RuntimeObject* mci_get_weak_target(VirtualMachineContext context, RuntimeObject* weak)
    {
        return context.engine.gc.getWeakTarget(weak);
    }

    public void mci_set_weak_target(VirtualMachineContext context, RuntimeObject* weak, RuntimeObject* target)
    {
        context.engine.gc.setWeakTarget(weak, target);
    }
}
