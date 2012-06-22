module mci.cli.tools.aot;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class AOTTool : Tool
{
    @property public string name() pure nothrow
    {
        return "aot";
    }

    @property public string description() pure nothrow
    {
        return "Compile assembled modules to native executables/libraries.";
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
