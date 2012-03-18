module mci.core.code.graph;

import std.string,
       mci.core.io,
       mci.core.analysis.cfg,
       mci.core.code.functions;

public final class GraphWriter
{
    private Stream _stream;
    private TextWriter _writer;
    private bool _done;

    invariant()
    {
        assert(_stream);
        assert((cast()_stream).canWrite);
        assert(!(cast()_stream).isClosed);
        assert(_writer);
    }

    public this(Stream stream)
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

    public void write(Function function_)
    in
    {
        assert(function_);
        assert(!_done);
    }
    body
    {
        _done = true;

        _writer.writefln("digraph \"%s\"", function_.name);
        _writer.writeln("{");

        _writer.writeln("    node [shape = record];");
        _writer.writeln();

        foreach (i, bb; function_.blocks)
        {
            writeBlock(bb.y);

            _writer.writeln();

            writeBranches(bb.y);

            if (i != function_.blocks.count - 1)
                _writer.writeln();
        }

        _writer.writeln("}");

        _writer.writeln();
    }

    private void writeBlock(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        _writer.writef("    \"%s\" [label = \"{'%s' | ", block.name, block.name);

        foreach (instr; block.stream)
            _writer.writef("%s\\l", instr);

        _writer.writeln("}\"];");
    }

    private void writeBranches(BasicBlock block)
    in
    {
        assert(block);
    }
    body
    {
        foreach (branch; getBranches(block))
            _writer.writefln("    \"%s\" -> \"%s\";", block.name, branch.name);

        if (block.unwindBlock)
            _writer.writefln("    \"%s\" -> \"%s\";", block.name, block.unwindBlock.name);
    }
}
