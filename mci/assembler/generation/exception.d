module mci.assembler.generation.exception;

import mci.core.diagnostics.debugging,
       mci.assembler.exception;

public class GenerationException : AssemblerException
{
    private SourceLocation _location;

    invariant()
    {
        assert(_location);
    }

    public this(string msg, SourceLocation location, string file = __FILE__,
                size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(location);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);

        _location = location;
    }

    public this(string msg, Throwable next, SourceLocation location,
                string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(next);
        assert(location);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _location = location;
    }

    @property public SourceLocation location()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _location;
    }
}
