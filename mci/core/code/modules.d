module mci.core.code.modules;

import std.array,
       std.file,
       std.path,
       std.process,
       mci.core.common,
       mci.core.config,
       mci.core.container,
       mci.core.code.functions,
       mci.core.typing.types;

public final class Module
{
    private string _name;
    private NoNullDictionary!(string, Function) _functions;
    private NoNullDictionary!(string, StructureType) _types;

    invariant()
    {
        assert(_name);
        assert(_functions);
        assert(_types);
    }

    public this(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
        _functions = new typeof(_functions)();
        _types = new typeof(_types)();
    }

    @property public string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    @property public Lookup!(string, Function) functions()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _functions;
    }

    @property public Lookup!(string, StructureType) types()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    public override string toString()
    {
        return _name;
    }
}

public enum string moduleFileExtension = ".mci";

public final class ModuleManager
{
    private NoNullDictionary!(string, Module) _modules;
    private NoNullList!string _probePaths;

    invariant()
    {
        assert(_modules);
        assert(_probePaths);
    }

    public this()
    {
        _modules = new typeof(_modules)();
        _probePaths = new typeof(_probePaths)();

        _probePaths.add(".");

        static if (isPosix)
        {
            _probePaths.addRange(buildPath("usr", "local", "lib"),
                                 buildPath("usr", "lib"),
                                 "/lib");
        }
        else
        {
            auto sysRoot = std.process.environment["SystemRoot"];

            if (sysRoot)
                _probePaths.add(buildPath(sysRoot, "System32"));
        }

        auto path = std.process.environment[isPosix ? "PATH" : "Path"];

        if (path)
            foreach (dir; split(path, pathSeparator))
                if (!contains(_probePaths, dir))
                    _probePaths.add(dir);
    }

    @property public Lookup!(string, Module) modules()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _modules;
    }

    @property public NoNullList!string probePaths()
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

    public Module create(string name)
    in
    {
        assert(name);
        assert(name !in _modules);
    }
    body
    {
        return _modules[name] = new Module(name);
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
