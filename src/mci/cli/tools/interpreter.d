module mci.cli.tools.interpreter;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class InterpreterTool : Tool
{
    @property public string description()
    {
        return "Run an assembled module with the interpreter.";
    }

    @property public string[] options()
    {
        return ["\t--optimize\t\t-p\t\tPass the module through the optimization pipeline.",
                "\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use."];
    }

    public ubyte run(string[] args)
    {
        bool optimize;
        GarbageCollectorType gcType;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "optimize|p", &optimize,
                   "collector|c", &gcType);
            args = args[1 .. $];
        }
        catch (Exception ex)
        {
            logf("Error: Could not parse command line: %s", ex.msg);
            return 2;
        }

        return 0;
    }
}
