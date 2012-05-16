module mci.vm.intrinsics.atomic;

import mci.core.atomic,
       mci.core.common,
       mci.vm.intrinsics.context,
       mci.vm.memory.base;

extern (C)
{
    public RuntimeObject* atomic_load(VirtualMachineContext context, RuntimeObject** ptr)
    {
        return atomicLoad(ptr);
    }

    public void atomic_store(VirtualMachineContext context, RuntimeObject** ptr, RuntimeObject* value)
    {
        atomicStore(ptr, value);
    }

    public size_t atomic_exchange(VirtualMachineContext context, RuntimeObject** ptr, RuntimeObject* condition, RuntimeObject* value)
    {
        // Do casts; we don't want to introduce shared in the intrinsics.
        return atomicSwap(ptr, condition, value);
    }

    public size_t atomic_load_u(VirtualMachineContext context, size_t* ptr)
    {
        return atomicLoad(ptr);
    }

    public void atomic_store_u(VirtualMachineContext context, size_t* ptr, size_t value)
    {
        atomicStore(ptr, value);
    }

    public size_t atomic_exchange_u(VirtualMachineContext context, size_t* ptr, size_t condition, size_t value)
    {
        return atomicSwap(ptr, condition, value);
    }

    public size_t atomic_add_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"+="(lhs, rhs);
    }

    public size_t atomic_sub_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"-="(lhs, rhs);
    }

    public size_t atomic_mul_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"*="(lhs, rhs);
    }

    public size_t atomic_div_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"/="(lhs, rhs);
    }

    public size_t atomic_rem_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"%="(lhs, rhs);
    }

    public size_t atomic_and_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"&="(lhs, rhs);
    }

    public size_t atomic_or_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"|="(lhs, rhs);
    }

    public size_t atomic_xor_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!"^="(lhs, rhs);
    }

    public isize_t atomic_load_s(VirtualMachineContext context, isize_t* ptr)
    {
        return atomicLoad(ptr);
    }

    public void atomic_store_s(VirtualMachineContext context, isize_t* ptr, isize_t value)
    {
        atomicStore(ptr, value);
    }

    public size_t atomic_exchange_s(VirtualMachineContext context, isize_t* ptr, isize_t condition, isize_t value)
    {
        return atomicSwap(ptr, condition, value);
    }

    public isize_t atomic_add_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"+="(lhs, rhs);
    }

    public isize_t atomic_sub_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"-="(lhs, rhs);
    }

    public isize_t atomic_mul_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"*="(lhs, rhs);
    }

    public isize_t atomic_div_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"/="(lhs, rhs);
    }

    public isize_t atomic_rem_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"%="(lhs, rhs);
    }

    public isize_t atomic_and_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"&="(lhs, rhs);
    }

    public isize_t atomic_or_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"|="(lhs, rhs);
    }

    public isize_t atomic_xor_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!"^="(lhs, rhs);
    }
}
