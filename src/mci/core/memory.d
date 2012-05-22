module mci.core.memory;

import mci.core.config;

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

public __gshared size_t pageSize;

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

public ubyte* allocateCodeMemory(size_t length)
in
{
    assert(length);
}
body
{
    static if (isPOSIX)
    {
         auto mem = mmap(null, length, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON, -1, 0);

         if (mem == MAP_FAILED)
            return null;

         return cast(ubyte*)mem;
    }
    else
        return cast(ubyte*)VirtualAlloc(null, length, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
}

public bool freeCodeMemory(ubyte* memory, size_t length)
in
{
    assert(memory);
    assert(length);
}
body
{
    static if (isPOSIX)
        return !munmap(memory, length);
    else
        return !VirtualFree(memory, 0, MEM_RELEASE);
}
