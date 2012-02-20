module mci.vm.intrinsics.atomic;

import core.atomic,
       mci.core.common,
       mci.vm.intrinsics.context;

extern (C)
{
    public size_t mci_atomic_exchange_u(VirtualMachineContext context, size_t* ptr, size_t condition, size_t value)
    {
        // Do a cast; we don't want to introduce shared in the intrinsics.
        return cas(cast(shared)ptr, condition, value);
    }

    public size_t mci_atomic_add_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("+=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_sub_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("-=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_mul_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("*=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_div_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("/=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_rem_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("%=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_and_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("&=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_or_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("|=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_xor_u(VirtualMachineContext context, size_t* lhs, size_t rhs)
    {
        return atomicOp!("^=", size_t, size_t)(*lhs, rhs);
    }

    public size_t mci_atomic_exchange_s(VirtualMachineContext context, isize_t* ptr, isize_t condition, isize_t value)
    {
        // Do a cast; we don't want to introduce shared in the intrinsics.
        return cas(cast(shared)ptr, condition, value);
    }

    public isize_t mci_atomic_add_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("+=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_sub_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("-=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_mul_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("*=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_div_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("/=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_rem_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("%=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_and_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("&=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_or_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("|=", isize_t, isize_t)(*lhs, rhs);
    }

    public isize_t mci_atomic_xor_s(VirtualMachineContext context, isize_t* lhs, isize_t rhs)
    {
        return atomicOp!("^=", isize_t, isize_t)(*lhs, rhs);
    }
}
