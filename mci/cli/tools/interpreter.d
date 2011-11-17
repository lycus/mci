module mci.cli.tools.interpreter;

import std.getopt,
       std.stdio,
       mci.cli.tool;

public enum GarbageCollectorType : ubyte
{
    libc = 0,
    dgc = 1,
}

public final class InterpreterTool : Tool
{
    private bool _verify;
    private bool _optimize;
    private GarbageCollectorType _gcType;

    public bool run(string[] args)
    {
        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "verify|v", &_verify,
                   "optimize|p", &_optimize,
                   "collector|c", &_gcType);
        }
        catch (Exception ex)
        {
            writefln("Error parsing command line: %s", ex.msg);
            return false;
        }

        return true;
    }
}
