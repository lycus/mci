module mci.cli.tool;

import mci.core.container,
       mci.cli.tools.assembler;

public interface Tool
{
    public abstract bool run(NoNullList!string args)
    in
    {
        assert(args);
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
        default:
            return null;
    }
}
