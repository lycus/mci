module mci.assembler.disassembly.ast;

import std.string,
       mci.core.io,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser;

public final class TreeDisassembler
{
    private string _inputFile;
    private Stream _stream;
    private TextWriter _writer;
    private bool _done;

    invariant()
    {
        assert(_inputFile);
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
        assert(_writer);
    }

    public this(string inputFile, Stream stream)
    in
    {
        assert(inputFile);
        assert(stream);
        assert((cast()stream).canWrite);
        assert(!(cast()stream).isClosed);
    }
    body
    {
        _inputFile = inputFile;
        _stream = stream;
        _writer = new typeof(_writer)(stream);
    }

    public void disassemble(CompilationUnit unit)
    in
    {
        assert(unit);
        assert(!_done);
    }
    body
    {
        _done = true;

        foreach (node; unit.nodes)
            writeNode(node);

        _writer.writeln();
    }

    private void writeNode(Node node)
    in
    {
        assert(node);
    }
    body
    {
        _writer.writeif("[%s in %s %s", split(typeid(node).name, ".")[$ - 1][0 .. $ - 4], _inputFile, node.location);

        auto str = node.toString();

        if (str.length)
            _writer.writef(" -> %s", str);

        _writer.writeln("]");

        _writer.indent();

        foreach (child; node.children)
            if (child)
                writeNode(child);

        _writer.dedent();
    }
}
