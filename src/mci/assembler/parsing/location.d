module mci.assembler.parsing.location;

import std.conv;

/**
 * Represents a location in a source code file.
 */
public struct SourceLocation
{
    private uint _line;
    private uint _column;

    pure nothrow invariant()
    {
        assert(_line);
    }

    //@disable this();

    /**
     * Constructs a new $(D SourceLocation) instance.
     *
     * Params:
     *  line = The line number of this location.
     *  column = The column number of this location.
     */
    public this(uint line, uint column = 0) pure nothrow
    in
    {
        assert(line);
    }
    body
    {
        _line = line;
        _column = column;
    }

    /**
     * Gets the line number of this location.
     *
     * Returns:
     *  The line number of this location.
     */
    @property public uint line() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _line;
    }

    /**
     * Gets the column number of this location.
     *
     * Returns:
     *  The column number of this location.
     */
    @property public uint column() pure nothrow
    {
        return _column;
    }

    public string toString()
    {
        return "(line " ~ to!string(_line) ~ (_column == 0 ? "" : ", column " ~ to!string(_column)) ~ ")";
    }
}
