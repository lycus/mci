module mci.cli.tool;

import mci.core.container,
       mci.core.tuple,
       mci.cli.tools.aot,
       mci.cli.tools.assembler,
       mci.cli.tools.debugger,
       mci.cli.tools.disassembler,
       mci.cli.tools.interpreter,
       mci.cli.tools.jit,
       mci.cli.tools.linker,
       mci.cli.tools.optimizer,
       mci.cli.tools.statistics,
       mci.cli.tools.verifier;

public interface Tool
{
    @property public string description()
    out (result)
    {
        assert(result);
    }

    @property public string[] options();

    public abstract bool run(string[] args)
    in
    {
        assert(args);

        foreach (arg; args)
            assert(arg);
    }
}

public ReadOnlyIndexable!(Tuple!(string, Tool)) allTools;

static this()
{
    allTools = toReadOnlyIndexable(tuple!(string, Tool)("aot", new AOTTool()),
                                   tuple!(string, Tool)("asm", new AssemblerTool()),
                                   tuple!(string, Tool)("dbg", new DebuggerTool()),
                                   tuple!(string, Tool)("disasm", new DisassemblerTool()),
                                   tuple!(string, Tool)("interp", new InterpreterTool()),
                                   tuple!(string, Tool)("jit", new JITTool()),
                                   tuple!(string, Tool)("link", new LinkerTool()),
                                   tuple!(string, Tool)("opt", new OptimizerTool()),
                                   tuple!(string, Tool)("verify", new VerifierTool()),
                                   tuple!(string, Tool)("stats", new StatisticsTool()));
}

public Tool getTool(string name)
in
{
    assert(name);
}
body
{
    foreach (item; allTools)
        if (item.x == name)
            return item.y;

    return null;
}
