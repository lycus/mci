module mci.assembler.disassembly.ast;

import std.algorithm,
       std.conv,
       std.stdio,
       std.string,
       mci.core.io,
       mci.assembler.parsing.ast,
       mci.assembler.parsing.parser;

public final class TreeDisassembler
{
    private string _inputFile;
    private FileStream _file;
    private BinaryWriter _writer;
    private ubyte _indent;
    private bool _done;

    invariant()
    {
        assert(_inputFile);
        assert(_file);
        assert(_file.canWrite);
        assert(!_file.isClosed);
        assert(_writer);
    }

    public this(string inputFile, FileStream file)
    in
    {
        assert(inputFile);
        assert(file);
        assert(file.canWrite);
        assert(!file.isClosed);
    }
    body
    {
        _inputFile = inputFile;
        _file = file;
        _writer = new BinaryWriter(file);
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

        writeln();
    }

    private void writeNode(Node node)
    in
    {
        assert(node);
    }
    body
    {
        writeif("[%s in %s %s", split(typeid(node).name, ".")[$ - 1][0 .. $ - 4], _inputFile, node.location);

        auto str = node.toString();

        if (str.length)
            writef(" -> %s", str);

        writeln("]");

        indent();

        foreach (child; node.children)
            if (child)
                writeNode(child);

        dedent();
    }

    private void indent()
    {
        _indent++;
    }

    private void dedent()
    {
        _indent--;
    }

    private void write(T ...)(T args)
    {
        foreach (arg; args)
            _writer.writeArray(to!string(arg));
    }

    private void writeln(T ...)(T args)
    {
        write(args);
        write(newline);
    }

    private void writef(T ...)(T args)
    {
        write(format(args));
    }

    private void writefln(T ...)(T args)
    {
        writef(args);
        writeln();
    }

    private void writei(T ...)(T args)
    {
        for (auto i = 0; i < _indent; i++)
            _writer.writeArray("    ");

        foreach (arg; args)
            _writer.writeArray(to!string(arg));
    }

    private void writeif(T ...)(T args)
    {
        writei(format(args));
    }
}
