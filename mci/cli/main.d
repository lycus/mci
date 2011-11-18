module mci.cli.main;

import std.stdio,
       std.getopt,
       mci.cli.tool;

private enum ExitCode : ubyte
{
    success,
    error,
    failure,
}

private ExitCode run(string[] args)
in
{
    assert(args);

    foreach (arg; args)
        assert(arg);
}
body
{
    auto cli = args[0];

    bool help;
    bool version_;

    try
    {
        getopt(args,
               config.caseSensitive,
               config.bundling,
               config.passThrough,
               "help|h", &help,
               "version|v", &version_);
    }
    catch (Exception ex)
    {
        error(cli, "Error parsing command line: %s", ex.msg);
        return ExitCode.failure;
    }

    writeln("Managed Compiler Infrastructure (MCI) 1.0 Command Line Interface");
    writeln("Copyright (c) 2011 The Lycus Foundation - http://github.com/lycus/mci");
    writeln("Available under the terms of the MIT License");
    writeln();

    if (help)
    {
        usage(cli);
        writeln();

        writeln("Available tools:");
        writeln();

        foreach (i, tool; allTools)
        {
            writefln("     %s\t%s", tool.x, tool.y.description);

            if (tool.y.options)
            {
                writeln();

                foreach (line; tool.y.options)
                    writefln("     %s", line);
            }

            if (i < allTools.count)
                writeln();
        }

        writeln("Available garbage collectors:");
        writeln();

        writefln("     dgc\tD Garbage Collector\t\tUses the D runtme's garbage collector.");
        writefln("     libc\tLibC Garbage Collector\t\tUses malloc/free; performs no actual collection.");
        writeln();
    }

    if (version_ || help)
        return ExitCode.success;

    if (args.length < 2)
    {
        usage(cli);
        return ExitCode.failure;
    }

    auto tool = getTool(args[1]);

    if (!tool)
    {
        error(cli, "No such tool: %s", args[1]);
        return ExitCode.failure;
    }

    return tool.run(args[0 .. 1] ~ args[2 .. $]) ? ExitCode.success : ExitCode.error;
}

private void usage(string cli)
in
{
    assert(cli);
}
body
{
    writefln("Usage: %s [--version] [--help] <tool> <args>", cli);
}

private void help(string cli)
in
{
    assert(cli);
}
body
{
    writefln("See %s --help", cli);
}

private void error(T...)(string cli, T args)
in
{
    assert(cli);
}
body
{
    writefln(args);
    help(cli);
}

private int main(string[] args)
{
    return run(args);
}
