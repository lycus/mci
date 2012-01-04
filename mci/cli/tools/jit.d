module mci.cli.tools.jit;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class JITTool : Tool
{
    @property public string description()
    {
        return "Run an assembled module with the just-in-time compiler.";
    }

    @property public string[] options()
    {
        return null;
    }

    public bool run(string[] args)
    {
        return true;
    }
}
