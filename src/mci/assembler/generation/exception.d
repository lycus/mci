module mci.assembler.generation.exception;

import mci.assembler.exception,
       mci.assembler.parsing.location;

public class GenerationException : AssemblerException
{
    private SourceLocation _location;

    public this(string msg, SourceLocation location, string file = __FILE__,
                size_t line = __LINE__)
    in
    {
        assert(msg);
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
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);

        _location = location;
    }

    @property public SourceLocation location()
    {
        return _location;
    }
}
