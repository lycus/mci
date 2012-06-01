module mci.cli.tools.interpreter;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class InterpreterTool : Tool
{
    @property public string name() pure nothrow
    {
        return "interp";
    }

    @property public string description() pure nothrow
    {
        return "Run an assembled module with the interpreter.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--collector=<type>\t-c <type>\tSpecify which garbage collector to use."];
    }

    public ubyte run(string[] args)
    {
        GarbageCollectorType gcType;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
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
