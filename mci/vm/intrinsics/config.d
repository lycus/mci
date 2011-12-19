module mci.vm.intrinsics.config;

import mci.core.config;

extern (C)
{
    public ubyte mci_get_compiler()
    {
        return compiler;
    }

    public ubyte mci_get_architecture()
    {
        return architecture;
    }

    public ubyte mci_get_operating_system()
    {
        return operatingSystem;
    }

    public ubyte mci_get_endianness()
    {
        return endianness;
    }

    public ubyte mci_get_emulation_layer()
    {
        return emulationLayer;
    }

    public ubyte mci_is_32_bit()
    {
        return is32Bit;
    }
}
