module mci.assembler.generation.driver;

import mci.core.common,
       mci.core.container,
       mci.core.program,
       mci.core.tuple,
       mci.core.code.modules,
       mci.core.typing.types,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser,
       mci.assembler.generation.functions,
       mci.assembler.generation.types;

public final class GeneratorState
{
    private Program _program;
    private NoNullDictionary!(string, CompilationUnit) _units;
    private NoNullDictionary!(Module, CompilationUnit) _moduleUnits;
    private NoNullDictionary!(TypeDeclarationNode, StructureType) _types;

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
    {
        return _program;
    }

    @property public Countable!(Tuple!(string, CompilationUnit)) units()
    {
        return _units;
    }

    @property public NoNullDictionary!(Module, CompilationUnit) moduleUnits()
    {
        return _moduleUnits;
    }

    @property public NoNullDictionary!(TypeDeclarationNode, StructureType) types()
    {
        return _types;
    }
}

public final class GeneratorDriver
{
    private GeneratorState _state;
    private NoNullList!GeneratorPass _passes;
    private bool _run;

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
    body
    {
        foreach (pass; _passes)
            pass.run(_state);

        _run = true;

        return _state.program;
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
            auto mod = new Module(unit.x);

            state.moduleUnits.add(mod, unit.y);
            state.program.modules.add(mod);
        }
    }
}

public final class TypeCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.moduleUnits)
            foreach (node; unit.y.nodes)
                if (auto type = cast(TypeDeclarationNode)node)
                    state.types.add(type, generateType(type, unit.x, state.program.typeCache));
    }
}

public final class TypeClosurePass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (type; state.types)
        {
            foreach (field; type.x.fields)
                generateField(field, type.y, state.program);

            type.y.close();
        }
    }
}

public final class FunctionCreationPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.moduleUnits)
            foreach (node; unit.y.nodes)
                if (auto func = cast(FunctionDeclarationNode)node)
                    generateFunction(func, unit.x, state.program);
    }
}
