module mci.core.memory;

import core.cpuid,
       std.traits,
       mci.core.common,
       mci.core.config;

static if (isPOSIX)
{
    import core.sys.posix.unistd,
           core.sys.posix.sys.mman;

    // TODO: Move to druntime.
    static if (operatingSystem == OperatingSystem.osx)
        private enum int _SC_PAGESIZE = 29;
    else static if (operatingSystem == OperatingSystem.freebsd)
        private enum int _SC_PAGESIZE = 47;
    else static if (operatingSystem == OperatingSystem.openbsd)
        private enum int _SC_PAGESIZE = 28;
}
else
{
    import core.sys.windows.windows;
}

public __gshared size_t pageSize; /// Holds the page size of the system.
public __gshared size_t simdAlignment; /// Holds the machine's native SIMD alignment (4/8 (32-bit/64-bit), 16, or 32).

shared static this()
{
    static if (isPOSIX)
        pageSize = sysconf(_SC_PAGESIZE); // _SC_PAGESIZE seems to be the standard name, as opposed to _SC_PAGE_SIZE.
    else
    {
        SYSTEM_INFO info;

        GetSystemInfo(&info);

        pageSize = info.dwAllocationGranularity;
    }

    // The machine word size is a reasonable default alignment
    // boundary, since we just assume no SIMD is present.
    simdAlignment = size_t.sizeof;

    static if (architecture == Architecture.x86)
    {
        if (avx)
            simdAlignment = 32;
        else if (sse)
            simdAlignment = 16;
    }
}

/**
 * Indicates the desired level of access to a memory region.
 */
public enum MemoryAccess : ubyte
{
    read, /// Memory can be read.
    write, /// Memory can be written. Also implies $(D read).
    execute, /// Memory can be executed. Also implies $(D read) and $(D write).
}

private Select!(isPOSIX, int, uint) accessToFlags(MemoryAccess access) pure nothrow
{
    static if (isPOSIX)
    {
        final switch (access)
        {
            case MemoryAccess.read:
                return PROT_READ;
            case MemoryAccess.write:
                return PROT_READ | PROT_WRITE;
            case MemoryAccess.execute:
                return PROT_READ | PROT_WRITE | PROT_EXEC;
        }
    }
    else
    {
        final switch (access)
        {
            case MemoryAccess.read:
                return PAGE_READ;
            case MemoryAccess.write:
                return PAGE_READWRITE;
            case MemoryAccess.execute:
                return PAGE_EXECUTE_READWRITE;
        }
    }
}

/**
 * Allocates memory directly from the operating system.
 *
 * If the allocation fails, $(D null) is returned; otherwise, a pointer to
 * the allocated memory is returned. On success, the returned pointer is
 * guaranteed to be aligned on a $(D pageSize) boundary (and therefore on
 * a machine word boundary).
 *
 * Params:
 *  access = The access level desired for the memory region.
 *  length = The requested amount of memory, in bytes.
 *
 * Returns:
 *  A pointer to the allocated memory on success; otherwise, $(D null).
 */
public ubyte* allocateMemoryRegion(MemoryAccess access, size_t length)
in
{
    assert(length);
}
out (result)
{
    if (result)
    {
        assert(isAligned(result, pageSize));
        assert(isAligned(result));
    }
}
body
{
    auto flags = accessToFlags(access);

    static if (isPOSIX)
    {
         auto mem = mmap(null, length, flags, MAP_PRIVATE | MAP_ANON, -1, 0);

         if (mem == MAP_FAILED)
            return null;

         return cast(ubyte*)mem;
    }
    else
        return cast(ubyte*)VirtualAlloc(null, length, MEM_COMMIT | MEM_RESERVE, flags);
}

/**
 * Frees memory allocated from the operating system.
 *
 * The given pointer should be the pointer returned by a previous
 * successful call to $(D allocateMemoryRegion). $(D length) should be
 * the length passed to that previous call.
 *
 * Params:
 *  memory = Pointer to the memory region to free.
 *  length = The amount of bytes originally allocated for $(D memory).
 *
 * Returns:
 *  $(D true) on successful deallocation; otherwise, $(D false).
 */
public bool freeMemoryRegion(ubyte* memory, size_t length)
in
{
    assert(memory);
    assert(isAligned(memory, pageSize));
    assert(isAligned(memory));
    assert(length);
}
body
{
    static if (isPOSIX)
        return !munmap(memory, length);
    else
        return !VirtualFree(memory, 0, MEM_RELEASE);
}

