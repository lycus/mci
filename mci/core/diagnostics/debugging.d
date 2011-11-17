module mci.core.diagnostics.debugging;

import mci.core.common,
       mci.core.nullable;

public final class SourceLocation
{
    private uint _line;
    private uint _column;

    invariant()
    {
        assert(_line);
    }

    public this(uint line, uint column = 0)
    in
    {
        assert(line);
    }
    body
    {
        _line = line;
        _column = column;
    }

    @property public uint line()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _line;
    }

    @property public uint column()
    {
        return _column;
    }
}

public final class DebuggingInfo
{
    private string _documentName;
    private SourceLocation _location;
    private string _languageName;

    invariant()
    {
        assert(_documentName);
        assert(_location);
        assert(_languageName);
    }

    public this(string documentName, SourceLocation location, string languageName)
    in
    {
        assert(documentName);
        assert(location);
        assert(languageName);
    }
    body
    {
        _documentName = documentName;
        _location = location;
        _languageName = languageName;
    }

    @property public istring documentName()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _documentName;
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

    @property public istring languageName()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _languageName;
    }
}
