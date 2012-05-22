module mci.vm.ffi;

import std.string,
       std.utf,
       mci.core.config,
       mci.core.code.functions;

static if (isPOSIX)
{
    import core.sys.posix.dlfcn,
           std.file,
           std.path;
}
else
{
    import core.sys.windows.windows;
}

public alias extern (C) void function() EntryPoint;

public void* openLibrary(string name)
in
{
    assert(name);
}
body
{
    static if (isPOSIX)
    {
        void* lib;

        if (isValidFilename(name))
            lib = dlopen(toUTFz!(const(char)*)(buildPath(getcwd(), name)), RTLD_LAZY);

        if (!lib)
            lib = dlopen(toUTFz!(const(char)*)(name), RTLD_LAZY);

        return lib;
    }
    else
        return LoadLibraryW(toUTF16z(name));
}

public EntryPoint getProcedure(void* library, string name)
in
{
    assert(library);
    assert(name);
}
body
{
    static if (isPOSIX)
        return cast(EntryPoint)dlsym(library, toUTFz!(const(char)*)(name));
    else
        return cast(EntryPoint)GetProcAddress(library, toUTFz!(const(char)*)(name));
}

public bool closeLibrary(void* library)
in
{
    assert(library);
}
body
{
    static if (isPOSIX)
        return !dlclose(library);
    else
        return !!FreeLibrary(library);
}
