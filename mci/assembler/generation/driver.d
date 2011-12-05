module mci.assembler.generation.driver;

import mci.core.container,
       mci.core.tuple,
       mci.core.code.modules,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser,
       mci.assembler.generation.exception,
       mci.assembler.generation.functions,
       mci.assembler.generation.types;

public final class GeneratorState
{
    private Module _module;
    private ModuleManager _manager;
    private NoNullDictionary!(string, CompilationUnit) _units;
    private NoNullDictionary!(TypeDeclarationNode, StructureType) _types;
    private string _currentFile;

    invariant()
    {
        assert(_module);
        assert(_manager);
        assert(_units);
        assert(_types);
    }

    public this(Module module_, ModuleManager manager, NoNullDictionary!(string, CompilationUnit) units)
    in
    {
        assert(module_);
        assert(manager);
        assert(units);
    }
    body
    {
        _module = module_;
        _manager = manager;
        _units = units.duplicate();
        _types = new typeof(_types)();
    }

    @property public Module module_()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _module;
    }

    @property public ModuleManager manager()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _manager;
    }

    @property public Countable!(Tuple!(string, CompilationUnit)) units()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _units;
    }

    @property public NoNullDictionary!(TypeDeclarationNode, StructureType) types()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    @property public string currentFile()
    {
        return _currentFile;
    }

    @property private void currentFile(string currentFile)
    in
    {
        assert(currentFile);
    }
    body
    {
        _currentFile = currentFile;
    }
}

public final class GeneratorDriver
{
    private Module _module;
    private GeneratorState _state;
    private NoNullList!GeneratorPass _passes;
    private bool _run;

    invariant()
    {
        assert(_module);
        assert(_state);
        assert(_passes);
    }

    public this(string moduleName, ModuleManager manager, NoNullDictionary!(string, CompilationUnit) units)
    in
    {
        assert(moduleName);
        assert(manager);
        assert(units);
    }
    body
    {
        _module = manager.attach(new Module(moduleName));
        _state = new typeof(_state)(_module, manager, units);
        _passes = new typeof(_passes)();

        _passes.add(new TypeCreationPass());
        _passes.add(new TypeClosurePass());
        _passes.add(new FunctionCreationPass());
    }

    public Module run()
    in
    {
        assert(!_run);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        _run = true;

        foreach (pass; _passes)
            pass.run(_state);

        return _module;
    }

    @property public string currentFile()
    {
        return _state.currentFile;
    }
}

public interface GeneratorPass
{
    public void run(GeneratorState state)
    in
    {
        assert(state);
    }
}

public final class TypeCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.units)
        {
            state.currentFile = unit.x;

            foreach (node; unit.y.nodes)
                if (auto type = cast(TypeDeclarationNode)node)
                    state.types.add(type, generateType(type, state.module_));
        }
    }
}

public final class TypeClosurePass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (type; state.types)
        {
            state.currentFile = type.y.module_.name;

            auto fields = new NoNullList!Field();

            foreach (field; type.x.fields)
            {
                if (contains(fields, (Field x) { return x.name == field.name.name; }))
                    throw new GenerationException("Field " ~ type.y.module_.name ~ "/" ~ type.y.name ~ ":" ~
                                                  field.name.name ~ " already defined.", field.location);

                fields.add(generateField(field, type.y, state.manager));
            }

            type.y.close();
        }
    }
}

public final class FunctionCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.units)
        {
            state.currentFile = unit.x;

            foreach (node; unit.y.nodes)
                if (auto func = cast(FunctionDeclarationNode)node)
                    generateFunction(func, state.module_, state.manager);
        }
    }
}
