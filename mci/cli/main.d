module mci.cli.main;

import std.stdio,
       mci.cli.tool;

private enum ExitCode : ubyte
{
    success = 0,
    error = 1,
    failure = 2,
}

private ExitCode run(string[] args)
{
    if (args.length < 2)
    {
        writefln("Usage: %s <tool> <args>", args[0]);
        return ExitCode.failure;
    }

    auto tool = getTool(args[1]);

    if (tool is null)
    {
        writefln("No such tool: %s", args[1]);
        return ExitCode.failure;
    }

    return tool.run(args[2 .. $]) ? ExitCode.success : ExitCode.error;
}

private int main(string[] args)
{
    return run(args);
}
