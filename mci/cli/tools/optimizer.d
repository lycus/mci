module mci.cli.tools.optimizer;

import std.getopt,
       mci.cli.main,
       mci.cli.tool;

public final class OptimizerTool : Tool
{
    @property public string description()
    {
        return "Pass assembled modules through the optimization pipeline.";
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
