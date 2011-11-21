module mci.cli.main;

import std.conv,
       std.stdio,
       std.getopt,
       mci.core.config,
       mci.cli.tool,
       mci.cli.tools.interpreter;

private enum ExitCode : ubyte
{
    success,
    error,
    failure,
}

private bool silent;

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
               "version|v", &version_,
               "silent|s", &silent);
    }
    catch (Exception ex)
    {
        logf("Error: Could not parse command line: %s", ex.msg);
        return ExitCode.failure;
    }

    log("Managed Compiler Infrastructure (MCI) 1.0 Command Line Interface");
    log("Copyright (c) 2011 The Lycus Foundation - http://github.com/lycus/mci");
    log("Available under the terms of the MIT License");
    logf("%s (%s, %s) on %s%s compiled with %s", architectureName, is32Bit ? "32-bit" : "64-bit", endiannessName,
         operatingSystemName, emulationLayer ? " under " ~ emulationLayer ~ " " : "", compilerName);
    log();

    if (help)
    {
        usage(cli);
        log();

        log("Available tools:");
        log();

        foreach (i, tool; allTools)
        {
            logf("     %s\t%s", tool.x, tool.y.description);

            if (tool.y.options)
            {
                log();

                foreach (line; tool.y.options)
                    logf("     %s", line);
            }

            if (i < allTools.count)
                log();
        }

        log("Available garbage collectors:");
        log();

        logf("     %s\tD Garbage Collector\t\tUses the D runtime's garbage collector.", to!string(GarbageCollectorType.dgc));
        logf("     %s\tLibC Garbage Collector\t\tUses calloc/free; performs no actual collection.", to!string(GarbageCollectorType.libc));
        log();
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
        logf("Error: No such tool: '%s'", args[1]);
        return ExitCode.failure;
    }

    return tool.run(args[1 .. $]) ? ExitCode.success : ExitCode.error;
}

private void usage(string cli)
in
{
    assert(cli);
}
body
{
    logf("Usage: %s [--version|-v] [--help|-h] [--silent|-s] <tool> <args>", cli);
}

public void log(T ...)(T args)
{
    if (!silent)
        writeln(args);
}

public void logf(T ...)(T args)
{
    if (!silent)
        writefln(args);
}

private int main(string[] args)
{
    return run(args);
}
