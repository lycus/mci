module mci.assembler.exception;

import mci.core.exception,
       mci.core.diagnostics.debugging;

public class AssemblerException : CompilerException
{
    public this(string msg, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);
    }
    
    public this(string msg, Throwable next, string file = __FILE__,
                size_t line = __LINE__)
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
    }
}

public class LexerException : AssemblerException
{
    private SourceLocation _location;
    
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
    {
        return _location;
    }
}

public class ParserException : AssemblerException
{
    private SourceLocation _location;

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
    {
        return _location;
    }
}
