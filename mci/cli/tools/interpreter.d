module mci.cli.tools.interpreter;

import std.getopt,
       std.stdio,
       mci.cli.tool;

public final class InterpreterTool : Tool
{
    private bool _verify;
    private bool _optimize;

    public bool run(string[] args)
    {
        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "verify|v", &_verify,
                   "optimize|p", &_optimize);
        }
        catch (Exception ex)
        {
            writefln("Error parsing command line: %s", ex.msg);
            return false;
        }

        return true;
    }
}
