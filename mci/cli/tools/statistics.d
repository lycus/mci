module mci.cli.tools.statistics;

import std.exception,
       std.getopt,
       std.path,
       mci.core.container,
       mci.core.tuple,
       mci.core.visitor,
       mci.core.code.functions,
       mci.core.code.instructions,
       mci.core.code.modules,
       mci.core.typing.members,
       mci.core.typing.types,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.cli.main,
       mci.cli.tool;

private final class StatisticsVisitor : ModuleVisitor
{
    private size_t _types;
    private size_t _fields;
    private size_t _functions;
    private size_t _parameters;
    private size_t _registers;
    private size_t _blocks;
    private size_t _instructions;

    protected override void visit(StructureType type)
    {
        _types++;
    }

    protected override void visit(Field field)
    {
        _fields++;
    }

    protected override void visit(Function function_)
    {
        _functions++;
    }

    protected override void visit(Parameter parameter)
    {
        _parameters++;
    }

    protected override void visit(Register register)
    {
        _registers++;
    }

    protected override void visit(BasicBlock block)
    {
        _blocks++;
    }

    protected override void visit(Instruction instruction)
    {
        _instructions++;
    }

    @property public size_t types()
    {
        return _types;
    }

    @property public size_t fields()
    {
        return _fields;
    }

    @property public size_t functions()
    {
        return _functions;
    }

    @property public size_t parameters()
    {
        return _parameters;
    }

    @property public size_t registers()
    {
        return _registers;
    }

    @property public size_t blocks()
    {
        return _blocks;
    }

    @property public size_t instructions()
    {
        return _instructions;
    }
}

public final class StatisticsTool : Tool
{
    @property public string description()
    {
        return "Show various statistics about assembled modules.";
    }

    @property public string[] options()
    {
        return ["\t--functions\t\t-f\t\tPrint a function list.",
                "\t--types\t\t\t-t\t\tPrint a type list."];
    }

    public bool run(string[] args)
    {
        bool printFuncs;
        bool printTypes;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "functions|f", &printFuncs,
                   "types|t", &printTypes);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return false;
        }

        if (args.length == 0)
        {
            log("Error: No input modules given.");
            return false;
        }

        string[] files;

        foreach (file; args)
        {
            if (file.length <= moduleFileExtension.length)
            {
                logf("Error: Input module '%s' has no name part.", file);
                return false;
            }

            if (extension(file) != moduleFileExtension)
            {
                logf("Error: Input module '%s' does not end in '%s'.", file, moduleFileExtension);
                return false;
            }

            foreach (f; files)
            {
                if (file == f)
                {
                    logf("Error: File '%s' specified multiple times.", file);
                    return false;
                }
            }

            files ~= file;
        }

        foreach (file; args)
        {
            try
            {
                auto manager = new ModuleManager();
                manager.attach(intrinsicModule);

                auto reader = new ModuleReader(manager);
                auto mod = reader.load(file);

                logf("---------- Statistics for module '%s' ----------", mod.name);
                log();

                auto v = new StatisticsVisitor();
                v.run(mod);

                logf("Functions: %s", v.functions);
                logf("Parameters: %s", v.parameters);
                logf("Registers: %s", v.registers);
                logf("Basic blocks: %s", v.blocks);
                logf("Instructions: %s", v.instructions);
                logf("Types: %s", v.types);
                logf("Fields: %s", v.fields);

                if (printFuncs)
                {
                    log();
                    logf("---------- Functions in module '%s' ----------", mod.name);
                    log();

                    foreach (func; mod.functions)
                        log(func.x);
                }

                if (printTypes)
                {
                    log();
                    logf("---------- Types in module '%s' ----------", mod.name);
                    log();

                    foreach (type; mod.types)
                        log(type.x);
                }
            }
            catch (ErrnoException ex)
            {
                logf("Error: Could not access '%s': %s", file, ex.msg);
                return false;
            }
            catch (ReaderException ex)
            {
                logf("Error: Could not load '%s': %s", file, ex.msg);
                return false;
            }
        }

        return true;
    }
}
