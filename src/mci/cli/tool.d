module mci.cli.tool;

import mci.core.container,
       mci.core.tuple,
       mci.cli.tools.aot,
       mci.cli.tools.assembler,
       mci.cli.tools.debugger,
       mci.cli.tools.disassembler,
       mci.cli.tools.graph,
       mci.cli.tools.interpreter,
       mci.cli.tools.jit,
       mci.cli.tools.linker,
       mci.cli.tools.optimizer,
       mci.cli.tools.statistics,
       mci.cli.tools.verifier;

/**
 * Represents a tool that can be invoked from the command line.
 */
public interface Tool
{
    /**
     * Gets a one-line description for this tool.
     *
     * Returns:
     *  A one-line description for this tool.
     */
    @property public string description() pure nothrow;

    /**
     * Gets a set of options that this tool supports.
     *
     * The formatting of these is unspecified, but will be suitable
     * for printing to a console.
     *
     * Returns:
     *  A set of options that this tool supports.
     */
    @property public string[] options() pure nothrow;

    /**
     * Runs this tool with the given command line arguments.
     *
     * It is assumed that the arguments have been cleared of the
     * top-level options of the command line interface.
     *
     * Params:
     *  args = Command line arguments.
     *
     * Returns:
     *  The exit code of the tool. A value of 0 indicates success.
     */
    public ubyte run(string[] args)
    in
    {
        assert(args);

        foreach (arg; args)
            assert(arg);
    }
}

public __gshared ReadOnlyIndexable!(Tuple!(string, Tool)) allTools; /// All tools currently available.

shared static this()
{
    allTools = toReadOnlyIndexable(tuple!(string, Tool)("aot", new AOTTool()),
                                   tuple!(string, Tool)("asm", new AssemblerTool()),
                                   tuple!(string, Tool)("dbg", new DebuggerTool()),
                                   tuple!(string, Tool)("disasm", new DisassemblerTool()),
                                   tuple!(string, Tool)("graph", new GraphTool()),
                                   tuple!(string, Tool)("interp", new InterpreterTool()),
                                   tuple!(string, Tool)("jit", new JITTool()),
                                   tuple!(string, Tool)("link", new LinkerTool()),
                                   tuple!(string, Tool)("opt", new OptimizerTool()),
                                   tuple!(string, Tool)("verify", new VerifierTool()),
                                   tuple!(string, Tool)("stats", new StatisticsTool()));
}

/**
 * Gets a tool by name.
 *
 * Params:
 *  name = The tool name.
 *
 * Returns:
 *  The $(D Tool) instance if found; otherwise, $(D null).
 */
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
