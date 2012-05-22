module mci.jit.memory;

import std.algorithm,
       mci.core.config,
       mci.core.container,
       mci.core.memory,
       mci.core.tuple;

/**
 * This class manages allocation of executable code memory. It is specifically
 * designed to not require freeing of memory; it relies on the D GC to do this.
 * Given this, it is important that any memory allocated via an instance of this
 * class isn't used after the instance has been collected by the GC.
 */
public final class CodeMemoryAllocator
{
    /**
     * Holds a list of memory, position pairs.
     */
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

    /**
     * Allocates a piece of executable memory.
     *
     * If this operation succeeds, the returned pointer is guaranteed to be aligned
     * on a machine word boundary. It is also guaranteed to have read, write, and
     * execute permissions.
     *
     * Explicitly freeing memory allocated through this method is not necessary.
     *
     * Params:
     *  length = The amount of memory, in bytes, to allocate. Must not be zero.
     *
     * Returns:
     *  A valid pointer to memory with read, write, and execute permissions, or
     *  $(D null) on failure (i.e. an out of memory condition).
     */
    public ubyte* allocate(size_t length)
    in
    {
        assert(length);
    }
    out (result)
    {
        if (result)
            assert(isAligned(result));
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
