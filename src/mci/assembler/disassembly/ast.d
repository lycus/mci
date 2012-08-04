module mci.assembler.disassembly.ast;

import std.string,
       mci.core.io,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser;

/**
 * Dumps an AST parsed from IAL source code to a structured tree
 * format. Useful for debugging the IAL assembler's parser.
 */
public final class TreeDisassembler
{
    private Stream _stream;
    private TextWriter _writer;
    private bool _done;

    pure nothrow invariant()
    {
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
        assert(_writer);
    }

    /**
     * Constructs a new $(D TreeDisassembler) instance.
     *
     * Params:
     *  stream = The stream to write to.
     */
    public this(Stream stream) pure nothrow
    in
    {
        assert(stream);
        assert((cast()stream).canWrite);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _stream = stream;
        _writer = new typeof(_writer)(stream);
    }

    /**
     * Dumps the specified compilation unit.
     *
     * Params:
     *  inputFile = Name of the input file that $(D unit) was parsed from.
     *  unit = The compilation unit to dump.
     */
    public void disassemble(string inputFile, CompilationUnit unit)
    in
    {
        assert(inputFile);
        assert(unit);
        assert(!_done);
    }
    body
    {
        _done = true;

        foreach (node; unit.nodes)
            writeNode(inputFile, node);

        _writer.writeln();
    }

    private void writeNode(string inputFile, Node node)
    in
    {
        assert(inputFile);
        assert(node);
    }
    body
    {
        _writer.writeif("[%s in %s %s", split(typeid(node).name, ".")[$ - 1][0 .. $ - 4], inputFile, node.location);

        auto str = node.toString();

        if (str.length)
            _writer.writef(" -> %s", str);

        _writer.writeln("]");

        _writer.indent();

        foreach (child; node.children)
            if (child)
                writeNode(inputFile, child);

        _writer.dedent();
    }
}
