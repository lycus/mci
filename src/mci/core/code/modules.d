module mci.core.code.modules;

import std.array,
       std.file,
       std.path,
       std.process,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.code.data,
       mci.core.code.fields,
       mci.core.code.functions,
       mci.core.code.metadata,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.core.utilities;

public final class Module
{
    private string _name;
    private NoNullDictionary!(string, GlobalField) _globalFields;
    private NoNullDictionary!(string, ThreadField) _threadFields;
    private NoNullDictionary!(string, Function) _functions;
    private NoNullDictionary!(string, StructureType) _types;
    private NoNullDictionary!(string, DataBlock) _dataBlocks;
    private Function _entryPoint;
    private Function _moduleEntryPoint;
    private Function _moduleExitPoint;
    private Function _threadEntryPoint;
    private Function _threadExitPoint;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_globalFields);
        assert(_threadFields);
        assert(_functions);
        assert(_types);
        assert(_dataBlocks);
    }

    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _globalFields = new typeof(_globalFields)();
        _threadFields = new typeof(_threadFields)();
        _functions = new typeof(_functions)();
        _types = new typeof(_types)();
        _dataBlocks = new typeof(_dataBlocks)();
    }

    @property public string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public Lookup!(string, GlobalField) globalFields() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _globalFields;
    }

    @property public Lookup!(string, ThreadField) threadFields() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _threadFields;
    }

    @property public Lookup!(string, Function) functions() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _functions;
    }

    @property public Lookup!(string, StructureType) types() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    @property public Lookup!(string, DataBlock) dataBlocks() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _dataBlocks;
    }

    @property public Function entryPoint()
    out (result)
    {
        if (result)
        {
            assert((cast()result).module_ is this);
            assert((cast()result).callingConvention == CallingConvention.standard);
            assert((cast()result).returnType is Int32Type.instance);
            assert((cast()result).parameters.empty);
        }
    }
    body
    {
        return _entryPoint;
    }

    @property public void entryPoint(Function entryPoint)
    in
    {
        if (entryPoint)
        {
            assert((cast()entryPoint).module_ is this);
            assert((cast()entryPoint).callingConvention == CallingConvention.standard);
            assert((cast()entryPoint).returnType is Int32Type.instance);
            assert((cast()entryPoint).parameters.empty);
        }
    }
    body
    {
        _entryPoint = entryPoint;
    }

    @property public Function moduleEntryPoint()
    out (result)
    {
        if (result)
        {
            assert((cast()result).module_ is this);
            assert((cast()result).callingConvention == CallingConvention.standard);
            assert(!(cast()result).returnType);
            assert((cast()result).parameters.empty);
        }
    }
    body
    {
        return _moduleEntryPoint;
    }

    @property public void moduleEntryPoint(Function moduleEntryPoint)
    in
    {
        if (moduleEntryPoint)
        {
            assert((cast()moduleEntryPoint).module_ is this);
            assert((cast()moduleEntryPoint).callingConvention == CallingConvention.standard);
            assert(!(cast()moduleEntryPoint).returnType);
            assert((cast()moduleEntryPoint).parameters.empty);
        }
    }
    body
    {
        _moduleEntryPoint = moduleEntryPoint;
    }

    @property public Function moduleExitPoint()
    out (result)
    {
        if (result)
        {
            assert((cast()result).module_ is this);
            assert((cast()result).callingConvention == CallingConvention.standard);
            assert(!(cast()result).returnType);
            assert((cast()result).parameters.empty);
        }
    }
    body
    {
        return _moduleExitPoint;
    }

    @property public void moduleExitPoint(Function moduleExitPoint)
    in
    {
        if (moduleExitPoint)
        {
            assert((cast()moduleExitPoint).module_ is this);
            assert((cast()moduleExitPoint).callingConvention == CallingConvention.standard);
            assert(!(cast()moduleExitPoint).returnType);
            assert((cast()moduleExitPoint).parameters.empty);
        }
    }
    body
    {
        _moduleExitPoint = moduleExitPoint;
    }

    @property public Function threadEntryPoint()
    out (result)
    {
        if (result)
        {
            assert((cast()result).module_ is this);
            assert((cast()result).callingConvention == CallingConvention.standard);
            assert(!(cast()result).returnType);
            assert((cast()result).parameters.empty);
        }
    }
    body
    {
        return _threadEntryPoint;
    }

    @property public void threadEntryPoint(Function threadEntryPoint)
    in
    {
        if (threadEntryPoint)
        {
            assert((cast()threadEntryPoint).module_ is this);
            assert((cast()threadEntryPoint).callingConvention == CallingConvention.standard);
            assert(!(cast()threadEntryPoint).returnType);
            assert((cast()threadEntryPoint).parameters.empty);
        }
    }
    body
    {
        _threadEntryPoint = threadEntryPoint;
    }

    @property public Function threadExitPoint()
    out (result)
    {
        if (result)
        {
            assert((cast()result).module_ is this);
            assert((cast()result).callingConvention == CallingConvention.standard);
            assert(!(cast()result).returnType);
            assert((cast()result).parameters.empty);
        }
    }
    body
    {
        return _threadExitPoint;
    }

    @property public void threadExitPoint(Function threadExitPoint)
    in
    {
        if (threadExitPoint)
        {
            assert((cast()threadExitPoint).module_ is this);
            assert((cast()threadExitPoint).callingConvention == CallingConvention.standard);
            assert(!(cast()threadExitPoint).returnType);
            assert((cast()threadExitPoint).parameters.empty);
        }
    }
    body
    {
        _threadExitPoint = threadExitPoint;
    }

    public override string toString()
    {
        return escapeIdentifier(_name);
    }
}

