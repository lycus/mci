import std.file,
       std.path,
       std.process,
       std.stdio;

private string windowsPath = buildPath("..", "..", "src", "mci", "cli", "Test", "mci.exe");
private string posixPath = buildPath("..", "..", "build", "mci");

private int main(string[] args)
{
    string cli;

    // Figure out where mci.cli(.exe) is located.
    if (exists(posixPath))
        cli = buildPath("..", posixPath);
    else if (exists(windowsPath))
        cli = buildPath("..", windowsPath);
    else
    {
        writeln("Could not locate mci(.exe).");
        return 1;
    }

    return !(test("pass", cli, 0, true) && test("fail", cli, 1, false));
}

private bool test(string directory, string cli, int expected, bool error)
{
    scope (exit)
        chdir("..");

    writefln("-- Testing '%s' (Expecting '%d') --", directory, expected);

    chdir(directory);

    foreach (file; dirEntries(".", "*.ial", SpanMode.shallow, false))
        if (!invoke(file.name, cli, expected, error))
            return false;

    return true;
}

private bool invoke(string file, string cli, int expected, bool error)
{
    auto name = file[0 .. $ - 4];
    auto command = cli ~ " asm " ~ file ~ " -o " ~ name ~ ".mci -d " ~ name ~ ".ast";
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
