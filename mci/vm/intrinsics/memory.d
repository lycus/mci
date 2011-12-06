module mci.vm.intrinsics.memory;

import core.stdc.stdlib;

public extern (C)
{
    ubyte* mci_memory_allocate(size_t size)
    {
        return cast(ubyte*)malloc(size);
    }

    ubyte* mci_memory_zero_allocate(size_t elements, size_t elementSize)
    {
        return cast(ubyte*)calloc(elements, elementSize);
    }

    ubyte* mci_memory_reallocate(ubyte* ptr, size_t newSize)
    {
        return cast(ubyte*)realloc(ptr, newSize);
    }

    void mci_memory_free(ubyte* ptr)
    {
        free(ptr);
    }
}
