module mci.cli.main;

import std.stdio,
       mci.cli.tool;

private int main(string[] args)
{
    if (args.length < 2)
    {
        writefln("Usage: %s <tool> <args>", args[0]);
        return 2;
    }

    auto tool = getTool(args[1]);

    if (tool is null)
    {
        writefln("No such tool: %s", args[1]);
        return 2;
    }

    return tool.run(args[2 .. $]) ? 0 : 1;
}
