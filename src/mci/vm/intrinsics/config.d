module mci.vm.intrinsics.config;

import mci.core.config,
       mci.vm.intrinsics.context;

extern (C)
{
    public ubyte get_compiler(VirtualMachineContext context)
    {
        return compiler;
    }

    public ubyte get_architecture(VirtualMachineContext context)
    {
        return architecture;
    }

    public ubyte get_operating_system(VirtualMachineContext context)
    {
        return operatingSystem;
    }

    public ubyte get_endianness(VirtualMachineContext context)
    {
        return endianness;
    }

    public ubyte get_emulation_layer(VirtualMachineContext context)
    {
        return emulationLayer;
    }

    public size_t is_32_bit(VirtualMachineContext context)
    {
        return is32Bit;
    }
}