static if (isPOSIX)
{
    static if (architecture == Architecture.arm)
    {
        static if (compiler == Compiler.gdc)
            import gcc.builtins;
        else
            static assert(false);
    }
    else static if (architecture == Architecture.mips)
    {
        static if (operatingSystem == OperatingSystem.linux)
        {
            private extern (C) int cacheflush(ubyte* addr, int size, CacheLevel level);

            private enum CacheLevel : ubyte
            {
                instruction = 0x1,
                data = 0x2,
            }
        }
        else
            static assert(false);
    }
}

/**
 * Flushes the instruction cache.
 *
 * This function must be called before code that is emitted to memory
 * dynamically is executed. Note that this function does not have to
 * be called for code loaded dynamically via shared library loading
 * routines.
 *
 * The $(D ptr) argument should be the result of a successful call to
 * $(D allocateMemoryRegion) with $(D MemoryAccess.execute) access.
 *
 * Params:
 *  ptr = Pointer to the beginning of the memory region containing code.
 *  size = The size of the memory region containing code.
 */
public void flushInstructionCache(ubyte* ptr, size_t size)
in
{
    assert(ptr);
    assert(size);
}
body
{
    static if (compiler == Compiler.dmd)
    {
        // No action required.
    }
    else static if (compiler == Compiler.gdc)
        __builtin___clear_cache(ptr, ptr + size);
    else static if (compiler == Compiler.ldc)
    {
        static if (isWindows)
            FlushInstructionCache(GetCurrentProcess(), ptr, size);
        else static if (architecture == Architecture.x86)
        {
            // No action required.
        }
        else static if (architecture == Architecture.arm)
            static assert(false); // TODO: Figure this out.
        else static if (architecture == Architecture.ppc)
            static assert(false); // TODO: Figure this out.
        else static if (architecture == Architecture.mips)
        {
            static if (operatingSystem == OperatingSystem.linux)
                cacheflush(ptr, size, CacheLevel.instruction | CacheLevel.data);
            else static if (operatingSystem == OperatingSystem.freebsd || operatingSystem == OperatingSystem.openbsd)
            {
                // TODO: Figure out what to do on these platforms.
                static assert(false);
            }
            else
                static assert(false);
        }
        else
            static assert(false);
    }
}

/**
 * Aligns $(D value) on an $(D alignment) boundary.
 *
 * Params:
 *  T = The type of $(D value). Must be an integral type.
 *  value = The value to align.
 *  alignment = The boundary to align $(D value) on.
 *
 * Returns:
 *  The aligned value. Can be equal to $(D value) if it was
 *  already aligned correctly.
 */
public T alignTo(T)(T value, T alignment = size_t.sizeof) pure nothrow
    if (isIntegral!T)
{
    auto val = value + alignment - 1;
    return val - val % alignment;
}

/**
 * Indicates whether $(D value) is aligned on an $(D alignment)
 * boundary.
 *
 * Params:
 *  T = The type of $(D value). Must be an integral type.
 *  value = The value to check for alignment.
 *  alignment = The boundary to check $(D value)'s alignment against.
 *
 * Returns:
 *  $(D true) if $(D value) is aligned on an $(D alignment) boundary;
 *  otherwise, $(D false).
 */
public bool isAligned(T)(T value, T alignment = size_t.sizeof) pure nothrow
    if (isIntegral!T)
{
    return !(value % alignment);
}

/**
 * Indicates whether a given pointer is aligned on an
 * $(D alignment) boundary.
 *
 * Params:
 *  T = The type $(D pointer) points to.
 *  pointer = The pointer to check for alignment.
 *  alignment = The boundary to check $(D pointer)'s alignment against.
 *
 * Returns:
 *  $(D true) if $(D pointer) is aligned on an $(D alignment) boundary;
 *  otherwise, $(D false).
 */
public bool isAligned(T)(T* pointer, size_t alignment = size_t.sizeof) pure nothrow
{
    return isAligned(cast(size_t)pointer, alignment);
}

/**
 * Returns the amount of padding needed to align $(D value)
 * on an $(D alignment) boundary.
 *
 * Params:
 *  T = The type of $(D value). Must be an integral type.
 *  value = The value that (possibly) needs alignment.
 *  alignment = The desired alignment boundary for $(D value).
 *
 * Returns:
 *  The amount of bytes needed to align $(D value) on an
 *  $(D alignment) boundary.
 */
public T alignmentPadding(T)(T value, T alignment = size_t.sizeof) pure nothrow
    if (isIntegral!T)
{
    auto al = alignment - 1;
    return al - (value + al) % alignment;
}
