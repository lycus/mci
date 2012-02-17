module mci.cli.tools.aot;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class AOTTool : Tool
{
    @property public string description()
    {
        return "Compile assembled modules to native executables/libraries.";
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
