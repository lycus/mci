module mci.cli.tools.linker;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class LinkerTool : Tool
{
    @property public string description()
    {
        return "Combine a series of assembled modules into a single module.";
    }

    @property public string[] options()
    {
        return null;
    }

    public ubyte run(string[] args)
    {
        return 0;
    }
}
