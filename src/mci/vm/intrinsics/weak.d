module mci.vm.intrinsics.weak;

import mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public RuntimeObject* create_weak(VirtualMachineContext context, RuntimeObject* target)
    {
        return context.engine.gc.createWeak(target);
    }

    public RuntimeObject* get_weak_target(VirtualMachineContext context, RuntimeObject* weak)
    {
        return context.engine.gc.getWeakTarget(weak);
    }

    public void set_weak_target(VirtualMachineContext context, RuntimeObject* weak, RuntimeObject* target)
    {
        context.engine.gc.setWeakTarget(weak, target);
    }
}
