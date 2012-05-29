module mci.assembler.generation.driver;

import mci.core.common,
       mci.core.container,
       mci.core.tuple,
       mci.core.code.functions,
       mci.core.code.modules,
       mci.core.typing.members,
       mci.core.typing.core,
       mci.core.typing.types,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser,
       mci.assembler.generation.exception,
       mci.assembler.generation.functions,
       mci.assembler.generation.types;

private final class GeneratorState
{
    private Module _module;
    private ModuleManager _manager;
    private NoNullDictionary!(string, CompilationUnit) _units;
    private List!(Tuple!(string, TypeDeclarationNode, StructureType)) _types;
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

    @property public Module module_() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _module;
    }

    @property public ModuleManager manager() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _manager;
    }

    @property public Lookup!(string, CompilationUnit) units() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _units;
    }

    @property public List!(Tuple!(string, TypeDeclarationNode, StructureType)) types() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _types;
    }

    @property public string currentFile() pure nothrow
    {
        return _currentFile;
    }

    @property private void currentFile(string currentFile) pure nothrow
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
        _passes.add(new EntryPointPass());
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

    @property public string currentFile() pure nothrow
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
                    state.types.add(tuple(unit.x, type, generateType(type, state.module_)));
        }
    }
}

public final class TypeClosurePass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (type; state.types)
        {
            state.currentFile = type.x;

            auto fields = new NoNullList!Field();

            foreach (field; type.y.fields)
            {
                if (contains(fields, (Field f) => f.name == field.name.name))
                    throw new GenerationException("Field " ~ field.toString() ~ " already defined.", field.location);

                fields.add(generateField(field, type.z, state.manager));
            }

            type.z.close();
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

            auto funcs = new List!(Tuple!(FunctionDeclarationNode, Function))();

            foreach (node; unit.y.nodes)
                if (auto func = cast(FunctionDeclarationNode)node)
                    funcs.add(tuple(func, generateFunction(func, state.module_, state.manager)));

            foreach (func; funcs)
                generateFunctionBody(func.x, func.y, state.module_, state.manager);
        }
    }
}

public final class EntryPointPass : GeneratorPass
{
    public void run(GeneratorState state)
    {
        foreach (unit; state.units)
        {
            state.currentFile = unit.x;

            foreach (node; unit.y.nodes)
            {
                if (auto ep = cast(EntryPointDeclarationNode)node)
                {
                    auto tep = cast(ThreadEntryPointDeclarationNode)ep;
                    auto txp = cast(ThreadExitPointDeclarationNode)ep;

                    auto str = match(ep,
                                     (ThreadEntryPointDeclarationNode t) => "Thread entry point",
                                     (ThreadExitPointDeclarationNode t) => "Thread exit point",
                                     () => "Entry point");

                    auto func = resolveFunction(ep.function_, state.module_, state.manager);
                    auto loc = ep.location;

                    if (func.module_ !is state.module_)
                        throw new GenerationException(str ~ " is not within the assembled module.", loc);

                    if (func.callingConvention != CallingConvention.standard)
                        throw new GenerationException(str ~ " does not have standard calling convention.", loc);

                    auto retType = tep || txp ? null : Int32Type.instance;

                    if (func.returnType !is retType)
                        throw new GenerationException(str ~ " does not have return type " ~ (retType ? retType.toString() : "void") ~ ".", loc);

                    if (!func.parameters.empty)
                        throw new GenerationException(str ~ " does not have an empty parameter list.", loc);

                    match(ep,
                          (ThreadEntryPointDeclarationNode t) => state.module_.threadEntryPoint = func,
                          (ThreadExitPointDeclarationNode t) => state.module_.threadExitPoint = func,
                          () => state.module_.entryPoint = func);
                }
            }
        }
    }
}
