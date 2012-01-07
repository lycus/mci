import std.array,
       std.file,
       std.path,
       std.process,
       std.stdio;

private string windowsPath = buildPath("..", "src", "mci", "cli", "Test", "mci.exe");
private string posixPath = buildPath("..", "build", "mci");

private int main(string[] args)
{
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
        writeln("Could not locate mci(.exe).");
        return 1;
    }

    foreach (arg; args[2 .. $])
        cli ~= " " ~ arg;

    return !(test(buildPath(dir, "pass"), cli, 0, true) && test(buildPath(dir, "fail"), cli, 1, false));
}

private bool test(string directory, string cli, int expected, bool error)
{
    writefln("-- Testing '%s' (Expecting '%d') --", directory, expected);

    chdir(directory);

    ulong passes;
    ulong failures;

    foreach (file; dirEntries(".", "*.ial", SpanMode.shallow, false))
    {
        if (invoke(file.name, cli, expected, error))
            passes++;
        else
            failures++;
    }

    writeln();
    writefln("== Passes: %s - Failures: %s ==", passes, failures);

    chdir(buildPath("..", ".."));

    return !failures;
}

private bool invoke(string file, string cli, int expected, bool error)
{
    auto command = replace(replace(cli, "<file>", file), "<name>", file[0 .. $ - 4]);
    auto result = system(command ~ " -s");

    if (result != expected)
    {
        writefln("%s\t\tFailed ('%d')", file[2 .. $], result);

        if (error)
        {
            writefln("Error was:");
            system(command);
        }

        return false;
    }
    else
    {
        writefln("%s\t\tPassed ('%d')", file[2 .. $], result);
        return true;
    }
}
