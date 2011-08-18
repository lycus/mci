module mci.core.diagnostics.debugging;

import mci.core.nullable;

public final class SourceLocation
{
    private uint _line;
    private Nullable!uint _column;
    
    public this(uint line, Nullable!uint column = Nullable!uint())
    {
        _line = line;
        _column = column;
    }
    
    @property public uint line()
    {
        return _line;
    }
    
    @property public Nullable!uint column()
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
