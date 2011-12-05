module mci.cli.tools.verifier;

import mci.cli.tool;

public final class VerifierTool : Tool
{
    @property public string description()
    {
        return "Verify the validity of an assembled module.";
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
