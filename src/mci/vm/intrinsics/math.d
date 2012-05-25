module mci.vm.intrinsics.math;

import std.math,
       mci.vm.intrinsics.context;

extern (C)
{
    public float mci_nan_with_payload_f32(VirtualMachineContext context, uint payload)
    {
        return NaN(payload);
    }

    public double mci_nan_with_payload_f64(VirtualMachineContext context, ulong payload)
    {
        return NaN(payload);
    }

    public uint mci_nan_get_payload_f32(VirtualMachineContext context, float value)
    {
        // This cast is safe due to the size constraints of the stored payload.
        return cast(uint)getNaNPayload(value);
    }

    public ulong mci_nan_get_payload_f64(VirtualMachineContext context, double value)
    {
        return getNaNPayload(value);
    }

    public size_t mci_is_nan_f32(VirtualMachineContext context, float value)
    {
        return isNaN(value);
    }

    public size_t mci_is_nan_f64(VirtualMachineContext context, double value)
    {
        return isNaN(value);
    }

    public size_t mci_is_inf_f32(VirtualMachineContext context, float value)
    {
        return isInfinity(value);
    }

    public size_t mci_is_inf_f64(VirtualMachineContext context, double value)
    {
        return isInfinity(value);
    }
}
