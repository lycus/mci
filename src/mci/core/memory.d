module mci.core.memory;

import std.traits,
       mci.core.config;

static if (isPOSIX)
{
    import core.sys.posix.sys.mman,
           core.sys.posix.unistd;
}
else
{
    import core.sys.windows.windows;

    // TODO: Kill this mess in 2.060 where it's moved to druntime.
    private struct SYSTEM_INFO
    {
        union
        {
            DWORD dwOemId;

            struct
            {
                WORD wProcessorArchitecture;
                WORD wReserved;
            }
        }

        DWORD dwPageSize;
        LPVOID lpMinimumApplicationAddress;
        LPVOID lpMaximumApplicationAddress;
        ULONG_PTR dwActiveProcessorMask;
        DWORD dwNumberOfProcessors;
        DWORD dwProcessorType;
        DWORD dwAllocationGranularity;
        WORD wProcessorLevel;
        WORD wProcessorRevision;
    }

    private alias SYSTEM_INFO* LPSYSTEM_INFO;

    export void GetSystemInfo(LPSYSTEM_INFO lpSystemInfo);
    export void GetNativeSystemInfo(LPSYSTEM_INFO lpSystemInfo);
}

public __gshared size_t pageSize; /// Holds the page size of the system.

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

private Select!(isPOSIX, int, uint) accessToFlags(MemoryAccess access)
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
         auto mem = mmap(null, length, flags, MAP_ANON, -1, 0);

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
 * the length passed to that call previous call.
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
