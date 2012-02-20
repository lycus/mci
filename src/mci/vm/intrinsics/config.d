module mci.vm.intrinsics.config;

import mci.core.config,
       mci.vm.intrinsics.context;

extern (C)
{
    public ubyte mci_get_compiler(VirtualMachineContext context)
    {
        return compiler;
    }

    public ubyte mci_get_architecture(VirtualMachineContext context)
    {
        return architecture;
    }

    public ubyte mci_get_operating_system(VirtualMachineContext context)
    {
        return operatingSystem;
    }

    public ubyte mci_get_endianness(VirtualMachineContext context)
    {
        return endianness;
    }

    public ubyte mci_get_emulation_layer(VirtualMachineContext context)
    {
        return emulationLayer;
    }

    public size_t mci_is_32_bit(VirtualMachineContext context)
    {
        return is32Bit;
    }
}
