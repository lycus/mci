module mci.cli.tools.debugger;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class DebuggerTool : Tool
{
    @property public string description()
    {
        return "Debug a program running under the interpreter or just-in-time compiler.";
    }

    @property public string[] options()
    {
        return null;
    }

    public ubyte run(string[] args)
    {
        return 0;
    }
}
