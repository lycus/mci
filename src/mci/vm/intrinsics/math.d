module mci.vm.intrinsics.math;

import std.math,
       mci.vm.intrinsics.context;

extern (C)
{
    public float nan_payload_f32(VirtualMachineContext context, uint payload)
    {
        return NaN(payload);
    }

    public double nan_payload_f64(VirtualMachineContext context, ulong payload)
    {
        return NaN(payload);
    }

    public size_t is_nan_f32(VirtualMachineContext context, float value)
    {
        return isNaN(value);
    }

    public size_t is_nan_f64(VirtualMachineContext context, double value)
    {
        return isNaN(value);
    }

    public size_t is_inf_f32(VirtualMachineContext context, float value)
    {
        return isInfinity(value);
    }

    public size_t is_inf_f64(VirtualMachineContext context, double value)
    {
        return isInfinity(value);
    }
}
