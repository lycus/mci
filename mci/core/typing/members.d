module mci.core.typing.members;

import std.variant,
       mci.core.container,
       mci.core.nullable,
       mci.core.typing.types;

public enum FieldAttributes : ubyte
{
    none = 0x00,
    global = 0x01,
    constant = 0x02,
}

alias Algebraic!(byte,
                 ubyte,
                 short,
                 ushort,
                 int,
                 uint,
                 long,
                 ulong,
                 float,
                 double,
                 Iterable!ubyte) FieldValue;

public class Field
{
    private string _name;
    private Type _type;
    private Nullable!uint _offset;
    public FieldAttributes attributes;
    public FieldValue value;

    public this(string name, Type type)
    in
    {
        assert(name);
        assert(type);
    }
    body
    {
        _name = name;
        _type = type;
    }

    @property public string name()
    {
        return _name;
    }

    @property public void name(string name)
    in
    {
        assert(name);
    }
    body
    {
        _name = name;
    }

    @property public Type type()
    {
        return _type;
    }

    @property public void type(Type type)
    in
    {
        assert(type);
    }
    body
    {
        _type = type;
    }

    @property public Nullable!uint offset()
    {
        return _offset;
    }

    @property public void offset(Nullable!uint offset)
    {
        _offset = offset;
    }
}
