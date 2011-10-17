module mci.core.diagnostics.debugging;

import mci.core.nullable;

public final class SourceLocation
{
    private uint _line;
    private uint _column;

    public this(uint line)
    in
    {
        assert(line);
    }
    body
    {
        this(line, 0);
    }

    public this(uint line, uint column)
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

    @property public string documentName()
    {
        return _documentName;
    }

    @property public SourceLocation location()
    {
        return _location;
    }

    @property public string languageName()
    {
        return _languageName;
    }
}
