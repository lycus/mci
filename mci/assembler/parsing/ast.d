module mci.assembler.parsing.ast;

import mci.core.container,
       mci.core.diagnostics.debugging,
       mci.core.typing.types;

public abstract class Node
{
    private SourceLocation _location;
    private NoNullList!Object _tags;

    protected this(SourceLocation location)
    in
    {
        assert(location);
    }
    body
    {
        _location = location;
        _tags = new NoNullList!Object();
    }

    @property public SourceLocation location()
    {
        return _location;
    }

    @property public NoNullList!Object tags()
    {
        return _tags;
    }
}

public class TypeDeclaration : Node
{
    private string _name;
    private TypeAttributes _attributes;
    private TypeLayout _layout;
    private uint _packingSize = (void*).sizeof;

    public this(SourceLocation location, string name, TypeAttributes attributes,
                TypeLayout layout, uint packingSize)
    in
    {
        assert(name);
        assert(attributes);
        assert(layout);
        assert(packingSize);
    }
    body
    {
        super(location);

        _name = name;
        _attributes = attributes;
        _layout = layout;
        _packingSize = packingSize;
    }

    @property public string name()
    {
        return _name;
    }

    @property public TypeAttributes attributes()
    {
        return _attributes;
    }

    @property public TypeLayout layout()
    {
        return _layout;
    }

    @property public uint packingSize()
    {
        return _packingSize;
    }
}
