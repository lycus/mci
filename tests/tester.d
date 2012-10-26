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

private __gshared string path;
private __gshared Mutex outputLock;

private struct TestPass
{
    public string file;
    public string description;
    public string command;
    public int expected;
    public bool swallowError;
    public Architecture[] excludedArchitectures;
    public OperatingSystem[] excludedOperatingSystems;
    public bool noParallel;
}

private int main(string[] args)
{
    path = buildPath("..", "build", "mci");
    outputLock = new typeof(outputLock)();

    auto dir = args[1];
    string cli;

    if (exists(path))
        cli = buildPath("..", "..", path);

    if (!cli)
    {
        stderr.writeln("Could not locate mci(.exe).");
        return 1;
    }

    TestPass[] passes;

    auto files = filter!(x => globMatch(x.name, "*.test"))(dirEntries(dir, SpanMode.shallow, false));
    auto names = sort(array(map!(x => x.name)(files)));

    foreach (file; names)
    {
        TestPass pass;

        pass.file = baseName(file);

        foreach (line; splitLines(readText(file)))
        {
            if (startsWith(line, "D: "))
                pass.description = line[3 .. $];
            else if (startsWith(line, "C: "))
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

    bool failed;

    foreach (pass; passes)
        if (!test(dir, cli, pass))
            failed = true;

    return failed;
}

private bool test(string directory, string cli, TestPass pass)
{
    if (canFind(pass.excludedArchitectures, architecture) || canFind(pass.excludedOperatingSystems, operatingSystem))
        return true;

    stderr.writefln(">> Testing '%s' pass '%s' (expecting '%s')", directory, pass.description, pass.expected);
    stderr.writeln();

    chdir(directory);

    ulong passes;
    ulong failures;

    auto files = filter!(x => globMatch(x.name, "*.ial") && count(x.name, '.') == 1)(dirEntries(getcwd(), SpanMode.shallow, false));
    auto names = sort(array(map!(x => baseName(x.name))(files)));

    auto func = (string file)
    {
        if (invoke(file, cli, pass))
            passes++;
        else
            failures++;
    };

    if (compiler == Compiler.gdc || pass.noParallel)
    {
        foreach (file; names)
            func(file);
    }
    else
    {
        foreach (file; parallel(names))
            func(file);
    }

    stderr.writeln();
    stderr.writefln("<< Passes: %s - Failures: %s", passes, failures);
    stderr.writeln();

    {
        auto f = File(pass.file ~ ".out", "w");

        f.writeln(passes);
        f.writeln(failures);
    }

    chdir(buildPath("..", ".."));

    return !failures;
}

private bool invoke(string file, string cli, TestPass pass)
{
    auto args = replace(replace(pass.command, "<file>", file), "<name>", file[0 .. $ - 4]);
    auto full = cli ~ " " ~ args;
    auto cmd = baseName(cli) ~ " " ~ args;
    auto name = pass.file[0 .. $ - 5];
    auto expFile = format("%s.exp.%s", file, name);

    string exp;

    if (exists(expFile))
        exp = readText(expFile);

    auto result = system(full ~ format(" 1> %s.res.%s 2>&1", file, name));
    auto output = readText(format("%s.res.%s", file, name));

    if (result != pass.expected)
    {
        outputLock.lock();

        scope (exit)
            outputLock.unlock();

        stderr.writefln("%-60sFailed ('%s')", cmd, result);

        if (!pass.swallowError)
        {
            stderr.writefln("Error was (%s):", full);
            stderr.writeln(readText(file ~ ".res"));
        }

        return false;
    }
    else if (exp && output != exp)
    {
        outputLock.lock();

        scope (exit)
            outputLock.unlock();

        stderr.writefln("%-60sFailed ('!')", cmd);

        if (!pass.swallowError)
        {
            stderr.writefln("Output was (%s):", full);
            stderr.writeln(output);
            stderr.writeln("Expected output is:");
            stderr.writeln(exp);
        }

        return false;
    }
    else
    {
        outputLock.lock();

        scope (exit)
            outputLock.unlock();

        stderr.writefln("%-60sPassed ('%s')", cmd, result);

        return true;
    }
}
