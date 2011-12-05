module mci.cli.tools.interpreter;

import std.getopt,
       std.stdio,
       mci.cli.main,
       mci.cli.tool;

public final class InterpreterTool : Tool
{
    private bool _verify;
    private bool _optimize;
    private GarbageCollectorType _gcType;

    @property public string description()
    {
        return "Run an assembled module with the IAL interpreter.";
    }

    @property public string[] options()
    {
        return ["\t--optimize\t\t-p\t\tPass the module through the optimization pipeline.",
                "\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use."];
    }

    public bool run(string[] args)
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
            return false;
        }

        return true;
    }
}
