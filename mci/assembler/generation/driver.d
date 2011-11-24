module mci.assembler.generation.driver;

import mci.core.container,
       mci.core.program,
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
    private Program _program;
    private NoNullDictionary!(string, CompilationUnit) _units;
    private NoNullDictionary!(Module, CompilationUnit) _moduleUnits;
    private NoNullDictionary!(TypeDeclarationNode, StructureType) _types;
    private string _currentModule;

    invariant()
    {
        assert(_program);
        assert(_units);
        assert(_moduleUnits);
        assert(_types);
    }

    public this(NoNullDictionary!(string, CompilationUnit) units)
    in
    {
        assert(units);
    }
    body
    {
        _units = units.duplicate();
        _program = new typeof(_program)();
        _moduleUnits = new typeof(_moduleUnits)();
        _types = new typeof(_types)();
    }

    @property public Program program()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _program;
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

    @property public NoNullDictionary!(Module, CompilationUnit) moduleUnits()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _moduleUnits;
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

    @property public string currentModule()
    {
        return _currentModule;
    }

    @property public void currentModule(string currentModule)
    in
    {
        assert(currentModule);
    }
    body
    {
        _currentModule = currentModule;
    }
}

public final class GeneratorDriver
{
    private GeneratorState _state;
    private NoNullList!GeneratorPass _passes;
    private bool _run;

    invariant()
    {
        assert(_state);
        assert(_passes);
    }

    public this(NoNullDictionary!(string, CompilationUnit) units)
    in
    {
        assert(units);
    }
    body
    {
        _state = new typeof(_state)(units);
        _passes = new typeof(_passes)();

        _passes.add(new ModuleCreationPass());
        _passes.add(new TypeCreationPass());
        _passes.add(new TypeClosurePass());
        _passes.add(new FunctionCreationPass());
    }

    public Program run()
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
        foreach (pass; _passes)
            pass.run(_state);

        _run = true;

        return _state.program;
    }

    @property public string currentModule()
    {
        return _state.currentModule;
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

public final class ModuleCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.units)
        {
            state.currentModule = unit.x;

            auto mod = new Module(state.program, unit.x);

            state.moduleUnits.add(mod, unit.y);
        }
    }
}

public final class TypeCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.moduleUnits)
        {
            state.currentModule = unit.x.name;

            foreach (node; unit.y.nodes)
                if (auto type = cast(TypeDeclarationNode)node)
                    state.types.add(type, generateType(type, unit.x));
        }
    }
}

public final class TypeClosurePass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (type; state.types)
        {
            state.currentModule = type.y.module_.name;

            auto fields = new NoNullList!Field();

            foreach (field; type.x.fields)
            {
                if (contains(fields, (Field x) { return x.name == field.name.name; }))
                    throw new GenerationException("Field " ~ type.y.module_.name ~ "/" ~ type.y.name ~ ":" ~
                                                  field.name.name ~ " already defined.", field.location);

                fields.add(generateField(field, type.y, state.program));
            }

            type.y.close();
        }
    }
}

public final class FunctionCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.moduleUnits)
        {
            state.currentModule = unit.x.name;

            foreach (node; unit.y.nodes)
                if (auto func = cast(FunctionDeclarationNode)node)
                    generateFunction(func, unit.x, state.program);
        }
    }
}
