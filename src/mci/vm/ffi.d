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

public alias extern (C) void function() EntryPoint; /// Represents a procedure loaded from a dynamic link library.

/**
 * Opens a dynamic link library. This will typically be a $(PRE .so) file
 * on POSIX systems, $(PRE .dylib) on OS X, or $(PRE .dll) on Windows.
 *
 * This function first attempts to load from the current directory (only if
 * $(D name) is a base name), then whatever directories the system searches
 * in.
 *
 * Attempts to resolve symbols lazily when possible.
 *
 * This actually uses a reference counting mechanism. When a library is first
 * loaded, its reference count is set to one. For each subsequent load of the
 * same library, it is incremented by one.
 *
 * Params:
 *  name = The name of the library to load. If this is a base name (i.e. no
 *         directory separators), this function will attempt to load the file
 *         from the current directory first.
 *
 * Returns:
 *  A handle to the library on success, or $(D null) on failure.
 */
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

/**
 * Attempts to locate a procedure with a specific name in a library
 * previously loaded with $(D openLibrary).
 *
 * Params:
 *  library = Handle to the library to search in. Must not be $(D null).
 *  name = The name of the procedure to find.
 *
 * Returns:
 *  The address of the procedure, or $(D null) if it could not be found.
 */
public EntryPoint getProcedure(void* library, string name)
in
{
    assert(library);
    assert(name);
}
body
{
    static if (isPOSIX)
    {
        // Clear error condition.
        dlerror();

        auto fcn = dlsym(library, toUTFz!(const(char)*)(name));

        return cast(EntryPoint)(dlerror() ? null : fcn);
    }
    else
        return cast(EntryPoint)GetProcAddress(library, toUTFz!(const(char)*)(name));
}

/**
 * Closes a library previously opened with $(D openLibrary).
 *
 * This actually decrements the reference count for $(D handle) and won't
 * unload the library until it reaches zero.
 *
 * Params:
 *  library = Handle to the library to close. Must not be $(D null).
 *
 * Returns:
 *  $(D true) on success; otherwise, $(D false).
 */
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