public enum string moduleFileExtension = ".mci"; /// The file extension of compiled modules.

public final class ModuleManager
{
    private NoNullDictionary!(string, Module, false) _modules;
    private NoNullList!string _probePaths;

    pure nothrow invariant()
    {
        assert(_modules);
        assert(_probePaths);
    }

    public this()
    {
        _modules = new typeof(_modules)();
        _probePaths = new typeof(_probePaths)();

        _probePaths.add(".");

        static if (isPOSIX)
        {
            static if (operatingSystem == OperatingSystem.osx)
            {
                auto home = std.process.environment["HOME"];

                if (home)
                    _probePaths.add(buildPath(home, "lib", "mci"));
            }

            _probePaths.add(buildPath("usr", "local", "lib", "mci"));

            static if (operatingSystem == OperatingSystem.osx)
                addRange(_probePaths, ["/lib", buildPath("usr", "lib", "mci")]);
            else
                addRange(_probePaths, [buildPath("usr", "lib", "mci"), buildPath("/lib", "mci")]);
        }
        else
        {
            auto sysRoot = std.process.environment["SystemRoot"];

            if (sysRoot)
                _probePaths.add(buildPath(sysRoot, "System32", "mci"));
        }

        auto path = std.process.environment[isPOSIX ? "PATH" : "Path"];

        if (path)
            foreach (dir; split(path, pathSeparator))
                if (!contains(_probePaths, dir))
                    _probePaths.add(dir);
    }

    @property public Lookup!(string, Module) modules() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _modules;
    }

    @property public NoNullList!string probePaths() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _probePaths;
    }

    public Module load(ModuleLoader loader, string name)
    in
    {
        assert(loader);
        assert(name);
    }
    body
    {
        if (auto mod = name in _modules)
            return *mod;

        foreach (path; _probePaths)
        {
            auto filePath = buildPath(path, name ~ moduleFileExtension);

            if (exists(filePath))
                if (auto mod = loader.load(filePath))
                    return _modules[name] = mod;
        }

        return null;
    }

    public Module attach(Module module_)
    in
    {
        assert(module_);
        assert(module_.name !in _modules);
    }
    body
    {
        return _modules[module_.name] = module_;
    }
}

public interface ModuleLoader
{
    Module load(string path)
    in
    {
        assert(path);
        assert(path.length > moduleFileExtension.length);
        assert(extension(path) == moduleFileExtension);
    }
}

public interface ModuleSaver
{
    void save(Module module_, string path)
    in
    {
        assert(module_);
        assert(path);
        assert(path.length > moduleFileExtension.length);
        assert(extension(path) == moduleFileExtension);
    }
}
