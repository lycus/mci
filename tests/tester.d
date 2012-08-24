import core.sync.mutex,
       std.algorithm,
       std.array,
       std.conv,
       std.file,
       std.parallelism,
       std.path,
       std.process,
       std.stdio,
       std.string,
       mci.core.common,
       mci.core.config;

private __gshared string windowsPath;
private __gshared string posixPath;
private __gshared Mutex outputLock;

private struct TestPass
{
    public string command;
    public int expected;
    public bool swallowError;
    public Architecture[] excludedArchitectures;
    public OperatingSystem[] excludedOperatingSystems;
    public bool noParallel;
}

private int main(string[] args)
{
    version (Windows)
        windowsPath = buildPath("..", "src", "mci", "cli", "Test", "mci.exe");
    else
        posixPath = buildPath("..", "build", "mci");

    outputLock = new typeof(outputLock)();

    auto dir = args[1];
    string cli;

    version (Windows)
    {
        if (exists(windowsPath))
            cli = buildPath("..", "..", windowsPath);
    }
    else
    {
        if (exists(posixPath))
            cli = buildPath("..", "..", posixPath);
    }

    if (!cli)
    {
        stderr.writeln("Could not locate mci(.exe).");
        return 1;
    }

    TestPass[] passes;

    foreach (file; sort(array(map!(x => x.name)(dirEntries(dir, "*.test", SpanMode.shallow, false)))))
    {
        TestPass pass;

        foreach (line; splitLines(readText(file)))
        {
            if (startsWith(line, "C: "))
                pass.command = line[3 .. $];
            else if (startsWith(line, "R: "))
                pass.expected = to!int(line[3 .. $]);
            else if (startsWith(line, "E: "))
                pass.swallowError = to!bool(line[3 .. $]);
            else if (startsWith(line, "!A: "))
                pass.excludedArchitectures = array(map!(x => to!Architecture(x))(split(line)));
            else if (startsWith(line, "!O: "))
                pass.excludedOperatingSystems = array(map!(x => to!OperatingSystem(x))(split(line)));
            else if (startsWith(line, "!P: "))
                pass.noParallel = to!bool(line[3 .. $]);
        }

        passes ~= pass;
    }

    foreach (pass; passes)
        if (!test(dir, cli, pass))
            return 1;

    return 0;
}

private bool test(string directory, string cli, TestPass pass)
{
    if (canFind(pass.excludedArchitectures, architecture) || canFind(pass.excludedOperatingSystems, operatingSystem))
        return true;

    stderr.writefln("---------- Testing '%s' (Expecting '%s') ----------", directory, pass.expected);
    stderr.writeln();

    chdir(directory);

    ulong passes;
    ulong failures;

    auto files = sort(array(filter!(x => count(x, '.') == 1)(map!(x => x.name[2 .. $])(dirEntries(".", "*.ial", SpanMode.shallow, false)))));
    auto func = (string file)
    {
        if (invoke(file, cli, pass))
            passes++;
        else
            failures++;
    };

    if (pass.noParallel)
    {
        foreach (file; files)
            func(file);
    }
    else
    {
        foreach (file; parallel(files))
            func(file);
    }

    stderr.writeln();
    stderr.writefln("========== Passes: %s - Failures: %s ==========", passes, failures);
    stderr.writeln();

    chdir(buildPath("..", ".."));

    return !failures;
}

private bool invoke(string file, string cli, TestPass pass)
{
    auto cmd = replace(replace(pass.command, "<file>", file), "<name>", file[0 .. $ - 4]);
    auto full = cli ~ " " ~ cmd;
    auto base = baseName(cli) ~ " " ~ cmd;
    auto result = system(full ~ " -s");

    if (result != pass.expected)
    {
        outputLock.lock();

        scope (exit)
            outputLock.unlock();

        stderr.writefln("%s\t\tFailed ('%s')", base, result);

        if (!pass.swallowError)
        {
            stderr.writefln("Error was (%s):", full);
            system(full);
        }

        return false;
    }
    else
    {
        outputLock.lock();

        scope (exit)
            outputLock.unlock();

        stderr.writefln("%s\t\tPassed ('%s')", base, result);

        return true;
    }
}
