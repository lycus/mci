module mci.cli.tools.disassembler;

import mci.cli.tool;

public final class DisassemblerTool : Tool
{
    @property public string description()
    {
        return "Disassemble an assembled program into Intermediate Assembly Language (IAL) modules.";
    }

    @property public string[] options()
    {
        return null;
    }

    public bool run(string[] args)
    {
        return true;
    }
}
