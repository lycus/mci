module mci.cli.tools.jit;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class JITTool : Tool
{
    @property public string name() pure nothrow
    {
        return "jit";
    }

    @property public string description() pure nothrow
    {
        return "Run an assembled module with the just-in-time compiler.";
    }

    @property public string[] options() pure nothrow
    {
        return null;
    }

    public int run(string[] args)
    {
        return 0;
    }
}
