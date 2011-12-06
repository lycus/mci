module mci.vm.intrinsics.memory;

import core.stdc.stdlib;

public extern (C)
{
    ubyte* mci_memory_malloc(size_t size)
    {
        return cast(ubyte*)malloc(size);
    }

    ubyte* mci_memory_calloc(size_t elements, size_t elementSize)
    {
        return cast(ubyte*)calloc(elements, elementSize);
    }

    ubyte* mci_memory_realloc(ubyte* ptr, size_t newSize)
    {
        return cast(ubyte*)realloc(ptr, newSize);
    }

    void mci_memory_free(ubyte* ptr)
    {
        free(ptr);
    }
}
