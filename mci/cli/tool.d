module mci.cli.tool;

import mci.cli.tools.assembler;

public interface Tool
{
    public abstract bool run(string[] args);
}

public Tool getTool(string name)
{
    switch (name)
    {
        case "asm":
            return new AssemblerTool();
        default:
            return null;
    }
}
