module mci.cli.tools.statistics;

import std.getopt,
       std.path,
       mci.core.container,
       mci.core.exception,
       mci.core.analysis.statistics,
       mci.core.code.modules,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader,
       mci.cli.main,
       mci.cli.tool;

public final class StatisticsTool : Tool
{
    @property public string name() pure nothrow
    {
        return "stats";
    }

    @property public string description() pure nothrow
    {
        return "Show various statistics about assembled modules.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--gfields\t\t-g\t\tPrint a global field list.",
                "\t--tfields\t\t-h\t\tPrint a thread field list.",
                "\t--functions\t\t-f\t\tPrint a function list.",
                "\t--types\t\t\t-t\t\tPrint a type list."];
    }

    public int run(string[] args)
    {
        bool printGlobalFields;
        bool printThreadFields;
        bool printFuncs;
        bool printTypes;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "gfields|g", &printGlobalFields,
                   "tfields|h", &printThreadFields,
                   "functions|f", &printFuncs,
                   "types|t", &printTypes);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        if (args.length == 0)
        {
            log("Error: No input modules given.");
            return 2;
        }

        string[] files;

        foreach (file; args)
        {
            if (file[0] == '.' && file.length <= moduleFileExtension.length + 1)
            {
                logf("Error: Input module '%s' has no name part.", file);
                return 2;
            }

            if (extension(file) != moduleFileExtension)
            {
                logf("Error: Input module '%s' does not end in '%s'.", file, moduleFileExtension);
                return 2;
            }

            foreach (f; files)
            {
                if (file == f)
                {
                    logf("Error: File '%s' specified multiple times.", file);
                    return 2;
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

                logf("---------- Statistics for module %s ----------", mod);
                log();

                auto v = new StatisticsVisitor();
                v.run(mod);

                logf("Global fields: %s", v.globalFields);
                logf("Thread fields: %s", v.threadFields);
                logf("Functions: %s", v.functions);
                logf("Parameters: %s", v.parameters);
                logf("Registers: %s", v.registers);
                logf("Basic blocks: %s", v.blocks);
                logf("Instructions: %s", v.instructions);
                logf("Types: %s", v.types);
                logf("Members: %s", v.members);

                if (printGlobalFields)
                {
                    log();
                    logf("---------- Global fields in module %s ----------", mod);
                    log();

                    foreach (field; mod.globalFields)
                        log(field.x);
                }

                if (printThreadFields)
                {
                    log();
                    logf("---------- Thread fields in module %s ----------", mod);
                    log();

                    foreach (field; mod.threadFields)
                        log(field.x);
                }

                if (printFuncs)
                {
                    log();
                    logf("---------- Functions in module %s ----------", mod);
                    log();

                    foreach (func; mod.functions)
                        log(func.x);
                }

                if (printTypes)
                {
                    log();
                    logf("---------- Types in module %s ----------", mod);
                    log();

                    foreach (type; mod.types)
                        log(type.x);
                }
            }
            catch (IOException ex)
            {
                logf("Error: Could not access '%s': %s", file, ex.msg);
                return 1;
            }
            catch (ReaderException ex)
            {
                logf("Error: Could not load '%s': %s", file, ex.msg);
                return 1;
            }
        }

        return 0;
    }
}
