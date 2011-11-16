import std.file,
       std.path,
       std.process,
       std.stdio;

private string windowsPath = buildPath("..", "..", "mci", "cli", "Test", "mci.cli.exe");
private string posixPath = buildPath("..", "..", "mci.cli");

private int main()
{
    string cli;

    // Figure out where mci.cli is located.
    if (exists(posixPath))
        cli = buildPath("..", posixPath);
    else if (exists(windowsPath))
        cli = buildPath("..", windowsPath);
    else
    {
        writeln("Could not locate mci.cli(.exe).");
        return 1;
    }

    return test("pass", cli, 0) && test("fail", cli, 1);
}

private bool test(string directory, string cli, int expected)
{
    scope (exit)
        chdir("..");

    chdir(directory);

    foreach (file; dirEntries(".", "*.ial", SpanMode.shallow, false))
    {
        if (!invoke(file.name, cli, expected))
            return false;
    }

    return true;
}

private bool invoke(string file, string cli, int expected)
{
    auto result = system(cli ~ " asm " ~ file ~ " -o " ~ file[0 .. $ - 4] ~ ".mci");

    if (result != expected)
    {
        writefln("%s: Failed (%d)", file[2 .. $], result);
        return false;
    }
    else
    {
        writefln("%s: Passed (%d)", file[2 .. $], result);
        return true;
    }
}
