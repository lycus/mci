module mci.jit.memory;

import std.algorithm,
       mci.core.config,
       mci.core.container,
       mci.core.memory,
       mci.core.tuple;

public final class CodeMemoryAllocator
{
    private List!(Tuple!(ubyte[], size_t)) _regions;

    invariant()
    {
        assert(_regions);
    }

    public this()
    {
        _regions = new typeof(_regions)();
    }

    ~this()
    {
        foreach (region; _regions)
            freeCodeMemory(region.x.ptr, region.x.length);
    }

    public ubyte* allocate(size_t length)
    in
    {
        assert(length);
    }
    body
    {
        // Attempt to find a region that can hold the requested amount of bytes.
        foreach (i, region; _regions)
        {
            if (region.y + length > region.x.length)
                continue;

            _regions[i] = tuple(region.x, region.y + length);

            return region.x.ptr + region.y + length;
        }

        // Round the length up to a multiple of the page size. If we only allocate
        // exactly what's handed to us, we'll waste a lot of page space when the
        // length can't fill up (almost) an entire page. This would also mess up
        // any sort of locality.
        auto realLength = alignTo(length, pageSize);

        // We didn't find a region (above) that could hold the amount of requested
        // memory, so we allocate a new one with the rounded-up size. This means we
        // get at least an entire page here. Note that this is what happens for the
        // first allocation too.
        auto region = allocateCodeMemory(realLength)[0 .. realLength];

        if (!region.ptr)
            return null; // No dice; the OS is out of usable pages to give us.

        _regions.add(tuple(region, cast(size_t)0));

        return region.ptr;
    }
}
