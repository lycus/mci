module mci.cli.tools.linker;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class LinkerTool : Tool
{
    @property public string name() pure nothrow
    {
        return "link";
    }

    @property public string description() pure nothrow
    {
        return "Combine a series of assembled modules into a single module.";
    }

    @property public string[] options() pure nothrow
    {
        return ["\t--strategy=<type>\t-r <type>\tSpecifies which name clash resolution strategy to use."];
    }

    public ubyte run(string[] args)
    {
        LinkerRenameStrategy strategy;

        try
        {
            getopt(args,
                   config.caseSensitive,
                   config.bundling,
                   "strategy|r", &strategy);
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
