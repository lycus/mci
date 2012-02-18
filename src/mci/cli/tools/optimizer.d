module mci.cli.tools.optimizer;

import std.exception,
       std.getopt,
       std.path,
       mci.cli.main,
       mci.cli.tool,
       mci.cli.tools.assembler,
       mci.core.code.modules,
       mci.optimizer.manager,
       mci.vm.intrinsics.declarations,
       mci.vm.io.exception,
       mci.vm.io.reader;

public final class OptimizerTool : Tool
{
    @property public string description()
    {
        return "Pass assembled modules through the optimization pipeline.";
    }

    @property public string[] options()
    {
        return ["\t--pass=<name>\t\t-p <name>\tRun specified pass on the input modules.",
                "\t--fast\t\t\t-1\t\tRun all fast optimization passes on the input modules.",
                "\t--moderate\t\t-2\t\tRun all moderate optimization passes on the input modules.",
                "\t--slow\t\t\t-3\t\tRun all slow optimization passes on the input modules.",
                "\t--unsafe\t\t-4\t\tRun all unsafe optimization passes on the input modules.",
                "\t--all\t\t\t-a\t\tRun all safe optimization passes on the input modules."];
    }

    public ubyte run(string[] args)
    {
        bool fast;
        bool moderate;
        bool slow;
        bool unsafe;
        bool all;
        string[] passes;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "pass|p", &passes,
                   "fast|1", &fast,
                   "moderate|2", &moderate,
                   "slow|3", &slow,
                   "unsafe|4", &unsafe,
                   "all|a", &all);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        fast |= all;
        moderate |= all;
        slow |= all;

        if (args.length == 0)
        {
            log("Error: No input modules given.");
            return 2;
        }

        string[] files;

        foreach (file; args)
        {
            if (file.length <= moduleFileExtension.length)
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
                auto optimizer = new OptimizationManager();

                if (fast)
                    optimizer.addFastPasses();

                if (moderate)
                    optimizer.addModeratePasses();

                if (slow)
                    optimizer.addSlowPasses();

                foreach (func; mod.functions)
                    optimizer.optimize(func.y, unsafe);
            }
            catch (ErrnoException ex)
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
