module mci.cli.tools.aot;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class AOTTool : Tool
{
    @property public string description()
    {
        return "Compile assembled modules to a native executable/library.";
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
