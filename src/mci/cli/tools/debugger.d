module mci.cli.tools.debugger;

import std.getopt,
       mci.cli.main,
       mci.cli.tool,
       mci.debugger.cli;

public final class DebuggerTool : Tool
{
    @property public string name() pure nothrow
    {
        return "dbg";
    }

    @property public string description() pure nothrow
    {
        return "Debug a program running under the interpreter or just-in-time compiler.";
    }

    @property public string[] options() pure nothrow
    {
        return null;
    }

    public ubyte run(string[] args)
    {
        return (new CommandLineDebugger()).run();
    }
}
