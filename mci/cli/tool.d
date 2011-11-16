module mci.cli.tool;

import mci.core.container,
       mci.cli.tools.assembler,
       mci.cli.tools.interpreter;

public interface Tool
{
    public abstract bool run(string[] args)
    in
    {
        assert(args);

        foreach (arg; args)
            assert(arg);
    }
}

public Tool getTool(string name)
in
{
    assert(name);
}
body
{
    switch (name)
    {
        case "asm":
            return new AssemblerTool();
        case "interp":
            return new InterpreterTool();
        default:
            return null;
    }
}
